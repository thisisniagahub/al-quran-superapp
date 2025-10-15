-- Al-Quran SuperApp Database Schema
-- Compliant with JAKIM/JAIS guidelines for source attribution

CREATE TABLE IF NOT EXISTS quran_surah (
  id SERIAL PRIMARY KEY,
  number INTEGER UNIQUE NOT NULL,
  name_ar VARCHAR(255) NOT NULL,
  name_en VARCHAR(255) NOT NULL,
  name_ms VARCHAR(255),
  name_id VARCHAR(255),
  ayah_count INTEGER NOT NULL,
  revelation_place VARCHAR(50), -- Makkah/Madinah
  juz_start INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS quran_ayah (
  id SERIAL PRIMARY KEY,
  surah_id INTEGER REFERENCES quran_surah(number),
  ayah_number INTEGER NOT NULL,
  text_ar TEXT NOT NULL, -- Uthmani script
  text_simple TEXT, -- Simplified Arabic
  juz INTEGER,
  page_mushaf INTEGER,
  source_verified BOOLEAN DEFAULT true,
  source_attribution VARCHAR(500) DEFAULT 'Quran.com / Tanzil.net (verified)',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(surah_id, ayah_number)
);

CREATE TABLE IF NOT EXISTS translations (
  id SERIAL PRIMARY KEY,
  ayah_id INTEGER REFERENCES quran_ayah(id),
  language VARCHAR(10), -- 'ms', 'id', 'en'
  text TEXT NOT NULL,
  translator_name VARCHAR(255) NOT NULL,
  translator_source VARCHAR(500),
  license_info TEXT,
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tafsir (
  id SERIAL PRIMARY KEY,
  ayah_id INTEGER REFERENCES quran_ayah(id),
  language VARCHAR(10),
  text TEXT NOT NULL,
  scholar_name VARCHAR(255), -- e.g., Ibn Kathir, Al-Jalalayn
  source_url VARCHAR(500),
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS audio_reciters (
  id SERIAL PRIMARY KEY,
  name_ar VARCHAR(255) NOT NULL,
  name_en VARCHAR(255) NOT NULL,
  style VARCHAR(100), -- Murattal, Mujawwad
  license_status VARCHAR(100) DEFAULT 'Permission granted',
  cdn_base_url VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS audio_files (
  id SERIAL PRIMARY KEY,
  reciter_id INTEGER REFERENCES audio_reciters(id),
  surah_id INTEGER,
  ayah_number INTEGER,
  file_url VARCHAR(500) NOT NULL,
  file_size_kb INTEGER,
  duration_sec INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  device_id VARCHAR(255) UNIQUE,
  preferred_language VARCHAR(10) DEFAULT 'ms',
  prayer_calc_method VARCHAR(50) DEFAULT 'JAKIM',
  location_lat DECIMAL(10, 8),
  location_lng DECIMAL(11, 8),
  timezone VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_active TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bookmarks (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  surah_id INTEGER,
  ayah_number INTEGER,
  note TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS reading_progress (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  last_surah INTEGER,
  last_ayah INTEGER,
  total_ayah_read INTEGER DEFAULT 0,
  streak_days INTEGER DEFAULT 0,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS shared_quotes (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  surah_id INTEGER,
  ayah_start INTEGER,
  ayah_end INTEGER,
  template_id VARCHAR(50),
  image_url VARCHAR(500),
  moderation_status VARCHAR(50) DEFAULT 'pending', -- pending/approved/rejected
  reported_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS prayer_times_cache (
  id SERIAL PRIMARY KEY,
  location_code VARCHAR(100), -- e.g., SGR01 for Selangor zones
  date DATE NOT NULL,
  fajr TIME,
  syuruk TIME,
  dhuhr TIME,
  asr TIME,
  maghrib TIME,
  isha TIME,
  source VARCHAR(100) DEFAULT 'e-Solat JAKIM',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(location_code, date)
);

CREATE TABLE IF NOT EXISTS hadith_references (
  id SERIAL PRIMARY KEY,
  ayah_id INTEGER REFERENCES quran_ayah(id),
  hadith_id VARCHAR(100), -- myHadith ID
  hadith_book VARCHAR(100),
  hadith_number VARCHAR(50),
  grade VARCHAR(50), -- Sahih, Hasan, Daif
  text_ar TEXT,
  text_translation TEXT,
  myhadith_url VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS content_reports (
  id SERIAL PRIMARY KEY,
  report_type VARCHAR(50), -- 'quote', 'comment', 'user_content'
  content_id INTEGER,
  reported_by INTEGER REFERENCES users(id),
  reason TEXT,
  status VARCHAR(50) DEFAULT 'pending',
  reviewed_by VARCHAR(100),
  reviewed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_ayah_surah ON quran_ayah(surah_id);
CREATE INDEX idx_translations_ayah ON translations(ayah_id);
CREATE INDEX idx_bookmarks_user ON bookmarks(user_id);
CREATE INDEX idx_prayer_location_date ON prayer_times_cache(location_code, date);
CREATE INDEX idx_shared_quotes_moderation ON shared_quotes(moderation_status);

-- Insert sample Surah metadata (first 3 surahs as example)
INSERT INTO quran_surah (number, name_ar, name_en, name_ms, name_id, ayah_count, revelation_place) VALUES
(1, 'الفاتحة', 'Al-Fatihah', 'Al-Fatihah', 'Al-Fatihah', 7, 'Makkah'),
(2, 'البقرة', 'Al-Baqarah', 'Al-Baqarah', 'Al-Baqarah', 286, 'Madinah'),
(3, 'آل عمران', 'Ali Imran', 'Ali Imran', 'Ali Imran', 200, 'Madinah')
ON CONFLICT (number) DO NOTHING;

-- Insert sample reciter
INSERT INTO audio_reciters (name_ar, name_en, style, cdn_base_url) VALUES
('عبد الباسط عبد الصمد', 'Abdul Basit Abdul Samad', 'Mujawwad', 'https://cdn.islamic.network/quran/audio/128/ar.abdulbasitmurattal')
ON CONFLICT DO NOTHING;
