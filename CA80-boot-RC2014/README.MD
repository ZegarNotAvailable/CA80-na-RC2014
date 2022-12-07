# Modu� CA80-boot.
![Boot](https://raw.githubusercontent.com/ZegarNotAvailable/CA80-na-RC2014/main/CA80-boot-RC2014/CA80_boot_RC2014.png)
- Zast�puje EPROM.
- Generuje sygna�y CLK RESET oraz NMI.
- W czasie rozruchu wpisuje z karty SD do RAM system operacyjny (np. monitor CA80) oraz inne oprogramowanie z plik�w *.hex wyszczeg�lnionych w pliku CA80.TXT 
- Ustawia zegar systemowy CA80 (z modu�u DS3231).
- Po RESET mo�e pe�ni� r�ne funkcje takie jak:
    - interfejs UART,
    - emulator klawiatury sterowany przez UART lub klawiatur� dotykow� (MPR121),
    - debuger wzorowany na MIKSID,
    - i inne o kt�rych zapomnia�em lub jeszcze ich nie wymy�li�em.
- ![G�ra](https://raw.githubusercontent.com/ZegarNotAvailable/CA80-na-RC2014/main/CA80-boot-RC2014/CA80-boot-a.png)
- U1, U2 i U3 pe�ni� funkcj� emulatora klawiatury - mo�na ich nie montowa� (wtedy IDC26 r�wnie� niepotrzebny).
- Z��cze "Serial" jest zgodne z Z80 MBC-2. Mo�na je u�y� do programowania AVR (Arduino IDE) lub pod��czy� terminal (np. uTerm).
- ![Sp�d](https://raw.githubusercontent.com/ZegarNotAvailable/CA80-na-RC2014/main/CA80-boot-RC2014/CA80-boot-b.png)
- Z��cza modu��w SD i RTC nie zmie�ci�y si� do g�ry - przepraszam.