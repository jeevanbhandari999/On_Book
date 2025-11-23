// *************  post_videos related query  ***********************
// -- CREATE TABLE IF NOT EXISTS public.post_videos(
// --   id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
// --   post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
// --   video_url TEXT NOT NULL,
// --   uploaded_by UUID NOT NULL REFERENCES auth.users(id),
// --   updated_by UUID NOT NULL REFERENCES auth.users(id),
// --   created_at TIMESTAMPTZ DEFAULT NOW() NULL,
// --   updated_at TIMESTAMPTZ DEFAULT NOW() NULL
// -- );

// -- alter table public.post_videos enable row level security;

// -- policy to view post videos
// -- create policy "view_post_videos" 
// -- on public.post_videos for select
// -- using(
// --   post_id in(
// --     select id from public.posts where organization_id in (
// --       select organization_id from public.users where user_id = auth.uid()
// --     )
// --   )
// -- );

// -- Users can manage the videos of posts if they can
// -- create policy "manage_post_viddeos"
// -- on public.post_videos for all using (
// --   post_id in(
// --     select id from public.posts where organization_id in (
// --       select organization_id from public.users where user_id = auth.uid()
// --    )
// --   )
// -- );


// -- users can view post post videos 
// -- create policy "users can see post videos"
// -- on public.post_videos for select to authenticated using (
// --   post_id in (
// --     select id from public.posts where organization_id in (
// --       select organization_id from public.users where user_id = auth.uid()
// --     )
// --   )
// -- );


// -- users can insert post vidos to their posts
// -- create policy "users can insert post videos"
// -- on public.post_videos for insert to authenticated with check (
// --   post_id in(
// --     select id from public.posts where organization_id in (
// --       select organization_id from public.users where user_id = auth.uid()
// --     )
// --   )
// -- );

// -- Update user can edit their videos
// -- create policy "users can update post videos"
// -- on public.post_videos for update to authenticated using (
// --   post_id in (
// --     select id from public.posts where organization_id in (
// --       select organization_id from public.users where user_id = auth.uid()
// --     )
// --   )
// -- );

// --delete users can delete their videos
// -- create policy "users can delete post videos"
// -- on public.post_videos for delete to authenticated using (
// --   post_id in (
// --     select id from public.posts where organization_id in (
// --       select organization_id from public.users where user_id = auth.uid()
// --     )
// --   )
// -- );


// Organization related and others(though needed to manage)
// TODO
// -- CREATE TABLE IF NOT EXISTS public.posts (
// --   id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
// --   organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
  
// --   title TEXT NOT NULL,
// --   description TEXT,
  
// --   primary_image_url TEXT NOT NULL,
  
// --   youtube_url TEXT,
// --   video_url TEXT,
  
// --   location GEOGRAPHY(POINT, 4326), -- PostGIS: POINT(longitude latitude)
// --   longitude NUMERIC(10,6),
// --   latitude NUMERIC(10,6),
  
// --   price NUMERIC(10,2),
// --   area NUMERIC(10,2),
// --   capacity INT,
  
// --   room_type TEXT,        -- ← Just text (no CHECK)
// --   status TEXT NOT NULL,  -- ← Just text (no CHECK)
  
// --   amenities TEXT[] DEFAULT '{}',
// --   tags TEXT[] DEFAULT '{}',
  
// --   created_by UUID NOT NULL REFERENCES auth.users(id),
// --   updated_by UUID NOT NULL REFERENCES auth.users(id),
  
// --   created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
// --   updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
// -- );

// -- -- Indexes
// -- CREATE INDEX IF NOT EXISTS idx_posts_organization ON public.posts(organization_id);
// -- CREATE INDEX IF NOT EXISTS idx_posts_location ON public.posts USING GIST(location);
// -- CREATE INDEX IF NOT EXISTS idx_posts_status ON public.posts(status);
// -- CREATE INDEX IF NOT EXISTS idx_posts_room_type ON public.posts(room_type);

// -- CREATE TABLE IF NOT EXISTS public.post_images (
// --   id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
// --   post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  
// --   image_url TEXT NOT NULL,
  
// --   uploaded_by UUID NOT NULL REFERENCES auth.users(id),
// --   updated_by UUID NOT NULL REFERENCES auth.users(id),
  
// --   created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
// --   updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
// -- );

// -- -- Index
// -- CREATE INDEX IF NOT EXISTS idx_post_images_post_id ON public.post_images(post_id);

// -- CREATE OR REPLACE FUNCTION trigger_set_updated_at()
// -- RETURNS TRIGGER AS $$
// -- BEGIN
// --   NEW.updated_at = NOW();
// --   RETURN NEW;
// -- END;
// -- $$ LANGUAGE plpgsql;

