# Al-Quran SuperApp 🕌

**Complete Al-Quran mobile application for Malaysia & Indonesia markets**  
Fully compliant with JAKIM/JAIS guidelines

---

## 🎯 Features

### Core Features
- ✅ **Complete Quran Reader** - Uthmani script, translations (Malay, Indonesian, English), tajwid mode
- ✅ **Audio Recitation** - Multiple reciters, verse-by-verse playback, offline download
- ✅ **Prayer Times** - e-Solat JAKIM (Malaysia) & Kemenag (Indonesia) integration
- ✅ **Qibla Compass** - Accurate Qibla direction with GPS
- ✅ **AI Ustaz/Ustazah** - Text + Voice Q&A powered by RAG (Quran, Hadith, e-Fatwa)
- ✅ **PeaceTV-style Streaming** - Islamic lectures, categorized videos, live streams
- ✅ **Tafsir & Hadith** - myHadith.islam.gov.my integration
- ✅ **Share Quote Generator** - Beautiful Islamic quote cards with compliance

### Advanced Features
- 🎙️ Voice Q&A with Text-to-Speech
- 🔖 Bookmarks, Notes & Reading Progress
- 📊 Gamification (Streaks, Badges, Achievements)
- 💰 Donation Hub (JAKIM-verified organizations)
- 👥 Community Feed & Reflections
- 📱 Offline Mode (SQLite storage)
- 🌐 Localization (Bahasa Melayu, Bahasa Indonesia, English)

### JAKIM/JAIS Compliance
- ✅ Source attribution for all Quran verses
- ✅ myHadith verification for hadith authenticity
- ✅ Content moderation for prohibited content (khurafat, bidaah, etc.)
- ✅ Mandatory disclaimers for AI-generated content
- ✅ e-Fatwa integration for official rulings

---

## 📂 Project Structure

```
al_quran_superapp_flutter/
├── backend/                    # Node.js API
│   ├── routes/
│   │   ├── quran.js           # Quran API (Al-Quran Cloud)
│   │   ├── prayer.js          # Prayer times (e-Solat)
│   │   ├── ai.js              # AI RAG (Ustaz/Ustazah)
│   │   ├── share.js           # Quote card generator
│   │   ├── hadith.js          # myHadith integration
│   │   ├── streaming.js       # Video/live stream API
│   │   └── community.js       # Community & donations
│   ├── compliance/
│   │   └── jakim_validator.js # JAKIM compliance checks
│   ├── db/
│   │   └── schema.sql         # PostgreSQL database schema
│   ├── index.js               # Express server
│   ├── package.json
│   └── .env.example
│
├── lib/                       # Flutter app
│   ├── models/
│   │   ├── surah.dart
│   │   └── prayer_times.dart
│   ├── services/
│   │   ├── quran_service.dart
│   │   ├── prayer_service.dart
│   │   └── ai_service.dart
│   ├── screens/
│   │   ├── home_screen_enhanced.dart
│   │   ├── quran/reader_screen_enhanced.dart
│   │   ├── prayer/prayer_screen_enhanced.dart
│   │   ├── ai/ai_chat_screen_enhanced.dart
│   │   └── streaming/streaming_screen_enhanced.dart
│   └── main.dart
│
├── pubspec.yaml               # Flutter dependencies
└── README.md                  # This file
```

---

## 🚀 Setup & Installation

### Prerequisites
- **Flutter** >= 2.18.0
- **Node.js** >= 16.x
- **PostgreSQL** >= 13.x
- **OpenAI API Key** (optional, for AI features)

### Backend Setup

1. **Install dependencies**
```bash
cd backend
npm install
```

2. **Configure environment**
```bash
cp .env.example .env
# Edit .env with your settings:
# - DB credentials
# - OpenAI API key (optional)
# - JAKIM API endpoints
```

3. **Setup database**
```bash
# Create database
createdb alquran_app

# Run schema
psql alquran_app < db/schema.sql
```

4. **Start backend**
```bash
npm start
# API runs on http://localhost:3000
```

### Flutter App Setup

1. **Install dependencies**
```bash
flutter pub get
```

2. **Update API endpoint**
```dart
// In lib/services/*.dart, change baseUrl:
static const String baseUrl = 'http://YOUR_IP:3000/api';
// Use your computer's IP address (not localhost) for testing on physical devices
```

3. **Run app**
```bash
# Android
flutter run

# iOS
flutter run -d ios
```

---

## 📡 API Endpoints

### Quran
- `GET /api/quran/surahs` - Get all surahs
- `GET /api/quran/surah/:number?translation=ms` - Get surah with translation
- `GET /api/quran/search?q=keyword` - Search ayahs
- `GET /api/quran/audio/:surah/:ayah?reciter=alafasy` - Get audio URL
- `GET /api/quran/tafsir/:surah/:ayah?lang=en` - Get tafsir

