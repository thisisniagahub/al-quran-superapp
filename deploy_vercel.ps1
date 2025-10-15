# Deploy Al-Quran SuperApp Backend to Vercel
Write-Host "🚀 Deploying Al-Quran SuperApp to Vercel..." -ForegroundColor Green

# Get Vercel token from .env
$vercelToken = (Get-Content backend\.env | Select-String "VERCEL_TOKEN" | ForEach-Object { $_ -replace "VERCEL_TOKEN=", "" }).Trim()

if ([string]::IsNullOrEmpty($vercelToken)) {
    Write-Host "❌ VERCEL_TOKEN not found in backend/.env" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Token found. Deploying..." -ForegroundColor Yellow

# Set environment variable
$env:VERCEL_TOKEN = $vercelToken

# Install Vercel CLI if not installed
Write-Host "📦 Checking Vercel CLI..." -ForegroundColor Cyan
$vercelCmd = Get-Command vercel -ErrorAction SilentlyContinue
if (!$vercelCmd) {
    Write-Host "📥 Installing Vercel CLI..." -ForegroundColor Yellow
    npm install -g vercel
}

# Change to backend directory
Set-Location backend

# Deploy to Vercel
Write-Host "🚀 Deploying to Vercel (production)..." -ForegroundColor Green
vercel --prod --token $vercelToken --yes

Write-Host ""
Write-Host "✅ DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Check deployment URL in output above"
Write-Host "2. Update Flutter app baseUrl with Vercel URL"
Write-Host "3. Setup PostgreSQL database (Vercel Postgres or external)"
Write-Host "4. Add environment variables in Vercel dashboard"
Write-Host ""
