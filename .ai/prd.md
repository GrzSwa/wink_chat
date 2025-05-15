# Dokument wymagań produktu (PRD) - WinkChat

## 1. Przegląd produktu

WinkChat to aplikacja mobilna w wersji Minimum Viable Product (MVP) zaprojektowana w celu ułatwienia nawiązywania kontaktów międzyludzkich w oparciu o osobowość i rozmowę, a nie wygląd zewnętrzny. Aplikacja ma na celu przełamanie barier komunikacyjnych, zmniejszenie lęku przed odrzuceniem i walkę z samotnością poprzez umożliwienie anonimowego czatowania z innymi użytkownikami znajdującymi się w pobliżu geograficznym (określonym administracyjnie). Skupia się na prostym, tekstowym przepływie interakcji w celu walidacji kluczowej hipotezy produktowej.

## 2. Problem użytkownika

Projekt WinkChat ma na celu rozwiązanie następujących kluczowych problemów, z jakimi borykają się użytkownicy we współczesnych interakcjach społecznych:

- Trudności w nawiązywaniu nowych kontaktów: Wiele osób, zwłaszcza introwertycznych lub nieśmiałych, ma problem z inicjowaniem rozmów i budowaniem relacji od podstaw.
- Powierzchowność w aplikacjach: Dominacja wyglądu fizycznego w wielu platformach społecznościowych i randkowych prowadzi do oceniania ludzi na podstawie pierwszego wrażenia wizualnego, pomijając znaczenie osobowości i rozmowy.
- Lęk przed odrzuceniem i oceną ze względu na wygląd: Obawa przed negatywną oceną lub wyśmianiem z powodu wyglądu zewnętrznego blokuje niektóre osoby przed próbą nawiązania kontaktu.
- Samotność i izolacja: Potrzeba łatwego i bezpiecznego sposobu na nawiązanie rozmowy z osobami w najbliższym otoczeniu, bez konieczności ujawniania tożsamości czy profili społecznościowych.
- Bariery komunikacyjne: Dla osób, które postrzegają swój wygląd jako przeszkodę w komunikacji, aplikacja tworzy przestrzeń, gdzie główną rolę odgrywa treść rozmowy.

## 3. Wymagania funkcjonalne

Poniżej przedstawiono zestaw funkcjonalności wchodzących w zakres MVP aplikacji WinkChat:

- Rejestracja i logowanie użytkowników: Umożliwienie założenia konta i logowania przy użyciu adresu e-mail i hasła.
- Ustawienia profilu anonimowego: Możliwość ustawienia unikalnego pseudonimu oraz określenia płci widocznej dla innych użytkowników.
- Określanie zasięgu lokalizacji: Użytkownik może wybrać z listy województwo, większe miasto (np. Warszawa, Sandomierz, Kielce) lub cały kraj (Polska), w którym chce wyszukiwać innych użytkowników.
- Wyszukiwanie osób w pobliżu: System wyszukuje aktywnych użytkowników znajdujących się w zdefiniowanej przez użytkownika lokalizacji administracyjnej. Lista wyników wyświetla tylko pseudonimy, płeć i status aktywności (kropka).
- Inicjowanie rozmowy: Użytkownik przeglądający listę znalezionych osób może wybrać daną osobę i wysłać prośbę o nawiązanie rozmowy.
- Ekran czatów: Widok prezentujący listę wszystkich aktualnych rozmów użytkownika, podzielonych na aktywne czaty oraz oczekujące prośby o nawiązanie rozmowy.
- Czat tekstowy: Podstawowa funkcjonalność umożliwiająca wysyłanie i odbieranie wiadomości tekstowych w ramach aktywnej konwersacji w czasie rzeczywistym (po zaakceptowaniu prośby).
- Podstawowy system zgłoszeń: Użytkownicy mają możliwość zgłaszania innych użytkowników. System zlicza zgłoszenia, a po osiągnięciu progu 10 zgłoszeń uruchamiana jest ręczna weryfikacja konta przez dedykowane osoby.

## 4. Granice produktu

Poniższe funkcjonalności nie wchodzą w zakres MVP aplikacji WinkChat i zostaną rozważone w przyszłych iteracjach rozwoju:

- Wysyłanie i odbieranie multimediów (zdjęć, filmów, wiadomości głosowych).
- Profile użytkowników zawierające zdjęcia.
- Zaawansowane filtry wyszukiwania (np. wiek, zainteresowania, status związku).
- Algorytmy automatycznego "matchowania" użytkowników.
- Powiadomienia push o nowych wiadomościach lub prośbach o czat.
- Zaawansowane funkcje moderacji i bezpieczeństwa (np. automatyczne wykrywanie niepożądanych treści, zaawansowane blokowanie, weryfikacja tożsamości/wieku).
- Funkcja umożliwiająca wzajemne "odkrycie" tożsamości lub wymianę danych kontaktowych wewnątrz aplikacji.
- Czaty grupowe.
- Personalizacja interfejsu (motywy, wygląd dymków czatu itp.).
- Funkcje monetyzacji (reklamy, subskrypcje premium).
- Geolokalizacja oparta na precyzyjnym promieniu wokół użytkownika.
- Informowanie użytkownika o nowych prośbach o czat w czasie rzeczywistym poza ekranem czatów.

## 5. Historyjki użytkowników

Poniżej przedstawiono kluczowe historyjki użytkowników dla MVP WinkChat:

- ID: US-001
- Tytuł: Rejestracja nowego konta
- Opis: Jako nowy użytkownik, chcę zarejestrować konto podając adres email i hasło, abym mógł korzystać z aplikacji.
- Kryteria akceptacji:

  - Gdy podam poprawny adres email i hasło spełniające wymagania, i kliknę "Zarejestruj", moje konto powinno zostać utworzone.
  - Gdy podam adres email, który jest już zajęty, system powinien wyświetlić błąd.
  - Gdy podam hasło niespełniające wymagań (np. zbyt krótkie), system powinien wyświetlić błąd.
  - Gdy pomyślnie się zarejestruję, powinienem zostać automatycznie zalogowany.

- ID: US-002
- Tytuł: Logowanie do istniejącego konta
- Opis: Jako istniejący użytkownik, chcę zalogować się na moje konto podając adres email i hasło, abym mógł kontynuować korzystanie z aplikacji.
- Kryteria akceptacji:

  - Gdy podam poprawny adres email i hasło dla istniejącego konta, powinienem zostać zalogowany.
  - Gdy podam niepoprawny adres email lub hasło, system powinien wyświetlić błąd.

- ID: US-003
- Tytuł: Ustawienie anonimowego profilu
- Opis: Jako nowy użytkownik, chcę ustawić swój anonimowy profil, podając pseudonim i wybierając płeć, aby inni mogli mnie identyfikować w ramach zasad anonimowości.
- Kryteria akceptacji:

  - Gdy po rejestracji lub pierwszym logowaniu podam unikalny pseudonim i wybiorę płeć, mój profil powinien zostać zapisany.
  - Gdy podam pseudonim, który jest już zajęty, system powinien wyświetlić błąd i poprosić o inny pseudonim.
  - Pseudonim powinien być widoczny dla innych użytkowników na liście osób do czatu i w oknie czatu.
  - Wybrana płeć powinna być widoczna dla innych użytkowników.

- ID: US-004
- Tytuł: Określenie preferowanej lokalizacji do wyszukiwania
- Opis: Jako użytkownik, chcę wybrać z listy preferowaną lokalizację (województwo, miasto lub kraj), w której chcę wyszukiwać rozmówców.
- Kryteria akceptacji:

  - System powinien przedstawić listę dostępnych opcji lokalizacji administracyjnej (województwa, wybrane miasta, cały kraj).
  - Gdy wybiorę lokalizację z listy, moje ustawienie powinno zostać zapisane.
  - Wyszukiwanie osób powinno odbywać się na podstawie wybranej przeze mnie lokalizacji.

- ID: US-005
- Tytuł: Wyszukiwanie aktywnych użytkowników w okolicy
- Opis: Jako użytkownik, chcę zobaczyć listę aktywnych użytkowników znajdujących się w mojej ustawionej lokalizacji, aby móc rozpocząć rozmowę.
- Kryteria akceptacji:

  - Gdy przejdę do zakładki "Nowa rozmowa", system powinien wyszukać aktywnych użytkowników w mojej wybranej lokalizacji.
  - Lista powinna wyświetlać tylko użytkowników, którzy są aktualnie aktywni w aplikacji.

