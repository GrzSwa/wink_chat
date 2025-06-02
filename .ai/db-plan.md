1. Lista kolekcji z ich polami, typami danych i ograniczeniami

**Firestore**

- Kolekcja: `users`

  - Dokument ID: UID użytkownika z Firebase Authentication (string)
  - Pola:
    - `uid`: string (wymagane, unikalne) - ID użytkownika z Auth
    - `pseudonim`: string (wymagane, unikalne)
    - `gender`: string (wymagane, dopuszczalne wartości: "M", "F")
    - `location`: mapa (wymagane)
      - `type`: string (wymagane, dopuszczalne wartości: "city", "country", "voivodeship")
      - `value`: string (wymagane, nazwa lokalizacji)
    - `lastSeen`: timestamp (wymagane) - Ostatni moment aktywności (alternatywa dla `isActive` boolean)
    - `createdAt`: timestamp (wymagane)
    - `updatedAt`: timestamp (wymagane, auto-aktualizacja)

- Kolekcja: `explore`

  - Dokument ID: Nazwa lokalizacji (string, np. "Warszawa", "Mazowieckie", "Polska")
  - Pola:
    - `type`: string (wymagane, dopuszczalne wartości: "city", "country", "voivodeship")
    - `activeUsers`: array of strings (wymagane) - Lista UIDów aktywnych użytkowników w tej lokalizacji

- Kolekcja: `chats`

  - Dokument ID: UID użytkownika z Firebase Authentication (string)
  - Pola:
    - `participantId`: mapa (wymagane, UID drugiego użytkownika rozmowy)
      - `messageID`: string (wymagane, ID rozmowy)
      - `status`: string (wymagane, dopuszczalne wartości: "pending", "active", "rejected", "ended")
      - `initiatorId`: string (wymagane, UID użytkownika wysyłającego prośbę)
      - `createdAt`: timestamp (wymagane) - Czas wysłania prośby
      - `updatedAt`: timestamp (wymagane, auto-aktualizacja)
      - `endedAt`: timestamp (opcjonalne) - Czas zakończenia rozmowy (dla celów archiwizacji)

- Kolekcja: `messages`

  - Dokument ID: messageID odpowiadający z kolekcji chats
  - Pola:
    - `from`: string (wymagane, UID nadawcy)
    - `to`: string (wymagane, UID odbiorcy)
    - `message`: string (wymagane, treść wiadomości)
    - `time`: timestamp (wymagane, czas wysłania wiadomości)

- Kolekcja: `reports`

  - Dokument ID: Auto-generowane przez Firestore (string)
  - Pola:
    - `reportingUserId`: string (wymagane, UID zgłaszającego)
    - `reportedUserId`: string (wymagane, UID zgłaszanego)
    - `type`: string (wymagane, dopuszczalne wartości: "Hejt", "Spam", "Rasizm", "Agresja słowna", "Oszust")
    - `timestamp`: timestamp (wymagane) - Czas zgłoszenia

- Kolekcja: `chatMessagesArchive` (Propozycja dla archiwum wiadomości)
  - Dokument ID: Auto-generowane przez Firestore (string)
  - Pola:
    - `chatId`: string (wymagane, ID dokumentu z kolekcji `chats`)
    - `messageData`: mapa (wymagane) - Zarchiwizowana wiadomość
      - `from`: string (wymagane, UID nadawcy)
      - `to`: string (wymagane, UID odbiorcy)
      - `message`: string (wymagane, treść wiadomości)
      - `time`: timestamp (wymagane, czas wysłania wiadomości)
    - `archivedAt`: timestamp (wymagane) - Czas archiwizacji wiadomości

**Realtime Database**

- Ścieżka główna: `/`
- Węzeł: `/messages/`
  - Węzły podrzędne: `{participantUID1-participantUID2}` (string, połączenie posortowanych UIDów uczestników, np. `abc-xyz`)
    - Węzły podrzędne: Automatyczne klucze push (string)
      - Wartość: mapa
        - `from`: string (wymagane, UID nadawcy)
        - `to`: string (wymagane, UID odbiorcy)
        - `message`: string (wymagane, treść wiadomości)
        - `time`: timestamp (wymagane) - Czas wysłania wiadomości

2. Indeksy (Firestore)

- `users`:
  - Indeks złożony: `location.type ASC`, `location.value ASC`, `lastSeen DESC` - Dla wyszukiwania aktywnych użytkowników w konkretnej lokalizacji.
  - Indeks na `pseudonim` (ASC) - Dla zapewnienia unikalności (w połączeniu z logiką backendową).
