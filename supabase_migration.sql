-- 1. Add uploader_name column
ALTER TABLE public.sounds 
ADD COLUMN IF NOT EXISTS uploader_name text;

-- 2. Make uploader_id nullable (for anonymous uploads)
ALTER TABLE public.sounds 
ALTER COLUMN uploader_id DROP NOT NULL;

-- 3. Update RLS Policies for Sounds
-- Drop old restrictve insert policy
DROP POLICY IF EXISTS "Authenticated users can upload sounds." ON public.sounds;

-- Create new public insert policy
CREATE POLICY "Everyone can upload sounds."
ON public.sounds FOR INSERT
WITH CHECK (true);

-- 4. Update Storage Policies
-- Drop old restrictive storage policy
DROP POLICY IF EXISTS "Authenticated users can upload sounds." ON storage.objects;

-- Create new public storage policy
CREATE POLICY "Everyone can upload sound files."
ON storage.objects FOR INSERT
WITH CHECK ( bucket_id = 'sounds' );
