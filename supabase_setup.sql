-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Create profiles table
create table public.profiles (
  id uuid references auth.users not null primary key,
  username text unique not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Turn on RLS
alter table public.profiles enable row level security;

-- Policies for profiles
create policy "Public profiles are viewable by everyone."
  on profiles for select
  using ( true );

create policy "Users can insert their own profile."
  on profiles for insert
  with check ( auth.uid() = id );

create policy "Users can update own profile."
  on profiles for update
  using ( auth.uid() = id );

-- Create sounds table
create table public.sounds (
  id uuid default uuid_generate_v4() primary key,
  title text not null,
  file_path text not null,
  uploader_id uuid references public.profiles(id) not null,
  play_count int default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Turn on RLS
alter table public.sounds enable row level security;

-- Policies for sounds
create policy "Sounds are viewable by everyone."
  on sounds for select
  using ( true );

create policy "Authenticated users can upload sounds."
  on sounds for insert
  with check ( auth.uid() = uploader_id );

-- Create storage bucket for sounds
insert into storage.buckets (id, name, public) values ('sounds', 'sounds', true);

-- Storage policies
create policy "Sounds are publicly accessible."
  on storage.objects for select
  using ( bucket_id = 'sounds' );

create policy "Authenticated users can upload sounds."
  on storage.objects for insert
  with check ( bucket_id = 'sounds' and auth.role() = 'authenticated' );
