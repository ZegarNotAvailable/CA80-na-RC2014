// ------------------------------------------------------------------------------
//  Program rozruchowy dla Z80 lub Z180 (na podstawie Z80-MBC2)
//  Z180 w przeciwienstwie do Z80 nie jest statyczny...
//  Musialem zmienic sposob komunikacji AVR -> Zilog.
// ------------------------------------------------------------------------------

#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include "Arduino.h"
#include "z80-disassembler.h"

#define VER "CA80-BEZ-ROM-3-5-F-BURNER"  // For info
#define CR 0xd                          // ASCII CR for GH CR-LF issue
#define RC2014 1                        // 1 - RC2014, 0 - CA80mini
//#define Z180                          // Zakomentuj jesli Z80
//#define DEBUG
// ------------------------------------------------------------------------------
//  Stale klawiatury
// ------------------------------------------------------------------------------

#define PCF_KBD    0x20     //Adres PCF8574A 0x38 , dla PCF8574 0x20

#define WAIT_EN      11    // PD3 pin 17   
#define MAXDATALENGTH 5
//definicje SD
#define FILES_NUMBER 5
#define NAME_WIDTH 9
#define EXTENSION String(".HEX")
#define SD_CS  4           // PB4 pin 5    SD SPI
File myFile;
char c;
byte namesNumber;
char fileNames[FILES_NUMBER][NAME_WIDTH];
String fileName = "ca80.txt";
byte CA80_REGS[25];                           // For Z80 registers
byte CA80_PROG_MEM[33];                       // For Z80 program memory
byte newData = 0;                             // For Z80 registers
byte data[] = {0x01, 0x02, 0x03, 0x04, 0x05}; // For diassembler


// ------------------------------------------------------------------------------
//
// Hardware definitions like(Z80-MBC2)
//
// ------------------------------------------------------------------------------

#define   D0            24    // PA0 pin 40   Z80 data bus
#define   D1            25    // PA1 pin 39
#define   D2            26    // PA2 pin 38
#define   D3            27    // PA3 pin 37
#define   D4            28    // PA4 pin 36
#define   D5            29    // PA5 pin 35
#define   D6            30    // PA6 pin 34
#define   D7            31    // PA7 pin 33

#define   AD0           18    // PC2 pin 24   Z80 A0
#define   RD_           19    // PC3 pin 25   Z80 RD
#define   WR_           20    // PC4 pin 26   Z80 WR
#define   RESET_        22    // PC6 pin 28   Z80 RESET

#define   SNMI          10    // PD2 pin 16   SNMI potrzebne w oryginalnym "starym" CA80
#define   NMI           12    // PD4 pin 18   NMI generowane przez TIMER1 - w "starym" CA80 zbędne
#define   INT_           1    // PB1 pin 2    Z80 control bus
#define   MEM_EN_        2    // PB2 pin 3    RAM Chip Enable (CE2). Active HIGH. Used only during boot
#define   WAIT_          3    // PB3 pin 4    Z80 WAIT Na płytce z ATmegą QFP niepodłączone!!!
#define   MOSI           5    // PB5 pin 6    SD SPI
#define   MISO           6    // PB6 pin 7    SD SPI
#define   SCK            7    // PB7 pin 8    SD SPI
#define   BUSREQ_       14    // PD6 pin 20   Z80 BUSRQ
#define   CLK           15    // PD7 pin 21   Z80 CLK
#define   SCL_PC0       16    // PC0 pin 22   (I2C)
#define   SDA_PC1       17    // PC1 pin 23   (I2C)
#define   LED_IOS        0    // PB0 pin 1    Led LED_IOS is ON if HIGH - Niepodłączone
#define   WAIT_RES_      0    // PB0 pin 1    Reset the Wait FF         - j. w.
#define   USER          13    // PD5 pin 19   Led USER and key (led USER is ON if LOW) Brak LED
#define   DS3231_RTC    0x68  // DS3231 I2C address
#define   DS3231_SECRG  0x00  // DS3231 Seconds Register
#define   DS3231_STATRG 0x0F  // DS3231 Status Register
#define   FAST_CLK      0     // 8 MHz
#define   SLOW_CLK      1     // 4 MHz
// ------------------------------------------------------------------------------
//
//  Constants
//
// ------------------------------------------------------------------------------

