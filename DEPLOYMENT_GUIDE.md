# 🚀 Deployment Guide - Al-Quran SuperApp

## ⚠️ BEFORE YOU START - SECURITY CHECK

**CRITICAL**: The tokens in `.env` were exposed and MUST be revoked!

1. **Read `SECURITY_WARNING.md` NOW!**
2. **Revoke old tokens** (GitHub + Vercel)
3. **Generate new tokens**
4. **Update `backend/.env`** with new tokens

---

## 📋 Pre-Deployment Checklist

- [ ] Tokens revoked and regenerated
- [ ] `.env` file updated with NEW tokens
- [ ] `.env` is in `.gitignore`
- [ ] PostgreSQL database ready (local or cloud)
- [ ] Node.js >= 16.x installed
- [ ] Flutter >= 2.18.0 installed

---

## 🎯 Deployment Steps

### Step 1: Initialize Git Repository

```bash
cd L:\al_quran_superapp_flutter

# Initialize git
git init

# Add all files
git add .

# Commit (co-authored with factory-droid)
git commit -m "Initial commit: Complete Al-Quran SuperApp with JAKIM compliance

Features:
- Complete Quran reader with audio & tafsir
- Prayer times (e-Solat JAKIM + Kemenag Indonesia)  
- AI Ustaz/Ustazah with voice Q&A
- PeaceTV-style streaming
- Share quote generator
- Community & donations
- Full JAKIM/JAIS compliance

Co-authored-by: factory-droid[bot] <138933559+factory-droid[bot]@users.noreply.github.com>"
```

### Step 2: Push to GitHub

```bash
# Load token from .env
$env:GITHUB_TOKEN = (Get-Content backend\.env | Select-String "GITHUB_TOKEN" | ForEach-Object { $_ -replace "GITHUB_TOKEN=", "" })

# Add remote
git remote add origin https://github.com/thisisniagahub/al-quran-superapp.git

# Push (using token)
git push https://thisisniagahub:${env:GITHUB_TOKEN}@github.com/thisisniagahub/al-quran-superapp.git main

# Or push using git credential helper
git push -u origin main
```

### Step 3: Deploy Backend to Vercel

#### Option A: Using Vercel CLI

```bash
# Install Vercel CLI
npm install -g vercel

# Login with token from .env
$env:VERCEL_TOKEN = (Get-Content backend\.env | Select-String "VERCEL_TOKEN" | ForEach-Object { $_ -replace "VERCEL_TOKEN=", "" })
vercel login --token $env:VERCEL_TOKEN

# Deploy backend
cd backend
vercel --prod

# Set environment variables in Vercel
vercel env add DB_HOST
vercel env add DB_USER
vercel env add DB_PASSWORD
vercel env add OPENAI_API_KEY
vercel env add JAKIM_VERIFICATION_ENABLED
```

#### Option B: Using Vercel Dashboard

1. Go to: https://vercel.com/new
2. Import Git Repository: `https://github.com/thisisniagahub/al-quran-superapp`
3. Framework Preset: **Other**
4. Root Directory: `backend`
5. Build Command: `npm install`
6. Output Directory: `.`
7. Add Environment Variables:
   - `DB_HOST`
   - `DB_USER`
   - `DB_PASSWORD`
   - `DB_NAME`
   - `OPENAI_API_KEY` (optional)
   - `JAKIM_VERIFICATION_ENABLED=true`
8. Click "Deploy"

### Step 4: Create vercel.json for Backend

Already created in `backend/vercel.json`:

```json
{
  "version": 2,
  "builds": [
    {
      "src": "index.js",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "index.js"
    }
  ],
  "env": {
    "NODE_ENV": "production"
  }
}
```

### Step 5: Setup Database (PostgreSQL)

#### Option A: Vercel Postgres (Recommended)

```bash
# In Vercel dashboard:
1. Go to Storage tab
2. Create PostgreSQL database
3. Copy connection string
4. Add to Vercel environment variables
```

#### Option B: External Database (Supabase/Railway/Neon)

1. Create database on provider
2. Get connection string
3. Run schema:
   ```bash
   psql YOUR_CONNECTION_STRING < backend/db/schema.sql
   ```
