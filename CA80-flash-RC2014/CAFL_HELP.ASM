;*********************************************************************
        ; INSTRUKCJA OBS£UGI PROGRAMU CAFL
        ; DO PRZYSTAWKI CA80 - FLASH
        ; ZASTÊPUJ¥CEJ KLASYCZNY MAGNETOFON.
;*********************************************************************
Z1:     ; Szukaj wolny sektor
        ; [1][NR SEKTORA][=]  SZUKAJ OD SEKTORA O PODANYM NR
        ; [1][=]              SZUKAJ OD SEKTORA NR 0
        ; SST39SF040 ma 128 sektorów 0 - 7F
        ; 80 - FF odwo³uj¹ siê do tych samych sektorów,
        ; jednak jest to istotne przy odczycie programów.
        ; Je¿eli numer sektora ró¿ni siê od nazwy programu,
        ; odczyt siê nie powiedzie.
;*********************************************************************        
Z2:     ; Kasuj sektor [2][NR SEKTORA][=]
        ; Je¿eli wpiszemy nr sektora FF - 
        ; ZOSTAN¥ SKASOWANE WSZYSTKIE NIEZAPISANE SEKTORY.
        ; W nowym, lub u¿ywanym do innych celów SST39SF040
        ; sektory mog¹ zawieraæ przypadkowe wartoœci,
        ; wiêc nale¿y koœæ "sformatowaæ".
        ; Mo¿liwe jest kasowanie wszystkich sektorów jednoczeœnie,
        ; jednak kasowanie pojedynczych sektorów 
        ; jest bezpieczniejsze dla danych. 
        ; ( zapisywanie programów jest czasoch³onne)
;*********************************************************************
Z3:     ; INICJUJ bufor (wyœwietl bufor)
        ; [3][NR SEKTORA][=]  PRZEPISZ SEKTOR O PODANYM NR DO BUFORA
        ; UMO¯LIWIA EDYCJÊ SEKTORA. NP. DOPISANIE NAZW
        ; LUB WGRANIE DRUGIEGO PROGRAMU, JE¯ELI BY£ JEDEN
        ; [3][=]              WYŒWIETL ZAWARTOŒÆ BUFORA BEZ ZMIAN
        ; Nale¿y konsekwentnie u¿ywaæ nazw programów zgodnych z 
        ; numerem sektora!!! Np. sektor nr 7A - program 7A i/lub FA
;*********************************************************************
Z4:     ; Zapisz RAM do bufora
        ; [4][ADR1[.][ADR2][.][NAZWA][=]
        ; Nale¿y konsekwentnie u¿ywaæ nazw programów zgodnych z 
        ; numerem sektora!!! Np. sektor nr 7A - program 7A i/lub FA
;*********************************************************************        
Z5:     ; Zapisz EOF do bufora
        ; [5][ADR.WEJ.][.][NAZWA][=]
        ; Nazwa jak w Z3 i Z4.
;*********************************************************************        
Z6:     ; Czytaj sektor (program) do RAM
        ; [6][NR SEKTORA][=]
        ; Je¿eli sektor zawiera dwa programy,
        ; decyduje najstarszy bit nazwy.
;*********************************************************************        
Z7:     ; Zapisz bufor do sektora
        ; [7][=]
;*********************************************************************
Z8:
;*********************************************************************
Z9:
;*********************************************************************
ZA:     ; Wyslij sektor przez wy. magnet.
        ; [A][NR SEKTORA][=]
        ; Zawartosc sektora zostanie wyslana tak, jak jest.
        ; Jezeli dane poprawne, na wysw. nazwa i adres bloku
        ; Nalezy wysylac tylko zapisane sektory.
;*********************************************************************
ZB:     ; Ustaw 3,5 kHz na wy. magnet.
        ; Naciœniêcie klawsza wychodzi ze zlecenia i wy³¹cza dŸwiêk.
;*********************************************************************        
        ; PROGRAM KOPIOWANIA DANYCH DO EEPROM (NP. KM28C64A) DLA CA80
;*********************************************************************        
ZC:     ; Kopiuj dane do EEPROM np MK28C64 W U11 (8000 - 9FFF)
        ; Przed zapisem nalezy zdjac SDP
        ; [C][ADR. POCZ][.][ADR. KONCA][.][ADR. PRZEZNACZENIA][=]
;*********************************************************************
ZD:     ; Odblokuj SDP (disable_SDP)
;*********************************************************************        
ZE:     ; Ustaw Software Data Protection (enable_SDP)
;*********************************************************************
ZF:     ; Szukaj nazw programów.
        ; [F][NR SEKTORA][=]  SZUKAJ NAZW PROGRAMÓW OD SEKTORA NR...
        ; WYŒWIETL "ludzkie" NAZWY PROGRAMÓW I ICH NUMERY
        ; [F][=]              SZUKAJ NAZW PROGRAMÓW OD SEKTORA "00"