const byte    LD_HL        =  0x36;       // Opcode of the Z80 instruction: LD(HL), n
const byte    INC_HL       =  0x23;       // Opcode of the Z80 instruction: INC HL
const byte    LD_HLnn      =  0x21;       // Opcode of the Z80 instruction: LD HL, nn
const byte    JP_nn        =  0xC3;       // Opcode of the Z80 instruction: JP nn
const word    CA80_SEC     = 0xFFED;      // Zegar CA80

// DS3231 RTC variables
byte          foundRTC;                   // Set to 1 if RTC is found, 0 otherwise
//seconds, minutes, hours, dayOfWeek, day, month, year;
byte          time[7];

void loadHL(word value);
void loadByteToRAM(byte value);
void receiveRegs();
void receivePrMem();
void printFullByte(byte b);
void printFullWord(word w);
void showRegs();
void showFirstLine();
void showSecondLine();
void showConditions(byte c);
void waitResume();

void sendNop(int NOPsToSend)
{
  for (int i = 0; i < NOPsToSend; i++)
  {
    sendDataBus(0);     //Z80 NOP
  }
}

void readRTC()
// Read current date/time binary values from the DS3231 RTC
{
  Wire.beginTransmission(DS3231_RTC);
  Wire.write(DS3231_SECRG);                       // Set the DS3231 Seconds Register
  if (Wire.endTransmission() != 0)
  {
    foundRTC = 0;
    Serial.println(F("RTC not found."));
    return;      // RTC not found
  }
  // Read from RTC
  Wire.requestFrom(DS3231_RTC, 7);
  for (byte i = 0; i < 7; i++)
  {
    time[i] = Wire.read();
  }
  dayOfWeek();
}

void dayOfWeek()
{
  const byte CA80dayOfWeek[] = {1, 7, 6, 5, 4, 3, 2}; //w CA80 poniedziałek ma wartość "7" a niedziela "1".
  uint16_t y = (((time[6] / 16) * 10 + (time[6] & 15)) + 2000); // w RTC są tylko dwie cyfry w BCD
  byte m = ((time[5] / 16) * 10 + (time[5] & 15));
  byte d = ((time[4] / 16) * 10 + (time[4] & 15));
  const int t[] = { 0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4 };
  y -= m < 3;
  time[3] = (CA80dayOfWeek[ (y + y / 4 - y / 100 + y / 400 + t[m - 1] + d) % 7]);
}

void sendTime()
{
  sendNop(4);
  loadHL(CA80_SEC);                   // Set Z80 HL = SEC (used as pointer to RAM);
  for (byte i = 0; i < 7; i++)
  {
    loadByteToRAM(time[i]);         // Write current data byte into RAM
  }
}

void readFile(String fileName)
{
  Serial.println(F("Initializing SD card..."));
  delay(200);
  if (!SD.begin(SD_CS))
  {
    Serial.println(F("initialization failed!"));
    return;
  }
  Serial.println(F("initialization done."));
  if (SD.exists(fileName))
  {
    Serial.print(fileName);
    Serial.println(F(" exists."));
  }
  else
  {
    Serial.print(fileName);
    Serial.println(F(" doesn't exist."));
  }
  myFile = SD.open(fileName); // re-open the file for reading:
  if (myFile)
  {
    namesNumber = 1;
    byte i, j;
    for (j = 0; j < FILES_NUMBER; j++)
    {
      for (i = 0; i < NAME_WIDTH; i++)
      {
        if (myFile.available())// read from the file until there's nothing else in it
        {
          c = (myFile.read());
          Serial.print(c);
          if ((c < '0') || (c > 'z'))
          {
            if (c == ' ')
            {
              if (i == 0)
              {
                Serial.println(F("Name is to short!"));
                return;
              }
              else
              {
                fileNames[j][i] = NULL;
                i = NAME_WIDTH;
                namesNumber++;
              }
            }
          }
          else
          {
            fileNames[j][i] = c;
          }
        }
        else
        {
          Serial.println(F("\r\n* End of file *"));
          myFile.close();
          return;
        }
      }
    }
  }
}

void sendFilesFromSD()
{
  byte j;
  Serial.println();
  sendNop(32);
  for (j = 0; j < namesNumber; j++)
  {
    fileName = String(String(fileNames[j]) + EXTENSION);
    if (SD.exists(fileName))
    {
      Serial.print(F("Loading "));
      Serial.println(fileName);
      sendNop(4);
      sendFileFromSD(fileName);
    }
    else
    {
      Serial.print(fileName);
      Serial.println(F(" doesn't exist."));
    }
  }
  fileName = "ca8000.HEX";
  if (SD.exists(fileName))
    {
      Serial.print(F("Loading "));
      Serial.println(fileName);
      sendNop(4);
      sendFileFromSD8000(fileName);
    }  
}

