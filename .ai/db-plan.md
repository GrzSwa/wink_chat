1. Lista tabel z ich kolumnami, typami danych i ograniczeniami

-- Rozszerzenie do generowania UUID, jeśli nie jest jeszcze włączone
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Typy ENUM
CREATE TYPE gender_enum AS ENUM ('male', 'female', 'other', 'prefer_not_to_say');
CREATE TYPE location_type_enum AS ENUM ('województwo', 'miasto', 'kraj');
CREATE TYPE chat_status_enum AS ENUM ('pending', 'active', 'rejected', 'closed_by_user1', 'closed_by_user2', 'blocked');
CREATE TYPE report_reason_enum AS ENUM ('Rasizm', 'Oszust', 'Spam', 'Hejt', 'Agresja', 'Inne');

-- Tabela: locations
CREATE TABLE locations (
id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
name TEXT NOT NULL UNIQUE,
type location_type_enum NOT NULL,
created_at TIMESTAMPTZ DEFAULT now(),
updated_at TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE locations IS 'Predefiniowane lokalizacje administracyjne (województwa, miasta, kraj).';
COMMENT ON COLUMN locations.name IS 'Nazwa lokalizacji (np. mazowieckie, Warszawa, Polska).';
COMMENT ON COLUMN locations.type IS 'Typ lokalizacji (województwo, miasto, kraj).';

-- Tabela: users
-- Ta tabela jest rozszerzeniem dla tabeli auth.users z Supabase.
CREATE TABLE users (
id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE, -- Klucz główny i obcy do auth.users
username TEXT NOT NULL UNIQUE,
gender gender_enum,
preferred_location_id UUID REFERENCES locations(id) ON DELETE SET NULL,
last_active_at TIMESTAMPTZ DEFAULT now(),
created_at TIMESTAMPTZ DEFAULT now(),
updated_at TIMESTAMPTZ DEFAULT now(),
report_count INT DEFAULT 0, -- Licznik zgłoszeń (chociaż główna logika jest w tabeli reports)

    CONSTRAINT username_length CHECK (char_length(username) >= 4 AND char_length(username) <= 20)

);

COMMENT ON TABLE users IS 'Przechowuje publiczne dane profilowe użytkowników, rozszerzając auth.users.';
COMMENT ON COLUMN users.id IS 'Referencja do ID użytkownika w tabeli auth.users.';
COMMENT ON COLUMN users.username IS 'Unikalny pseudonim użytkownika (4-20 znaków).';
COMMENT ON COLUMN users.gender IS 'Płeć wybrana przez użytkownika.';
COMMENT ON COLUMN users.preferred_location_id IS 'Preferowana lokalizacja użytkownika do wyszukiwania innych.';
COMMENT ON COLUMN users.last_active_at IS 'Timestamp ostatniej aktywności użytkownika (ping).';
COMMENT ON COLUMN users.report_count IS 'Pomocniczy licznik zgłoszeń, główna tabela to "reports". Ręczna weryfikacja po przekroczeniu progu.';

-- Tabela: chats
CREATE TABLE chats (
id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
user1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
user2_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
status chat_status_enum NOT NULL DEFAULT 'pending',
created_at TIMESTAMPTZ DEFAULT now(),
updated_at TIMESTAMPTZ DEFAULT now(),

    CONSTRAINT users_in_chat_are_different CHECK (user1_id <> user2_id),
    CONSTRAINT unique_chat_pair UNIQUE (LEAST(user1_id, user2_id), GREATEST(user1_id, user2_id))

);

COMMENT ON TABLE chats IS 'Reprezentuje unikalną konwersację 1-na-1 między dwoma użytkownikami.';
COMMENT ON COLUMN chats.user1_id IS 'ID pierwszego użytkownika w czacie.';
COMMENT ON COLUMN chats.user2_id IS 'ID drugiego użytkownika w czacie.';
COMMENT ON COLUMN chats.status IS 'Status czatu (pending, active, rejected, closed).';
COMMENT ON CONSTRAINT unique_chat_pair ON chats IS 'Zapewnia, że para użytkowników może mieć tylko jeden czat, niezależnie od kolejności.';

-- Tabela: messages
CREATE TABLE messages (
id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
content TEXT NOT NULL,
created_at TIMESTAMPTZ DEFAULT now(),
read_at TIMESTAMPTZ -- Timestamp odczytania wiadomości (opcjonalne dla MVP, ale przydatne)
);

COMMENT ON TABLE messages IS 'Przechowuje wiadomości tekstowe w ramach czatu.';
COMMENT ON COLUMN messages.chat_id IS 'ID czatu, do którego należy wiadomość.';
COMMENT ON COLUMN messages.sender_id IS 'ID użytkownika, który wysłał wiadomość.';
COMMENT ON COLUMN messages.content IS 'Treść wiadomości tekstowej.';
COMMENT ON COLUMN messages.read_at IS 'Timestamp, kiedy odbiorca odczytał wiadomość.';

-- Tabela: reports
CREATE TABLE reports (
id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
reporting_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
reported_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
reason report_reason_enum NOT NULL,
description TEXT, -- Opcjonalny dodatkowy opis zgłoszenia
created_at TIMESTAMPTZ DEFAULT now(),

    CONSTRAINT reporting_user_cannot_be_reported_user CHECK (reporting_user_id <> reported_user_id)

);

COMMENT ON TABLE reports IS 'Przechowuje zgłoszenia użytkowników dotyczące innych użytkowników.';
COMMENT ON COLUMN reports.reporting_user_id IS 'ID użytkownika zgłaszającego.';
COMMENT ON COLUMN reports.reported_user_id IS 'ID użytkownika zgłaszanego.';
COMMENT ON COLUMN reports.reason IS 'Predefiniowany powód zgłoszenia.';
COMMENT ON COLUMN reports.description IS 'Opcjonalny, dodatkowy opis powodu zgłoszenia przez użytkownika.';

-- Tabela: security_warnings (do wyświetlania ostrzeżeń US-016)
CREATE TABLE security_warnings (
id SERIAL PRIMARY KEY,
message TEXT NOT NULL,
is_active BOOLEAN DEFAULT TRUE,
display_frequency_hours INT DEFAULT 24, -- Jak często może być wyświetlane jednemu użytkownikowi
last_displayed_globally TIMESTAMPTZ,
created_at TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE security_warnings IS 'Przechowuje komunikaty ostrzegawcze dotyczące bezpieczeństwa.';
COMMENT ON COLUMN security_warnings.message IS 'Treść ostrzeżenia.';
COMMENT ON COLUMN security_warnings.is_active IS 'Czy ostrzeżenie jest aktywne do wyświetlania.';
COMMENT ON COLUMN security_warnings.display_frequency_hours IS 'Sugerowana minimalna częstotliwość wyświetlania (w godzinach).';

2. Relacje między tabelami

- **users** 1:1 **auth.users** (Supabase): Tabela `users` rozszerza `auth.users`, używając tego samego `id`.
- **users** 1:N **locations** (preferowana lokalizacja): Każdy użytkownik ma jedną `preferred_location_id` wskazującą na rekord w `locations`. Lokalizacja może być przypisana do wielu użytkowników.
- **users** M:N **chats**: Relacja realizowana przez tabelę `chats` z dwoma kluczami obcymi (`user1_id`, `user2_id`) do tabeli `users`. Unikalność pary jest zapewniona.
  - Dokładniej: `users` 1:N `chats` (jako `user1_id`) i `users` 1:N `chats` (jako `user2_id`). Każdy czat ma dokładnie dwóch użytkowników.
- **chats** 1:N **messages**: Każdy czat może zawierać wiele wiadomości. Każda wiadomość należy do jednego czatu.
- **users** 1:N **messages** (jako nadawca): Każdy użytkownik może wysłać wiele wiadomości. Każda wiadomość ma jednego nadawcę.
- **users** 1:N **reports** (jako zgłaszający): Użytkownik może zgłosić wielu innych użytkowników lub tego samego użytkownika wielokrotnie z różnych powodów.
- **users** 1:N **reports** (jako zgłaszany): Użytkownik może być zgłoszony wiele razy przez różnych użytkowników.
- **security_warnings**: Tabela niezależna, przechowująca globalne komunikaty.

3. Indeksy

-- Tabela: users
CREATE INDEX idx_users_preferred_location_id ON users(preferred_location_id);
CREATE INDEX idx_users_last_active_at ON users(last_active_at DESC); -- DESC dla szybszego wyszukiwania najaktywniejszych
-- `users.username` jest już indeksowany dzięki ograniczeniu UNIQUE.
-- `users.id` jest indeksowany jako PRIMARY KEY.

-- Tabela: locations
-- `locations.name` jest już indeksowany dzięki ograniczeniu UNIQUE.
-- `locations.id` jest indeksowany jako PRIMARY KEY.
CREATE INDEX idx_locations_type ON locations(type);

-- Tabela: chats
CREATE INDEX idx_chats_user1_id ON chats(user1_id);
CREATE INDEX idx_chats_user2_id ON chats(user2_id);
CREATE INDEX idx_chats_status ON chats(status);
-- Indeks dla unique_chat_pair jest tworzony automatycznie.
-- `chats.id` jest indeksowany jako PRIMARY KEY.

-- Tabela: messages
CREATE INDEX idx_messages_chat_id ON messages(chat_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC); -- Dla wyświetlania najnowszych wiadomości
-- `messages.id` jest indeksowany jako PRIMARY KEY.

-- Tabela: reports
CREATE INDEX idx_reports_reporting_user_id ON reports(reporting_user_id);
CREATE INDEX idx_reports_reported_user_id ON reports(reported_user_id);
CREATE INDEX idx_reports_reason ON reports(reason);
CREATE INDEX idx_reports_created_at ON reports(created_at DESC);
-- `reports.id` jest indeksowany jako PRIMARY KEY.

-- Tabela: security_warnings
CREATE INDEX idx_security_warnings_is_active ON security_warnings(is_active);

4. Zasady PostgreSQL (Row-Level Security - RLS)

-- Najpierw włącz RLS dla każdej tabeli
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations ENABLE ROW LEVEL SECURITY; -- Choć prawdopodobnie publiczne
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE security_warnings ENABLE ROW LEVEL SECURITY; -- Prawdopodobnie publiczne

-- Domyślnie blokuj wszystko, chyba że jawnie zezwolono
CREATE POLICY "Deny All Default" ON users FOR ALL USING (false);
CREATE POLICY "Deny All Default" ON locations FOR ALL USING (false);
CREATE POLICY "Deny All Default" ON chats FOR ALL USING (false);
CREATE POLICY "Deny All Default" ON messages FOR ALL USING (false);
CREATE POLICY "Deny All Default" ON reports FOR ALL USING (false);
CREATE POLICY "Deny All Default" ON security_warnings FOR ALL USING (false);

-- Polityki dla tabeli users
CREATE POLICY "Users can see their own profile" ON users
FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
FOR UPDATE USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);
-- Tworzenie nowych użytkowników jest obsługiwane przez Supabase Auth; ta tabela `users` jest uzupełniana triggerem lub logiką serwera po utworzeniu w `auth.users`.
-- Zakładamy, że istnieje rola 'moderator' lub 'admin'
-- CREATE POLICY "Admins can see all user profiles" ON users FOR SELECT USING (get_my_claim('userrole') = '"admin"'); -- Przykład dla admina

-- Polityki dla tabeli locations
CREATE POLICY "All users can see locations" ON locations
FOR SELECT USING (true);
-- Zarządzanie lokalizacjami (INSERT, UPDATE, DELETE) przez admina/ręcznie.

-- Polityki dla tabeli chats
CREATE POLICY "Users can see and manage chats they participate in" ON chats
FOR ALL USING (auth.uid() = user1_id OR auth.uid() = user2_id)
WITH CHECK (auth.uid() = user1_id OR auth.uid() = user2_id);

CREATE POLICY "Users can create chats where they are one of the participants" ON chats
FOR INSERT WITH CHECK (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Polityki dla tabeli messages
CREATE POLICY "Users can see messages in their chats" ON messages
FOR SELECT USING (
EXISTS (
SELECT 1 FROM chats
WHERE chats.id = messages.chat_id
AND (chats.user1_id = auth.uid() OR chats.user2_id = auth.uid())
)
);

CREATE POLICY "Users can send messages in their active chats" ON messages
FOR INSERT WITH CHECK (
sender_id = auth.uid() AND
EXISTS (
SELECT 1 FROM chats
WHERE chats.id = messages.chat_id
AND (chats.user1_id = auth.uid() OR chats.user2_id = auth.uid())
AND chats.status = 'active'
)
);
-- UPDATE/DELETE wiadomości nie jest przewidziane w MVP.

-- Polityki dla tabeli reports
CREATE POLICY "Users can create reports" ON reports
FOR INSERT WITH CHECK (reporting_user_id = auth.uid());

-- Dostęp do odczytu zgłoszeń tylko dla moderatorów/administratorów
-- Ta polityka wymagałaby istnienia roli 'moderator' i mechanizmu jej przypisywania
-- CREATE POLICY "Moderators can see all reports" ON reports
-- FOR SELECT USING (is_claims_admin() OR get_my_claim('user_role') = '"moderator"'); -- Funkcja is_claims_admin() jest często używana w Supabase
-- Dla uproszczenia, bez roli moderatora, nikt nie może czytać raportów przez RLS (tylko przez backend z uprawnieniami superużytkownika)
-- Jeśli nie ma roli moderatora, to można zostawić domyślne DENY dla SELECT.

-- Polityki dla tabeli security_warnings
CREATE POLICY "All users can read active security warnings" ON security_warnings
FOR SELECT USING (is_active = TRUE);
-- Zarządzanie ostrzeżeniami przez admina.

5. Wszelkie dodatkowe uwagi lub wyjaśnienia dotyczące decyzji projektowych

- **UUID jako klucze główne**: Zgodnie z zaleceniami, dla lepszej skalowalności i unikania kolizji w systemach rozproszonych.
- **TIMESTAMPTZ**: Używane dla wszystkich pól daty/czasu, aby zapewnić spójność stref czasowych.
- **ENUMY**: Dla pól o predefiniowanym zestawie wartości (płeć, typ lokalizacji, status czatu, powód zgłoszenia) dla integralności danych i wydajności.
- **Integracja z Supabase Auth**: Tabela `users` jest ściśle powiązana z `auth.users` poprzez `id`. Zakłada się, że po stronie Supabase (np. przez trigger lub funkcję) po utworzeniu użytkownika w `auth.users` tworzony jest odpowiedni wpis w `public.users`. E-mail i hasło są zarządzane przez `auth.users`.
- **Unikalność pseudonimów**: Zapewniona przez `UNIQUE` constraint na `users.username`.
- **Długość pseudonimu**: Zapewniona przez `CHECK` constraint.
- **Unikalność konwersacji**: `UNIQUE (LEAST(user1_id, user2_id), GREATEST(user1_id, user2_id))` w tabeli `chats` zapewnia, że para użytkowników (A,B) ma tylko jedną konwersację, niezależnie od tego, kto jest `user1_id` a kto `user2_id`.
- **Status aktywności**: `users.last_active_at` będzie aktualizowane przez aplikację co 5 minut (ping). Wyszukiwanie aktywnych użytkowników będzie filtrować na podstawie tego pola i `preferred_location_id`.
- **Zgłoszenia**: Tabela `reports` przechowuje pojedyncze zgłoszenia. Kolumna `users.report_count` może być aktualizowana triggerem po wstawieniu do `reports` dla szybkiego wglądu, ale próg 10 zgłoszeń i weryfikacja są procesem ręcznym przez moderatorów (monitorujących tabelę `reports`). RLS ogranicza dostęp do tabeli `reports`.
- **Brak automatycznego blokowania**: Na etapie MVP, przekroczenie progu zgłoszeń nie powoduje automatycznej zmiany statusu konta.
- **Przechowywanie wiadomości**: Wiadomości są przechowywane bezterminowo w ramach MVP.
- **Lokalizacje predefiniowane**: Tabela `locations` jest zarządzana ręcznie. Użytkownicy wybierają z tej listy.
- **RLS**: Polityki RLS są kluczowe dla bezpieczeństwa danych, zapewniając, że użytkownicy mają dostęp tylko do swoich danych i danych, do których są uprawnieni. Polityki dotyczące ról (np. moderator) wymagają odpowiedniej konfiguracji tych ról w PostgreSQL i mechanizmu ich przypisywania w Supabase (np. przez custom claims JWT).
- **Brak informacji o czasie rzeczywistym w RLS**: Implementacja informacji o nowych prośbach o czat poza ekranem czatów (np. powiadomienia push) jest poza zakresem MVP i nie została uwzględniona w schemacie RLS bezpośrednio, ale Supabase Realtime może być użyte do subskrypcji zmian w tabeli `chats`.
- **Ostrzeżenia o bezpieczeństwie (US-016)**: Dodano prostą tabelę `security_warnings` do przechowywania tych komunikatów. Logika wyświetlania (np. "okresowo") musiałaby być zaimplementowana w aplikacji, potencjalnie śledząc ostatnie wyświetlenie dla użytkownika w `localStorage` lub innej tabeli.
