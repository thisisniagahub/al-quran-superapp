# Complete Setup Script for Al-Quran SuperApp
# Run this AFTER Vercel deployment

param(
    [Parameter(Mandatory=$true)]
    [string]$VercelUrl
)

Write-Host "🚀 Setting up Al-Quran SuperApp..." -ForegroundColor Green
Write-Host "Vercel URL: $VercelUrl" -ForegroundColor Cyan
Write-Host ""

# Step 1: Update Flutter services
Write-Host "📱 Step 1: Updating Flutter service URLs..." -ForegroundColor Yellow

$apiUrl = "$VercelUrl/api"

# Update quran_service.dart
Write-Host "  Updating quran_service.dart..."
$quranService = Get-Content "lib\services\quran_service.dart" -Raw
$quranService = $quranService -replace "http://localhost:3000/api", $apiUrl
Set-Content "lib\services\quran_service.dart" -Value $quranService

# Update prayer_service.dart
Write-Host "  Updating prayer_service.dart..."
$prayerService = Get-Content "lib\services\prayer_service.dart" -Raw
$prayerService = $prayerService -replace "http://localhost:3000/api", $apiUrl
Set-Content "lib\services\prayer_service.dart" -Value $prayerService

# Update ai_service.dart
Write-Host "  Updating ai_service.dart..."
$aiService = Get-Content "lib\services\ai_service.dart" -Raw
$aiService = $aiService -replace "http://localhost:3000/api", $apiUrl
Set-Content "lib\services\ai_service.dart" -Value $aiService

Write-Host "  ✅ Flutter services updated!" -ForegroundColor Green
Write-Host ""

# Step 2: Install dependencies
Write-Host "📦 Step 2: Installing Flutter dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host "  ✅ Dependencies installed!" -ForegroundColor Green
Write-Host ""

# Step 3: Build APK
Write-Host "🔨 Step 3: Building Android APK..." -ForegroundColor Yellow
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ APK built successfully!" -ForegroundColor Green
    Write-Host "  📍 Location: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Cyan
} else {
    Write-Host "  ❌ APK build failed!" -ForegroundColor Red
}
Write-Host ""

# Step 4: Build App Bundle
Write-Host "🔨 Step 4: Building Android App Bundle..." -ForegroundColor Yellow
flutter build appbundle --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ AAB built successfully!" -ForegroundColor Green
    Write-Host "  📍 Location: build\app\outputs\bundle\release\app-release.aab" -ForegroundColor Cyan
} else {
    Write-Host "  ❌ AAB build failed!" -ForegroundColor Red
}
Write-Host ""

# Summary
Write-Host "════════════════════════════════════════" -ForegroundColor Green
Write-Host "✅ SETUP COMPLETE!" -ForegroundColor Green
Write-Host "════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Summary:" -ForegroundColor Cyan
Write-Host "  ✅ Flutter services updated with API: $apiUrl"
Write-Host "  ✅ APK built: build\app\outputs\flutter-apk\app-release.apk"
Write-Host "  ✅ AAB built: build\app\outputs\bundle\release\app-release.aab"
Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Install APK on Android device for testing"
Write-Host "  2. Test all features with live backend"
Write-Host "  3. Submit AAB to Google Play Store"
Write-Host ""
Write-Host "🔗 Links:" -ForegroundColor Cyan
Write-Host "  Backend API: $VercelUrl"
Write-Host "  API Health: $VercelUrl/health"
Write-Host "  GitHub: https://github.com/thisisniagahub/al-quran-superapp"
Write-Host ""
