			
USER8255	.eq		$E0
PA		    .eq		0
PB		    .eq		1
PC		    .eq		2
CTRL		  .eq		3

EME8      .eq   $E8
      ;
      ;LICZNIKI PROGRAMOWE
      ;
LCI:      .eq $FFE8
SYG:      .eq $FFE9      
TIME:     .eq $FFEA             ; Licznik binarny %256 (liczy w dó³) co 2 ms
      ;
      ;ZEGAR CZASU RZECZYWISTEGO
      ;
MSEK:     .eq $FFEB             ; <0, 4>
SETSEK:   .eq $FFEC             ; <0, 99> setne sekundy
SEK:      .eq $FFED             ; <0, 59> sekundy
MIN:      .eq $FFEE             ; <0, 59> minuty
GODZ:     .eq $FFEF             ; <0, 23> godziny
DNITYG:   .eq $FFF0             ; <7, 6, 5, 4, 3, 2, 1>
DNIM:     .eq $FFF1             ; <1 ... > dni miesi¹ca
MIES:     .eq $FFF2             ; <1, 12> miesi¹ce
LATA:     .eq $FFF3             ; <0, 99> rok
      ;
			;	BUFOR WYŒWIETLACZA
      ;
CYF0	    .eq	$FFF7
CYF1	    .eq	$FFF8
CYF2	    .eq	$FFF9
CYF3	    .eq	$FFFA
CYF4	    .eq	$FFFB
CYF5	    .eq	$FFFC
CYF6	    .eq	$FFFD
CYF7	    .eq	$FFFE
      ;
      ; PROCEDURY SYSTEMOWE
      ;
      ; WYŒWIETLACZ
      ;
APWYS     .eq $FFC1 ; wskazuje po³o¿enie parametru wyœwietlacza
PWYS      .eq $FFF6 ; parametr wyœwietlacza      
COM	      .eq	$01AB	; COM - pokazuje znak 7-seg z rejestru C
COM1      .eq $01AC ; COM1 - pokazuje znak 7-seg z rejestru C bez zmiany PWYS
CLR	      .eq	$0010	; CLR - kasowanie wyswietlacza
CLR1      .eq $0011 ; CLR1 - kasowanie wyswietlacza bez zmiany PWYS
PRINT	    .eq	$01D4	; PRINT - drukuje komunikat z (HL)
PRINT1    .eq $01D5 ; PRINT1 - drukuje komunikat z (HL) bez zmiany PWYS
CO        .eq $01E0 ; CO - wyswietlenie cyfry hex
CO1       .eq $01E1 ; CO1 - wyswietlenie cyfry hex bez zmiany PWYS
LBYTE	    .eq	$0018	; LBYTE - wyswietlenie Aku w HEX
LBYTE1    .eq $001B ; LBYTE1 - wyswietlenie Aku w HEX bez zmiany PWYS
LADR      .eq $0020 ; LADR - wyswietlenie HL w HEX
LADR1     .eq $022D ; LADR1 - wyswietlenie HL w HEX bez zmiany PWYS
CZAS	    .eq	$022D	; CZAS - pokazuje czas/date
      ;
      ; KLAWIATURA
      ;
CSTS      .eq $FFC3 ; CSTS - test czy klawisz nacisniety
CI        .eq $FFC6 ; CI - pobranie znaku z klawiatury
      ;
      ; KLAWIATURA I WYŒWIETLACZ 
      ;
TI        .eq $0007 ; TI - pobranie znaku z echem
TI1       .eq $0008 ; TI1 - pobranie znaku z echem bez zmiany PWYS
PARAM     .eq $01F4 ; PARAM - pobranie liczby 16-bit do HL z echem
PARAM1    .eq $01F5 ; PARAM1 - pobranie liczby 16-bit do HL z echem bez zmiany PWYS
PARA1     .eq $01F8 ; PARA1 - pierwsz¹ cyfrê podajemy w akumulatorze a dalej jak PARAM1
EXPR      .eq $0213 ; EXPR - pobranie ciagu liczb 16bit na stos
EXPR1     .eq $0214 ; EXPR1 - pobranie ciagu liczb 16bit na stos bez zmiany PWYS
      ;
      ; POMOCNICZE
      ;      
HILO      .eq $023B ; HILO - iterator, HL++, CY = !(DE >= HL)
SPEC      .eq $00C9 ; RET - dla obs³ugi magnetofonu
      ;          
      ; OBS£UGA MAGNETOFONU
      ;   
ZMAG      .eq $0626 ; zapis na magnetofon
ZEOF      .eq $067B ; zapis rekordu EOF
OMAG      .eq $071B ; odczyt z magnetofonu
MAGSP     .eq $FFB2 ; parametr szybkoœci zapisu
DLUG      .eq $FFB1 ; d³ugoœæ rekordu danych
      
EOM       .eq $FF            

EM        .eq $806
RTS       .eq $803
ELOC      .eq $FF8D
LLOC      .eq $FFA5