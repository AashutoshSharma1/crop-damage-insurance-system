-- =========================================================
-- CROP INSURANCE & FARM MONITORING SYSTEM DATABASE SCHEMA
-- Target Database: Supabase PostgreSQL
-- =========================================================

-- 1. Farms Table
CREATE TABLE IF NOT EXISTS public.farms (
    id TEXT PRIMARY KEY,
    farmer_name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    aadhaar TEXT,
    residential_address TEXT,
    field_address TEXT,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    land_area_acres DOUBLE PRECISION NOT NULL,
    crop_name TEXT NOT NULL DEFAULT 'Wheat',
    polygon_boundary JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Crop Health Logs Table
CREATE TABLE IF NOT EXISTS public.crop_health_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farm_id TEXT NOT NULL REFERENCES public.farms(id) ON DELETE CASCADE,
    temperature DOUBLE PRECISION NOT NULL,
    humidity DOUBLE PRECISION NOT NULL,
    rainfall_mm DOUBLE PRECISION NOT NULL,
    status_indicator TEXT NOT NULL, -- 'GOOD', 'WARNING', 'BAD'
    status_message TEXT NOT NULL,
    forecast_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Crop Stage Templates Table
CREATE TABLE IF NOT EXISTS public.crop_stage_templates (
    id SERIAL PRIMARY KEY,
    crop_name TEXT NOT NULL,
    stage_number INT NOT NULL,
    stage_name TEXT NOT NULL,
    days_from_start INT NOT NULL,
    days_from_end INT NOT NULL
);

-- 4. Farm Crop Stages Logs Table
CREATE TABLE IF NOT EXISTS public.farm_crop_stages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farm_id TEXT NOT NULL REFERENCES public.farms(id) ON DELETE CASCADE,
    stage_number INT NOT NULL,
    stage_name TEXT NOT NULL,
    deadline_start TIMESTAMP WITH TIME ZONE NOT NULL,
    deadline_end TIMESTAMP WITH TIME ZONE NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    uploaded_photo_urls JSONB DEFAULT '[]'::jsonb,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    blurriness_score DOUBLE PRECISION,
    is_auto_captured BOOLEAN DEFAULT FALSE,
    uploaded_at TIMESTAMP WITH TIME ZONE
);

