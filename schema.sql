-- ───────────────────────────────────────────────────────────────
-- The Grind — Supabase schema (multi-player)
-- Paste ALL of this into Supabase → SQL Editor → New query → Run.
-- Safe to run more than once; it never drops your data.
-- ───────────────────────────────────────────────────────────────

-- One row per person in a room
create table if not exists public.grind_players (
  id         bigint generated always as identity primary key,
  room       text not null,
  name       text not null,
  created_at timestamptz not null default now()
);
create index if not exists grind_players_room_idx on public.grind_players (room);

-- Optional LeetCode sync: link a person to their public LeetCode profile so their
-- score, streak and activity heatmap auto-populate. Safe to run on an existing table.
alter table public.grind_players add column if not exists leetcode_username text;
alter table public.grind_players add column if not exists lc_stats     jsonb;
alter table public.grind_players add column if not exists lc_synced_at timestamptz;

-- One row per solved problem, tied to a person
create table if not exists public.grind_solves (
  id         bigint generated always as identity primary key,
  room       text not null,
  player_id  bigint not null,
  title      text not null,
  num        text,
  topic      text,
  diff       text not null check (diff in ('e','m','h')),
  solved_on  date not null default current_date,
  created_at timestamptz not null default now()
);
create index if not exists grind_solves_room_idx on public.grind_solves (room);

-- Access: no login. Privacy is via the shared room code only.
grant all on public.grind_players, public.grind_solves to anon;

alter table public.grind_players enable row level security;
alter table public.grind_solves  enable row level security;

drop policy if exists "anon players" on public.grind_players;
drop policy if exists "anon solves"  on public.grind_solves;
create policy "anon players" on public.grind_players for all to anon using (true) with check (true);
create policy "anon solves"  on public.grind_solves  for all to anon using (true) with check (true);

-- Send full old row on updates/deletes so realtime room-filters match reliably
alter table public.grind_players replica identity full;
alter table public.grind_solves  replica identity full;

-- Turn on realtime push (safe to re-run)
do $$ begin alter publication supabase_realtime add table public.grind_players; exception when others then null; end $$;
do $$ begin alter publication supabase_realtime add table public.grind_solves;  exception when others then null; end $$;
