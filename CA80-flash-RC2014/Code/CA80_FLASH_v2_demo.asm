;*********************************************************************
;                 PAMIEC MASOWA DLA CA80
;
;         PROGRAM PRZECHOWUJE DANE W FLASH SST39SF040 
; FORMAT "PLIKOW" ZGODNY Z UZYWANYM W ZLECENIACH *4 *5 *6 CA80
;       NUMER SEKTORA JEST ODPOWIEDNIKIEM NAZWY PROGRAMU.
; PROCEDURA FMAG dziala jak OMAG (MIK08 REJESTR B=NR SEKTORA) 
;                   (C) Zegar & Nadolic
;*********************************************************************
        .cr z80                     
        .tf CA80_FLASH2_demo.hex,int   
        .lf CA80_FLASH2_demo.lst
        .sf CA80_FLASH2_demo.sym       
        .in ca80.inc
SYS8255 .eq 0F0H         
CIM     .eq 184H
GSTAT   .eq 0FFB3H
A5      .eq 7555H       ;adres dla klucza FLASH
AA      .eq 7AAAH       ;adres dla klucza FLASH
FL      .eq 6000H       ;poczatek sektora FLASH
FLEND   .eq FL+0FFEH    ;adres wskaznika pierwszej wolnej komorki
KA      .eq 0AAH        ;klucz sterujacy EEPROM I FLASH
K5      .eq 55H         ;klucz sterujacy EEPROM I FLASH
MARK    .eq 0E2FDH      ;znacznik poczatku naglowka
PBYTE   .eq 06ABH       ;wyslij bajt na wyj. magn. (monitor CA80)
BUFOR   .eq 5000H       ;poczatek bufora w RAM
BUF_LEN .eq 1000H       ;d≥ugoúÊ bufora/sektora
SECT    .eq BUFOR+0FFDH ;numer sektora (LS373)
BUFEND  .eq BUFOR+0FFEH ;pierwsza wolna komorka do zapisu
NAME1   .eq BUFOR+0FD0H ;nazwa pierwszego programu w buforze/sektorze
NAME2   .eq BUFOR+0FE4H ;nazwa drugiego programu w buforze/sektorze
;ACSEC   .eq FL-3        ;ostatnio uzyty sektor (LS373)
;*********************************************************************
; LCD - sterowanie 8-bitowe wyswietlaczem LCD 4 x 20 znakow,
; podlaczony bezpoúrednio do szyny danych
; Enable - 40H, RS - A0, R/W - A1, DATA na D0 .. D7 Z80
;*********************************************************************
LCD_E     .eq 040h      ;LCD              
LCD_IR    .eq LCD_E+0h  ;write only!
LCD_WDR   .eq LCD_E+1h  ;write only!
LCD_RDR   .eq LCD_E+3h  ;read only!
LCD_BUSY  .eq LCD_E+2h  ;read only!
;*********************************************************************
L1:          .eq 80h    ; pocz. 1. linii LCD
L2:          .eq 0C0h   ; pocz. 2. linii
L3:          .eq 94h    ; pocz. 3. linii
L4:          .eq 0D4h   ; pocz. 4. linii
;*********************************************************************
;4000H - 4FFFH EEPROM Z OPROGRAMOWANIEM
;5000H - 5FFFH RAM BUFOR (6264)
;        5FFDH REJESTR NUMERU SEKTORA (74LS373)
;6000H - 6FFFH SEKTOR FLASH
;7000H - 7FFFH 7555H I 7AAAH KODY STERUJ•CE FLASH (74HC244)
;*********************************************************************
        .sm code           ; 
        .or $4000          ; U12/C000
;*********************************************************************        
;Program testujacy dla pracy krokowej MIK05 str. 187
;*********************************************************************
        ld A,K5
        ld (0C555H),A      ;Docelowo program bedzie w U10
        ld A,(0C555H)      ;Uruchomienie *80 wymaga 55H
        ld A,90H           ;pod adr. 4001H
        out (SYS8255+CTRL),A
        ld A,K5
        out (SYS8255+PB),A
        out (SYS8255+PC),A
        ld A,KA
        out (SYS8255+PB),A
        out (SYS8255+PC),A
        jp 0000H
KOMFL:  .db 39H, 77H, 71H, 38H, EOM        ;CAFL
;*********************************************************************
Flash:
        ld SP,$ff66        ;
        ld HL,CIFL         ;Wlaczenie obslugi "G" w NMI
        ld (CI+1),HL
        ;ld HL,CSTSFL
        ;ld (CSTS+1),HL
        CALL LCD_INIT
CAFL:
        ld SP,$ff66        ;
        rst CLR
        .db 80H
CAFLA:
        ld HL,KOMFL
        call PRINT
        .db 40H
        call TI
        .db 17H
        ld E,A             ; nr zlecenia
        cp LCTX            ; czy "legalne"
        jp nc,ERFL
        rst CLR
        .db 70H
        ld HL,CAFL
        push HL            
        ld C,2             ;dla EXPR
        ld HL,CTBLX        ;tablica rozejsc
        ld D,0             ;w E numer zlecenia
        add HL,DE
        add HL,DE
        ld E,(HL)
        inc HL
        ld D,(HL)
        ex DE,HL
        jp (HL)            ;Pseudo CALL        
