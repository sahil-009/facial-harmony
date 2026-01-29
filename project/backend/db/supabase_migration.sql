-- Facial Harmony Database Schema (SIMPLIFIED - Device-based, No Auth)
-- Run this in Supabase SQL Editor

-- 1. PROFILES TABLE (Device-based only)
CREATE TABLE IF NOT EXISTS profiles (
    device_id TEXT PRIMARY KEY,
    gender TEXT CHECK (gender IN ('male', 'female')),
    is_premium BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. FACE SCANS TABLE
CREATE TABLE IF NOT EXISTS face_scans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id TEXT REFERENCES profiles(device_id) ON DELETE CASCADE,
    scan_quality FLOAT,
    analysis_version TEXT DEFAULT 'beauty_v1',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. BEAUTY RESULTS TABLE
CREATE TABLE IF NOT EXISTS beauty_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id TEXT REFERENCES profiles(device_id) ON DELETE CASCADE,
    scan_id UUID REFERENCES face_scans(id) ON DELETE CASCADE,
    beauty_score FLOAT,
    symmetry_score FLOAT,
    jaw_score FLOAT,
    face_shape_primary TEXT,
    face_shape_secondary TEXT,
    analysis_version TEXT DEFAULT 'beauty_v1',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. BEAUTY TIPS SHOWN TABLE
CREATE TABLE IF NOT EXISTS beauty_tips_shown (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id TEXT REFERENCES profiles(device_id) ON DELETE CASCADE,
    scan_id UUID REFERENCES face_scans(id) ON DELETE CASCADE,
    tip_id TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. CELEBRITY MATCHES TABLE
CREATE TABLE IF NOT EXISTS celebrity_matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id TEXT REFERENCES profiles(device_id) ON DELETE CASCADE,
    scan_id UUID REFERENCES face_scans(id) ON DELETE CASCADE,
    celebrity_name TEXT NOT NULL,
    resemblance_score FLOAT,
    analysis_version TEXT DEFAULT 'beauty_v1',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. CELEBRITY DATA TABLE (Read-only reference)
CREATE TABLE IF NOT EXISTS celebrities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    face_shapes TEXT[],
    jaw_score INT,
    symmetry_score INT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE face_scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE beauty_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE beauty_tips_shown ENABLE ROW LEVEL SECURITY;
ALTER TABLE celebrity_matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE celebrities ENABLE ROW LEVEL SECURITY;

-- PROFILES: Allow all operations (device-based, no auth)
CREATE POLICY "Allow all operations on profiles"
    ON profiles FOR ALL
    USING (true)
    WITH CHECK (true);

-- FACE SCANS: Allow all operations
CREATE POLICY "Allow all operations on face_scans"
    ON face_scans FOR ALL
    USING (true)
    WITH CHECK (true);

-- BEAUTY RESULTS: Allow all operations
CREATE POLICY "Allow all operations on beauty_results"
    ON beauty_results FOR ALL
    USING (true)
    WITH CHECK (true);

-- BEAUTY TIPS: Allow all operations
CREATE POLICY "Allow all operations on beauty_tips_shown"
    ON beauty_tips_shown FOR ALL
    USING (true)
    WITH CHECK (true);

-- CELEBRITY MATCHES: Allow all operations
CREATE POLICY "Allow all operations on celebrity_matches"
    ON celebrity_matches FOR ALL
    USING (true)
    WITH CHECK (true);

-- CELEBRITIES: Read-only for everyone
CREATE POLICY "Everyone can view celebrities"
    ON celebrities FOR SELECT
    USING (true);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX idx_profiles_device_id ON profiles(device_id);
CREATE INDEX idx_face_scans_device_id ON face_scans(device_id);
CREATE INDEX idx_beauty_results_device_id ON beauty_results(device_id);
CREATE INDEX idx_beauty_results_scan_id ON beauty_results(scan_id);
CREATE INDEX idx_tips_device_id ON beauty_tips_shown(device_id);
CREATE INDEX idx_celebrity_matches_device_id ON celebrity_matches(device_id);

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for profiles table
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
