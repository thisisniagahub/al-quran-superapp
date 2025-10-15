require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

const quranRoutes = require('./routes/quran');
const prayerRoutes = require('./routes/prayer');
const aiRoutes = require('./routes/ai');
const shareRoutes = require('./routes/share');
const hadithRoutes = require('./routes/hadith');
const streamingRoutes = require('./routes/streaming');
const communityRoutes = require('./routes/community');

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// Static files for share cards
app.use('/uploads', express.static('uploads'));

// Routes
app.use('/api/quran', quranRoutes);
app.use('/api/prayer', prayerRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/share', shareRoutes);
app.use('/api/hadith', hadithRoutes);
app.use('/api/streaming', streamingRoutes);
app.use('/api/community', communityRoutes);

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

app.listen(PORT, () => {
  console.log(`🚀 Al-Quran SuperApp API running on port ${PORT}`);
  console.log(`📖 Environment: ${process.env.NODE_ENV}`);
  console.log(`✅ JAKIM Compliance: ${process.env.JAKIM_VERIFICATION_ENABLED === 'true' ? 'ENABLED' : 'DISABLED'}`);
});

module.exports = app;