- ID: US-006
- Tytuł: Wyświetlenie listy znalezionych użytkowników
- Opis: Jako użytkownik przeglądający zakładkę "Nowa rozmowa", chcę widzieć listę aktywnych użytkowników znalezionych w mojej lokalizacji, aby wybrać kogoś do rozmowy.
- Kryteria akceptacji:

  - Lista powinna wyświetlać pseudonim każdego znalezionego użytkownika.
  - Lista powinna wyświetlać płeć każdego znalezionego użytkownika.
  - Każdy element listy powinien mieć wskaźnik (np. kropkę) informujący o statusie aktywności użytkownika.
  - Kliknięcie w element listy powinno przenieść mnie do widoku szczegółów tego użytkownika (lub inicjowania rozmowy).

- ID: US-007
- Tytuł: Wyświetlenie szczegółów użytkownika przed inicjacją czatu
- Opis: Jako użytkownik, chcę zobaczyć podstawowe informacje o wybranym użytkowniku z listy ("Nowa rozmowa") zanim wyślę prośbę o czat.
- Kryteria akceptacji:

  - Po kliknięciu w użytkownika na liście, powinienem zobaczyć ekran z jego pseudonimem i płcią.
  - Na tym ekranie powinien znajdować się przycisk do wysłania prośby o nawiązanie rozmowy.

- ID: US-008
- Tytuł: Wysyłanie prośby o nawiązanie rozmowy
- Opis: Jako użytkownik, chcę móc wysłać prośbę o nawiązanie rozmowy do wybranego użytkownika z listy, aby zainicjować kontakt.
- Kryteria akceptacji:

  - Gdy jestem na ekranie szczegółów użytkownika i kliknę przycisk "Wyślij prośbę o nawiązanie rozmowy", prośba powinna zostać wysłana do tego użytkownika.
  - Po wysłaniu prośby, status na ekranie powinien zmienić się na "wysłano".

- ID: US-009
- Tytuł: Otrzymanie prośby o nawiązanie rozmowy
- Opis: Jako użytkownik, chcę zostać poinformowany o otrzymaniu prośby o nawiązanie rozmowy od innego użytkownika, abym mógł zdecydować czy chcę ją zaakceptować.
- Kryteria akceptacji:

  - Gdy inny użytkownik wyśle mi prośbę o rozmowę, powinna ona pojawić się na liście moich czatów (na ekranie czatów), oznaczona jako oczekująca lub prośba.
  - Widoczność prośby następuje po wejściu na ekran czatów.

- ID: US-010
- Tytuł: Zarządzanie prośbami o rozmowę
- Opis: Jako użytkownik, chcę mieć możliwość zaakceptowania lub odrzucenia otrzymanej prośby o nawiązanie rozmowy.
- Kryteria akceptacji:

  - Gdy otrzymam prośbę o rozmowę, powinna być dostępna opcja "Akceptuj".
  - Gdy kliknę "Akceptuj", prośba powinna zniknąć z listy oczekujących i rozpocząć się nowy, aktywny czat.
  - Gdy otrzymam prośbę o rozmowę, powinna być dostępna opcja "Odrzuć".
  - Gdy kliknę "Odrzuć", prośba powinna zniknąć z listy oczekujących i czat nie powinien zostać nawiązany.

- ID: US-011
- Tytuł: Wyświetlenie ekranu czatów
- Opis: Jako użytkownik, chcę mieć dostęp do ekranu, na którym widzę wszystkie moje aktywne i oczekujące rozmowy.
- Kryteria akceptacji:

  - Aplikacja powinna mieć dedykowany ekran ("Ekran czatów" lub podobny) wyświetlający listę moich konwersacji.
  - Lista powinna zawierać zarówno aktywne czaty, jak i oczekujące prośby o nawiązanie rozmowy.
  - Każdy element listy czatu powinien wyświetlać pseudonim rozmówcy.

- ID: US-012
- Tytuł: Rozróżnianie statusów czatów na liście
- Opis: Jako użytkownik, chcę łatwo odróżnić aktywne czaty od oczekujących prośb o rozmowę na ekranie czatów.
- Kryteria akceptacji:

  - Aktywne czaty i oczekujące prośby powinny być wizualnie odróżnione na liście (np. poprzez ikonę, kolor tła, sekcję na liście).

