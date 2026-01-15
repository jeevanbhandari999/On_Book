
// Creating the ratings table in supabase
// CREATE TABLE public.ratings (
//   rating_id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
//   post_id           uuid NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
//   given_by_user_id  uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,

//   rating_value      int NOT NULL CHECK (rating_value >= 1 AND rating_value <= 5),
//   comment           text,

//   created_at        timestamptz NOT NULL DEFAULT now(),
//   updated_at        timestamptz NOT NULL DEFAULT now()
// );


// Trigger for auto updating updated_at
// Creating function
// CREATE OR REPLACE FUNCTION update_updated_at_column()
// RETURNS TRIGGER AS $$
// BEGIN
//   NEW.updated_at = now();
//   RETURN NEW;
// END;
// $$ LANGUAGE plpgsql;

// Creating trigger
// CREATE TRIGGER trigger_update_ratings_updated_at
// BEFORE UPDATE ON public.ratings
// FOR EACH ROW
// EXECUTE FUNCTION update_updated_at_column();


// Unique constraints, one review per post per user
// ALTER TABLE public.ratings
// ADD CONSTRAINT unique_user_post_rating UNIQUE (post_id, given_by_user_id);



// ALTER TABLE public.ratings ENABLE ROW LEVEL SECURITY;

// CREATE POLICY "Users can insert their own ratings"
// ON public.ratings
// FOR INSERT
// WITH CHECK (auth.uid() = given_by_user_id);

// CREATE POLICY "Users can update own ratings"
// ON public.ratings
// FOR UPDATE
// USING (auth.uid() = given_by_user_id)
// WITH CHECK (auth.uid() = given_by_user_id);

// CREATE POLICY "Users can delete own ratings"
// ON public.ratings
// FOR DELETE
// USING (auth.uid() = given_by_user_id);

// CREATE POLICY "Only logged in users can view ratings"
// ON public.ratings
// FOR SELECT
// USING (auth.role() = 'authenticated');