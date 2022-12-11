;*********************************************************************
;                 Demo "magnetofonu" CA80.
;                   (C) Zegar & Nadolic
;*********************************************************************
        .cr z80                     
        .tf CA80_bonjour.hex,int   
        .lf CA80_bonjour.lst
        .sf CA80_bonjour.sym       
        .in ca80.inc                
        .sm code                ; 
        .or $c000               ; U12/C000
		;ld  SP,$ff66                ; 
		;
.begin
    call CLR
      .db 80H
.repeat		                      ; while (--licznik)
		ld B,bonjourEnd-bonjour     ; B-licznik elementów tabeli
		ld IX,bonjour               ; adres tabeli znaczków
		ld HL,APWYS
		ld E,(HL)
		inc HL
		ld D,(HL)
		ex DE,HL
.loop2		
		ld C,(IX+10H)               ; wez element tabeli - PWYS
		ld (HL),C                   ; ustaw PWYS
		ld C,08H                    ; kod dolnego segmentu - kursor
		call COM1                   ; pokaż znaczek
    ld C,(IX+2*10H)             ; wez element tabeli - DELAY
		call delay                  ; opóznienie
		ld C,(IX+0)                 ; wez element tabeli - ZNAK
		call COM1                   ; pokaż znaczek
		inc IX                      ; indeks++
		djnz .loop2                 ; while (--licznik)
		ret                         ; USUŃ ŻEBY ZAPĘTLIĆ
		jr .repeat
        ;

bonjour:
        .db 7CH, 5CH, 54H, 0EH, 63H, 62H, 21H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H
bonjourEnd:
        .db 17H, 16H, 15H, 14H, 13H, 12H, 11H, 10H, 17H, 16H, 15H, 14H, 13H, 12H, 11H, 10H
        .db 50H, 30H, 60H, 20H, 35H, 45H, 50H, 7FH, 35H, 45H, 50H, 7FH, 35H, 45H, 50H, 7FH
          ;
delay:  push    BC
        push    AF
        ld      B,C
.delay        
        halt            ; 2ms
        halt            ; 2ms
        halt            ; 2ms
        djnz    .delay  ; while( --B )
        pop     AF
        pop     BC
        ret
   ;################################################
   ;##   po ostatnim bajcie naszego programu wpisujemy 2 x AAAA
   ;.db 0AAh, 0AAh, 0AAh, 0AAh ; po tym markerze /2x AAAA/ nazwa programu
   ;################################################
 .db 0AAh, 0AAh, 0AAh, 0AAh     ; marker nazwy
 .db "Bonjour"                  ; nazwa programu, max 16 znaków /dla LCD 4x 20 znakow w linii/
 .db EOM                        ; koniec tekstu

; koniec zabawy. :-)
        