ERFL:
        rst CLR
        .db 80H
        ld HL,KOMERR
        call PRINT
        .db 35H
        jr CAFLA
KOMERR  .eq 0034H          ;juz jest w CA80
;********************************************************
; Tablica adresÛw poczπtkÛw linii LCD
;********************************************************
NUM_LINII:      
  .db L1, L2, L3, L4  ; musi byÊ na jednej stronie!
;********************************************************
     
CTBLX:
        .dw Z0             ;Czy wolny sektor
        .dw Z1             ;Szukaj wolny sektor (jeszcze brak)
        .dw Z2             ;Kasuj sektor
        .dw Z3             ;Ustaw adres bufora(kasuj bufor)
        .dw Z4             ;Zapisz RAM do bufora
        .dw Z5             ;Zapisz EOF do bufora
        .dw Z6             ;Czytaj sektor do RAM
        .dw Z7             ;Zapisz bufor do sektora
        .dw Z8             ;Czytaj z wejscia magn. do bufora (jeszcze brak)
        .dw Z9             ;Weryfikuj we. magn. z buforem (jeszcze brak)
        .dw ZA             ;Wyslij sektor przez wy. magnet.
        .dw ZB             ;Ustaw 3,5 kHz na wy. magnet.
        .dw ZC             ;Kopiuj dane do EEPROM W U11
        .dw ZD             ;Disable SDP (np. MK28C64) W U11
        .dw ZE             ;Enable SDP (lub np. AT28C64) W U11
        .dw ZF             ;SzukaJ nazw programow        
LCTX    .eq $-CTBLX/2
CIFL:
        call CIM           ;Str.11 w MIK08
        push AF
        cp 10H             ;Kod klaw. "G"
        jp z,CAFL
        pop AF
        ret
;*********************************************************************
Z0:       ;Sprawdz czy wolny sektor [0][NR SEKTORA][=]
          ;Wysw. adres i jego zawartosc
          ;6FFF FF oznacza pusty, inna wartosc przeciwnie
        dec C              ;jeden parametr
        call EXPR
        .db 20H
        pop DE
Z01:        
        ld A,E
        LD (SECT),A
        ld HL,FL
        ld D,EOM
        ld BC,BUF_LEN
.loop
        ld A,D
        cpi
        jr NZ,.koniec
        jp PE,.loop
.koniec
        dec HL
.wysadr        
        rst LADR
        .db 43h
        ld A,(HL)
        rst LBYTE
        .db 20H
        CALL LCD_INFO_SECT
        rst TI1
        ret C
        jr Z,.nsec
.adrnff        
        cp 10H
        ret NC
        ld C,A
        rst CLR
        .db 43H
        call CO1
        ld A,C        
        call PARA1
        ld E,L           ;W E nowy nr sektora
        jp Z01           ;sprawdz nowy sektor
.nsec                    ;wyswietl nr sektora
        rst CLR
        .db 43H
        ld A,E
        rst LBYTE
        .db 23H
        rst TI1
        ret C
        jr Z,.wysadr
        jr .adrnff
        
CHKBUF: ;sprawdz. czy bufor zainicjowany
        ld A,(BUFEND+1) ;sprawdz starszy bajt adresu
        and 0F0H        ;starsza cyfra
        cp BUFOR/256         ;powinno byc wyliczone z BUFOR
        jp NZ,ERFL
        CALL LCD_INFO
        LD IY,NAME1
        LD A,(IY+0)
        ret

SET_NAME:                 ;SPRAWDè I ZAPISZ NAZW  
        LD IY,NAME2
        BIT 7,B
        JR NZ,W_NAME
        LD IY,NAME1
W_NAME:
        LD A,EOM
        CP (IY+0)
        JR Z,NEW_NAME
        LD A,B
        CP (IY+0)
        JP NZ,ERFL
        JP NAME_SEARCH
NEW_NAME:
        LD (IY+0),B
        LD (IY+1),0
        LD (IY+2),0        
NAME_SEARCH:
        PUSH BC
        PUSH DE
        PUSH IY
        PUSH HL
        SBC HL,DE
        LD B,H
        LD C,L
        POP HL
        PUSH HL
.NS:        
        LD D,0
        LD A,0AAh
        CPIR
        JP PO,NO_NAME
.AA:        
        INC D
        CPI
        JP PO,NO_NAME
        JR Z,.AA
        LD A,D
        SUB 4
        JR C,.NS
        DEC HL
        LD DE,3
        ADD IY,DE
        PUSH IY
        POP DE
.NAME        
        LD B,10h
        LD A,(HL)
        CP EOM
        JR Z,NO_NAME
        LD (DE),A
        INC HL
        INC DE
        DJNZ .NAME
NO_NAME:       
        CALL LCD_INFO
        POP HL
        POP IY
        POP DE
        POP BC
        RET

PRINT_L0_C:                 ; WYåWIETL W PIERWSZEJ LINII Z KASOWANIEM LCD
        CALL LCD_CLR
PRINT_L0:                   ; WYåWIETL W PIERWSZEJ LINII 
        LD BC,0
PRINT_LX:                   ; WYåWIETL W DOWOLNYM MIEJSCU
        CALL LCD_SET_CURSOR ; W BC POZYCJA KURSORA        
        CALL LCD_PRINT
        RET
        
