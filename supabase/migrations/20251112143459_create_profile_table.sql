-- Create profile table for user metadata
-- This table stores user-specific information beyond what's in auth.users
-- Each profile is linked 1:1 with an auth.users record

CREATE TABLE profile (
  -- Primary key references auth.users(id)
  -- CASCADE delete ensures profile is removed when user account is deleted
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Username must be unique and required
  -- Used for display and @mentions
  username TEXT NOT NULL UNIQUE,

  -- Optional bio text (no length limit in MVP)
  bio TEXT,

  -- Timestamps for tracking
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),

  -- Constraints
  CONSTRAINT username_length CHECK (char_length(username) >= 3 AND char_length(username) <= 30),
  CONSTRAINT username_format CHECK (username ~ '^[a-zA-Z0-9_]+$')
);

-- Index for faster username lookups
CREATE INDEX idx_profile_username ON profile(username);

-- Enable Row Level Security
ALTER TABLE profile ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can insert their own profile
-- This prevents users from creating profiles for other user IDs
CREATE POLICY "Users can insert their own profile"
  ON profile
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- RLS Policy: All authenticated users can view any profile
-- This enables social features like viewing other users' profiles
CREATE POLICY "Profiles are viewable by all authenticated users"
  ON profile
  FOR SELECT
  TO authenticated
  USING (true);

-- RLS Policy: Users can only update their own profile
-- Prevents unauthorized modification of other users' data
CREATE POLICY "Users can update their own profile"
  ON profile
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- RLS Policy: Users can delete their own profile
-- Allows users to remove their profile data
CREATE POLICY "Users can delete their own profile"
  ON profile
  FOR DELETE
  TO authenticated
  USING (auth.uid() = id);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at on profile updates
CREATE TRIGGER update_profile_updated_at
  BEFORE UPDATE ON profile
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add helpful comment
COMMENT ON TABLE profile IS 'User profile metadata including username and bio';
