-- One-time setup for the personal navigation portal cloud sync.
-- Run this in Supabase Dashboard -> SQL Editor -> New query.
-- This table stores each signed-in user's own navigation data.

create table if not exists public.portal_profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.portal_profiles enable row level security;

-- Browser clients should only use the authenticated role for this table.
revoke all on table public.portal_profiles from anon;
grant select, insert, update on table public.portal_profiles to authenticated;

drop policy if exists "Users can read their own portal profile" on public.portal_profiles;
create policy "Users can read their own portal profile"
  on public.portal_profiles
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "Users can insert their own portal profile" on public.portal_profiles;
create policy "Users can insert their own portal profile"
  on public.portal_profiles
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update their own portal profile" on public.portal_profiles;
create policy "Users can update their own portal profile"
  on public.portal_profiles
  for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