4. Add connection details to Vercel env vars

### Step 6: Update Flutter App with Vercel URL

After backend is deployed, update Flutter app:

```dart
// In all service files (quran_service.dart, prayer_service.dart, ai_service.dart)
// Change:
static const String baseUrl = 'http://localhost:3000/api';

// To:
static const String baseUrl = 'https://your-app.vercel.app/api';
```

### Step 7: Build Flutter App

#### For Android:

```bash
flutter build apk --release
# APK at: build/app/outputs/flutter-apk/app-release.apk

# Or App Bundle:
flutter build appbundle --release
# AAB at: build/app/outputs/bundle/release/app-release.aab
```

#### For iOS:

```bash
flutter build ios --release
# Then open Xcode and archive
```

---

## 🔧 Environment Variables Reference

### Backend Environment Variables

```bash
# Server
PORT=3000
NODE_ENV=production

# Database (REQUIRED)
DB_HOST=your-db-host.com
DB_PORT=5432
DB_NAME=alquran_app
DB_USER=your-db-user
DB_PASSWORD=your-db-password

# AI (Optional)
OPENAI_API_KEY=sk-xxxxxxxxxxxxx
AI_MODEL=gpt-4

# JAKIM Compliance
JAKIM_VERIFICATION_ENABLED=true
CONTENT_MODERATION_STRICT=true
```

---

## 🧪 Testing Deployment

### Test Backend API

```bash
# Health check
curl https://your-app.vercel.app/health

# Test Quran API
curl https://your-app.vercel.app/api/quran/surahs

# Test Prayer API
curl "https://your-app.vercel.app/api/prayer/times/malaysia?zone=SGR01"
```

### Test Flutter App

1. Update baseUrl in services
2. Run app: `flutter run`
3. Test each feature:
   - Quran reader
   - Prayer times
   - AI chat
   - Streaming
   - Share quotes

---

## 📊 Monitoring & Logs

### Vercel Logs

```bash
# View logs
vercel logs

# Real-time logs
vercel logs --follow
```

### In Vercel Dashboard:

- Analytics: https://vercel.com/[project]/analytics
- Logs: https://vercel.com/[project]/logs
- Deployments: https://vercel.com/[project]/deployments

---

## 🔒 Post-Deployment Security

1. **Verify .env not pushed to Git**
   ```bash
   git ls-files | grep .env
   # Should return nothing!
   ```

2. **Enable Vercel Password Protection** (optional)
   - Go to Project Settings > General
   - Enable Password Protection for preview deployments

3. **Setup CORS properly** (already done in backend)

4. **Monitor for suspicious activity**
   - Check Vercel logs regularly
   - Monitor database queries
   - Review API usage

---

## 🐛 Troubleshooting

### Backend won't start

```bash
# Check logs
vercel logs

# Common issues:
# 1. Missing environment variables
# 2. Database connection failed
# 3. Port already in use (local)
```

### Flutter app can't connect to API

```bash
# Check:
# 1. baseUrl is correct (https://, not http://)
# 2. API is deployed and accessible
# 3. CORS is enabled (already set in backend)
# 4. No typos in endpoints
```

### Database errors

```bash
# Check:
# 1. Connection string is correct
# 2. Database exists
# 3. Schema is loaded (run schema.sql)
# 4. User has permissions
```

---

## 📱 App Store Submission (Future)

### Google Play Store

1. Create app in Google Play Console
2. Upload AAB file
3. Fill in app details (screenshots, description)
4. Submit for review

### Apple App Store

1. Create app in App Store Connect
2. Archive app in Xcode
3. Upload to App Store Connect
4. Fill in app details
5. Submit for review

---

## 🔄 Continuous Deployment

### Auto-deploy on Git push

Vercel automatically deploys on every push to `main` branch:

```bash
git add .
git commit -m "Update features"
git push origin main
# Vercel will auto-deploy!
```

---

## 📞 Support

- **Vercel Docs**: https://vercel.com/docs
- **Flutter Docs**: https://docs.flutter.dev
- **PostgreSQL Docs**: https://www.postgresql.org/docs/

---

**Ready to deploy? Follow the steps above!**

_Remember: REVOKE old tokens first! Check SECURITY_WARNING.md_