- `chats`:
  - Indeks tablicowy na `participantIds` - Dla wyszukiwania czatów, w których użytkownik uczestniczy.
  - Indeks na `status` (ASC) - Dla filtrowania czatów według statusu (pending, active).
  - Indeks na `updatedAt` (DESC) lub `endedAt` (DESC) - Dla sortowania listy czatów.
- `reports`:
  - Indeks złożony: `reportedUserId ASC`, `timestamp DESC` - Dla pobierania zgłoszeń dotyczących konkretnego użytkownika, posortowanych chronologicznie.
  - Indeks na `status` (ASC) - Dla filtrowania zgłoszeń przez moderatorów.
- `chatMessagesArchive`:
  - Indeks złożony: `chatId ASC`, `messageData.time ASC` - Dla pobierania zarchiwizowanych wiadomości dla konkretnego czatu, posortowanych chronologicznie.

3. Zasady nierelacyjnych baz danych

- **Firestore:**
  - Modelowanie danych zorientowane na odczyty: Struktura kolekcji i dokumentów ma ułatwiać najczęstsze zapytania (np. pobieranie profilu, wyszukiwanie użytkowników, pobieranie listy czatów użytkownika).
  - Unikanie dużych dokumentów: Wiadomości czatu są przechowywane poza dokumentem czatu (w RTDB lub archiwum), aby dokumenty czatu pozostały małe.
  - Unikanie list (arrays) w dokumentach, które często rosną i są modyfikowane przez wielu użytkowników jednocześnie (np. storing all messages in a chat document as an array - czego unikamy). Tablica `participantIds` jest statyczna (ma zawsze 2 elementy), więc jest akceptowalna.
  - Użycie referencji i zdenormalizowanych danych (np. przechowywanie pseudonimu i płci w czacie, jeśli potrzebne do wyświetlenia bez dodatkowego odczytu z `users`) powinno być świadomą decyzją projektową. W tym schemacie przyjęto minimalną denormalizację w Firestore, opierając się na UIDach.
- **Realtime Database:**
  - Struktura drzewiasta: Dane są zorganizowane w strukturę JSON.
  - Optymalizacja pod kątem Realtime: Struktura `/messages/{chatId}/` jest optymalna do nasłuchiwania zmian w czasie rzeczywistym dla konkretnego czatu.
  - Użycie automatycznych kluczy (`push()`): Zapewnia unikalne identyfikatory dla wiadomości i ułatwia dodawanie nowych danych.
  - Płaska struktura: Unikanie głębokiego zagnieżdżania danych w RTDB dla lepszej wydajności.

4. Wszelkie dodatkowe uwagi lub wyjaśnienia dotyczące decyzji projektowych

- **Podział między Firestore i Realtime Database dla Czatu:** Ten projekt przyjmuje model danych, gdzie aktywne wiadomości czatu znajdują się w Realtime Database dla optymalizacji pod kątem niskiego opóźnienia i subskrypcji w czasie rzeczywistym, a metadane czatu i zarchiwizowane wiadomości są w Firestore dla bardziej złożonych zapytań i strukturalnego przechowywania danych długoterminowych. Jest to złożona architektura, która wymaga starannego zarządzania danymi i synchronizacją między bazami danych.
- **Archwizacja Wiadomości:** Zaproponowano oddzielną kolekcję `chatMessagesArchive` w Firestore do przechowywania zarchiwizowanych wiadomości z RTDB. Proces archiwizacji musi być zaimplementowany niezawodnie (np. za pomocą Cloud Functions) i powinien obejmować przeniesienie wiadomości do Firestore i ich usunięcie z Realtime Database.
- **Status Aktywności (`lastSeen`):** Zamiast boolean `isActive`, zaproponowano pole `lastSeen` typu timestamp. Pozwala to na bardziej elastyczne określanie statusu aktywności (np. "aktywny w ciągu ostatnich X minut"). Częste aktualizacje tego pola mogą generować dużą liczbę zapisów w Firestore.
- **Unikalność Pseudonimu:** Chociaż pseudonim jest oznaczony jako unikalny, Firestore nie wymusza unikalności pola automatycznie. Wymaga to dodatkowej logiki po stronie serwera (Cloud Function/transakcja) podczas tworzenia profilu, aby sprawdzić i zapewnić unikalność pseudonimu w całej kolekcji `users`.
- **Bezpieczeństwo:** Zdefiniowanie szczegółowych zasad bezpieczeństwa Firebase Security Rules dla Firestore i Realtime Database jest kluczowe. Muszą one restrykcyjnie kontrolować dostęp do danych zgodnie z wymaganiami anonimowości (np. tylko pseudonim, płeć, status i lokalizacja widoczne publicznie, email tylko dla użytkownika, dane czatu tylko dla uczestników, dane zgłoszeń tylko dla moderatorów).
