# Program bootloadera rozszerzony o funkcje emulatora.
[YouTube](https://youtu.be/CPxt6IMGpsw)
- Wersja próbna, niepełna i wymagająca wielu godzin pracy.
- W czasie rozruchu:
    - inicjuje generator CLK,
    - ładuje "system operacyjny" i pliki użytkownika,
    - ustawia zegar systemowy,
    - przeprowadza RESET procesora,
    - inicjuje generator NMI,
- Po rozruchu:
    - emuluje klawiaturę (wejście przez UART),
    - emuluje UART,
    - po przełączeniu zworki na CA80 SYS I/O w pozycję MIKSID/RTS udaje MIKSID,
    - wysyła kody klawiszy na złącze ZK
    - na monitorze (przez UART) wyświetla aktualny stan rejestrów użytkownika,
    - klawisz "L" powoduje wygenerowanie listingu (deasemblację) od aktualnego PC
## Wymagania.
- Testowany na CA80 mini oraz CA180.
- Na CA180 nie działa prawidłowo praca krokowa (należy zmienić ustawienia CTC).
- Nie sprawdzany na RC2014.
## Pliki dla CA80
- Zawartość folderu SD-MIKSID należy skopiować na kartę microSD o możliwie małej pojemności.
