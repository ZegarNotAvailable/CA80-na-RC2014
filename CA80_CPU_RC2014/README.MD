# Moduł procesora.
- Umożliwia użycie 64 kB RAM.
- Przestrzeń adresowa jest podzielona na cztery bloki po 16 kB.
- Za pomocą zworek na J3 możemy wyłączyć dwa z bloków "00", "40" lub "80", które odpowiadają podstawkom U9, U10 i U11.
- Za pomocą J2 możemy "wyłączone" obszary podpiąć do EEPROM na tej płytce lub wykorzystać w innym module.
- J5 to punkty lutownicze opisane w MIK05 str 189. i MIK09 str. 35. i 53.
- Można też ustawić auto-reset lub wykorzystać zewnętrzny.