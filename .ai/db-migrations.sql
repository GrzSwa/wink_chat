-- Migration: Create initial WinkChat schema
-- Timestamp: 20250515145429 (UTC)
-- Description: Sets up the initial tables, types, indexes, and RLS policies for the WinkChat MVP.
-- Affected tables: locations, users, chats, messages, reports, security_warnings
-- Special considerations:
--   - Assumes Supabase Auth is in use and `auth.users` table exists.
--   - `users` table links to `auth.users`.
--   - RLS policies are granular for `anon` and `authenticated` roles.
--   - Moderator-specific access (e.g., for reading reports) is not defined in these RLS policies
--     and would typically be handled by backend logic using a service_role key or by defining
--     custom claims and roles for moderators.

-- enable uuid-ossp extension if not already enabled
create extension if not exists "uuid-ossp" with schema extensions;

-- define enum types

-- gender_enum type for user gender
create type public.gender_enum as enum ('male', 'female', 'other', 'prefer_not_to_say');
comment on type public.gender_enum is 'defines possible gender options for users.';

-- location_type_enum type for location types
create type public.location_type_enum as enum ('województwo', 'miasto', 'kraj');
comment on type public.location_type_enum is 'defines administrative types of locations (e.g., province, city, country).';

-- chat_status_enum type for chat statuses
create type public.chat_status_enum as enum ('pending', 'active', 'rejected', 'closed_by_user1', 'closed_by_user2', 'blocked');
comment on type public.chat_status_enum is 'defines the various states a chat can be in.';

-- report_reason_enum type for report reasons
create type public.report_reason_enum as enum ('Rasizm', 'Oszust', 'Spam', 'Hejt', 'Agresja', 'Inne');
comment on type public.report_reason_enum is 'defines predefined reasons for user reports.';

