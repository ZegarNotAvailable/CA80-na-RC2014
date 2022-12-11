# Przykłady programów do nauki używania "magnetofonu".
- Wszystkie były wykorzystane w filmie [YouTube](https://youtu.be/FDMQDgoEjF4)
- Napisane są dla [sbasm](https://www.sbprojects.net/sbasm/download.php)
- Można wprowadzić je z pliku *.hex za pomocą bootloadera lub innego sprzętu (kilka skonstruowałem) lub ręcznie z klawiatury (patrz plik *.lst).
## Magnetofon_demo.
- Krótki program wczytujący z "magnetofonu" inne programy.
    - Można go zapisać w dowolnym sektorze (pod dowolną nazwą).
    - Wywołuje kolejno w pętli programy o nazwach 7D, 7E i FE.
## Buon_giorno.
- Wypisuje na wyświetlaczu CA80 "buon giorno".
- Należy go zapisać w sektorze 7E z nazwą 7E.
## CA80_bonjour.
- Należy go zapisać w sektorze 7E z nazwą FE.
## Nie_ardu.
- Animacja mam nadzieję zabawna.
- Należy go zapisać w sektorze 7D z nazwą 7D.
## Programy używane w przykładach muszą spełniać kilka warunków:
- Program wywoływany musi być w innym obszarze pamięci, niż wywołujący (unikać nadpisania).
- Program wywoływany musi być zapamiętany z EOF - rekordem zawierającym adres wejścia do programu.
- Program wywoływany musi być zakończony rozkazem RET.
- Program wywoływany nie może zmieniać wskaźnika stosu (LD SP,nnnn)
## Życzę dobrej zabawy.