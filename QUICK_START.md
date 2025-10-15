# ⚡ Quick Start Guide - Al-Quran SuperApp

Get your app running in **15 minutes**!

---

## 🎯 What You Need

✅ GitHub account (done - code already pushed!)  
✅ Vercel account (free): https://vercel.com  
✅ Flutter installed: https://flutter.dev  

---

## 🚀 Step-by-Step (15 minutes)

### Step 1: Deploy Backend to Vercel (5 min)

1. Open: **https://vercel.com/new**
2. Click **"Import Git Repository"**
3. Select: `thisisniagahub/al-quran-superapp`
4. Settings:
   - Root Directory: `backend`
   - Framework: Other
5. Click **"Deploy"**
6. ✅ Done! Copy your URL (e.g., `https://al-quran-superapp-xxx.vercel.app`)

### Step 2: Setup Flutter App (5 min)

Open PowerShell in project folder:

```powershell
# Replace YOUR-VERCEL-URL with actual URL from Step 1
.\setup_complete.ps1 -VercelUrl "https://YOUR-VERCEL-URL.vercel.app"
```

This automatically:
- Updates API URLs in Flutter
- Installs dependencies  
- Builds APK
- Builds AAB

### Step 3: Test (2 min)

```powershell
# Test backend
.\test_backend.ps1 -ApiUrl "https://YOUR-VERCEL-URL.vercel.app"

# Install APK on phone
adb install build\app\outputs\flutter-apk\app-release.apk
```

### Step 4: Setup Database (3 min) - OPTIONAL

**Option A: Vercel Postgres**
1. Vercel Dashboard → Storage → Create Postgres
2. Copy connection string
3. Add to Environment Variables in Vercel
4. Run: `cd backend && node scripts/migrate.js`

**Option B: Skip for now**
- App works without database
- Some features limited (no user data persistence)
- Add database later

---

## ✅ Done!

You now have:
- ✅ Backend running on Vercel
- ✅ APK ready to install
- ✅ AAB ready for Play Store

---

## 📱 Install on Phone

```bash
# Connect phone via USB, enable USB debugging
adb install build\app\outputs\flutter-apk\app-release.apk
```

Or copy APK to phone and install manually.

---

## 🎯 Next Steps

### Immediate:
- Test all features in app
- Verify API connectivity

### For Production:
- Setup database (Vercel Postgres or Supabase)
- Add custom domain to Vercel
- Setup Firebase for analytics
- Submit to Google Play Store

---

## 🆘 Problems?

### "Flutter not found"
```powershell
# Install Flutter: https://flutter.dev/docs/get-started/install
# Then run: flutter doctor
```

### "Vercel deployment failed"
- Check Root Directory is `backend`
- Check logs in Vercel dashboard

### "App can't connect to API"
- Verify Vercel URL in services files
- Test API: `curl https://your-url.vercel.app/health`

---

## 📚 More Help

- **Full Guide**: `DEPLOYMENT_GUIDE.md`
- **Documentation**: `README.md`
- **Status**: `DEPLOYMENT_SUCCESS.md`

---

**Built with ❤️ for the Muslim Ummah**

_Mematuhi garis panduan JAKIM/JAIS_
