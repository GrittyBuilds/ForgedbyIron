-- Forged by Iron — Supabase setup
-- Run this once in your Supabase project: Dashboard → SQL Editor → New query → paste → Run.
-- It creates the table the app syncs to and locks it down with Row-Level Security
-- so each signed-in user can only read and write their own row.

-- 1. The table: one JSON blob per user (the app strips progress photos before syncing).
create table if not exists public.tracker_data (
  user_id    uuid primary key references auth.users (id) on delete cascade default auth.uid(),
  payload    jsonb       not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- 2. Turn on Row-Level Security (deny-by-default once enabled).
alter table public.tracker_data enable row level security;

-- 3. Policies: a user may only touch the row whose user_id matches their auth id.
drop policy if exists "own row - select" on public.tracker_data;
create policy "own row - select" on public.tracker_data
  for select using (auth.uid() = user_id);

drop policy if exists "own row - insert" on public.tracker_data;
create policy "own row - insert" on public.tracker_data
  for insert with check (auth.uid() = user_id);

drop policy if exists "own row - update" on public.tracker_data;
create policy "own row - update" on public.tracker_data
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "own row - delete" on public.tracker_data;
create policy "own row - delete" on public.tracker_data
  for delete using (auth.uid() = user_id);

-- 4. (Optional) If you don't want to deal with confirmation emails while testing,
--    go to Authentication → Providers → Email and turn OFF "Confirm email".
--    With it on, "Create account" in the app will ask you to confirm via email first,
--    then sign in.
