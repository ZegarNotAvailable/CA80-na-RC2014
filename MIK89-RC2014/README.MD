# Moduł z portem użytkownika (8255) i Z80CTC.
![MIK89](https://raw.githubusercontent.com/ZegarNotAvailable/CA80-na-RC2014/main/MIK89-RC2014/MIK89_RC2014_PCB.jpg)
- Od oryginalnego różni się:
    - Zamiast złącza systemowego CA80 ZS jest szyna RC2014.
    - Zamiast punktów lutowniczych do podłączenia ZU50 jest ZU64 (zgodne z drugą wersją CA80).
    - Dodano dekoder adresów z możliwością wybrania trzech (zworką). Dzięki temu można użyć dodatkowy port.
    - Dodano licznik 7493, aby uzyskać sygnał NMI z CTC (opis MIK05 str. 2). Jeżeli mamy inne źródło tego sygnału, po prostu go nie montujemy.