void sendRecord()
{
  if (myFile.available())
  {
    byte i = getByteFromFile();
    word adr = getAdrFromFile();
    byte typ = getByteFromFile();
    if (typ == 0)
    {
      sendDataToCA80(i, adr);
    }
    else
    {
      Serial.print(F("End of file: "));
      Serial.println(fileName);
    }
    byte suma = getByteFromFile(); // zakladam, ze plik jest poprawny i nie sprawdzam sumy
    // ale trzeba ja przeczytac!!!
    if (CR == myFile.read())   // tak jak znaki CR (jezeli sa)
    {
      myFile.read();   // i LF na koncu rekordu :-)
    }
  }
}

void sendRecord8000()
{
  if (myFile.available())
  {
    byte i = getByteFromFile();
    word adr = getAdrFromFile();
    adr += 0x8000;
    if (adr > 0xf000)
    {
      adr -= 0x1000;
    }
    byte typ = getByteFromFile();
    if (typ == 0)
    {
      sendDataToCA80(i, adr);
    }
    else
    {
      Serial.print(F("End of file: "));
      Serial.println(fileName);
    }
    byte suma = getByteFromFile(); // zakladam, ze plik jest poprawny i nie sprawdzam sumy
    // ale trzeba ja przeczytac!!!
    if (CR == myFile.read())   // tak jak znaki CR (jezeli sa)
    {
      myFile.read();   // i LF na koncu rekordu :-)
    }
  }
}

byte getByteFromFile()
{
  byte h, l;
  if (myFile.available())
  {
    h = myFile.read();
    h = asciiToDigit(h);
  }
  if (myFile.available())
  {
    l = myFile.read();
    l = asciiToDigit(l);
  }
  return ((16 * h) + l);
}

byte asciiToDigit(byte l)
{
  l = l - 0x30;
  if (l > 0x09)
  {
    l = l - 0x07;
  }
  return l;
}

word getAdrFromFile()
{
  byte h = getByteFromFile();
  byte l = getByteFromFile();
  return ((256 * h) + l);
}

void sendDataToCA80(byte l, word adr)  //l - liczba bajtow do przeslania, adr - adres pierwszego bajtu
{
  loadHL(adr);                   // Set Z80 HL = SEC (used as pointer to RAM);
  for (byte i = 0; i < l; i++)
  {
    byte b = getByteFromFile();
    loadByteToRAM(b);         // Write current data byte into RAM (adr w HL, HL++),
  }
}

void sendFileFromSD(String fileName)
{
  myFile = SD.open(fileName); // re-open the file for reading:
  if (myFile)
  {
    while (myFile.available())// read from the file until there's nothing else in it
    {
      byte c = (myFile.read());
      if (c  == 0x3a)
      {
        sendRecord();
      }
      else
      {
        Serial.print(F("Wrong format file: "));
        Serial.println(fileName);
        myFile.close();
        return;
      }
    }
    myFile.close();
  }
}

void sendFileFromSD8000(String fileName)
{
  myFile = SD.open(fileName); // re-open the file for reading:
  if (myFile)
  {
    while (myFile.available())// read from the file until there's nothing else in it
    {
      byte c = (myFile.read());
      if (c  == 0x3a)
      {
        sendRecord8000();
      }
      else
      {
        Serial.print(F("Wrong format file: "));
        Serial.println(fileName);
        myFile.close();
        return;
      }
    }
    myFile.close();
  }
}

void setCLK(byte mode)
{
  // Initialize CLK @ 8MHz (@ Fosc = 16MHz). Z80 clock_freq = (Atmega_clock) / ((OCR2 + 1) * 2)
  ASSR &= ~(1 << AS2);                            // Set Timer2 clock from system clock
  TCCR2 |= (1 << CS20);                           // Set Timer2 clock to "no prescaling"
  TCCR2 &= ~((1 << CS21) | (1 << CS22));
  TCCR2 |= (1 << WGM21);                          // Set Timer2 CTC mode
  TCCR2 &= ~(1 << WGM20);
  TCCR2 |= (1 <<  COM20);                         // Set "toggle OC2 on compare match"
  TCCR2 &= ~(1 << COM21);
  OCR2 = mode;                                    // Set the compare value to toggle OC2 (1 = 4 MHz or 0 = 8 MHz)
  pinMode(CLK, OUTPUT);                           // Set OC2 as output and start to output the clock
  Serial.print(F("Z80 is running from now at "));
  if (mode) Serial.println(F("4 MHz."));
  else Serial.println(F("8 MHz."));

  Serial.println();
}