// -- -- For posts
// -- DROP TRIGGER IF EXISTS set_posts_updated_at ON public.posts;
// -- CREATE TRIGGER set_posts_updated_at
// --   BEFORE UPDATE ON public.posts
// --   FOR EACH ROW
// --   EXECUTE FUNCTION trigger_set_updated_at();

// -- -- For post_images
// -- DROP TRIGGER IF EXISTS set_post_images_updated_at ON public.post_images;
// -- CREATE TRIGGER set_post_images_updated_at
// --   BEFORE UPDATE ON public.post_images
// --   FOR EACH ROW
// --   EXECUTE FUNCTION trigger_set_updated_at();

// -- Enable RLS
// -- ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
// -- ALTER TABLE public.post_images ENABLE ROW LEVEL SECURITY;

// -- -- Users can view posts from their organization
// -- CREATE POLICY "view_org_posts"
// --   ON public.posts FOR SELECT
// --   USING (
// --     organization_id IN (
// --       SELECT organization_id FROM public.users WHERE user_id = auth.uid()
// --     )
// --   );

// -- -- Users can manage posts in their org
// -- CREATE POLICY "manage_org_posts"
// --   ON public.posts FOR ALL
// --   USING (
// --     organization_id IN (
// --       SELECT organization_id FROM public.users WHERE user_id = auth.uid()
// --     )
// --   )
// --   WITH CHECK (true);

// -- -- Users can view images of posts they can see
// -- CREATE POLICY "view_post_images"
// --   ON public.post_images FOR SELECT
// --   USING (
// --     post_id IN (
// --       SELECT id FROM public.posts
// --       WHERE organization_id IN (
// --         SELECT organization_id FROM public.users WHERE user_id = auth.uid()
// --       )
// --     )
// --   );

// -- -- Users can manage images of posts they can manage
// -- CREATE POLICY "manage_post_images"
// --   ON public.post_images FOR ALL
// --   USING (
// --     post_id IN (
// --       SELECT id FROM public.posts
// --       WHERE organization_id IN (
// --         SELECT organization_id FROM public.users WHERE user_id = auth.uid()
// --       )
// --     )
// --   );

// -- SELECT (View) - Users can see images of posts they can see
// -- CREATE POLICY "Users can view post images"
// --   ON public.post_images FOR SELECT
// --   TO authenticated
// --   USING (
// --     post_id IN (
// --       SELECT id FROM public.posts
// --       WHERE organization_id IN (
// --         SELECT organization_id 
// --         FROM public.users 
// --         WHERE user_id = auth.uid()
// --       )
// --     )
// --   );

// -- -- INSERT (Upload) - Users can add images to their posts
// -- CREATE POLICY "Users can insert post images"
// --   ON public.post_images FOR INSERT
// --   TO authenticated
// --   WITH CHECK (
// --     post_id IN (
// --       SELECT id FROM public.posts
// --       WHERE organization_id IN (
// --         SELECT organization_id 
// --         FROM public.users 
// --         WHERE user_id = auth.uid()
// --       )
// --     )
// --   );

// -- -- UPDATE (Edit) - Users can update their images
// -- CREATE POLICY "Users can update post images"
// --   ON public.post_images FOR UPDATE
// --   TO authenticated
// --   USING (
// --     post_id IN (
// --       SELECT id FROM public.posts
// --       WHERE organization_id IN (
// --         SELECT organization_id 
// --         FROM public.users 
// --         WHERE user_id = auth.uid()
// --       )
// --     )
// --   )
// --   WITH CHECK (true);

// -- -- DELETE (Remove) - Users can delete their images
// -- CREATE POLICY "Users can delete post images"
// --   ON public.post_images FOR DELETE
// --   TO authenticated
// --   USING (
// --     post_id IN (
// --       SELECT id FROM public.posts
// --       WHERE organization_id IN (
// --         SELECT organization_id 
// --         FROM public.users 
// --         WHERE user_id = auth.uid()
// --       )
// --     )
// --   );

// -- Allow authenticated users to upload to post-images
// -- create policy "Allow authenticated uploads"
// -- on storage.objects
// -- for insert
// -- to authenticated
// -- with check (
// --   bucket_id = 'post-images'
// -- );

// -- Allow anyone to read public images
// -- create policy "Allow public read"
// -- on storage.objects
// -- for select
// -- using ( bucket_id = 'post-images' );


// users profile and others related 
// -- -- 1. Enable extensions (postgis is now available)
// -- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
// -- CREATE EXTENSION IF NOT EXISTS "postgis";

