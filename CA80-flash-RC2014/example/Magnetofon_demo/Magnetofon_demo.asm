;*********************************************************************
;                 Demo "magnetofonu" CA80.
;
; FORMAT "PLIKOW" ZGODNY Z UZYWANYM W ZLECENIACH *4 *5 *6 CA80
;       NUMER SEKTORA JEST ODPOWIEDNIKIEM NAZWY PROGRAMU.
; PROCEDURA FMAG dziala jak OMAG (MIK08 REJESTR B=NR SEKTORA) 
;                   (C) Zegar & Nadolic
;*********************************************************************

        .cr z80                     
        .tf Magnetofon_demo.hex,int   
        .lf Magnetofon_demo.lst
        .sf Magnetofon_demo.sym       
        .sm code           ; 
        .or 0D000H
;Demo Flash
EOM     .eq 0FFH      ; Koniec komunikatu
FMAG    .eq 4337H     ; Adres nale¿y sprawdziæ w pliku CA80_Flash*.lst
        ld SP,0FF66H
.loop
        ld B,7EH      ;Numer sektora
        call FMAG
        ld B,0FEH     ;Numer sektora
        call FMAG
        ld B,7DH      ;Numer sektora
        call FMAG
        jr .loop
   ;################################################
   ;##   po ostatnim bajcie naszego programu wpisujemy 2 x AAAA
   ;.db 0AAh, 0AAh, 0AAh, 0AAh ; po tym markerze /2x AAAA/ nazwa programu
   ;################################################
 .db 0AAh, 0AAh, 0AAh, 0AAh ; marker nazwy
 .db "Magnetofon-demo"       ; nazwa programu, max 16 znaków /dla LCD 4x 20 znakow w linii/
 .db EOM                    ; koniec tekstu