void  setNMI()
{
  // TIMER1 ustawiamy na 1000 Hz (toggle, więc na wyjściu NMI będzie 500 Hz)
  TCCR1A = 0;                                     // zerujemy TCCR1A
  TCCR1A |= (1 << COM1B0) | (1 << FOC1B);         // PD4 500 Hz NMI
  TCCR1B = 0;                                     // zerujemy TCCR1B
  TCNT1  = 0;                                     // zerujemy licznik
  //  1000 Hz
  OCR1A = 15999; // = 16000000 / (1 * 1000) - 1 (must be <65536)
  OCR1B = 15000; // wartosc prawie dowolna
  // CTC mode
  TCCR1B |= (1 << WGM12);
  // ustawiamy prescaler
  TCCR1B |= (0 << CS12) | (0 << CS11) | (1 << CS10);
  pinMode(NMI, OUTPUT);                           // PD4 jako wyjscie
}


void setup()
{
  // ------------------------------------------------------------------------------

  Wire.begin();                                   // Wake up I2C bus
  Serial.begin(115200);
  Serial.println(F(VER));
  pinsSetings();
  Serial.println(F("Loading..."));
  readFile(fileName);
  sendFilesFromSD();
  Serial.println(F("Real time setting..."));
  readRTC();
  sendTime();
  Serial.println(F("* Done. *\r\n"));
  digitalWrite(USER, HIGH);
  // ----------------------------------------
  // Z80 BOOT
  // ----------------------------------------

#ifdef Z180

  setCLK(FAST_CLK);                               // jeżeli Z180 CLK = 8 MHz

#endif

  resetCPU();
  setNMI();                                       // NMI = 500 Hz

  //digitalWrite(SNMI, LOW);                      // Odblokowanie NMI i INT w oryginalnym CA80
}

// ------------------------------------------------------------------------------


void loop()
{
  if (!digitalRead(WAIT_))
  {
    if (!digitalRead(WR_))
    {      
      if (RC2014 ^ !digitalRead(AD0))               // Read Z80 address bus line AD0 (PC2)
      {
        byte command = PINA; // Read Z80 data bus D0-D7 (PA0-PA7)
        waitResume();
        //Serial.println(command, HEX);
        if (command == 'R')
        {
          receiveRegs();
        }
        if (command == 'P')
        {
          receivePrMem();
          newData = 1;
        }
      }
      else
      {
        waitResume();
      }
    }
  }
  if ( newData )
  {
#ifdef DEBUG

    showRegs();

#endif  //DEBUG
    Serial.println();
    showConditions(4);
    showFirstLine();
    showConditions(16);
    showSecondLine();

    newData = 0;
  }
  if (Serial.available())
  {
    char k = Serial.read();
    Serial.write(k);
    switch (k)
    {
      case 'L':
        listing();
        break;
      default:
        sendKeyCode(k);
        delay(100);
        sendKeyCode('-');
        delay(100);
        break;
    }
  }
}
// ------------------------------------------------------------------------------
// MikSid routines
// ------------------------------------------------------------------------------

void receiveRegs()
{
  for ( byte i = 0; i < 24; i++)
  {
    bool w;
    do
    {
      w = (digitalRead(WAIT_));
    } while (w);
    CA80_REGS[i] = PINA;
    waitResume();
  }
#ifdef DEBUG

  showRegs();

#endif  //DEBUG
}

void receivePrMem()
{
  for ( byte i = 0; i < 32; i++)
  {
    bool w;
    do
    {
      w = (digitalRead(WAIT_));
    } while (w);
    CA80_PROG_MEM[i] = PINA;
    waitResume();
  }
}

