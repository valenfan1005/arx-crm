-- ARX KOL CRM — Supabase schema
-- Run this in Supabase Dashboard → SQL Editor → New Query

-- =========================================================
-- 1. Options table — customizable dropdowns (no code change to add new options)
-- =========================================================
create table if not exists options (
  id bigserial primary key,
  category text not null,
  value text not null,
  sort_order int default 0,
  created_at timestamptz default now(),
  unique(category, value)
);

-- Seed initial options from Excel template
insert into options (category, value, sort_order) values
  -- Status flow (shared by all 3 modules)
  ('status', 'Prospects', 1),
  ('status', 'In Contact', 2),
  ('status', 'In Negotiating', 3),
  ('status', 'Ready to Sign', 4),
  ('status', 'Rejected', 5),
  -- Trader sub-category (P0)
  ('trader_sub_category', 'Crypto Trading', 1),
  ('trader_sub_category', 'CFD Trading', 2),
  -- Non-Trader sub-category (P1)
  ('nontrader_sub_category', 'Crypto Native', 1),
  ('nontrader_sub_category', 'Non-Crypto Native', 2),
  -- Trading asset
  ('trading_asset', 'Crypto', 1),
  ('trading_asset', 'CFD', 2),
  -- Trading pairs
  ('trading_pairs', 'Gold', 1),
  ('trading_pairs', 'Index', 2),
  ('trading_pairs', 'Oil', 3),
  ('trading_pairs', 'Silver', 4),
  ('trading_pairs', 'BTC', 5),
  ('trading_pairs', 'ETH', 6),
  ('trading_pairs', 'Forex', 7),
  -- Trading platform
  ('trading_platform', 'OKX', 1),
  ('trading_platform', 'Binance', 2),
  ('trading_platform', 'Bybit', 3),
  ('trading_platform', 'Hyperliquid', 4),
  ('trading_platform', 'EXNESS', 5),
  ('trading_platform', 'XM', 6),
  ('trading_platform', 'IC Markets', 7),
  -- Social content
  ('social_content', 'Trading Signal', 1),
  ('social_content', 'Copy Trading', 2),
  ('social_content', 'Educational', 3),
  ('social_content', 'Market Analysis', 4),
  ('social_content', 'News', 5),
  -- Main content type
  ('content_type', 'Short Video', 1),
  ('content_type', 'Long Video', 2),
  ('content_type', 'Live streaming', 3),
  ('content_type', 'Text Post', 4),
  ('content_type', 'Newsletter', 5),
  -- Language
  ('language', 'English', 1),
  ('language', 'Korean', 2),
  ('language', 'Vietnamese', 3),
  ('language', 'Chinese', 4),
  ('language', 'Thai', 5),
  ('language', 'Japanese', 6),
  -- Region
  ('region', 'Korea', 1),
  ('region', 'Vietnam', 2),
  ('region', 'Taiwan', 3),
  ('region', 'Philippines', 4),
  ('region', 'Thailand', 5),
  ('region', 'Greater China', 6),
  ('region', 'Global', 7),
  -- Owner (BD assignee)
  ('owner', 'Valen', 1),
  ('owner', 'Harry', 2),
  ('owner', 'Alina', 3)
on conflict (category, value) do nothing;

-- =========================================================
-- 2. Trader KOL (P0) — full Trading + Social info
-- =========================================================
create table if not exists trader_kols (
  id bigserial primary key,
  name text not null,
  status text not null default 'Prospects',
  sub_category text,
  trading_asset text,
  trading_pairs text,
  trading_platform text,
  social_content text,
  main_content_type text,
  language text,
  region text,
  youtube_link text,
  youtube_followers bigint,
  twitter_link text,
  twitter_followers bigint,
  telegram_link text,
  telegram_members bigint,
  contact_no text,
  email text,
  terms text,
  feedback text,
  owner text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- =========================================================
-- 3. Non-Trader KOL (P1) — Social info only
-- =========================================================
create table if not exists non_trader_kols (
  id bigserial primary key,
  name text not null,
  status text not null default 'Prospects',
  sub_category text,
  social_content text,
  main_content_type text,
  language text,
  region text,
  youtube_link text,
  youtube_followers bigint,
  twitter_link text,
  twitter_followers bigint,
  telegram_link text,
  telegram_members bigint,
  contact_no text,
  email text,
  terms text,
  feedback text,
  owner text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- =========================================================
-- 4. Agency (P0)
-- =========================================================
create table if not exists agencies (
  id bigserial primary key,
  name text not null,
  status text not null default 'Prospects',
  account text,
  website text,
  region text,
  kol_type text,
  kol_qty int,
  contact_person text,
  contact_no text,
  email text,
  terms text,
  feedback text,
  owner text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- =========================================================
-- 5. updated_at trigger
-- =========================================================
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trader_kols_updated_at on trader_kols;
create trigger trader_kols_updated_at before update on trader_kols
  for each row execute function set_updated_at();

drop trigger if exists non_trader_kols_updated_at on non_trader_kols;
create trigger non_trader_kols_updated_at before update on non_trader_kols
  for each row execute function set_updated_at();

drop trigger if exists agencies_updated_at on agencies;
create trigger agencies_updated_at before update on agencies
  for each row execute function set_updated_at();

-- =========================================================
-- 6. RLS — all authenticated users can read/write everything
-- =========================================================
alter table options enable row level security;
alter table trader_kols enable row level security;
alter table non_trader_kols enable row level security;
alter table agencies enable row level security;

drop policy if exists "auth_all_options" on options;
create policy "auth_all_options" on options
  for all to authenticated using (true) with check (true);

drop policy if exists "auth_all_trader" on trader_kols;
create policy "auth_all_trader" on trader_kols
  for all to authenticated using (true) with check (true);

drop policy if exists "auth_all_nontrader" on non_trader_kols;
create policy "auth_all_nontrader" on non_trader_kols
  for all to authenticated using (true) with check (true);

drop policy if exists "auth_all_agencies" on agencies;
create policy "auth_all_agencies" on agencies
  for all to authenticated using (true) with check (true);

-- =========================================================
-- 7. Indexes for common filters
-- =========================================================
create index if not exists trader_kols_status_idx on trader_kols(status);
create index if not exists trader_kols_owner_idx on trader_kols(owner);
create index if not exists trader_kols_region_idx on trader_kols(region);
create index if not exists non_trader_kols_status_idx on non_trader_kols(status);
create index if not exists non_trader_kols_owner_idx on non_trader_kols(owner);
create index if not exists agencies_status_idx on agencies(status);
create index if not exists agencies_owner_idx on agencies(owner);
