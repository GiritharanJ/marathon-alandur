-- Run in Supabase > SQL Editor
create table registrations (
  id uuid primary key default gen_random_uuid(),
  reg_no text unique,
  full_name text not null, age_group text not null, gender text not null,
  mobile text not null, whatsapp text, area text not null,
  tshirt text not null, health text, screenshot_url text not null,
  status text not null default 'pending' check (status in ('pending','confirmed','rejected')),
  created_at timestamptz default now()
);
create table sponsors (
  id uuid primary key default gen_random_uuid(),
  org_name text not null, contact_name text not null, mobile text not null,
  email text, tier text not null, amount numeric, message text, proof_url text,
  status text not null default 'new' check (status in ('new','contacted','confirmed','declined')),
  created_at timestamptz default now()
);
create sequence reg_seq start 1;
-- Registration number is issued when admin confirms
create function issue_reg_no() returns trigger language plpgsql as $$
begin
  if new.status='confirmed' and new.reg_no is null then
    new.reg_no := 'CMF-' || lpad(nextval('reg_seq')::text,4,'0');
  end if;
  return new;
end $$;
create trigger trg_reg_no before insert or update on registrations
  for each row execute function issue_reg_no();

alter table registrations enable row level security;
alter table sponsors enable row level security;
create policy "public can register" on registrations for insert to anon with check (status='pending');
create policy "public can sponsor"  on sponsors for insert to anon with check (status='new');
create policy "admin all reg" on registrations for all to authenticated using (true) with check (true);
create policy "admin all spn" on sponsors for all to authenticated using (true) with check (true);

-- Storage bucket for screenshots
insert into storage.buckets (id,name,public) values ('uploads','uploads',true);
create policy "public upload" on storage.objects for insert to anon with check (bucket_id='uploads');
create policy "admin read" on storage.objects for select to authenticated using (bucket_id='uploads');
