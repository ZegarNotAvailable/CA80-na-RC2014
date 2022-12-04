#      INSTRUKCJA OBS�UGI PROGRAMU CAFL DO PRZYSTAWKI CA80-FLASH ZAST�PUJ�CEJ KLASYCZNY MAGNETOFON.
###     Polecenie Z1:     - Szukaj wolny sektor
         [1][NR SEKTORA][=]  SZUKAJ OD SEKTORA O PODANYM NR
         [1][=]              SZUKAJ OD SEKTORA NR 0
         SST39SF040 ma 128 sektor�w 0 - 7F.
         80 - FF odwo�uj� si� do tych samych sektor�w,
         jednak jest to istotne przy odczycie program�w.
         Je�eli numer sektora r�ni si� od nazwy programu,
         odczyt si� nie powiedzie.
###     Polecenie Z2:     -  Kasuj sektor 
        [2][NR SEKTORA][=]
         Je�eli wpiszemy nr sektora FF - 
         ZOSTAN� SKASOWANE WSZYSTKIE NIEZAPISANE SEKTORY.
         W nowym, lub u�ywanym do innych cel�w SST39SF040
         sektory mog� zawiera� przypadkowe warto�ci,
         wi�c nale�y ko�� "sformatowa�".
         Mo�liwe jest kasowanie wszystkich sektor�w jednocze�nie,
         lecz kasowanie pojedynczych sektor�w jest bezpieczniejsze dla danych. 
         (zapisywanie program�w jest czasoch�onne)
###     Polecenie Z3:     - INICJUJ bufor (wy�wietl bufor)
         [3][NR SEKTORA][=]  PRZEPISZ SEKTOR O PODANYM NR DO BUFORA
         UMO�LIWIA EDYCJ� SEKTORA. NP. DOPISANIE NAZW
         LUB WGRANIE DRUGIEGO PROGRAMU, JE�ELI BY� JEDEN
         [3][=]              WY�WIETL ZAWARTO�� BUFORA BEZ ZMIAN
         Nale�y konsekwentnie u�ywa� nazw program�w zgodnych z 
         numerem sektora!!! Np. sektor nr 7A - program 7A i/lub FA
###     Polecenie Z4:     - Zapisz RAM do bufora
         [4][ADR1][.][ADR2][.][NAZWA][=]
         Nale�y konsekwentnie u�ywa� nazw program�w zgodnych z 
         numerem sektora!!! Np. sektor nr 7A - program 7A i/lub FA
###     Polecenie Z5:     - Zapisz EOF do bufora
         [5][ADR.WEJ.][.][NAZWA][=]
         Nazwa jak w Z3 i Z4.
###     Polecenie Z6:     - Czytaj sektor (program) do RAM
         [6][NR SEKTORA][=]
         Je�eli sektor zawiera dwa programy,
         decyduje najstarszy bit nazwy.
###     Polecenie Z7:     - Zapisz bufor do sektora
         [7][=]
###     Polecenie Z8:     - Jeszcze brak
###     Polecenie Z9:     - Jeszcze brak  
###     Polecenie ZA:     - Wyslij sektor przez wyj�cie magnetofonowe
         [A][NR SEKTORA][=]
         Zawartosc sektora zostanie wyslana tak, jak jest.
         Je�eli dane s� poprawne, na wy�wietlaczu nazwa i adres bloku.
         Nale�y wysy�a� tylko zapisane sektory.
###     Polecenie ZB:     - Ustaw 3,5 kHz na wy. magnet.
        ; Naci�ni�cie klawsza wychodzi ze zlecenia i wy��cza d�wi�k.
##        PROGRAM KOPIOWANIA DANYCH DO EEPROM (NP. KM28C64A) DLA CA80
###     Polecenie ZC:     - Kopiuj dane do EEPROM np MK28C64 W U11 (8000 - 9FFF)
         Przed zapisem nalezy zdjac SDP
         [C][ADR. POCZ][.][ADR. KONCA][.][ADR. PRZEZNACZENIA][=]
###     Polecenie ZD:     - Odblokuj SDP (disable_SDP)
###     Polecenie ZE:     - Ustaw Software Data Protection (enable_SDP)
###     Polecenie ZF:     - Szukaj nazw program�w.
         [F][NR SEKTORA][=]  SZUKAJ NAZW PROGRAM�W OD SEKTORA NR...
         WY�WIETL "ludzkie" NAZWY PROGRAM�W I ICH NUMERY
         [F][=]              SZUKAJ NAZW PROGRAM�W OD SEKTORA "00"
         LCD wy�wietla informacje o czterech znalezionych programach.
         [=] Szukaj nast�pnych.
         [NR PROGRAMU] Wczytaj program o wpisanym numerze.