// -- -- 2. Create users table
// -- CREATE TABLE IF NOT EXISTS public.users (
// --   id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
// --   user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
// --   full_name TEXT NOT NULL,
// --   image_url TEXT,
// --   role TEXT NOT NULL CHECK (role IN ('user', 'owner', 'admin', 'manager', 'worker')),
// --   organization_id UUID,
// --   phone TEXT,
// --   address TEXT,
// --   location GEOGRAPHY(POINT, 4326), -- Now works!
// --   contacts JSONB DEFAULT '[]'::jsonb,
// --   created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
// --   updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

// --   CONSTRAINT one_profile_per_user UNIQUE (user_id)
// -- );

// -- -- 3. Indexes
// -- CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);
// -- CREATE INDEX IF NOT EXISTS idx_users_organization ON public.users(organization_id);
// -- CREATE INDEX IF NOT EXISTS idx_users_location ON public.users USING GIST(location);
// -- CREATE INDEX IF NOT EXISTS idx_users_full_name ON public.users(full_name);

// -- -- 4. Updated_at trigger
// -- CREATE OR REPLACE FUNCTION trigger_set_updated_at()
// -- RETURNS TRIGGER AS $$
// -- BEGIN
// --   NEW.updated_at = NOW();
// --   RETURN NEW;
// -- END;
// -- $$ LANGUAGE plpgsql;

// -- DROP TRIGGER IF EXISTS set_users_updated_at ON public.users;
// -- CREATE TRIGGER set_users_updated_at
// --   BEFORE UPDATE ON public.users
// --   FOR EACH ROW
// --   EXECUTE FUNCTION trigger_set_updated_at();

// -- -- 5. RLS
// -- ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

// -- CREATE POLICY "Users can view own profile"
// --   ON public.users FOR SELECT
// --   USING (auth.uid() = user_id);

// -- CREATE POLICY "Users can update own profile"
// --   ON public.users FOR UPDATE
// --   USING (auth.uid() = user_id)
// --   WITH CHECK (auth.uid() = user_id);

// -- CREATE POLICY "Users can insert own profile"
// --   ON public.users FOR INSERT
// --   WITH CHECK (auth.uid() = user_id);

// -- alter table public.users enable row level security;

// -- -- Insert policy
// -- create policy "Allow insert own user"
// -- on public.users for insert
// -- to authenticated
// -- with check (auth.uid() = user_id);


// -- 1. Enable extensions (only if using location)
// -- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
// -- CREATE EXTENSION IF NOT EXISTS "postgis";

// -- -- 2. Create organizations table
// -- CREATE TABLE IF NOT EXISTS public.organizations (
// --   id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
// --   name TEXT NOT NULL,
// --   logo_url TEXT,
// --   address TEXT,
// --   phone TEXT,
  
// --   -- Location: all nullable (you can ignore if not using maps)
// --   location GEOGRAPHY(POINT, 4326),
// --   longitude NUMERIC(10,6),
// --   latitude NUMERIC(10,6),
  
// --   created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
// --   created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
// --   updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
// -- );

// -- -- 3. Indexes (for faster search)
// -- CREATE INDEX IF NOT EXISTS idx_organizations_name ON public.organizations(name);
// -- CREATE INDEX IF NOT EXISTS idx_organizations_created_by ON public.organizations(created_by);
// -- CREATE INDEX IF NOT EXISTS idx_organizations_location ON public.organizations USING GIST(location);

// -- -- 4. Auto update updated_at
// -- CREATE OR REPLACE FUNCTION trigger_set_updated_at()
// -- RETURNS TRIGGER AS $$
// -- BEGIN
// --   NEW.updated_at = NOW();
// --   RETURN NEW;
// -- END;
// -- $$ LANGUAGE plpgsql;

// -- DROP TRIGGER IF EXISTS set_organizations_updated_at ON public.organizations;
// -- CREATE TRIGGER set_organizations_updated_at
// --   BEFORE UPDATE ON public.organizations
// --   FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

// -- -- 5. RLS: Only owner can see/edit their organization
// -- ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;

// -- CREATE POLICY "Owners can view own organization"
// --   ON public.organizations FOR SELECT
// --   USING (auth.uid() = created_by);

// -- CREATE POLICY "Owners can update own organization"
// --   ON public.organizations FOR UPDATE
// --   USING (auth.uid() = created_by)
// --   WITH CHECK (auth.uid() = created_by);

// -- CREATE POLICY "Owners can insert organization"
// --   ON public.organizations FOR INSERT
// --   WITH CHECK (auth.uid() = created_by);

// -- Enable RLS
// -- alter table public.organizations enable row level security;

// -- -- Allow all authenticated users to READ organizations
// -- create policy "read_all_orgs"
// -- on public.organizations
// -- for select
// -- to authenticated
// -- using (true);