PRINT_3B_LX:                ; WYåWIETL 3 BAJTY W DOWOLNYM MIEJSCU
        CALL LCD_SET_CURSOR ; W BC POZYCJA KURSORA        
PRINT_3B:                   ; WYåWIETL 3 BAJTY OD POZYCJ KURSORA
        LD B,3
.P3B:        
        CALL SPACJA
        LD A,(HL)
        CALL LCD_BYTE
        INC HL
        DJNZ .P3B
        RET
        
LCD_INFO:
        PUSH HL
        PUSH BC
        LD HL,T_BUFOR
        CALL PRINT_L0_C
        LD HL,NAME1
        JR LCD_INFO1
LCD_INFO_SECT:
        PUSH HL
        PUSH BC
        LD HL,T_SECT
        CALL PRINT_L0_C
        LD HL,NAME1-BUFOR+FL  ; W SEKTORZE FLASH        
LCD_INFO1:
        LD A,(SECT)
        CALL LCD_BYTE
        PUSH HL
        CALL PRINT_3B
        LD BC,100h            ; ROW 1, COL 0
        CALL PRINT_LX
        LD BC,200h            ; ROW 2, COL 0
        CALL LCD_SET_CURSOR 
        LD L,BUFEND-BUFOR
        LD C,(HL)
        INC HL
        LD B,(HL)
        LD A,B        
        CP EOM
        JR NZ,.N_EMPTY
        LD BC,BUFOR
.N_EMPTY:        
        LD HL,NAME1
        OR A                  ; CF = 0
        SBC HL,BC
        CALL LCD_WORD
        LD HL,T_FREE
        CALL LCD_PRINT
        POP HL
        LD BC,NAME2-NAME1
        ADD HL,BC
        CALL PRINT_3B
        LD BC,300h
        CALL PRINT_LX
        POP BC
        POP HL
        RET

T_BUFOR:
        .db "BUFOR:   "
        .db EOM
T_SECT:
        .db "SEKTOR:  "
        .db EOM
T_FREE:
        .db " FREE  "
        .db EOM
