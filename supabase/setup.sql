-- =====================================================================
-- TAMREEN DATABASE SETUP
-- Paste ALL of this into Supabase > SQL Editor > New query, then click Run.
-- Run it once only, on a fresh project.
-- =====================================================================

-- ---------- Tables ----------

create table public.categories (
  id          text primary key,
  name_en     text not null,
  name_ar     text not null,
  sort_order  int  not null default 0
);

-- Public trainer profiles (what parents see). No contact details here.
create table public.trainers (
  id                text primary key default gen_random_uuid()::text,
  category_id       text not null references public.categories(id),
  name_en           text not null,
  name_ar           text,
  area_en           text,
  area_ar           text,
  ages_en           text,
  ages_ar           text,
  about_en          text,
  about_ar          text,
  price_egp         int,
  years_experience  int,
  slots             jsonb not null default '[]'::jsonb,  -- [{"day_en","day_ar","hours_en","hours_ar"}]
  areas             jsonb not null default '[]'::jsonb,  -- [{"en","ar"}]
  color             text not null default '#1E2A44',
  lat               double precision,
  lng               double precision,
  is_published      boolean not null default true,
  created_at        timestamptz not null default now()
);

-- Trainer contact details: only your operators can see these.
create table public.trainer_private (
  trainer_id      text primary key references public.trainers(id) on delete cascade,
  phone           text,
  whatsapp        text,
  email           text,
  internal_notes  text
);

-- One row per app user. Role decides parent mode, trainer mode or operator.
create table public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  role        text not null default 'parent' check (role in ('parent', 'trainer', 'operator')),
  full_name   text,
  phone       text,
  trainer_id  text references public.trainers(id),
  created_at  timestamptz not null default now()
);

create table public.bookings (
  id                uuid primary key default gen_random_uuid(),
  ref               bigint generated always as identity (start with 1001),
  parent_id         uuid not null default auth.uid() references auth.users(id) on delete cascade,
  trainer_id        text not null references public.trainers(id),
  child_name        text not null,
  child_age         int check (child_age between 1 and 18),
  days              text[] not null default '{}',
  time_of_day       text,
  place             text,
  area              text,
  notes             text,
  status            text not null default 'new'
                    check (status in ('new', 'contacting', 'alternative_offered', 'confirmed', 'declined', 'cancelled')),
  alternative_time  text,
  operator_notes    text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create table public.reviews (
  id              uuid primary key default gen_random_uuid(),
  trainer_id      text not null references public.trainers(id) on delete cascade,
  booking_id      uuid unique references public.bookings(id) on delete set null,
  author_id       uuid default auth.uid() references auth.users(id) on delete set null,
  author_label_en text,
  author_label_ar text,
  stars           int not null check (stars between 1 and 5),
  comment         text,
  created_at      timestamptz not null default now()
);

-- What the app lists: published trainers with their average rating.
create view public.trainer_cards with (security_invoker = true) as
select t.*,
       coalesce(round(avg(r.stars)::numeric, 1), 0) as rating,
       count(r.id)::int as review_count
from public.trainers t
left join public.reviews r on r.trainer_id = t.id
where t.is_published
group by t.id;

-- ---------- Helper functions ----------

create or replace function public.is_operator()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'operator');
$$;

-- Every new user gets a profile (role = parent by default).
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id) values (new.id) on conflict do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger bookings_touch_updated_at
  before update on public.bookings
  for each row execute function public.touch_updated_at();

