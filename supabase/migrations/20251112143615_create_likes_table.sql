-- Create likes table for social interactions
-- Junction table connecting users to points they've liked
-- Composite primary key prevents duplicate likes

CREATE TABLE likes (
  -- Foreign key to points table
  -- CASCADE delete removes likes when point is deleted
  point_id UUID NOT NULL REFERENCES points(id) ON DELETE CASCADE,

  -- Foreign key to auth.users
  -- CASCADE delete removes user's likes when their account is deleted
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Timestamp for when the like was created
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Composite primary key ensures each user can only like a point once
  PRIMARY KEY (point_id, user_id)
);

-- Index for quickly finding all likes by a specific user
CREATE INDEX idx_likes_user_id ON likes(user_id);

-- Index for quickly counting likes on a specific point
-- This is already covered by the PRIMARY KEY index on point_id, user_id

-- Enable Row Level Security
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can like any active point
-- We check that the point exists and is active in the application layer
-- The database-level constraint ensures point_id references a valid point
CREATE POLICY "Users can insert their own likes"
  ON likes
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- RLS Policy: All authenticated users can view likes
-- This enables showing like counts and "who liked this" features
CREATE POLICY "Likes are viewable by all authenticated users"
  ON likes
  FOR SELECT
  TO authenticated
  USING (true);

-- RLS Policy: Users can remove (unlike) their own likes
-- Prevents users from removing other users' likes
CREATE POLICY "Users can delete their own likes"
  ON likes
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Note: We do NOT allow UPDATE on likes
-- Likes are immutable once created - they can only be added or removed

-- Add helpful comments
COMMENT ON TABLE likes IS 'Junction table for user likes on points';
COMMENT ON COLUMN likes.point_id IS 'Reference to the point being liked';
COMMENT ON COLUMN likes.user_id IS 'Reference to the user who liked the point';