;*********************************************************************
Z4:   ;Zapisz RAM do bufora
      ;[4][ADR1[.][ADR2][.][NAZWA][=]
        inc C            ; 3 parametry
        call EXPR
        .db 40H
        pop BC           
        ld B,C           ;B - nazwa
        pop DE           ;ADR2
        pop HL           ;ADR1
        call CHKBUF        
        CALL SET_NAME
        push BC
.wr0    push HL
        ld A,(DLUG)      ;dlug. bloku danych
        ld C,A
        ld B,0
.wr1    inc B
        dec C
        jr Z,.wr2
        call HILO
        jr NC,.wr1
        INC (IY+1)
        ;B - wyliczona dlugosc bloku danych
.wr2    push DE
        ld HL,MARK
        INC (IY+1)
        call BADR
        pop DE
        pop HL
        pop AF
        push AF
        push DE
        ld E,A               ;Nazwa
        ld D,0               ;Zerow. sumy kontrolnej
        call BBYT            ;zapisanie nazwy
        ld A,E
        rst LBYTE
        .db 25H
        ld A,B               ;dlug. bloku
        call BBYT
        call BADR
        rst LADR
        .db 40H
        xor A
        sub D                ;-suma kontrolna naglowka
        call BBYT
        ld D,0
        ;zapisanie bloku danych do bufora
.wr3    ld A,(HL)
        call BBYT
        inc HL
        djnz .wr3
        ;SUMD - suma kontrolna bloku danych
        xor A
        sub D                 ;-SUMD
        call BBYT
        pop DE
        dec HL
        call HILO
        jr NC,.wr0
        ;DE<HL - koniec zapisu
        pop BC
        CALL LCD_INFO
        ret
        
CHK_NAME:
        LD IY,NAME2
        BIT 7,B
        JR NZ,C_NAME
        LD IY,NAME1
C_NAME:
        LD A,EOM
        CP (IY+0)
        JP Z,ERFL
        LD A,B
        CP (IY+0)
        JP NZ,ERFL
        RET
        
;*********************************************************************        
Z5:     ;Zapisz EOF do bufora
        ;[5][ADR.WEJ.][.][NAZWA][=]
        call EXPR
        .db 40H
        pop BC
        ld B,C                  ;Nazwa
        pop HL                  ;Adres wejscia
BEOF:   call CHKBUF
        CALL CHK_NAME           ;MOØLIWY ZAPIS TYLKO GDY NAZWA JEST ZGODNA
        INC (IY+2)
        push HL
        CALL LCD_INFO
        ld HL,MARK
        call BADR
        ld A,B
        ld D,0
        call BBYT
        xor A
        call BBYT
        pop HL
        call BADR
        xor A
        sub D
        jr BBYT
BADR:   ;Zapisz HL w buforze
        ld A,L
        call BBYT
        ld A,H
BBYT:   ;Zapisz bajt w buforze
        ld C,A
        add A,D                   ;suma modulo 256
        ld D,A
        ld A,C
BBYTE:  push DE
        push HL
        ld DE,BUFEND-4
        ld HL,(BUFEND)            ;wskaznik bufora
        ld (HL),A                 ;zapis do bufora
        call HILO
        jp C,ERFL                 ;za duzo danych        
        ld (BUFEND),HL
        pop HL
        pop DE
        call DELAY
        ret
;*********************************************************************
ZA:     ;Wyslij sektor przez wy. magnet.
        ;[A][NR SEKTORA][=]
        dec C              ;jeden parametr
        call EXPR
        .db 20H
        pop BC
        ld B,C        
        ld A,C             ; nr sektora
FLMAG:  ;wej: A - numer sektora
        ;zawartosc sektora zostanie wyslana tak, jak jest.
        ;jezeli dane poprawne, na wysw. nazwa i adres bloku
        ;nalezy wysylac tylko zapisane sektory.
        LD (SECT),A
        call SYNCH
        ld IX,FL
FLM1:   ld HL,MARK
FLM0:   call RFLBYT
        ld C,A
        call PBYTE  ;monitor CA80 - wyslanie bajtu na magnetofon
        ld A,c      ;PBYTE zmienia AF
FLX:    cp L
        jr NZ,FLM0
        call RFLBYT
        ld C,A
        call PBYTE  ;monitor CA80 - wyslanie bajtu na magnetofon
        ld A,c      ;PBYTE zmienia AF
        cp H
        jr NZ,FLX
        ;znaleziono MARK
        call RFLBYT
        ld C,A      ;NAZWA
        call PBYTE  ;monitor CA80 - wyslanie bajtu na magnetofon
        ld A,c      ;PBYTE zmienia AF
        rst LBYTE   ;wyswietlenie nazwy
        .db 25H
        call RFLBYT ;DLUGOSC
        ld B,A          
        call PBYTE  ;monitor CA80 - wyslanie bajtu na magnetofon
        call RFLBYT
        ld L,A      ;mlodszy bajt adresu
        call PBYTE  ;monitor CA80 - wyslanie bajtu na magnetofon
        call RFLBYT
        ld H,A      ;starszy bajt adresu
        call PBYTE  ;monitor CA80 - wyslanie bajtu na magnetofon
        rst LADR    ;wyswietlenie adresu
        .db 40H
        call RFLBYT ;suma        
        call PBYTE  ;monitor CA80 - wyslanie bajtu na magnetofon
        ld A,B
        or A
        jr Z,FLM1
        ;blok danych
FLM2:   call RFLBYT        
        call PBYTE  ;monitor CA80 - wyslanie bajtu na magnetofon
        djnz FLM2       
        call RFLBYT ;suma      
        call PBYTE  ;monitor CA80 - wyslanie bajtu na magnetofon
        jr  FLM1    ;wyslij nastepny sektor
                
        
RFLBYT: ;odczyt bajtu z flash bez sumy kontrolnej
        ld A,(IX+0)
        inc IX        
        ld C,A
        ld A,0F0H             ;sprawdzamy czy nadal adres sektora
        .db 0DDH,0A4H         ;and IXH
        cp 60H
        jp NZ,CAFL
        ret
        

SYNCH:  push BC
        ld B,8  ;liczba bajtow synchronizacji (w CA80 bylo 32)
.pbx    xor A
        call PBYTE
        djnz .pbx
        pop BC
        ret
;*********************************************************************        
Z6:     ;Czytaj sektor do RAM
        ;[6][NR SEKTORA][=]
        dec C              ;jeden parametr
        call EXPR
        .db 20H
        pop BC
        ld B,C        
FMAG:   ;dziala jak OMAG MIK08
        call SYNCH
        ld A,B             ; nr sektora
        LD (SECT),A
        push BC
        CALL LCD_INFO_SECT
        ld IX,FL
RED1:   ld HL,MARK
RED0:   call RFBYT
REX:    cp L
        jp NZ,RED0
        call RFBYT
        cp H
        jp NZ,REX
        ;znaleziono MARK
        ld D,0
        call RFBYT
        ld E,A              ;E - nazwa pliku
        rst LBYTE
        .db 25H
        call RFBYT
        ld B,A              ;B - dlugosc bloku
        call RFBYT
        ld L,A              ;L - mlodszy bajt adresu
        call RFBYT
        ld H,A              ;H - starszy bajt
        rst LADR
        .db 40H
        call RFBYT
        jr NZ,REOF          ;CY = 0 - blad SUMN
        pop AF
        push AF             ;A - nazwa deklarowana
        cp E
        jr NZ,RED1          ;nazwy rozne
        ;sprawdzenie czy EOF
        ld A,B
        or A                  ;czy dlug. = 0
        jr Z,REOF
        ld A,(IX+0)
        call SOUND            ;monitor CA80 - wyslanie bajtu na magnetofon
        ld A,48H              ;wyswietl. symbolu odczytywania "="        
        ld (0FFFBH),A         ;BWYS+4
RED2:                         ;rekord z blokiem danych
        call RFBYT
        ld (HL),A
        inc HL
        djnz RED2
        call RFBYT
        ld A,(IX+1)
        call SOUND            ;monitor CA80 - wyslanie bajtu na magnetofon        
        ld A,0
        ld (0FFFBH),A         ;BWYS+4
        scf                   ;CY = 1 - blad SUMD
        jr NZ,REOF
        jr RED1               ;czytaj nastepny rekord
REOF:
        pop BC
        jp NZ,ERFL            ;nie ma jeszcze obs≥ugi bledu
        ld A,(GSTAT)          ;czy program uzytkownika
        or A
        jr NZ,.monjes
        rst CLR
        .db 80H
        jp (HL)               ;skok do programu uzytkownika
.monjes
        ld (0FFA9H),HL        ;adr PC uzytkownika (PLOC-1)
        ret
SOUND:  
        call PBYTE            ;monitor CA80 - wyslanie bajtu na magnetofon
        ld A,8
        out (SYS8255+CTRL),A  ; cisza
        ret
RFBYT:  ;odczyt bajtu z flash
        ld A,(IX+0)
        inc IX        
        ld C,A
        ;push HL;push IX;pop HL               
        ld A,0F0H             ;sprawdzamy czy nadal adres sektora
        .db 0DDH,0A4H         ;and IXH zamiast and H
        cp 60H
        jp NZ,ERFL
        ;pop HL
        ld A,C
        add A,D               ;SUMA KONTROLNA
        ld D,A
        or A
        ld A,C
        ;call DELAY
        ret
        
KOMSEC: .db 6DH,0,79H,50H,77H,6DH,79H,EOM ;s_erase
        
SPRSEC: ;sprawdzenie sektora
        ld HL,FL
        ld A,EOM
        ld BC,BUF_LEN
.loop
        cpi
        jr NZ,.koniec
        jp PE,.loop
.koniec
        ld A,B
        or C
        ret Z
        ld HL,KOMSEC
        call PRINT
        .db 80
        call CI
        jp ERFL
        
KOMNRS: .db 54H,50H,0,6DH,79H,39H,EOM ;nr_sec
;*********************************************************************        
Z7:     ;Zapisz bufor do sektora
        ;[7][=]
        call CHKBUF        
        LD (SECT),A
        call SST_S_ERASE
        ld HL,BUFOR
        ld DE,FL
        ld BC,BUF_LEN
.next   call SST_B_KEY
        ldi
        jp PE,.next
        CALL LCD_INFO_SECT
        ret
;*********************************************************************
Z1:     ;Szukaj wolny sektor
        ;[1][NR SEKTORA][=]  SZUKAJ OD SEKTORA O PODANYM NR
        ;[1][=]              SZUKAJ OD SEKTORA NR 0
        CALL TI
        .db 20h
        JR C,.SZUK
        JP Z,ERFL
        CALL PARA1
        LD A,L
        JR .SZUK1
.SZUK:
        XOR A
        JR .SZUK1
.SZUK2:
        INC A
        AND 7Fh
        OR A
        JR Z,BRAK
.SZUK1:
        LD L,A
        LD (SECT),A
        LD H,0FDh
        LD A,(FL)
        CP H
        LD A,L
        JR Z,.SZUK2
        CALL LCD_INFO_SECT
        LD A,L
        CALL LBYTE
        .db 20        
        RST TI1
        JP NC,CAFL
        LD A,(SECT)
        JR .SZUK2
BRAK:
        RET
        
        
;*********************************************************************
Z8:
;*********************************************************************
Z9:
        ret
        
KOMZB:  .db 73H,39H,66H,0,5CH,54H,EOM   ;pc4_on     
;*********************************************************************
ZB:     ;Ustaw 3,5 kHz na wy. magnet.
        ld A,9
        out (SYS8255+CTRL),A
        ld HL,KOMZB
        call PRINT
        .db 60H
        call CI
        ld A,8
        out (SYS8255+CTRL),A
        ret
;*********************************************************************        
Z2:     ; Kasuj sektor [2][NR SEKTORA][=]
        ; Jeøeli wpiszemy FF - 
        ; ZOSTAN• SKASOWANE WSZYSTKIE NIEZAPISANE SEKTORY
        dec C              ;jeden parametr
        call EXPR
        .db 20H
        pop DE        
        ld A,E             ; nr sektora
        CP EOM
        JR NZ,.SE
        CALL FLASH_FORMAT
.SE:        
        call SST_S_ERASE
        ret

KOMBUFER:
        .db 7CH,3EH,71H,3FH,50H,EOM ;"bUFOr"
;*********************************************************************
Z3:     ; INICJUJ bufor (wyúwietl bufor)
        ; [3][NR SEKTORA][=]  PRZEPISZ SEKTOR O PODANYM NR DO BUFORA
        ; UMOØLIWIA EDYCJ  SEKTORA. NP. DOPISANIE NAZW
        ; LUB WGRANIE DRUGIEGO PROGRAMU, JEØELI BY£ JEDEN
        ; [3][=]              WYåWIETL ZAWARTOå∆ BUFORA BEZ ZMIAN
        ld HL,KOMBUFER
        PUSH BC
        call PRINT
        .db 52H
        CALL TI
        .db 20h
        JR C,.INFO
        JP Z,ERFL
        CALL PARA1
        LD A,L
        LD (SECT),A
        LD HL,FL
        ld DE,BUFOR                
        LD BC,BUF_LEN
        LD A,(SECT-BUFOR+FL)
        CP EOM
        JR NZ,.ZAP
        LD BC,BUF_LEN-3
        LD (BUFEND),DE
.ZAP:        
        LDIR
.INFO        
        CALL LCD_INFO
        RET

SST_S_ERASE:
        push HL            ; kasowanie sektora (4 kB)
        push DE
        push BC
        push AF
        LD (SECT),A        ; nr sektora w A
        ld A,K5
        ld HL,A5           ; adres 
        ld (HL),KA         ; klucz
        ld DE,AA           ; adres 
        ld (DE),A          ; klucz
        ld (HL),080H       ; klucz
        ld (HL),KA         ; klucz
        ld (DE),A          ; klucz 
        ld H,60H           ; dowolny - A18..A12 w LS373
        ld (HL),30H        ; klucz
        ld B,10H           ; wait 28..30 ms
.loop
        halt               ; 2 ms
        djnz .loop         ; Tse MAX 25 ms
        pop AF
        pop BC
        pop DE
        pop HL
        ret
        
SST_B_KEY:                 ; odblokowanie flash (SST39SF040)
        push HL            ; nie stosujemy pollingu
        push DE            ; ani innych sztuczek - mierzymy czas
        push AF            ; 4 * 11 cykli        
        push BC            ; zapis do Flash Tbp MAX 20 us
        ld b,9H            ; wait 170 * 0.125us (8 MHz > 20 us) 
.loop                      ; czekamy na koniec zapisu poprzedniego bajtu
        djnz .loop         ; 9*13 cykli
        pop BC             ; 10                
        ld A,K5            ; 7 cykli
        ld HL,A5           ; adres 10 cykli
        ld (HL),KA         ; klucz
        ld DE,AA           ; adres 
        ld (DE),A          ; klucz
        pop AF             ; 
        pop DE             ; 
        ld (HL),0A0H       ; klucz
        pop HL             ;  
        ret                ; 
       
DELAY:  push    BC
        push    AF
        ld      B,02H
.delay        
        halt            ; 2ms
        djnz    .delay  ; while( --B )
        pop     AF
        pop     BC
        ret
;*********************************************************************        
;PROGRAM KOPIOWANIA DANYCH DO EEPROM (NP. KM28C64A) DLA CA80

ZC:   ;kopiuj dane do EEPROM np MK28C64 W U11
      ;przed zapisem nalezy zdjac SDP
      ;[C][ADR. POCZ][.][ADR. KONCA][.][ADR. PRZEZNACZENIA][=]
        inc C            ; 3 parametry
        call EXPR
        .db 40H
        pop HL           ;ADR. PRZEZNACZENIA
        ld A,L
        and 0C0H         ;wyrownujemy do poczatku strony
        ld L,A           ;zapis 64 bajtow mozliwy tylko dla jednej strony
        push hl
        pop IX           ;ADR. PRZEZNACZENIA
        pop DE           ;ADR. KONCA
        pop HL           ;ADR. POCZATKU
        ld A,0C0H        ;wyrownujemy do poczatku strony
        and L
        ld L,A
        halt                        ; <2ms (dla pewnosci, bo mozemy trafic tuz przed NMI)
.loop:
        ld B,40h                    ; zapis 64 bajtÛw jednoczesnie
.loop1:
        ld C,(HL)  	                ; kopiuj bajt
        ld (IX+0),C                 ; Tlbc (load byte cycle 200 ns max 150 us) 
        inc IX                      ;- musimy sie spieszyc
        call HILO
        ret C    
        djnz .loop1                 ; czy juz 64?
        call ladr                   ; pokaz HL
        .db $44                     ; 
        halt                        ; 2ms (nota katalogowa: czas zapisu MAX 5 ms)
        halt                        ; 2ms
        halt                        ; 2ms 
        jr .loop                    ;                        
        ;

KOM_E_SDP:
        .db 50H,79H,77H,5EH,0H,3FH,54H,38H,EOM  ;read_onl
;*********************************************************************        
ZE: ; ustaw Software Data Protection (enable_SDP)
        ld A,K5                     ;
        ld HL,9555H                 ; adres 8000H + 1555H
        ld (HL),KA                  ; klucz
        ld DE,0AAAAH                ; adres 8000H + 2AAAH 
        ld (DE),A                   ; klucz
        ld (HL),0A0H                ; klucz
        ld HL,KOM_E_SDP
        call PRINT
        .db 80H
        call CI        
        ; PamiÍÊ juø jest zabezpieczona
        ret
		;
KOM_D_SDP:
        .db 1CH,0,39H,77H,54H,0,3EH,50H,EOM ;u_can_wr
;*********************************************************************
ZD:  ; odblokuj SDP (disable_SDP)
        ld A,55H
        ld HL,9555H                 ; adres 
        ld (HL),0AAH                ; klucz
        ld DE,0AAAAH                ; adres 
        ld (DE),A                   ; klucz
        ld (HL),080H                ; klucz
        ld (HL),0AAH                ; klucz
        ld (DE),A                   ; klucz 
        ld (HL),020H                ; klucz
        ld HL,KOM_D_SDP
        call PRINT
        .db 80H
        call CI        
        ; PamiÍÊ juø jest odbezpieczona
        ret
;*********************************************************************
ZF: ; szukanie nazw programow
        ; [F][NR SEKTORA][=]  SZUKAJ NAZW PROGRAM”W OD SEKTORA NR...
        ; WYåWIETLA NAZWY PROGRAM”W I ICH NUMERY
        ; [F][=]              SZUKAJ NAZW PROGRAM”W OD SEKTORA "00"
        ld HL,T_NAZWY
        call PRINT
        .db 52H
        CALL LCD_CLR
        LD DE,0                       ; D - NR SEKTORA 
        CALL TI                       ; E - NR ZNALEZIONEJ NAZWY
        .db 20h
        JR C,.ODZERA
        JP Z,ERFL
        CALL PARA1
        LD D,L
.ODZERA:        
        LD A,D
        CP 80h
        JR NC,.KON_SEC
        LD (SECT),A
        LD A,(FL)
        CP 0FDh
        CALL Z,SZ_NAZWY
        INC D
        JR .ODZERA
.KON_SEC:
        LD HL,T_KON_SEC
        LD B,E
        LD C,0
        CALL PRINT_LX
        CALL PAUZA
        RET
T_KON_SEC:
        .db "Koniec sektorow."
        .db EOM
T_NAZWY:
        .db 54h, 77h, 5Bh, 3Eh, 66h, EOM
SZ_NAZWY:        
        LD HL,NAME1-BUFOR+FL+3  ; W SEKTORZE FLASH
        CALL SZ_N1
        LD HL,NAME2-BUFOR+FL+3  ; W SEKTORZE FLASH
SZ_N1:        
        LD A,(HL)
        CP EOM
        CALL NZ,WYS_NAZWE        
        RET
WYS_NAZWE:
        PUSH HL
        LD B,E
        LD C,0
        CALL LCD_SET_CURSOR
        DEC HL
        DEC HL
        DEC HL
        LD A,(HL)
        CALL LCD_BYTE
        CALL SPACJA
        POP HL
        CALL LCD_PRINT
        INC E
        LD A,E
        AND 3
        CALL Z,PAUZA
        RET
T_WYBOR:
        .db 39h, 76h, 3Fh, 3Fh, 6Dh, EOM
PAUZA:
        LD HL,T_WYBOR
        CALL PRINT
        .db 52h
        CALL TI
        .db 20h
        JR C,.NEXT
        JR Z,.BACK
        CALL PARA1
        LD C,L
        CALL Z6+6
        JP FLASH
.BACK:
        LD DE,0
.NEXT:
        CALL LCD_CLR
        RET
;*********************************************************************
; FORMATOWANIE FLASH. WYKONUJEMY TYLKO RAZ, WI C NIE MA GO W MENU.
; ABY JE WYWO£A∆, NALEØY WYBRA∆ KASOWANIE SEKTORA FF
;*********************************************************************
FLASH_FORMAT:
          LD B,7Fh
          LD HL,FL
.FORM1:          
          LD A,B
          LD (SECT),A
          LD A,(HL)
          CP EOM           ; OMIJAMY SEKTORY SKASOWANE
          JR Z,.FORM
          CP 0FDh           ; OMIJAMY SEKTORY ZAPISANE          
          JR Z,.FORM        ; ØEBY NIE TRACI∆ PROGRAM”W
          LD A,B
          CALL SST_S_ERASE
.FORM:
          DJNZ .FORM1
          RET
;********************************************************
;             Podprogramy do obslugi LCD.               *
; Sterowanie 8-bitowe wyswietlaczem LCD 4 x 20 znakÛw   *
;       pod≥πczonym bezpoúrednio do szyny danych        *
; Enable - 40H, RS - A0, R/W - A1, DATA D0 .. D7 Z80    *
;********************************************************
;     Wykorzysta≥em fagmenty kodu kolegi @Nadolic       *
;                     (C) Zegar                         *
;********************************************************
;******************************************************** 
; Podstawowe instr. ustawiajace LCD
; 38-sterowanie 8-bit, 1-CLR LCD, 6- przesuw kursora na prawo
; E-kursor na dole i wlacz LCD
;********************************************************        
  .or 4E00h
LCD_INIT:
  ld a, 30h         ; patrz nota katalogowa
  out (LCD_IR),a
  halt              ; wait for MORE then 4,1 ms
  halt              ; NIE WOLNO SPRAWDZA∆ BUSY!
  halt              ; Czekaj ok. 3*2 ms do nastÍpnego NMI    
  ld a, 30h
  out (LCD_IR),a
  call DEL_100US    ; wait for MORE then 100 us
  call DEL_100US
  ld a, 30h
  out (LCD_IR),a
  call DEL_100US
  ld a, 38h         ; sterowanie 8-bit
  out (LCD_IR),a
  call LCD_CLR      ; A tutaj juø nam wszystko wolno
  ld a, 0Eh         ; kursor na dole i wlacz LCD
  call LCD_COMM
  ld a, 6           ; przesuw kursora w prawo
  call LCD_COMM
  ret               ; koniec LCD_INIT
  
;******************************************************** 
; Wyswietl tekst wg (hl), koniec tekstu 0FFh       
;******************************************************** 
LCD_PRINT:  
  ld b,20          ; max liczba znakow (gdy brak 0FFh)
.wys_t2
  ld a,(hl)         ; pobierz znak
  cp EOM
  RET Z             ; czy koniec?
  CALL LCD_A
  inc hl
  djnz .wys_t2
.wys2
  ret
;********************************************************
; Czekaj 0.1 ms
;********************************************************   
DEL_100US:
  ld a, 30h ; dla CLK 4MHz
.op2
  dec a
  jr nz,.op2
  ret
;********************************************************
; Czekaj na gotowoúÊ LCD
;********************************************************   
busy:
    push af
    PUSH BC
    LD B,0
.busy1    
    in a,(LCD_BUSY)
    and 80h
    JR Z,.FREE
    djnz .busy1         ; zabezpieczenie przed zawieszeniem
.FREE:
    POP BC
    pop af
    ret
;******************************************************** 
; Wyúlij rozkaz (command) do LCD
;********************************************************    
LCD_COMM:
  call busy           
  out (LCD_IR),a
  RET
;********************************************************
; CzyúÊ LCD i ustaw kursor na pozycji poczatkowej LCD
;********************************************************
LCD_CLR: 
  ld a, 1
  call LCD_COMM
;********************************************************
; Ustaw kursor na poczatek LCD            
;********************************************************
LCD_home: 
  ld a, L1            ; 1. linia
  call LCD_COMM           
  ret
;********************************************************
; Wyswietl zaw. rej A na LCD, wg aktualnego stanu LCD
;********************************************************
LCD_BYTE: 
  push hl                        
  call BYTE_TO_ASCII
  ld a, H
  CALL LCD_A          ; bez ustawiania pozycji kursora
  ld a, L
  CALL LCD_A          ; bez ustawiania pozycji kursora
  pop hl
  ret
  
;********************************************************
; Wyswietl zaw. rej HL na LCD, wg aktualnego stanu LCD
;********************************************************
LCD_WORD:  
  ld a, H
  CALL LCD_BYTE          ; bez ustawiania pozycji kursora
  ld a, L
  CALL LCD_BYTE          ; bez ustawiania pozycji kursora
  ret
  
;********************************************************
; Podziel rej. A na dwa znaki i zwrÛÊ je w HL
;********************************************************
BYTE_TO_ASCII: 
  PUSH AF
  AND 0F0H  ; usun mlodsze bity
  RRCA      ; przesuÒ w prawo
  RRCA
  RRCA
  RRCA
  CALL HEXtoASCII 
  LD H, A
  POP AF
  AND 0FH ; usun starsze bity
  CALL HEXtoASCII
  LD L, A
  RET
;********************************************************
; Ustaw kursor. B - wiersz, C - kolumna
;********************************************************  
LCD_SET_CURSOR:       ; 
  ld a, B             ; NR WIERSZA 0-3
  CALL LCD_ROW_ADR
  LD A,C              ; NR KOLUMNY 0-19
  CP 14H
  JR C,COL_OK
  XOR A               ; ZACZNIJ OD ZERA
COL_OK:  
  ADD A,B
  call LCD_COMM           
  ; CALL busy_TEST             
  ret
;********************************************************
; Oblicz adres poczπtku linii nr w A (0-3)
; Zwraca adres linii w B (jeden bajt)
;********************************************************  
LCD_ROW_ADR:
  push HL
  AND 3               ; Dla pewnoúci
  ld HL,NUM_LINII
  add A,L
  ld L,A
  ld B,(HL)
  pop HL
  RET
;********************************************************
; Wyúwietl czas systemowy CA80 na LCD
;********************************************************    
czas_LCD:
  ld HL,GODZ
  ld A,(HL)
  call LCD_BYTE
  call dwukropek
  dec HL
  ld A,(HL)
  call LCD_BYTE
  call dwukropek
  dec HL              ; w HL SEK ;)
  ld A,(HL)
  call LCD_BYTE
  ret
