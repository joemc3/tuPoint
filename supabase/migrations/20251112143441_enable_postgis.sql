-- Enable PostGIS extension for spatial data types and functions
-- This extension provides support for geographic objects in PostgreSQL
-- Required for storing and querying lat/lon coordinates as GEOMETRY types

CREATE EXTENSION IF NOT EXISTS postgis;

-- Verify installation
COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
