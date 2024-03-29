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
## UWAGA!!
### Nale�y zwr�ci� uwag� na sygna� MEM_EN.
- Projekt jest wzorowany na Z80-MBC2, wi�c s� te� tego konsekwencje.
- MEM_EN jest odpowiednikiem RAM_CE2. W pierwowzorze by�a tylko jedna ko�� RAM, a w RC2014 mo�e wyst�pi� kilka modu��w z jak�� pami�ci�, wi�c do ka�dego musi ten sygna� dotrze�.
- Wybra�em PIN 40 (USER4), poniewa� nie wyst�puje on w oryginalnym RC, �eby zminimalizowa� ryzyko konfliktu z innym modu�em.
- Nie wiedzia�em, �e p�yty bazowe (backplane) np. SC112, maj� po��czenia s�siednich gniazd 40 - 80. By� to pierwszy pomys� na "daisy chain" (wianek ze stokrotek) IEI - IEO.
- Z tego powodu mo�e doj�� do przerwy w sygnale MEM_EN. 
### Modu�y zawieraj�ce pami�� i CA80-boot powinny mie� zwarte piny USER4 i USER8 (40 i 80) oraz znajdowa� si� w s�siednich gniazdach!!!
- Mo�na r�wnie� po��czy� w/w piny pod backplane.