# 🚀 Deploy to Vercel - Step by Step

## Option 1: Via Vercel Dashboard (RECOMMENDED - 5 minutes)

### Step 1: Go to Vercel
Open browser: **https://vercel.com/new**

### Step 2: Import Repository
1. Click **"Import Git Repository"**
2. Paste: `https://github.com/thisisniagahub/al-quran-superapp`
3. Click **"Import"**

### Step 3: Configure
**Project Settings**:
- **Project Name**: `al-quran-superapp-api` (or any name)
- **Framework Preset**: **Other**
- **Root Directory**: `backend` ⬅️ IMPORTANT!
- **Build Command**: (leave empty)
- **Output Directory**: `.`
- **Install Command**: `npm install`

### Step 4: Environment Variables
Click **"Environment Variables"** tab and add:

```bash
NODE_ENV=production
JAKIM_VERIFICATION_ENABLED=true
CONTENT_MODERATION_STRICT=true
```

*Optional (if using AI features)*:
```bash
OPENAI_API_KEY=sk-your-key-here
AI_MODEL=gpt-4
```

*Optional (if database ready)*:
```bash
DB_HOST=your-db-host
DB_PORT=5432
DB_NAME=alquran_app
DB_USER=your-user
DB_PASSWORD=your-password
```

### Step 5: Deploy!
1. Click **"Deploy"**
2. Wait 1-2 minutes
3. ✅ **DONE!**

### Step 6: Copy URL
After deployment:
- Copy URL (e.g., `https://al-quran-superapp-xxxx.vercel.app`)
- Save it for next step

---

## After Vercel Deployment

### Run Setup Script

Open PowerShell in project folder and run:

```powershell
.\setup_complete.ps1 -VercelUrl "https://YOUR-VERCEL-URL.vercel.app"
```

This will:
✅ Update Flutter services with your Vercel URL  
✅ Install dependencies  
✅ Build APK  
✅ Build AAB  

---

## Test Backend API

```bash
# Health check
curl https://YOUR-VERCEL-URL.vercel.app/health

# Test Quran API
curl https://YOUR-VERCEL-URL.vercel.app/api/quran/surahs

# Test Prayer API
curl "https://YOUR-VERCEL-URL.vercel.app/api/prayer/times/malaysia?zone=SGR01"
```

---

## Database Setup (After Vercel Deploy)

### Option A: Vercel Postgres

1. In Vercel dashboard → **Storage** tab
2. Click **Create Database** → **Postgres**
3. Copy connection string
4. Go to **Environment Variables** and add DB credentials
5. Run migration:
   ```bash
   cd backend
   node scripts/migrate.js
   ```

### Option B: Supabase (Free Tier)

1. Go to https://supabase.com
2. Create new project
3. Copy connection details
4. Add to Vercel environment variables
5. Run migration:
   ```bash
   cd backend
   node scripts/migrate.js
   ```

---

## Complete Checklist

- [ ] Deployed to Vercel via dashboard
- [ ] Copied Vercel URL
- [ ] Ran setup_complete.ps1 script
- [ ] Setup database (Vercel Postgres or Supabase)
- [ ] Ran database migration
- [ ] Tested API endpoints
- [ ] APK built successfully
- [ ] Tested app on Android device

---

## Troubleshooting

**Build fails on Vercel?**
- Check Root Directory is set to `backend`
- Check package.json is valid

**API returns errors?**
- Check environment variables in Vercel
- Check Vercel logs: `vercel logs`

**Flutter can't connect?**
- Verify baseUrl in services is correct
- Check API is deployed and accessible
- Check CORS (already enabled in backend)

---

## Need Help?

Check these files:
- `DEPLOYMENT_GUIDE.md` - Full deployment guide
- `README.md` - Complete documentation
- `STATUS_REPORT.md` - Project status

Or check Vercel logs in dashboard.
