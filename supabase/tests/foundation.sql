-- Synthetic identities/catalog only; fixtures roll back, never copy customer PII.
begin;
create function pg_temp.assert_true(value boolean, label text) returns void
language plpgsql as $$ begin
  if value is distinct from true then raise exception 'FAIL: %',label; end if;
  raise notice 'PASS: %',label;
end $$;
create function pg_temp.denied(statement text, label text) returns void
language plpgsql as $$ begin
  begin execute statement;
  exception when insufficient_privilege then
    raise notice 'PASS: %',label; return;
  end;
  raise exception 'FAIL (operation permitted): %',label;
end $$;
insert into auth.users(id,phone,phone_confirmed_at,raw_user_meta_data) values
('00000000-0000-0000-0000-000000000001','919000000001',now(),'{"role":"super_admin","is_active":true}'),
('00000000-0000-0000-0000-000000000002','919000000002',now(),'{}'),
('00000000-0000-0000-0000-000000000003','919000000003',null,'{}');
select pg_temp.assert_true((select count(*)=3 from public.profiles),'Auth trigger creates profiles');
select pg_temp.assert_true((select count(*)=0 from app_private.admin_memberships),'metadata cannot grant admin');
select pg_temp.assert_true((select not phone_verified and phone_number is null from public.profiles where id='00000000-0000-0000-0000-000000000003'),'unverified Auth phone not trusted');
insert into public.categories(id,name,name_tamil,is_active) values
('bricks','Bricks','செங்கற்கள்',true),('inactive','Hidden category','',false);
insert into public.locations(id,city,active) values ('karaikudi','Karaikudi',true),('madurai','Madurai',true),('inactive','Hidden',false);
insert into public.products(id,category_id,name,name_tamil,brand,unit,keywords,is_active,stock_status,minimum_order_quantity) values
('a','bricks','Red Clay Brick','செங்கல்','BM','piece','{brick,red brick}',true,'available',500),
('b','bricks','Low','சிமெண்ட்','Brand','bag','{}',true,'lowStock',10),
('c','bricks','Out of stock','','','load','{}',true,'outOfStock',1),
('d','bricks','Coming soon','','','kg','{}',true,'comingSoon',1),
('e','bricks','Hidden product','','','piece','{}',true,'hidden',1),
('f','bricks','Inactive product','','','piece','{}',false,'available',1),
('g','inactive','Inactive parent','','','piece','{}',true,'available',1);
insert into public.product_prices(product_id,location_id,price,effective_from,effective_to) values
('a','karaikudi',7,'2020-01-01Z','2021-01-01Z'),
('a','karaikudi',8,'2021-01-01Z',null),
('a','madurai',8.50,'2021-01-01Z',null),
('b','karaikudi',430,'2099-01-01Z',null),
('e','karaikudi',1,'2021-01-01Z',null),
('g','karaikudi',1,'2021-01-01Z',null),
('a','inactive',1,'2021-01-01Z',null);
do $$ begin
  begin insert into public.product_prices(product_id,location_id,price,effective_from) values ('a','karaikudi',99,'2022-01-01Z');
    raise exception 'Overlap allowed'; exception when exclusion_violation then raise notice 'PASS: overlapping prices rejected'; end;
  begin insert into public.products(id,category_id,name,unit,minimum_order_quantity) values ('bad','bricks','Bad','piece',0);
    raise exception 'Invalid minimum allowed'; exception when check_violation then raise notice 'PASS: minimum quantity constraint'; end;
  begin update public.product_prices set price=10 where product_id='a';
    raise exception 'Price mutation allowed'; exception when raise_exception then
      if sqlerrm <> 'Only closing an open price period is allowed' then raise; end if;
      raise notice 'PASS: destructive price updates rejected'; end;
end $$;

