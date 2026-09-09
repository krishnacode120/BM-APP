-- Stage B only. No Firebase data import, orders, admin RPCs or public writes.
create schema if not exists app_private;
revoke all on schema app_private from public, anon, authenticated;
create schema if not exists extensions;
create extension if not exists btree_gist with schema extensions;
set local search_path = public, extensions;
grant usage on schema public to anon, authenticated;

create table public.locations (
  id text primary key check (length(id) between 1 and 128),
  city text not null check (length(city) between 1 and 120),
  district text not null default '', state text not null default 'Tamil Nadu',
  country text not null default 'India', active boolean not null default false,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.categories (
  id text primary key check (length(id) between 1 and 128),
  name text not null check (length(name) between 1 and 160),
  name_tamil text not null default '', description text not null default '',
  description_tamil text not null default '', image_url text,
  sort_order integer not null default 0, is_active boolean not null default false,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '' check (name = '' or length(btrim(name)) between 2 and 80),
  phone_number text unique check (phone_number ~ '^\+[1-9][0-9]{7,14}$'),
  phone_verified boolean not null default false,
  is_active boolean not null default true,
  preferred_language text not null default 'en' check (preferred_language in ('en','ta')),
  selected_location_id text references public.locations(id),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check (not phone_verified or phone_number is not null)
);
create index profiles_location_idx on public.profiles(selected_location_id);
create table app_private.admin_memberships (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  role text not null check (role in ('admin','super_admin')),
  is_active boolean not null default false,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
alter table app_private.admin_memberships enable row level security;
revoke all on app_private.admin_memberships from public, anon, authenticated;

create table public.products (
  id text primary key check (length(id) between 1 and 128),
  category_id text not null references public.categories(id),
  name text not null check (length(name) between 1 and 160),
  name_tamil text not null default '', description text not null default '',
  description_tamil text not null default '', images text[] not null default '{}',
  thumbnail text, brand text not null default '',
  unit text not null check (unit in ('piece','bag','load','kg','ton','meter','cubicFeet','other')),
  minimum_order_quantity integer not null default 1 check (minimum_order_quantity > 0),
  stock_status text not null default 'hidden'
    check (stock_status in ('available','lowStock','outOfStock','comingSoon','hidden')),
  stock_quantity integer check (stock_quantity >= 0),
  specifications jsonb not null default '{}' check (jsonb_typeof(specifications) = 'object'),
  keywords text[] not null default '{}',
  is_popular boolean not null default false, is_featured boolean not null default false,
  is_active boolean not null default false,
  search_vector tsvector not null default ''::tsvector,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id), updated_by uuid references auth.users(id)
);
create index products_category_idx on public.products(category_id, id);
create index products_created_by_idx on public.products(created_by);
create index products_updated_by_idx on public.products(updated_by);
create index products_visible_idx on public.products(id) where is_active and stock_status <> 'hidden';
create index products_popular_idx on public.products(id) where is_active and is_popular and stock_status <> 'hidden';
create index products_search_idx on public.products using gin(search_vector);
create index categories_active_sort_idx on public.categories(sort_order,id) where is_active;
create index locations_active_city_idx on public.locations(city,id) where active;

create table public.product_prices (
  id uuid primary key default gen_random_uuid(),
  product_id text not null references public.products(id),
  location_id text not null references public.locations(id),
  price numeric(14,2) not null check (price >= 0),
  currency text not null default 'INR' check (currency = 'INR'),
  effective_from timestamptz not null default now(), effective_to timestamptz,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  updated_by uuid references auth.users(id),
  check (effective_to is null or effective_to > effective_from),
  constraint product_prices_no_overlap exclude using gist
    (product_id with =, location_id with =,
     tstzrange(effective_from,effective_to,'[)') with &&)
);
create index prices_lookup_idx on public.product_prices(product_id, location_id, effective_from desc);
create index prices_location_idx on public.product_prices(location_id);
create index prices_updated_by_idx on public.product_prices(updated_by);

create function app_private.touch_updated_at() returns trigger
language plpgsql security invoker set search_path = '' as $$
begin new.updated_at = statement_timestamp(); return new; end $$;
create trigger profiles_touch before update on public.profiles
for each row execute function app_private.touch_updated_at();
create trigger categories_touch before update on public.categories
for each row execute function app_private.touch_updated_at();
create trigger locations_touch before update on public.locations
for each row execute function app_private.touch_updated_at();
create trigger products_touch before update on public.products
for each row execute function app_private.touch_updated_at();

-- Only Auth can invoke this trigger. No metadata fields grant authority.
-- A definer is required because Auth's service role cannot write application tables.
create function app_private.sync_auth_profile() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles(id, phone_number, phone_verified)
  values (new.id,
    case when new.phone_confirmed_at is not null and nullif(new.phone,'') is not null
      then '+' || ltrim(new.phone, '+') else null end,
    new.phone_confirmed_at is not null and nullif(new.phone,'') is not null)
  on conflict(id) do update set
    phone_number = excluded.phone_number, phone_verified = excluded.phone_verified;
  -- Never reset name, is_active or membership on subsequent sign-ins.
  return new;
end $$;
create trigger bm_auth_profile after insert or update of phone, phone_confirmed_at on auth.users
for each row execute function app_private.sync_auth_profile();

create function app_private.index_product_search() returns trigger
language plpgsql security invoker set search_path = '' as $$
declare category_text text;
begin
  select c.name || ' ' || c.name_tamil into category_text from public.categories c where c.id = new.category_id;
  new.search_vector = to_tsvector('simple'::regconfig,
    concat_ws(' ',new.name,new.name_tamil,new.brand,array_to_string(new.keywords,' '),category_text));
  return new;
end $$;
create trigger products_search before insert or update of name,name_tamil,brand,keywords,category_id on public.products
for each row execute function app_private.index_product_search();
create function app_private.refresh_category_search() returns trigger
language plpgsql security invoker set search_path = '' as $$
begin
  update public.products set category_id = new.id where category_id = new.id;
  return new;
end $$;
create trigger categories_search after update of name,name_tamil on public.categories
for each row execute function app_private.refresh_category_search();

create function app_private.protect_price_history() returns trigger
language plpgsql security invoker set search_path = '' as $$
begin
  if tg_op = 'DELETE' then raise exception 'Price history cannot be deleted'; end if;
  if (to_jsonb(new) - 'effective_to' - 'updated_at') is distinct from
     (to_jsonb(old) - 'effective_to' - 'updated_at') or old.effective_to is not null
     or new.effective_to is null then
    raise exception 'Only closing an open price period is allowed';
  end if;
  new.updated_at = statement_timestamp();
  return new;
end $$;
create trigger prices_history before update or delete on public.product_prices
for each row execute function app_private.protect_price_history();

alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.locations enable row level security;
alter table public.products enable row level security;
alter table public.product_prices enable row level security;
revoke all on public.profiles, public.categories, public.locations,
  public.products, public.product_prices from public, anon, authenticated;
grant select on public.categories, public.locations, public.products, public.product_prices to anon, authenticated;
grant select on public.profiles to authenticated;
grant update(name,preferred_language,selected_location_id) on public.profiles to authenticated;

create policy profiles_own_read on public.profiles for select to authenticated
  using (id = (select auth.uid()) and is_active);
create policy profiles_own_preferences on public.profiles for update to authenticated
  using (id = (select auth.uid()) and is_active and phone_verified)
  with check (id = (select auth.uid()) and is_active and phone_verified and
    (selected_location_id is null or exists(select 1 from public.locations l where l.id = selected_location_id and l.active)));
create policy categories_public_read on public.categories for select to anon, authenticated using(is_active);
create policy locations_public_read on public.locations for select to anon, authenticated using(active);
create policy products_public_read on public.products for select to anon, authenticated using
  (is_active and stock_status <> 'hidden' and exists(select 1 from public.categories c where c.id = category_id and c.is_active));
create policy prices_public_read on public.product_prices for select to anon, authenticated using
  (exists(select 1 from public.products p where p.id = product_id) and
   exists(select 1 from public.locations l where l.id = location_id and l.active));

-- SECURITY INVOKER: these bounded read RPCs obey the caller's RLS.
create function public.catalog_products(p_category text default null, p_query text default null,
  p_after text default null, p_limit integer default 30, p_popular boolean default false)
returns setof public.products language sql stable security invoker set search_path = '' as $$
  select p.* from public.products p
  where p.is_active and p.stock_status <> 'hidden'
    and (p_category is null or p.category_id = p_category)
    and (p_after is null or p.id > p_after)
    and (not p_popular or p.is_popular)
    and (nullif(btrim(p_query),'') is null or
      p.search_vector @@ plainto_tsquery('simple'::regconfig,left(p_query,120)))
  order by p.id limit greatest(1,least(coalesce(p_limit,30),50));
$$;
create function public.current_product_price(p_product_id text, p_location_id text)
returns setof public.product_prices language sql stable security invoker set search_path = '' as $$
  select pp.* from public.product_prices pp
  where pp.product_id = p_product_id and pp.location_id = p_location_id
    and pp.effective_from <= statement_timestamp()
    and (pp.effective_to is null or pp.effective_to > statement_timestamp())
  order by pp.effective_from desc limit 1;
$$;
revoke all on function public.catalog_products(text,text,text,integer,boolean) from public, anon, authenticated;
revoke all on function public.current_product_price(text,text) from public, anon, authenticated;
grant execute on function public.catalog_products(text,text,text,integer,boolean) to anon, authenticated;
grant execute on function public.current_product_price(text,text) to anon, authenticated;
revoke all on all functions in schema app_private from public, anon, authenticated;
