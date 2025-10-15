const express = require('express');
const cors = require('cors');

// Conditional requires - only load if routes exist
let quranRoutes, prayerRoutes, hadithRoutes, streamingRoutes;
try {
  quranRoutes = require('./routes/quran');
  prayerRoutes = require('./routes/prayer');
  hadithRoutes = require('./routes/hadith');
  streamingRoutes = require('./routes/streaming');
} catch (e) {
  console.log('Routes not loaded:', e.message);
}

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Static files for share cards
app.use('/uploads', express.static('uploads'));

// Routes - only register if loaded
if (quranRoutes) app.use('/api/quran', quranRoutes);
if (prayerRoutes) app.use('/api/prayer', prayerRoutes);
if (hadithRoutes) app.use('/api/hadith', hadithRoutes);
if (streamingRoutes) app.use('/api/streaming', streamingRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ 
    error: 'Internal server error', 
    message: process.env.NODE_ENV === 'development' ? err.message : undefined 
  });
});

// Only listen if not in Vercel (serverless)
if (process.env.NODE_ENV !== 'production') {
  app.listen(PORT, () => {
    console.log(`🚀 Al-Quran SuperApp API running on port ${PORT}`);
  });
}

// Export for Vercel
module.exports = app;