- ID: US-013
- Tytuł: Prowadzenie czatu tekstowego
- Opis: Jako użytkownik w ramach aktywnego czatu, chcę wysyłać i odbierać wiadomości tekstowe w czasie rzeczywistym z moim rozmówcą.
- Kryteria akceptacji:

  - Gdy otworzę aktywny czat, powinienem zobaczyć pole do wprowadzania tekstu.
  - Gdy wpiszę tekst i kliknę przycisk "Wyślij", moja wiadomość powinna zostać wysłana do rozmówcy.
  - Moje wysłane wiadomości powinny pojawiać się w oknie czatu.
  - Wiadomości wysłane przez rozmówcę powinny pojawiać się w oknie czatu w czasie rzeczywistym.

- ID: US-014
- Tytuł: Zgłaszanie niewłaściwego użytkownika
- Opis: Jako użytkownik, chcę móc zgłosić innego użytkownika, którego zachowanie uważam za niewłaściwe, aby przyczynić się do bezpieczeństwa platformy.
- Kryteria akceptacji:

  - Powinien być dostępny sposób na zgłoszenie użytkownika (np. z poziomu czatu lub profilu użytkownika).
  - Gdy zgłoszę użytkownika, system powinien zarejestrować to zgłoszenie.

- ID: US-015
- Tytuł: Widoczność statusu dla wysłanej prośby
- Opis: Jako użytkownik, który wysłał prośbę o rozmowę, chcę widzieć, że moja prośba została wysłana i jest w stanie oczekiwania.
- Kryteria akceptacji:

  - Po wysłaniu prośby o rozmowę (US-008), ekran lub element listy na ekranie czatów powinien wskazywać status "wysłano" lub "oczekująca".

- ID: US-016
- Tytuł: Widoczność ostrzeżeń o bezpieczeństwie
- Opis: Jako użytkownik, chcę widzieć ostrzeżenia dotyczące bezpieczeństwa online i świadomości ryzyka, aby zwiększyć swoją czujność.
- Kryteria akceptacji:
  - Aplikacja powinna okresowo wyświetlać komunikaty ostrzegawcze dotyczące bezpieczeństwa w internecie i potencjalnych zagrożeń (np. osoby podające się za kogoś innego).

## 6. Metryki sukcesu

Poniżej przedstawiono kluczowe metryki, które będą używane do mierzenia sukcesu MVP WinkChat:

- Walidacja hipotezy: Potwierdzenie istnienia zapotrzebowania na platformę do anonimowego czatowania tekstowego opartego na lokalizacji i osobowości. Mierzone poprzez ogólne zainteresowanie, liczbę rejestracji i zaangażowanie.
- Liczba zarejestrowanych użytkowników: Osiągnięcie 500-1000 zarejestrowanych kont w ciągu pierwszych 1-3 miesięcy od uruchomienia.
- Aktywni użytkownicy dziennie/miesięcznie (DAU/MAU): Utrzymanie minimum 60% DAU/MAU (wymaga doprecyzowania, która wartość dotyczy DAU, a która MAU).
- Średnia liczba nawiązywanych nowych rozmów: Średnia liczba propozycji czatu zaakceptowanych i prowadzących do aktywnej rozmowy na aktywnego użytkownika tygodniowo.
- Zaangażowanie w rozmowę: Mierzone poprzez średnią liczbę wymienianych wiadomości w ramach jednej aktywnej konwersacji. Analiza danych z zapisanych logów czatów.
- Pozytywny feedback: Zebranie opinii od użytkowników poprzez ankiety w aplikacji, wskazujących na docenienie unikalnej propozycji wartości aplikacji i satysfakcję z korzystania z niej.
- Retencja użytkowników: Utrzymanie co najmniej 75% użytkowników po pierwszym tygodniu korzystania z aplikacji. (Przyjęto, że cel 75% dotyczy retencji tygodniowej, wymaga potwierdzenia).
- Dane do dalszego rozwoju: Zidentyfikowanie obszarów do poprawy i pożądanych nowych funkcji na podstawie analizy zachowań użytkowników i zebranych opinii.
