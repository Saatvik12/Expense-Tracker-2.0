create table categories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name text not null,
  unique (user_id, name)
);

create table entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  type text not null check (type in ('in','out')),
  amount numeric(12,2) not null check (amount > 0),
  mode text not null check (mode in ('cash','fampay')),
  category text,
  note text,
  entry_date date not null default current_date,
  created_at timestamptz not null default now()
);

create table keeper_moves (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  direction text not null check (direction in ('to_keeper','from_keeper')),
  amount numeric(12,2) not null check (amount > 0),
  note text,
  move_date date not null default current_date,
  created_at timestamptz not null default now()
);

create index on entries (user_id, entry_date);
create index on keeper_moves (user_id, move_date);

alter table categories   enable row level security;
alter table entries      enable row level security;
alter table keeper_moves enable row level security;

create policy own on categories   for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy own on entries      for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy own on keeper_moves for all using (user_id = auth.uid()) with check (user_id = auth.uid());



create table settings (
  user_id uuid primary key default auth.uid() references auth.users(id) on delete cascade,
  monthly_cap numeric(12,2),
  warn80 boolean not null default true
);
alter table settings enable row level security;
create policy own on settings for all using (user_id = auth.uid()) with check (user_id = auth.uid());