;********************************************************
; Wyúwietl spacjÍ (np. kasowanie fragmentu LCD)
;********************************************************    
SPACJA:
  LD A," "
  JR LCD_A
;********************************************************
; Wyúwietl separator zegara
;********************************************************  
dwukropek:
  ld a, ":"             ;dwukropek
;********************************************************
; Wyúwietl jeden znak ASCII na LCD (w A kod znaku)
;********************************************************  
LCD_A:  
  call busy
  out (LCD_WDR),a
  ret
;********************************************************
; Kasuj jednπ liniÍ LCD
;********************************************************       
LCD_1L_CLR:             ; W A numer linii do skasowania (0 - 3)
  CALL LCD_ROW_ADR      ; ZWRACA W B ADRES LINII
  LD A,B
  CALL LCD_COMM
  ld b,14h              ; 20 znakÛw w linii
.CLR1:  
  CALL SPACJA
  djnz .CLR1
  ret
;********************************************************
; ZamieÒ cyfrÍ HEX na ASCII (do wyswietlania na LCD)
;********************************************************    
HEXtoASCII: 
  CP 0AH                ; litera czy cyfra?
  SBC A,69H 
  DAA                   ;Taki trick znalazlem w sieci :D
  RET                   
;********************************************************
; --------teksty do testu
;********************************************************  
MES1:
 .db  "HELLO WORLD!"
 .db EOM
MES2:
 .db "FROM CA80."
 .db EOM
TEXT_BUSY:
  .db "Busy: "
  .db EOM

   ;################################################
   ;##   po ostatnim bajcie naszego programu wpisujemy 2 x AAAA
   ;.db 0AAh, 0AAh, 0AAh, 0AAh ; po tym markerze /2x AAAA/ nazwa programu
   ;################################################
 .db 0AAh, 0AAh, 0AAh, 0AAh ; marker nazwy
 .db "CA80_FLASH2_demo"       ; nazwa programu, max 16 znakÛw /dla LCD 4x 20 znakow w linii/
 .db 255                ; koniec tekstu

; koniec zabawy. :-)

              