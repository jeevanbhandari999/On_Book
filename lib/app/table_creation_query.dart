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
