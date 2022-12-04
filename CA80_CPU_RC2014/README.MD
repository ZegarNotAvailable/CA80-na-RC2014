# Moduł procesora.
![CPU](https://github.com/ZegarNotAvailable/CA80-na-RC2014/blob/main/CA80_CPU_RC2014/CA80_CPU_RC2014_2022-09-03.png)
- Umożliwia użycie 64 kB RAM.
- Przestrzeń adresowa jest podzielona na cztery bloki po 16 kB.
- Za pomocą zworek na J3 możemy wyłączyć dwa z bloków "00", "40" lub "80", które odpowiadają podstawkom U9, U10 i U11.
- Za pomocą J2 możemy "wyłączone" obszary podpiąć do EEPROM na tej płytce lub wykorzystać w innym module.
- J5 to punkty lutownicze opisane w MIK05 str 189. i MIK09 str. 35. i 53.
- Można też ustawić auto-reset lub wykorzystać zewnętrzny.