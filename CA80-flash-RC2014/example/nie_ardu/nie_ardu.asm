;*********************************************************************
;                 Demo "magnetofonu" CA80.
;                   (C) Zegar & Nadolic
;*********************************************************************

        .cr z80                     
        .tf nie_ardu.hex,int   
        .lf nie_ardu.lst
        .sf nie_ardu.sym       
        .in ca80.inc                
        .sm code                ; 
        .or $c000               ; U12/C000
		;ld  SP,$ff66                ; 
		;
.begin
    call CLR
      .db 80H
.repeat		                      
    ld HL, mess
    call NEWPRINT
		jr NZ,.repeat
        ;

delay:  push    BC
        push    AF
        ld B,A
.delay        
        nop             ; 2ms (bylo HALT)
        halt            ; 2ms
        halt            ; 2ms
        djnz    .delay  ; while( --B )
        pop     AF
        pop     BC
        ret
        
NEWPRINT:
		; HL adres tabeli znaczków
		; kazdy znak ma trzy parametry: kod 7seg, PWYS, DELAY (razy 6ms)
		; jezeli bit3 PWYS (normalnie zero), to wstawiamy kursor
		; 
		ld IX,APWYS
		ld E,(IX)
		ld D,(IX+1)                 ; nie użyłem Hi i Lo ;-(
		push DE
		pop IX                      ; adres PWYS
loop:		
    ld A,(HL)                   ; wez element tabeli - ZNAK
    cp 0FFH
    ret Z                       ; koniec tabeli znaków
    ld C,A                      ; dla COM1
    inc HL
		ld A,(HL)                   ; wez element tabeli - PWYS
		ld B,A
		and 0F7H                    ; wytnij ewentualny bit3
		ld (IX),A                   ; ustaw PWYS
		bit 3,B
		jr Z,bezKursora
		ld B,C
		ld C,8                      ; dolny segment - kursor
		call COM1                   
		ld C,B
bezKursora:		
		inc HL
		ld A,(HL)                   ; wez element tabeli - DELAY
		or A
		call NZ,delay               ; opóznienie
		call COM1                   ; pokaż znaczek
		inc HL                      ; indeks++
		jr loop
		
mess:
          .db 77H, 17H, 7FH  ;A
          .db 50H, 16H, 30H  ;r
          .db 5EH, 15H, 55H  ;d
          .db 1CH, 14H, 90H  ;u
          .db 04H, 13H, 50H  ;i
          .db 54H, 12H, 70H  ;n
          .db 5CH, 11H, 50H  ;o
          .db 0DCH, 11H, 0C0H ;.
          .db 5CH, 10H, 18H
          .db 7FH, 10H, 18H
          .db 07FH, 11H, 18H
          .db 5CH, 10H, 0H
          .db 5CH, 11H, 18H
          .db 63H, 10H, 18H
          .db 00H, 10H, 18H
          .db 7FH, 11H, 0H
          .db 5CH, 11H, 18H
          .db 77H, 12H, 0H
          .db 5CH, 12H, 18H
          .db 63H, 11H, 18H
          .db 00H, 11H, 18H
          .db 7FH, 12H, 0H
          .db 5CH, 12H, 18H
          .db 67H, 13H, 0H
          .db 5CH, 13H, 18H
          .db 63H, 12H, 18H
          .db 00H, 12H, 18H
          .db 7FH, 13H, 0H
          .db 5CH, 13H, 18H
          .db 7FH, 14H, 0H
          .db 5CH, 14H, 18H
          .db 63H, 13H, 18H
          .db 00H, 13H, 18H
          .db 7FH, 14H, 0H
          .db 5CH, 14H, 18H
          .db 7FH, 15H, 0H
          .db 5CH, 15H, 18H
          .db 63H, 14H, 18H
          .db 00H, 14H, 18H
          .db 7FH, 15H, 0H
          .db 5CH, 15H, 18H
          .db 73H, 16H, 0H
          .db 5CH, 16H, 18H
          .db 63H, 15H, 18H
          .db 00H, 15H, 18H
          .db 7FH, 16H, 0H
          .db 5CH, 16H, 18H
          .db 77H, 17H, 0H
          .db 5CH, 17H, 18H
          .db 63H, 16H, 18H
          .db 00H, 16H, 18H
          .db 7FH, 17H, 0H
          .db 5CH, 17H, 50H
          .db 00H, 17H, 50H
          .db 8H, 12H, 50H
          .db 54H, 12H, 50H
          .db 8H, 11H, 18H
          .db 5CH, 11H, 50H
          .db 5CH, 17H, 18H
          .db 7FH, 17H, 18H
          .db 5CH, 17H, 18H
          .db 63H, 16H, 0H
          .db 5CH, 16H, 18H
          .db 63H, 17H, 18H
          .db 0H, 17H, 18H
          .db 7FH, 16H, 0H
          .db 5CH, 16H, 18H
          .db 63H, 15H, 0H
          .db 5CH, 15H, 18H
          .db 63H, 16H, 18H
          .db 0H, 16H, 18H          
          .db 7FH, 15H, 18H
          .db 5CH, 15H, 18H
          .db 63H, 14H, 0H
          .db 5CH, 14H, 18H          
          .db 63H, 15H, 18H
          .db 00H, 15H, 18H
          .db 7FH, 14H, 0H
          .db 5CH, 14H, 18H
          .db 63H, 13H, 0H
          .db 5CH, 13H, 18H
          .db 63H, 14H, 18H
          .db 00H, 14H, 18H
          .db 7FH, 13H, 0H
          .db 5CH, 13H, 18H
          .db 77H, 12H, 0H
          .db 5CH, 12H, 18H
          .db 63H, 13H, 18H
          .db 00H, 13H, 18H
          .db 7FH, 12H, 0H
          .db 5CH, 12H, 18H
          .db 7FH, 11H, 0H
          .db 5CH, 11H, 18H
          .db 63H, 12H, 18H
          .db 00H, 12H, 18H
          .db 7FH, 11H, 0H
          .db 5CH, 11H, 18H
          .db 63H, 10H, 0H
          .db 5CH, 10H, 18H
          .db 63H, 10H, 18H
          .db 00H, 10H, 18H
          .db 7FH, 11H, 0H
          .db 5CH, 11H, 18H
          .db 63H, 12H, 0H
          .db 5CH, 12H, 18H
          .db 63H, 12H, 18H
          .db 00H, 12H, 18H
          .db 7FH, 11H, 0H
          .db 5CH, 11H, 18H
          .db 63H, 10H, 0H
          .db 5CH, 10H, 18H
          .db 63H, 10H, 18H
          .db 00H, 11H, 18H
          .db 7FH, 10H, 0H
          .db 5CH, 10H, 18H
          .db 00H, 10H, 18H
          .db EOM        
          ;
   ;################################################
   ;##   po ostatnim bajcie naszego programu wpisujemy 2 x AAAA
   ;.db 0AAh, 0AAh, 0AAh, 0AAh ; po tym markerze /2x AAAA/ nazwa programu
   ;################################################
 .db 0AAh, 0AAh, 0AAh, 0AAh ; marker nazwy
 .db "To nie Arduino!"       ; nazwa programu, max 16 znaków /dla LCD 4x 20 znakow w linii/
 .db EOM                    ; koniec tekstu