-- 5. Insurance Claims Table
CREATE TABLE IF NOT EXISTS public.claims (
    id TEXT PRIMARY KEY,
    farmer_id TEXT NOT NULL REFERENCES public.farms(id) ON DELETE CASCADE,
    farmer_name TEXT NOT NULL,
    damage_reason TEXT NOT NULL,
    description TEXT NOT NULL,
    photo_urls JSONB NOT NULL DEFAULT '[]'::jsonb,
    status TEXT NOT NULL DEFAULT 'submitted', -- 'submitted', 'under_review', 'verified', 'approved', 'rejected'
    officer_notes TEXT,
    estimated_payout DOUBLE PRECISION,
    ml_damage_percentage DOUBLE PRECISION,
    ml_confidence DOUBLE PRECISION,
    ml_severity TEXT,
    ml_detected_hazard TEXT,
    sentinel_ndvi_drop DOUBLE PRECISION,
    sentinel_damage_estimate DOUBLE PRECISION,
    date_submitted TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Claim Timeline Audit Table
CREATE TABLE IF NOT EXISTS public.claim_timeline (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    claim_id TEXT NOT NULL REFERENCES public.claims(id) ON DELETE CASCADE,
    status TEXT NOT NULL,
    remarks TEXT NOT NULL,
    updated_by TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =========================================================
-- INITIAL SEED DATA FOR STAGE TEMPLATES & DEMO FARMER
-- =========================================================

INSERT INTO public.crop_stage_templates (crop_name, stage_number, stage_name, days_from_start, days_from_end)
VALUES
    ('Potato', 1, 'Stage 1: Sowing & Sprouting', 0, 20),
    ('Potato', 2, 'Stage 2: Vegetative & Stolon', 21, 45),
    ('Potato', 3, 'Stage 3: Tuber Initiation', 46, 75),
    ('Potato', 4, 'Stage 4: Tuber Bulking', 76, 100),
    ('Potato', 5, 'Stage 5: Maturation & Harvesting', 101, 120),
    ('Tomato', 1, 'Stage 1: Nursery & Transplanting', 0, 15),
    ('Tomato', 2, 'Stage 2: Vegetative Growth', 16, 40),
    ('Tomato', 3, 'Stage 3: Flowering & Fruit Set', 41, 70),
    ('Tomato', 4, 'Stage 4: Fruit Development & Ripening', 71, 95),
    ('Tomato', 5, 'Stage 5: Harvesting', 96, 110),
    ('Rice', 1, 'Stage 1: Nursery & Transplanting', 0, 20),
    ('Rice', 2, 'Stage 2: Vegetative Tillering', 21, 45),
    ('Rice', 3, 'Stage 3: Panicle Initiation', 46, 75),
    ('Rice', 4, 'Stage 4: Flowering & Milky Stage', 76, 100),
    ('Rice', 5, 'Stage 5: Dough Stage & Harvest', 101, 120),
    ('Wheat', 1, 'Stage 1: Sowing & Germination', 0, 20),
    ('Wheat', 2, 'Stage 2: Crown Root & Tillering', 21, 40),
    ('Wheat', 3, 'Stage 3: Jointing & Booting', 41, 65),
    ('Wheat', 4, 'Stage 4: Flowering & Grain Filling', 66, 95),
    ('Wheat', 5, 'Stage 5: Ripening & Harvesting', 96, 120),
    ('Corn', 1, 'Stage 1: Sowing & Emergence', 0, 15),
    ('Corn', 2, 'Stage 2: Vegetative Growth (V6-V12)', 16, 35),
    ('Corn', 3, 'Stage 3: Tasseling & Silking', 36, 60),
    ('Corn', 4, 'Stage 4: Blister & Dough Stage', 61, 80),
    ('Corn', 5, 'Stage 5: Physiological Maturity & Harvest', 81, 100)
ON CONFLICT DO NOTHING;

INSERT INTO public.farms (id, farmer_name, email, phone, aadhaar, residential_address, field_address, latitude, longitude, land_area_acres, crop_name, polygon_boundary)
VALUES (
    'FARMER_101',
    'Rajesh Kumar',
    'rajesh.farmer@agri.in',
    '+91 98765 43210',
    '5412-8901-3456',
    'House No. 42, Village Rampur, District Karnal, Haryana',
    'Khasra No. 114/2, North Rampur Fields, Karnal',
    29.6857,
    76.9905,
    4.2,
    'Wheat',
    '[[29.6865, 76.9895], [29.6870, 76.9915], [29.6848, 76.9920], [29.6845, 76.9898]]'::jsonb
)
ON CONFLICT (id) DO UPDATE SET
    latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude,
    polygon_boundary = EXCLUDED.polygon_boundary;

-- 7. Users / Auth Credentials Table
CREATE TABLE IF NOT EXISTS public.users (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL, -- 'farmer', 'field_officer'
    name TEXT NOT NULL,
    farm_id TEXT REFERENCES public.farms(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed Default Auth Credentials
INSERT INTO public.users (id, email, password_hash, role, name, farm_id)
VALUES 
    ('USR_FARMER_101', 'rajesh.farmer@agri.in', 'farmer123', 'farmer', 'Rajesh Kumar', 'FARMER_101'),
    ('USR_OFFICER_201', 'officer.karnal@agri.in', 'officer123', 'field_officer', 'Inspector D. Sharma', NULL)
ON CONFLICT (id) DO NOTHING;

-- 8. Field Officers Directory Table
CREATE TABLE IF NOT EXISTS public.officers (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    zone TEXT NOT NULL,
    assigned_farm_ids JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed Officer Directory Data
INSERT INTO public.officers (id, name, email, zone, assigned_farm_ids)
VALUES 
    ('OFFICER_201', 'Inspector D. Sharma', 'officer.karnal@agri.in', 'Karnal North Zone', '["FARMER_101", "FARMER_102", "FARMER_103"]'::jsonb),
    ('OFFICER_202', 'Inspector A. Verma', 'verma.indore@agri.in', 'Indore West Zone', '["FLD-2041", "FLD-1988"]'::jsonb),
    ('OFFICER_203', 'Inspector S. Patil', 'patil.punjab@agri.in', 'Punjab Central Belt', '["FLD-2210"]'::jsonb),
    ('OFFICER_204', 'Inspector R. Deshmukh', 'deshmukh.nashik@agri.in', 'Nashik Agricultural Zone', '["FLD-2078", "FLD-1902"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Seed Demo Claims
INSERT INTO public.claims (id, farmer_id, farmer_name, damage_reason, description, photo_urls, status, officer_notes, estimated_payout)
VALUES
    ('CLM-2026-891', 'FARMER_101', 'Rajesh Kumar', 'Unseasonal Hailstorm & Heavy Rain', 'Heavy hailstorm damaged Wheat crop at jointing stage. 40% lodging noticed.', '["assets/claims/proof_1.jpg"]'::jsonb, 'submitted', NULL, 0.0),
    ('CLM-2026-442', 'FARMER_102', 'Suresh Singh', 'Insect & Pest Outbreak', 'Stem borer infestation spotted across 2 acres. Foliage severely damaged.', '["assets/claims/proof_2.jpg"]'::jsonb, 'submitted', NULL, 0.0),
    ('CLM-2026-105', 'FARMER_103', 'Anita Devi', 'Heavy Rain & Waterlogging', 'Field flooded due to continuous heavy downpour for 36 hours.', '["assets/claims/proof_3.jpg"]'::jsonb, 'verified', 'Ground verification completed.', 32000.0)
ON CONFLICT (id) DO NOTHING;