-- create locations table
create table public.locations (
    id uuid primary key default extensions.uuid_generate_v4(),
    name text not null unique,
    type public.location_type_enum not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
comment on table public.locations is 'stores predefined administrative locations (provinces, cities, country).';
comment on column public.locations.id is 'unique identifier for the location.';
comment on column public.locations.name is 'name of the location (e.g., mazowieckie, Warszawa, Polska). must be unique.';
comment on column public.locations.type is 'type of the location (województwo, miasto, kraj).';
comment on column public.locations.created_at is 'timestamp of when the location was created.';
comment on column public.locations.updated_at is 'timestamp of when the location was last updated.';

-- enable row level security for locations
alter table public.locations enable row level security;

-- rls policies for locations table
-- anon users can read locations
drop policy if exists "anon_can_read_locations" on public.locations;
create policy "anon_can_read_locations" on public.locations
    for select
    to anon
    using (true);
comment on policy "anon_can_read_locations" on public.locations is 'allows anonymous users to read all locations.';

-- authenticated users can read locations
drop policy if exists "authenticated_can_read_locations" on public.locations;
create policy "authenticated_can_read_locations" on public.locations
    for select
    to authenticated
    using (true);
comment on policy "authenticated_can_read_locations" on public.locations is 'allows authenticated users to read all locations.';
-- insert, update, delete on locations are admin-only operations, not covered by these RLS for anon/authenticated.

-- create users table
create table public.users (
    id uuid primary key references auth.users(id) on delete cascade,
    username text not null unique,
    gender public.gender_enum,
    preferred_location_id uuid references public.locations(id) on delete set null,
    last_active_at timestamptz not null default now(),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    report_count integer not null default 0,
    constraint username_length check (char_length(username) >= 4 and char_length(username) <= 20)
);
comment on table public.users is 'stores public profile data for users, extending auth.users.';
comment on column public.users.id is 'primary key, references id in auth.users table from supabase auth.';
comment on column public.users.username is 'unique username for the user (4-20 characters).';
comment on column public.users.gender is 'gender selected by the user.';
comment on column public.users.preferred_location_id is 'user''s preferred location for finding others, references locations table.';
comment on column public.users.last_active_at is 'timestamp of the user''s last activity (ping).';
comment on column public.users.created_at is 'timestamp of when the user profile was created.';
comment on column public.users.updated_at is 'timestamp of when the user profile was last updated.';
comment on column public.users.report_count is 'auxiliary counter for reports against the user. main report data is in the "reports" table.';
comment on constraint username_length on public.users is 'ensures username is between 4 and 20 characters long.';

-- enable row level security for users
alter table public.users enable row level security;

-- rls policies for users table
-- authenticated users can select their own profile
drop policy if exists "authenticated_select_own_user" on public.users;
create policy "authenticated_select_own_user" on public.users
    for select
    to authenticated
    using (auth.uid() = id);
comment on policy "authenticated_select_own_user" on public.users is 'allows authenticated users to select their own profile information.';

-- authenticated users can insert their own profile (e.g., initial setup after registration)
drop policy if exists "authenticated_insert_own_user" on public.users;
create policy "authenticated_insert_own_user" on public.users
    for insert
    to authenticated
    with check (auth.uid() = id);
comment on policy "authenticated_insert_own_user" on public.users is 'allows authenticated users to insert their own profile data (id must match their auth.uid).';

-- authenticated users can update their own profile
drop policy if exists "authenticated_update_own_user" on public.users;
create policy "authenticated_update_own_user" on public.users
    for update
    to authenticated
    using (auth.uid() = id)
    with check (auth.uid() = id);
comment on policy "authenticated_update_own_user" on public.users is 'allows authenticated users to update their own profile information.';
-- anon users generally should not interact with the users table directly for select/insert/update/delete.

-- create chats table
create table public.chats (
    id uuid primary key default extensions.uuid_generate_v4(),
    user1_id uuid not null references public.users(id) on delete cascade,
    user2_id uuid not null references public.users(id) on delete cascade,
    status public.chat_status_enum not null default 'pending',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint users_in_chat_are_different check (user1_id <> user2_id),
    constraint unique_chat_pair unique (least(user1_id, user2_id), greatest(user1_id, user2_id))
);
comment on table public.chats is 'represents a unique 1-on-1 conversation between two users.';
comment on column public.chats.id is 'unique identifier for the chat.';
comment on column public.chats.user1_id is 'id of the first user in the chat.';
comment on column public.chats.user2_id is 'id of the second user in the chat.';
comment on column public.chats.status is 'current status of the chat (pending, active, rejected, closed).';
comment on column public.chats.created_at is 'timestamp of when the chat was created.';
comment on column public.chats.updated_at is 'timestamp of when the chat was last updated.';
comment on constraint users_in_chat_are_different on public.chats is 'ensures a user cannot chat with themselves.';
comment on constraint unique_chat_pair on public.chats is 'ensures that a pair of users can only have one chat session, regardless of who initiated.';

-- enable row level security for chats
alter table public.chats enable row level security;

-- rls policies for chats table
-- authenticated users can select chats they participate in
drop policy if exists "authenticated_select_own_chats" on public.chats;
create policy "authenticated_select_own_chats" on public.chats
    for select
    to authenticated
    using (auth.uid() = user1_id or auth.uid() = user2_id);
comment on policy "authenticated_select_own_chats" on public.chats is 'allows authenticated users to select chats they are a participant in.';

-- authenticated users can insert (create) new chats where they are a participant
drop policy if exists "authenticated_insert_own_chats" on public.chats;
create policy "authenticated_insert_own_chats" on public.chats
    for insert
    to authenticated
    with check (auth.uid() = user1_id or auth.uid() = user2_id);
comment on policy "authenticated_insert_own_chats" on public.chats is 'allows authenticated users to create new chats where they are one of the participants.';

-- authenticated users can update chats (e.g. status) they participate in
drop policy if exists "authenticated_update_own_chats" on public.chats;
create policy "authenticated_update_own_chats" on public.chats
    for update
    to authenticated
    using (auth.uid() = user1_id or auth.uid() = user2_id)
    with check (auth.uid() = user1_id or auth.uid() = user2_id);
comment on policy "authenticated_update_own_chats" on public.chats is 'allows authenticated users to update chats (e.g., change status) they are a participant in.';
-- delete policy for chats is not defined for authenticated users in MVP, status updates handle closing.
-- anon users have no direct access to chats.

-- create messages table
create table public.messages (
    id uuid primary key default extensions.uuid_generate_v4(),
    chat_id uuid not null references public.chats(id) on delete cascade,
    sender_id uuid not null references public.users(id) on delete cascade,
    content text not null,
    created_at timestamptz not null default now(),
    read_at timestamptz
);
comment on table public.messages is 'stores text messages within a chat.';
comment on column public.messages.id is 'unique identifier for the message.';
comment on column public.messages.chat_id is 'id of the chat this message belongs to.';
comment on column public.messages.sender_id is 'id of the user who sent the message.';
comment on column public.messages.content is 'text content of the message.';
comment on column public.messages.created_at is 'timestamp of when the message was sent.';
comment on column public.messages.read_at is 'timestamp of when the message was read by the recipient (optional for mvp).';

-- enable row level security for messages
alter table public.messages enable row level security;

-- rls policies for messages table
-- authenticated users can select messages from chats they participate in
drop policy if exists "authenticated_select_messages_in_own_chats" on public.messages;
create policy "authenticated_select_messages_in_own_chats" on public.messages
    for select
    to authenticated
    using (
        exists (
            select 1
            from public.chats
            where chats.id = messages.chat_id
            and (chats.user1_id = auth.uid() or chats.user2_id = auth.uid())
        )
    );
comment on policy "authenticated_select_messages_in_own_chats" on public.messages is 'allows authenticated users to select messages from chats they are a participant in.';

-- authenticated users can insert messages into active chats they participate in
drop policy if exists "authenticated_insert_messages_in_own_active_chats" on public.messages;
create policy "authenticated_insert_messages_in_own_active_chats" on public.messages
    for insert
    to authenticated
    with check (
        sender_id = auth.uid() and
        exists (
            select 1
            from public.chats
            where chats.id = messages.chat_id
            and (chats.user1_id = auth.uid() or chats.user2_id = auth.uid())
            and chats.status = 'active'
        )
    );
comment on policy "authenticated_insert_messages_in_own_active_chats" on public.messages is 'allows authenticated users to send messages in their active chats.';
-- update/delete policies for messages are not defined for MVP.
-- anon users have no direct access to messages.


-- create reports table
create table public.reports (
    id uuid primary key default extensions.uuid_generate_v4(),
    reporting_user_id uuid not null references public.users(id) on delete cascade,
    reported_user_id uuid not null references public.users(id) on delete cascade,
    reason public.report_reason_enum not null,
    description text,
    created_at timestamptz not null default now(),
    constraint reporting_user_cannot_be_reported_user check (reporting_user_id <> reported_user_id)
);
comment on table public.reports is 'stores user-submitted reports about other users.';
comment on column public.reports.id is 'unique identifier for the report.';
comment on column public.reports.reporting_user_id is 'id of the user submitting the report.';
comment on column public.reports.reported_user_id is 'id of the user being reported.';
comment on column public.reports.reason is 'predefined reason for the report.';
comment on column public.reports.description is 'optional additional description for the report.';
comment on column public.reports.created_at is 'timestamp of when the report was submitted.';
comment on constraint reporting_user_cannot_be_reported_user on public.reports is 'ensures a user cannot report themselves.';

-- enable row level security for reports
alter table public.reports enable row level security;

-- rls policies for reports table
-- authenticated users can insert (create) reports
drop policy if exists "authenticated_insert_reports" on public.reports;
create policy "authenticated_insert_reports" on public.reports
    for insert
    to authenticated
    with check (reporting_user_id = auth.uid());
comment on policy "authenticated_insert_reports" on public.reports is 'allows authenticated users to submit new reports.';
-- select, update, delete policies for reports are not defined for anon/authenticated users.
-- report viewing is intended for moderators/admins via backend/service_role.

-- create security_warnings table
create table public.security_warnings (
    id serial primary key,
    message text not null,
    is_active boolean not null default true,
    display_frequency_hours integer not null default 24,
    last_displayed_globally timestamptz,
    created_at timestamptz not null default now()
);
comment on table public.security_warnings is 'stores security warning messages to be displayed to users.';
comment on column public.security_warnings.id is 'unique identifier for the security warning.';
comment on column public.security_warnings.message is 'content of the warning message.';
comment on column public.security_warnings.is_active is 'whether the warning is currently active for display.';
comment on column public.security_warnings.display_frequency_hours is 'suggested minimum display frequency in hours.';
comment on column public.security_warnings.last_displayed_globally is 'timestamp of when this warning was last marked as displayed globally (for system use).';
comment on column public.security_warnings.created_at is 'timestamp of when the warning was created.';

-- enable row level security for security_warnings
alter table public.security_warnings enable row level security;

-- rls policies for security_warnings table
-- anon users can select active security warnings
drop policy if exists "anon_select_active_security_warnings" on public.security_warnings;
create policy "anon_select_active_security_warnings" on public.security_warnings
    for select
    to anon
    using (is_active = true);
comment on policy "anon_select_active_security_warnings" on public.security_warnings is 'allows anonymous users to read active security warnings.';

-- authenticated users can select active security warnings
drop policy if exists "authenticated_select_active_security_warnings" on public.security_warnings;
create policy "authenticated_select_active_security_warnings" on public.security_warnings
    for select
    to authenticated
    using (is_active = true);
comment on policy "authenticated_select_active_security_warnings" on public.security_warnings is 'allows authenticated users to read active security warnings.';
-- insert, update, delete on security_warnings are admin-only operations.


-- create indexes for performance

-- indexes for users table
create index if not exists idx_users_preferred_location_id on public.users(preferred_location_id);
create index if not exists idx_users_last_active_at on public.users(last_active_at desc);
-- users.username is indexed by unique constraint.
-- users.id is indexed by primary key constraint.
comment on index public.idx_users_preferred_location_id is 'speeds up queries filtering users by preferred location.';
comment on index public.idx_users_last_active_at is 'speeds up queries for finding recently active users.';

-- indexes for locations table
-- locations.name is indexed by unique constraint.
-- locations.id is indexed by primary key constraint.
create index if not exists idx_locations_type on public.locations(type);
comment on index public.idx_locations_type is 'speeds up queries filtering locations by type.';

-- indexes for chats table
create index if not exists idx_chats_user1_id on public.chats(user1_id);
create index if not exists idx_chats_user2_id on public.chats(user2_id);
create index if not exists idx_chats_status on public.chats(status);
-- index for unique_chat_pair is created automatically by the unique constraint.
-- chats.id is indexed by primary key constraint.
comment on index public.idx_chats_user1_id is 'speeds up queries finding chats for user1.';
comment on index public.idx_chats_user2_id is 'speeds up queries finding chats for user2.';
comment on index public.idx_chats_status is 'speeds up queries filtering chats by status.';

-- indexes for messages table
create index if not exists idx_messages_chat_id on public.messages(chat_id);
create index if not exists idx_messages_sender_id on public.messages(sender_id);
create index if not exists idx_messages_created_at on public.messages(created_at desc);
-- messages.id is indexed by primary key constraint.
comment on index public.idx_messages_chat_id is 'speeds up queries retrieving messages for a specific chat.';
comment on index public.idx_messages_sender_id is 'speeds up queries related to messages sent by a specific user.';
comment on index public.idx_messages_created_at is 'speeds up sorting messages by creation time, typically for displaying recent messages first.';

-- indexes for reports table
create index if not exists idx_reports_reporting_user_id on public.reports(reporting_user_id);
create index if not exists idx_reports_reported_user_id on public.reports(reported_user_id);
create index if not exists idx_reports_reason on public.reports(reason);
create index if not exists idx_reports_created_at on public.reports(created_at desc);
-- reports.id is indexed by primary key constraint.
comment on index public.idx_reports_reporting_user_id is 'speeds up queries related to reports made by a specific user.';
comment on index public.idx_reports_reported_user_id is 'speeds up queries finding reports against a specific user.';
comment on index public.idx_reports_reason is 'speeds up queries filtering reports by reason.';
comment on index public.idx_reports_created_at is 'speeds up sorting reports by creation time.';

-- indexes for security_warnings table
create index if not exists idx_security_warnings_is_active on public.security_warnings(is_active);
-- security_warnings.id is indexed by primary key constraint (serial).
comment on index public.idx_security_warnings_is_active is 'speeds up queries for fetching active security warnings.';