void showRegs()
{
  Serial.println();
  for ( byte i = 0; i < 24; i++)
  {
    if (i == 12) Serial.println();
    Serial.write("DEBCAFIXIYSPHLPCA'B'D'H'"[i]);
    byte regL = CA80_REGS[i];
    i++;
    Serial.write("DEBCAFIXIYSPHLPCA'B'D'H'"[i]);
    byte regH = CA80_REGS[i];
    word reg = (regH  * 256 ) + regL;
    Serial.print(F(" = "));
    Serial.print(reg, HEX);
    Serial.print(F(", "));
  }
  Serial.println();
}

void printRegister(byte j)
{
  printFullByte(CA80_REGS[j]);
}

void printReg16(byte k)
{
  Serial.print(F(" "));
  Serial.write("DEBCAFXXYYSPHLPCA'B'D'H'"[k]);
  Serial.write("D=B=AFX=Y=S=H=P=A'B'D'H'"[(k + 1)]);
  printRegister(k + 1);
  printRegister(k);
}

void printFullWord(word w)
{
  printFullByte(w / 256);
  printFullByte(w % 256);
}

void printFullByte(byte b)
{
  if (b < 16)
    Serial.write('0');
  Serial.print(b, HEX);
}

void showFirstLine()
{
  byte index[] = {2, 0, 12, 10, 14};  //B (BC), D (DE), H (HL), S (SP), P (PC)
  Serial.print(F(" A="));
  printRegister(5);
  for (byte i = 0; i < 5; i++)
  {
    printReg16(index[i]);
  }
  Serial.print(F("   "));
  char buf[20];
  for (byte i = 0; i < MAXDATALENGTH ; i++)
  {
    data[i] = CA80_PROG_MEM[i];
  }
  int bytesUsed = Z80Disassembler::disassemble(buf, data, MAXDATALENGTH);//dataLength);
  for (byte i = 0; i < bytesUsed; i++)
  {
    printFullByte(data[i]);
  }
  for (byte i = 0; i < (9 - ( 2 * bytesUsed)); i++)
  {
    Serial.write(' ');
  }
  Serial.println(buf);
}

void showSecondLine()
{
  byte index[] = {18, 20, 22, 6, 8};  //B' (BC), D' (DE), H' (HL), X (IX), Y (IY)
  Serial.print(F(" A'"));
  printRegister(17);
  for (byte i = 0; i < 5; i++)
  {
    printReg16(index[i]);
  }
  Serial.println(F("   "));
}


void showConditions(byte c)
{
  byte condition = CA80_REGS[c];
  for (int i = 7; i > -1; i--)
  {
    if (i != 5 && i != 3)
    {
      if (condition & 1 << i)
      {
        Serial.write("SZxHxPNC"[(7 - i)]);
      }
      else
      {
        Serial.write('-');
      }
    }
  }
}

#define PC 14
#define SP 10
#define HL 12

word reg16(byte reg)
{
  return (CA80_REGS[reg] + (256 * CA80_REGS[(reg + 1)]));  //
}

void listing()
{
  Serial.println();
  byte ptr = 0;
  word pc = reg16(PC);
  char buf[20];
  for (byte i = 0; i < 11; i++)
  {
    printFullWord(pc);
    Serial.write(' ');
    for (byte i = 0; i < MAXDATALENGTH ; i++)
    {
      data[i] = CA80_PROG_MEM[(i + ptr)];
    }
    int bytesUsed = Z80Disassembler::disassemble(buf, data, MAXDATALENGTH);//dataLength);
    ptr += bytesUsed;
    pc += bytesUsed;
    for (byte i = 0; i < bytesUsed; i++)
    {
      printFullByte(data[i]);
    }
    for (byte i = 0; i < (9 - ( 2 * bytesUsed)); i++)
    {
      Serial.write(' ');
    }
    Serial.println(buf);
  }
}
// ------------------------------------------------------------------------------

// Z80 bootstrap routines

// ------------------------------------------------------------------------------

#define WAIT_RES_HIGH   PORTB |= B00000001
#define WAIT_RES_LOW    PORTB &= B11111110
#define BUSREQ_HIGH     PORTD |= B01000000
#define BUSREQ_LOW      PORTD &= B10111111
#define MEM_EN_HIGH     PORTB |= B00000100
#define MEM_EN_LOW      PORTB &= B11111011
#define TEST_RD         PINC & B00001000  //PC3

void waitResume()
{
  BUSREQ_LOW;                         // Request for a DMA
  WAIT_RES_LOW;                       // Now is safe reset WAIT FF (exiting from WAIT state)
  delayMicroseconds(2);               // Wait 2us
  WAIT_RES_HIGH;
  BUSREQ_HIGH;                        // Resume Z80 from DMA
}

