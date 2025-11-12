-- Create points table for location-based posts
-- Each point represents a piece of content tied to a specific geographic location
-- Uses PostGIS for spatial data storage and querying

CREATE TABLE points (
  -- UUID primary key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Foreign key to auth.users
  -- CASCADE delete removes user's points when their account is deleted
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Post content with 280 character limit (Twitter-style)
  content TEXT NOT NULL CHECK (char_length(content) <= 280 AND char_length(content) > 0),

  -- Timestamp for when the point was created
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- PostGIS GEOMETRY column storing lat/lon as POINT
  -- SRID 4326 is WGS84 (standard GPS coordinate system)
  geom GEOMETRY(POINT, 4326) NOT NULL,

  -- Maidenhead grid locator (6-character format)
  -- Used for approximate location display without revealing exact coordinates
  -- Example: "FN20xi" represents roughly an 800m x 800m area
  maidenhead_6char TEXT NOT NULL CHECK (char_length(maidenhead_6char) = 6),

  -- Soft delete flag - points are never truly deleted, just marked inactive
  -- This allows for content moderation and user history
  is_active BOOLEAN NOT NULL DEFAULT true
);

-- Spatial index on geom for efficient geographic queries
-- GIST (Generalized Search Tree) index is optimal for spatial data
CREATE INDEX idx_points_geom ON points USING GIST(geom);

-- Index on maidenhead code for grid square grouping
CREATE INDEX idx_points_maidenhead ON points(maidenhead_6char);

-- Partial index on active points only (most common query pattern)
CREATE INDEX idx_points_active ON points(is_active) WHERE is_active = true;

-- Index on user_id for fetching user's points
CREATE INDEX idx_points_user_id ON points(user_id);

-- Composite index for user's active points
CREATE INDEX idx_points_user_active ON points(user_id, is_active) WHERE is_active = true;

-- Enable Row Level Security
ALTER TABLE points ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can insert their own points
-- Prevents users from creating points attributed to other users
CREATE POLICY "Users can insert their own points"
  ON points
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- RLS Policy: All authenticated users can view active points
-- This enables the main feed functionality
-- Inactive points are hidden from all users (except via admin queries)
CREATE POLICY "Active points are viewable by all authenticated users"
  ON points
  FOR SELECT
  TO authenticated
  USING (is_active = true);

-- RLS Policy: Users can soft-delete (deactivate) their own points
-- Implemented as an UPDATE that sets is_active = false
CREATE POLICY "Users can soft-delete their own points"
  ON points
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Note: We do NOT allow hard deletes via DELETE policy
-- Points should only be soft-deleted by setting is_active = false
-- Hard deletes should only be possible via admin/service role

-- Add helpful comments
COMMENT ON TABLE points IS 'Location-based posts with PostGIS spatial data';
COMMENT ON COLUMN points.geom IS 'PostGIS POINT(longitude, latitude) in SRID 4326';
COMMENT ON COLUMN points.maidenhead_6char IS 'Maidenhead grid locator (6-char) for approximate location display';
COMMENT ON COLUMN points.is_active IS 'Soft delete flag - false means point is hidden';
