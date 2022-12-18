# CA80 na platformie RC2014
![CA80](https://raw.githubusercontent.com/ZegarNotAvailable/CA80-na-RC2014/main/CA80-RC2014.jpg)
- Postanowiłem opracować nową wersję wykorzystując zalety starego CA80 - modułowość i nowego - uproszczona klawiatura.
- Szczegółowy opis projektu jest na blogu [KlonCA80](https://klonca80.blogspot.com).
- [YouTube](https://youtu.be/DX81GWKvyLs).
### Podział oryginalnej konstrukcji na mniejsze moduły.
- Płyta główna została podzielona na dwa moduły: CPU + RAM + ROM (można go zastąpić np. [sc108](https://smallcomputercentral.com/sc108-z80-processor-rc2014/) lub [tapy](http://www.vtsys.pl/moduly-rc2014/z80-cpu-64kb-ram/)) oraz SYSTEM I/O.
- MIK89 jest prawie nie zmieniony. Dodałem licznik umożliwiający uzyskanie sygnału NMI z Z80 CTC.
- MIK1 - UART na i8251.
- Płyty bazowej nie projektuję, bo można wybrać z gotowych np. [sc112](https://smallcomputercentral.com/sc112-modular-backplane-rc2014/) lub [tapy](http://www.vtsys.pl/moduly-rc2014/basic-backplane-4/).
### Dodatkowe moduły rozszerzające możliwości i ułatwiające pracę.
- LCD umożliwiający wyświtlenie większej liczby danych.
- CAFL emulator magnetofonu - pamięć masowa.
- Bootloader oparty o AVR. Pomysł zapożyczony z projektu [Z80-MBC2](https://hackaday.io/project/159973-z80-mbc2-a-4-ics-homebrew-z80-computer).
### Wykorzystanie kalkulatora ELWRO144 jako terminala - zintegrowanej klawiatury z wyświetlaczem.
![ELWRO144](https://raw.githubusercontent.com/ZegarNotAvailable/CA80-na-RC2014/main/CA80-ELWRO144.jpg)
- Płytka klawiatury z gumowymi switchami.
- Płytka wyświetlacza VFD pełniąca jednocześnie funkcję złącza z komputerem za pomocą taśmy IDC.
## Projekty modułów.
### CPU
### Sys I/O
### MIK89
### MIK1
## Moduły dodatkowe
### CAFL
### LCD
### Bootloader