void waitRD()
{
  bool test;
  do
  {
    test = (PINC & B00001000);
  }
  while (test);
}

void ramEN()
{
  DDRA = 0x00;                        // Configure Z80 data bus D0-D7 (PA0-PA7) as input...
  PORTA = 0xFF;                       // ...with pull-up
  MEM_EN_HIGH;
}

void sendDataBus(byte data)
{
  waitRD();
  MEM_EN_LOW;                         // Force the RAM in HiZ (CE2 = LOW)
  DDRA = 0xFF;                        // Configure Z80 data bus D0-D7 (PA0-PA7) as output
  PORTA = data;                       // Write data on data bus
  BUSREQ_LOW;                         // Request for a DMA
  WAIT_RES_LOW;                       // Now is safe reset WAIT FF (exiting from WAIT state)
  delayMicroseconds(2);               // Wait 2us just to be sure that Z80 read the data and go HiZ
  WAIT_RES_HIGH;
  ramEN();
  BUSREQ_HIGH;                        // Resume Z80 from DMA
}

void loadByteToRAM(byte value)
// Load a given byte to RAM using a sequence of two Z80 instructions forced on the data bus.
// The MEM_EN_ signal is used to force the RAM in HiZ, so the Atmega can write the needed instruction/data
//  on the data bus.
// The two instruction are "LD (HL), n" and "INC (HL)".
{

  // Execute the LD(HL),n instruction (T = 3+3+3). See the Z80 datasheet and manual.
  // After the execution of this instruction the <value> byte is loaded in the memory address pointed by HL.
  sendDataBus(LD_HL);
  sendDataBus(value);                      // Write the byte to load in RAM on data bus
  sendDataBus(INC_HL);                     // Write "INC HL" opcode on data bus
}

// ------------------------------------------------------------------------------

void loadHL(word value)
// Load "value" word into the HL registers inside the Z80 CPU, using the "LD HL,nn" instruction.
// In the following "T" are the T-cycles of the Z80 (See the Z80 datashet).
{
  // Execute the LD dd,nn instruction (T = 4+3+3), with dd = HL and nn = value. See the Z80 datasheet and manual.
  // After the execution of this instruction the word "value" (16bit) is loaded into HL.
  sendDataBus(LD_HLnn);                    // Write "LD HL, n" opcode on data bus
  sendDataBus(lowByte(value));             // Write first byte of "value" to load in HL
  sendDataBus(highByte(value));            // Write second byte of "value" to load in HL
}

void pinsSetings()
{
  // ----------------------------------------
  // INITIALIZATION
  // ----------------------------------------

  // Initialize RESET_ and WAIT_RES_
  pinMode(RESET_, OUTPUT);                        // Configure RESET_ and set it ACTIVE
  digitalWrite(RESET_, LOW);
  pinMode(WAIT_RES_, OUTPUT);                     // Configure WAIT_RES_ and set it ACTIVE to reset the WAIT FF (U1C/D)
  digitalWrite(WAIT_RES_, LOW);
  pinMode(WAIT_EN, OUTPUT);                       // Configure WAIT_EN and set it ACTIVE
  digitalWrite(WAIT_EN, HIGH);

  pinMode(USER, INPUT_PULLUP);                    // Read USER Key

  // Initialize USER,  INT_, MEM_EN_, and BUSREQ_
  pinMode(USER, OUTPUT);                          // USER led OFF
  digitalWrite(USER, HIGH);
  pinMode(INT_, INPUT_PULLUP);                    // Configure INT_ and set it NOT ACTIVE
  //pinMode(INT_, OUTPUT);                        // Z80 CTC conflict !!!
  //digitalWrite(INT_, HIGH);
  pinMode(MEM_EN_, OUTPUT);                       // Configure MEM_EN_ as output
  digitalWrite(MEM_EN_, HIGH);                    // Set MEM_EN_ HZ
  pinMode(BUSREQ_, INPUT_PULLUP);                 // Set BUSREQ_ HIGH
  pinMode(BUSREQ_, OUTPUT);
  digitalWrite(BUSREQ_, HIGH);

  // Initialize D0-D7, AD0, MREQ_, RD_ and WR_
  DDRA = 0x00;                                    // Configure Z80 data bus D0-D7 (PA0-PA7) as input with pull-up
  PORTA = 0xFF;
  pinMode(RD_, INPUT_PULLUP);                     // Configure RD_ as input with pull-up
  pinMode(WR_, INPUT_PULLUP);                     // Configure WR_ as input with pull-up
  pinMode(AD0, INPUT_PULLUP);
  // Initialize CLK and reset the Z80 CPU
  setCLK(SLOW_CLK);                              // FAST_CLK or SLOW_CLK
  // jednak będzie w stanie WAIT do czasu podania kodu rozkazu (FETCH)
  pinMode(SNMI, OUTPUT);                          // Blokada NMI i INT w CA80
  digitalWrite(SNMI, HIGH);
  delay(1000);
  digitalWrite(RESET_, HIGH);
  while (Serial.available() > 0) Serial.read();   // Flush serial Rx buffer
}

