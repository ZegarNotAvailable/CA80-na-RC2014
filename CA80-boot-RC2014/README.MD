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