-- OPTIONAL development-only synthetic catalog. Never run automatically at startup.
-- First: set app.bm_development_seed = 'approved';
do $$ begin
  if current_setting('app.bm_development_seed',true) is distinct from 'approved'
  then raise exception 'Explicit development seed approval required'; end if;
end $$;
begin;
insert into public.categories(id,name,name_tamil,description,description_tamil,sort_order,is_active)
values ('dev-bricks','[DEMO] Bricks','[DEMO] செங்கற்கள்','Synthetic development catalog','சோதனைப் பொருட்கள்',1,true)
on conflict do nothing;
insert into public.locations(id,city,district,state,country,active) values
('dev-karaikudi','Karaikudi [DEMO]','Sivaganga','Tamil Nadu','India',true),
('dev-madurai','Madurai [DEMO]','Madurai','Tamil Nadu','India',true) on conflict do nothing;
insert into public.products(id,category_id,name,name_tamil,description,description_tamil,unit,
minimum_order_quantity,stock_status,keywords,is_popular,is_active) values
('dev-red-brick','dev-bricks','[DEMO] Red Clay Brick','[DEMO] செங்கல்','Not a live offer','சோதனைக்கான பொருள்','piece',
500,'available','{brick,red brick,செங்கல்}',true,true),
('dev-fly-ash','dev-bricks','[DEMO] Fly Ash Brick','[DEMO] ஃப்ளை ஆஷ் செங்கல்','Not a live offer','சோதனைக்கான பொருள்','piece',
500,'outOfStock','{brick,fly ash}',false,true) on conflict do nothing;
insert into public.product_prices(product_id,location_id,price,effective_from) values
('dev-red-brick','dev-karaikudi',8,'2020-01-01Z'),
('dev-red-brick','dev-madurai',8.5,'2020-01-01Z') on conflict do nothing;
commit;