void resetCPU()
{
  digitalWrite(RESET_, LOW);                      // Activate the RESET_ signal
  // Flush serial Rx buffer
  while (Serial.available() > 0)
  {
    Serial.read();
  }

  // Leave the Z80 CPU running
  delay(1);                                       // Just to be sure...
  digitalWrite(WAIT_EN, LOW);
  digitalWrite(WAIT_RES_, LOW);                      //
  digitalWrite(WAIT_RES_, HIGH);                      //
  digitalWrite(RESET_, HIGH);                     // Release Z80 from reset and let it run
  delay(5);                                       // Dla pewnosci zamiast SNMI_ (MCU_CTS)
}

// ------------------------------------------------------------------------------
//  Stale klawiatury
// ------------------------------------------------------------------------------

//const byte PCF_kbd = 0x38;     //Adres PCF8574A 0x38 , dla PCF8574 0x20
// ------------------------------------------------------------------------------
// Kody klawiszy tworzymy wg. wzoru: starsza cyfra nr kolumny, mlodsza ma zero na pozycji
// numeru wiersza
//  wiersz \ kolumna  5 4 3 2 1 0
// -------------------------------
//  3 (0111)          Z C D E F M
//  2 (1011)          Y 8 9 A B G
//  1 (1101)          X 4 5 6 7 .
//  0 (1110)          W 0 1 2 3 =
// ------------------------------------------------------------------------------
const byte noKey = (0xFF);
const byte keyM = (0x07);
const byte keyDot = (0x0D);
const byte keyCR = (0x0E);
const byte keyG = (0x0B);

const byte keyW = (0x5E);
const byte keyX = (0x5D);
const byte keyY = (0x5B);
const byte keyZ = (0x57);

const byte keyCode[] =          //Kody klawiszy 0 - F
{
  (0x4E), // 0
  (0x3E), // 1
  (0x2E), // 2
  (0x1E), // 3
  (0x4D), // 4
  (0x3D), // 5
  (0x2D), // 6
  (0x1D), // 7
  (0x4B), // 8
  (0x3B), // 9
  (0x2B), // A
  (0x1B), // B
  (0x47), // C
  (0x37), // D
  (0x27), // E
  (0x17)  // F
};

// ------------------------------------------------------------------------------
//  Funkcje klawiatury
// ------------------------------------------------------------------------------


void sendKeyCode(byte key)
{
  if ( key > 'Z' )
    key -= 0x20;
  if ( key == 'M' )
  {
    sendKey (keyM);
    return;
  }
  if ( key == 'G' )
  {
    sendKey (keyG);
    return;
  }
  if ( key == '=' )
  {
    sendKey (keyCR);
    return;
  }
  if ( key == '-' )
  {
    sendKey (noKey);
    return;
  }
  if ( key == '.' )
  {
    sendKey (keyDot);
    return;
  }
  if ( key == 'W' )
  {
    sendKey (keyW);
    return;
  }
  if ( key == 'X' )
  {
    sendKey (keyX);
    return;
  }
  if ( key == 'Y' )
  {
    sendKey (keyY);
    return;
  }
  if ( key == 'Z' )
  {
    sendKey (keyZ);
    return;
  }
  if (key < '0' || key > 'F') return; //Ignoruj niewlasciwe klawisze
  byte b = (key - 0x30);
  if (b > 0x09)
    b = b - 0x07;
  if (b > 0x0F) return;
  sendKey(keyCode[b]);
}

void sendKey (byte k)
{
  Wire.beginTransmission(PCF_KBD);
  Wire.write(k);                    //Wysylamy kod klawisza
  Wire.endTransmission();
}