-- Parent actions (parents can't edit bookings directly, only through these).
create or replace function public.cancel_booking(p_booking_id uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  update public.bookings set status = 'cancelled'
  where id = p_booking_id and parent_id = auth.uid()
    and status in ('new', 'contacting', 'alternative_offered');
  if not found then raise exception 'This booking can no longer be cancelled'; end if;
end;
$$;

create or replace function public.respond_to_alternative(p_booking_id uuid, p_accept boolean)
returns void language plpgsql security definer set search_path = public as $$
begin
  update public.bookings
  set status = case when p_accept then 'confirmed' else 'cancelled' end
  where id = p_booking_id and parent_id = auth.uid() and status = 'alternative_offered';
  if not found then raise exception 'There is no new time to respond to'; end if;
end;
$$;

-- ---------- Security rules (who can see and change what) ----------

alter table public.categories      enable row level security;
alter table public.trainers        enable row level security;
alter table public.trainer_private enable row level security;
alter table public.profiles        enable row level security;
alter table public.bookings        enable row level security;
alter table public.reviews         enable row level security;

create policy "Anyone can read categories" on public.categories
  for select using (true);

create policy "Anyone can read published trainers" on public.trainers
  for select using (is_published or public.is_operator());
create policy "Operators manage trainers" on public.trainers
  for all using (public.is_operator()) with check (public.is_operator());

create policy "Operators manage trainer contacts" on public.trainer_private
  for all using (public.is_operator()) with check (public.is_operator());

create policy "Users read own profile" on public.profiles
  for select using (id = auth.uid() or public.is_operator());

create policy "Parents read own bookings" on public.bookings
  for select using (parent_id = auth.uid() or public.is_operator());
create policy "Parents create booking requests" on public.bookings
  for insert with check (
    parent_id = auth.uid() and status = 'new'
    and alternative_time is null and operator_notes is null
  );
create policy "Operators update bookings" on public.bookings
  for update using (public.is_operator()) with check (public.is_operator());

create policy "Anyone can read reviews" on public.reviews
  for select using (true);
create policy "Parents review their confirmed bookings" on public.reviews
  for insert with check (
    author_id = auth.uid()
    and reviews.booking_id is not null
    and exists (
      select 1 from public.bookings b
      where b.id = reviews.booking_id
        and b.parent_id = auth.uid()
        and b.status = 'confirmed'
        and b.trainer_id = reviews.trainer_id
    )
  );

-- ---------- Starting data ----------

insert into public.categories (id, name_en, name_ar, sort_order) values
  ('football', 'Football', 'كرة القدم', 1),
  ('swimming', 'Swimming', 'سباحة', 2),
  ('drawing',  'Drawing',  'رسم', 3),
  ('piano',    'Piano',    'بيانو', 4),
  ('chess',    'Chess',    'شطرنج', 5),
  ('karate',   'Karate',   'كاراتيه', 6),
  ('tennis',   'Tennis',   'تنس', 7),
  ('ballet',   'Ballet',   'باليه', 8);

-- SAMPLE trainers so the app has something to show. Replace with your real trainers.
insert into public.trainers
  (id, category_id, name_en, name_ar, area_en, area_ar, ages_en, ages_ar, about_en, about_ar,
   price_egp, years_experience, color, slots, areas)
values
  ('sample-1', 'football', 'Karim Adel', 'كريم عادل', 'Nasr City', 'مدينة نصر', '6–14 yrs', '6–14 سنة',
   'Former player and certified youth coach. Focuses on core skills, fitness and teamwork, with a monthly progress check for each child.',
   'لاعب كرة سابق ومدرب ناشئين معتمد. يركّز على المهارات الأساسية واللياقة وروح الفريق، مع متابعة شهرية لمستوى كل طفل.',
   300, 8, '#166534',
   '[{"day_en":"Saturday","day_ar":"السبت","hours_en":"4 – 8 pm","hours_ar":"4 – 8 م"},
     {"day_en":"Monday","day_ar":"الاثنين","hours_en":"5 – 9 pm","hours_ar":"5 – 9 م"},
     {"day_en":"Wednesday","day_ar":"الأربعاء","hours_en":"5 – 9 pm","hours_ar":"5 – 9 م"}]',
   '[{"en":"Nasr City","ar":"مدينة نصر"},{"en":"Heliopolis","ar":"مصر الجديدة"}]'),
  ('sample-2', 'swimming', 'Nour El-Sayed', 'نور السيد', 'Heliopolis', 'مصر الجديدة', '5–12 yrs', '5–12 سنة',
   'Certified swimming coach for beginners and intermediates, with a strong focus on water safety.',
   'مدربة سباحة معتمدة للمبتدئين والمستوى المتوسط، مع تركيز كبير على الأمان في الماء.',
   400, 6, '#1E40AF',
   '[{"day_en":"Sunday","day_ar":"الأحد","hours_en":"9 am – 1 pm","hours_ar":"9 ص – 1 م"},
     {"day_en":"Tuesday","day_ar":"الثلاثاء","hours_en":"4 – 7 pm","hours_ar":"4 – 7 م"}]',
   '[{"en":"Heliopolis","ar":"مصر الجديدة"},{"en":"Nasr City","ar":"مدينة نصر"}]'),
  ('sample-3', 'drawing', 'Mariam Fawzy', 'مريم فوزي', 'Maadi', 'المعادي', '4–12 yrs', '4–12 سنة',
   'Visual artist teaching drawing and painting that builds children''s imagination and confidence.',
   'فنانة تشكيلية تقدّم حصص رسم وتلوين تنمّي الخيال والثقة بالنفس عند الأطفال.',
   250, 5, '#9A3412',
   '[{"day_en":"Monday","day_ar":"الاثنين","hours_en":"5 – 7 pm","hours_ar":"5 – 7 م"},
     {"day_en":"Thursday","day_ar":"الخميس","hours_en":"4 – 6 pm","hours_ar":"4 – 6 م"}]',
   '[{"en":"Maadi","ar":"المعادي"},{"en":"Degla","ar":"دجلة"}]'),
  ('sample-4', 'chess', 'Omar Hany', 'عمر هاني', 'New Cairo', 'التجمع الخامس', '6–16 yrs', '6–16 سنة',
   'Rated chess player who teaches kids logical thinking and planning through chess.',
   'لاعب شطرنج مصنّف، يعلّم الأطفال التفكير المنطقي والتخطيط من خلال الشطرنج.',
   280, 7, '#1F2937',
   '[{"day_en":"Sunday","day_ar":"الأحد","hours_en":"4 – 8 pm","hours_ar":"4 – 8 م"},
     {"day_en":"Tuesday","day_ar":"الثلاثاء","hours_en":"4 – 8 pm","hours_ar":"4 – 8 م"}]',
   '[{"en":"New Cairo","ar":"التجمع الخامس"},{"en":"El Rehab","ar":"الرحاب"}]'),
  ('sample-5', 'piano', 'Salma Ramy', 'سلمى رامي', 'Zamalek', 'الزمالك', '5–16 yrs', '5–16 سنة',
   'Conservatoire graduate teaching piano from the very start up to grade exams.',
   'خريجة كونسرفتوار، تدرّس البيانو من البداية حتى امتحانات المستويات.',
   450, 10, '#5B21B6',
   '[{"day_en":"Wednesday","day_ar":"الأربعاء","hours_en":"5 – 8 pm","hours_ar":"5 – 8 م"},
     {"day_en":"Saturday","day_ar":"السبت","hours_en":"11 am – 2 pm","hours_ar":"11 ص – 2 م"}]',
   '[{"en":"Zamalek","ar":"الزمالك"},{"en":"Mohandessin","ar":"المهندسين"}]');

insert into public.reviews (trainer_id, author_id, author_label_en, author_label_ar, stars, comment) values
  ('sample-1', null, 'Sample parent', 'ولي أمر (مثال)', 5, 'Always on time, and my son improved a lot in two months.'),
  ('sample-2', null, 'Sample parent', 'ولي أمر (مثال)', 5, 'My daughter was afraid of water and now swims on her own.'),
  ('sample-3', null, 'Sample parent', 'ولي أمر (مثال)', 4, 'Fun, well-organised classes.'),
  ('sample-4', null, 'Sample parent', 'ولي أمر (مثال)', 5, 'Clear explanations and very patient.'),
  ('sample-5', null, 'Sample parent', 'ولي أمر (مثال)', 4, 'Excellent, though a bit pricey.');
