# Modu³ CA80-boot.
![Boot](https://raw.githubusercontent.com/ZegarNotAvailable/CA80-na-RC2014/main/CA80-boot-RC2014/CA80_boot_RC2014.png)
- Zastêpuje EPROM.
- Generuje sygna³y CLK RESET oraz NMI.
- W czasie rozruchu wpisuje z karty SD do RAM system operacyjny (np. monitor CA80) oraz inne oprogramowanie z plików *.hex wyszczególnionych w pliku CA80.TXT 
- Ustawia zegar systemowy CA80 (z modu³u DS3231).
- Po RESET mo¿e pe³niæ ró¿ne funkcje takie jak:
    - interfejs UART,
    - emulator klawiatury sterowany przez UART lub klawiaturê dotykow¹ (MPR121),
    - debuger wzorowany na MIKSID,
    - i inne o których zapomnia³em lub jeszcze ich nie wymyœli³em.
- ![Góra](https://raw.githubusercontent.com/ZegarNotAvailable/CA80-na-RC2014/main/CA80-boot-RC2014/CA80-boot-a.png)
- U1, U2 i U3 pe³ni¹ funkcjê emulatora klawiatury - mo¿na ich nie montowaæ (wtedy IDC26 równie¿ niepotrzebny).
- Z³¹cze "Serial" jest zgodne z Z80 MBC-2. Mo¿na je u¿yæ do programowania AVR (Arduino IDE) lub pod³¹czyæ terminal (np. uTerm).
- ![Spód](https://raw.githubusercontent.com/ZegarNotAvailable/CA80-na-RC2014/main/CA80-boot-RC2014/CA80-boot-b.png)
- Z³¹cza modu³ów SD i RTC nie zmieœci³y siê do góry - przepraszam.
## UWAGA!!
### Nale¿y zwróciæ uwagê na sygna³ MEM_EN.
- Projekt jest wzorowany na Z80-MBC2, wiêc s¹ te¿ tego konsekwencje.
- MEM_EN jest odpowiednikiem RAM_CE2. W pierwowzorze by³a tylko jedna koœæ RAM, a w RC2014 mo¿e wyst¹piæ kilka modu³ów z jak¹œ pamiêci¹, wiêc do ka¿dego musi ten sygna³ dotrzeæ.
- Wybra³em PIN 40 (USER4), poniewa¿ nie wystêpuje on w oryginalnym RC, ¿eby zminimalizowaæ ryzyko konfliktu z innym modu³em.
- Nie wiedzia³em, ¿e p³yty bazowe (backplane) np. SC112, maj¹ po³¹czenia s¹siednich gniazd 40 - 80. By³ to pierwszy pomys³ na "daisy chain" (wianek ze stokrotek) IEI - IEO.
- Z tego powodu mo¿e dojœæ do przerwy w sygnale MEM_EN. 
### Modu³y zawieraj¹ce pamiêæ i CA80-boot powinny mieæ zwarte piny USER4 i USER8 (40 i 80) oraz znajdowaæ siê w s¹siednich gniazdach!!!
- Mo¿na równie¿ po³¹czyæ w/w piny pod backplane.