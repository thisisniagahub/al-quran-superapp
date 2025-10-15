// Database Migration Script
// Run: node scripts/migrate.js

require('dotenv').config();
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});

async function migrate() {
  console.log('🔄 Starting database migration...');
  
  try {
    // Read schema file
    const schemaPath = path.join(__dirname, '../db/schema.sql');
    const schema = fs.readFileSync(schemaPath, 'utf8');
    
    // Execute schema
    await pool.query(schema);
    
    console.log('✅ Database migration completed successfully!');
    console.log('📊 Tables created:');
    console.log('  - quran_surah');
    console.log('  - quran_ayah');
    console.log('  - translations');
    console.log('  - tafsir');
    console.log('  - audio_reciters');
    console.log('  - audio_files');
    console.log('  - users');
    console.log('  - bookmarks');
    console.log('  - reading_progress');
    console.log('  - shared_quotes');
    console.log('  - prayer_times_cache');
    console.log('  - hadith_references');
    console.log('  - content_reports');
    
  } catch (error) {
    console.error('❌ Migration failed:', error.message);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

migrate();