set local role anon;
select pg_temp.assert_true((select count(*)=1 from public.categories),'anon active categories only');
select pg_temp.assert_true((select count(*)=2 from public.locations),'anon active locations only');
select pg_temp.assert_true((select count(*)=4 from public.products),'hidden/inactive/parent-inactive products filtered');
select pg_temp.assert_true((select count(*)=0 from public.products where id='e'),'direct hidden ID read denied');
select pg_temp.assert_true((select count(*)=4 from public.product_prices),'hidden product/location prices not exposed');
select pg_temp.assert_true((select price=8 from public.current_product_price('a','karaikudi')),'location Karaikudi price');
select pg_temp.assert_true((select price=8.5 from public.current_product_price('a','madurai')),'location Madurai numeric price');
select pg_temp.assert_true((select count(*)=0 from public.current_product_price('b','karaikudi')),'future price not applicable');
select pg_temp.assert_true((select count(*)=0 from public.current_product_price('c','karaikudi')),'missing price empty not zero');
select pg_temp.assert_true((select count(*)=1 from public.catalog_products(p_query=>'red brick')),'multi-word English search');
select pg_temp.assert_true((select count(*)=1 from public.catalog_products(p_query=>'செங்கல்')),'Tamil search');
select pg_temp.assert_true((select count(*)=1 from public.catalog_products(p_query=>'Brand')),'brand search');
select pg_temp.assert_true((select count(*)=4 from public.catalog_products(p_query=>'Bricks')),'category search');
select pg_temp.assert_true((select count(*)=0 from public.catalog_products(p_query=>'unfindable')),'empty search results');
select pg_temp.assert_true((select count(*)=2 from public.catalog_products(p_after=>'b',p_limit=>2)),'bounded keyset pagination');
select pg_temp.denied('select * from public.profiles','anonymous cannot read profiles');
select pg_temp.denied('insert into public.categories(id,name) values (''evil'',''Evil'')','anonymous cannot write categories');
select pg_temp.denied('update public.product_prices set price=0','anonymous cannot change prices');
select pg_temp.denied('select * from app_private.admin_memberships','anonymous cannot access admin schema');
select pg_temp.denied('select app_private.sync_auth_profile()','private definer function not callable');
reset role;
select set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000001',true);
set local role authenticated;
select pg_temp.assert_true((select count(*)=1 from public.profiles),'customer own profile only');
update public.profiles set name='Test Customer',preferred_language='ta',selected_location_id='karaikudi'
where id='00000000-0000-0000-0000-000000000001';
select pg_temp.assert_true((select name='Test Customer' and preferred_language='ta' from public.profiles),'permitted name/language/location update');
update public.profiles set name='Stolen' where id='00000000-0000-0000-0000-000000000002';
select pg_temp.denied('update public.profiles set is_active=false','cannot set active status');
select pg_temp.denied('update public.profiles set phone_verified=false','cannot change verified flag');
select pg_temp.denied('update public.profiles set phone_number=''+919000000099''','cannot change identity phone');
select pg_temp.denied('update public.profiles set id=''00000000-0000-0000-0000-000000000002''','cannot change ownership');
select pg_temp.denied('update public.profiles set selected_location_id=''inactive''','inactive selected location denied');
select pg_temp.denied('insert into public.profiles(id) values (''00000000-0000-0000-0000-000000000004'')','cannot create arbitrary profile');
select pg_temp.denied('update public.products set stock_status=''available''','customer cannot change inventory');
select pg_temp.denied('insert into app_private.admin_memberships(user_id,role) values (auth.uid(),''super_admin'')','customer cannot self-promote');
reset role;
select pg_temp.assert_true((select name='' from public.profiles where id='00000000-0000-0000-0000-000000000002'),'other profile unchanged');
update public.profiles set is_active=false where id='00000000-0000-0000-0000-000000000001';
update auth.users set phone_confirmed_at=now() where id='00000000-0000-0000-0000-000000000001';
select pg_temp.assert_true((select not is_active and name='Test Customer' from public.profiles where id='00000000-0000-0000-0000-000000000001'),'Auth refresh cannot reactivate or overwrite name');
set local role authenticated;
select pg_temp.assert_true((select count(*)=0 from public.profiles),'inactive profile inaccessible');
reset role;
update public.categories set name='Masonry' where id='bricks';
set local role anon;
select pg_temp.assert_true((select count(*)=4 from public.catalog_products(p_query=>'Masonry')),'category rename refreshes indexed search');
reset role;
rollback;
