-- VNA Document Vault: run once in Supabase > SQL Editor
create table public.members(
  user_id uuid primary key references auth.users on delete cascade,
  role text not null default 'member' check (role in ('admin','member')));
create function public.is_member() returns boolean language sql security definer set search_path=public stable
 as $$ select exists(select 1 from public.members where user_id=auth.uid()) $$;
create function public.is_admin() returns boolean language sql security definer set search_path=public stable
 as $$ select exists(select 1 from public.members where user_id=auth.uid() and role='admin') $$;

create table public.documents(
  id uuid primary key default gen_random_uuid(),
  name text not null, kind text not null default 'file', mime text, size bigint default 0,
  path text, category text default 'Other', tags text default '', description text default '',
  body text, fav boolean default false,
  created_by uuid default auth.uid(), created_at timestamptz default now(), updated_at timestamptz default now());

alter table public.members enable row level security;
alter table public.documents enable row level security;
create policy "members read own role" on public.members for select using (user_id=auth.uid() or public.is_admin());
create policy "admins manage members" on public.members for all using (public.is_admin()) with check (public.is_admin());
create policy "members read docs" on public.documents for select using (public.is_member());
create policy "members add docs" on public.documents for insert with check (public.is_member());
create policy "members edit docs" on public.documents for update using (public.is_member());
create policy "admins delete docs" on public.documents for delete using (public.is_admin());

-- Private storage bucket (20 MB per file)
insert into storage.buckets(id,name,public,file_size_limit) values('vault','vault',false,20971520) on conflict (id) do nothing;
create policy "members read files" on storage.objects for select using (bucket_id='vault' and public.is_member());
create policy "members upload files" on storage.objects for insert with check (bucket_id='vault' and public.is_member());
create policy "members update files" on storage.objects for update using (bucket_id='vault' and public.is_member());
create policy "admins delete files" on storage.objects for delete using (bucket_id='vault' and public.is_admin());

-- After creating your first user (Authentication > Users), make them admin:
-- insert into public.members(user_id,role) values ('PASTE-USER-UUID','admin');
-- Add more people later:
-- insert into public.members(user_id,role) select id,'member' from auth.users where email='person@example.org';