### Prayer Times
- `GET /api/prayer/times/malaysia?zone=SGR01&date=2025-10-15` - Malaysia (e-Solat)
- `GET /api/prayer/times/indonesia?city=jakarta&date=2025-10-15` - Indonesia
- `GET /api/prayer/qibla?lat=3.1390&lng=101.6869` - Qibla direction
- `GET /api/prayer/zones/malaysia` - List of Malaysia zones

### AI
- `POST /api/ai/ask-ustaz` - Ask AI Ustaz/Ustazah
- `POST /api/ai/verify-hadith` - Verify hadith authenticity
- `POST /api/ai/quran-semantic-search` - Semantic verse search
- `POST /api/ai/tadabbur` - Get verse suggestions by emotion

### Share & Community
- `POST /api/share/generate-card` - Generate quote card
- `GET /api/share/templates` - Get card templates
- `GET /api/community/feed` - Get community posts
- `GET /api/community/donations` - Get donation causes

### Streaming
- `GET /api/streaming/live` - Get live streams
- `GET /api/streaming/categories` - Get video categories
- `GET /api/streaming/videos/:category` - Get videos by category

---

## 🔒 JAKIM Compliance

This app follows **18 official JAKIM/JAIS guidelines**:

1. **Garis Panduan Kandungan Berunsur Islam Dalam Media Baharu**
2. **Garis Panduan Bahan Penerbitan Bercetak & Audio Visual**
3. **Garis Panduan Program Motivasi Berunsur Islam**
4. **Garisan Panduan Penapisan Kandungan Bahan-Bahan Penyiaran**
5. **Garisan Panduan Pembuatan, Pengendalian, Penjualan & Pelupusan Ayat Suci Al-Quran**
6. **Social Media & ICT dalam Islam**
7. **PTSI 2.0 V9 2025**
8. **Nilai MADANI**
9. **MINDA-MAQASID**
10. + 8 more official documents

### Compliance Features
- ✅ Mandatory source attribution on all Quran quotes
- ✅ myHadith verification for hadith authenticity
- ✅ Auto-blocking of prohibited content (khurafat, bidaah, etc.)
- ✅ AI cannot issue fatwa (redirects to e-Fatwa)
- ✅ Content moderation with human review
- ✅ Audit logs for regulatory requests

---

## 📱 Screens

### Main Screens
1. **Home** - Daily ayah, hadith, zikir, quick access
2. **Quran Reader** - Full Quran with translations, audio, tafsir
3. **Prayer Times** - e-Solat/Kemenag times, Qibla compass
4. **AI Ustaz** - Voice Q&A with JAKIM-compliant responses
5. **Streaming** - Islamic lectures & live streams

### Additional Screens
- Bookmarks & Notes
- Community Feed
- Donation Hub
- Profile & Achievements
- Share Quote Generator
- Tafsir Detail

---

## 🎨 Design

- **Color Scheme**: Islamic Green (#2D5F3F), Earth Brown (#8B5A3C), Sky Blue (#4A7C9D)
- **Fonts**: Amiri (Arabic), Scheherazade (Arabic alternative), System fonts (UI)
- **RTL Support**: Full right-to-left for Arabic text
- **Dark Mode**: Coming soon

---

## 🧪 Testing

```bash
# Backend tests
cd backend
npm test

# Flutter tests
flutter test

# Integration tests
flutter drive --target=test_driver/app.dart
```

---

## 📦 Build & Deploy

### Backend Deployment
```bash
# Production build
npm run build

# Deploy to server (PM2)
pm2 start index.js --name alquran-api

# Or use Docker
docker build -t alquran-backend .
docker run -p 3000:3000 alquran-backend
```

### Flutter App Build
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 📄 License

This project is licensed under the MIT License.

**Important**: Quran text, translations, and hadith content have separate licenses. Always attribute sources:
- **Quran**: Tanzil.net / Al-Quran Cloud
- **Hadith**: myHadith.islam.gov.my
- **Prayer Times**: e-Solat JAKIM / Kemenag Indonesia

---

## 🙏 Credits

- **JAKIM** - e-Solat, myHadith, e-Fatwa, Guidelines
- **Al-Quran Cloud** - Quran API
- **Tanzil.net** - Quran Uthmani text
- **EveryAyah.com** - Audio recitations

---

## 📞 Support

For issues or questions:
- Create an issue on GitHub
- Email: support@alquran-superapp.com (placeholder)

---

**Built with ❤️ for the Muslim Ummah in Malaysia & Indonesia**

_Mematuhi garis panduan JAKIM/JAIS • Verified Islamic Content_
