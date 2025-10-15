# Build Flutter App Script
Write-Host "🔨 Building Al-Quran SuperApp..." -ForegroundColor Green
Write-Host ""

# Check Flutter
Write-Host "📦 Checking Flutter installation..." -ForegroundColor Cyan
flutter --version

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter not found! Please install Flutter first." -ForegroundColor Red
    Write-Host "Download: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Flutter found!" -ForegroundColor Green
Write-Host ""

# Clean
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
flutter pub get

Write-Host ""

# Build APK
Write-Host "🔨 Building APK (Release)..." -ForegroundColor Yellow
flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ APK built successfully!" -ForegroundColor Green
    $apkPath = "build\app\outputs\flutter-apk\app-release.apk"
    $apkSize = (Get-Item $apkPath).Length / 1MB
    Write-Host "📍 Location: $apkPath" -ForegroundColor Cyan
    Write-Host "📊 Size: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Cyan
} else {
    Write-Host "❌ APK build failed!" -ForegroundColor Red
}

Write-Host ""

# Build App Bundle
Write-Host "🔨 Building App Bundle (Release)..." -ForegroundColor Yellow
flutter build appbundle --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ AAB built successfully!" -ForegroundColor Green
    $aabPath = "build\app\outputs\bundle\release\app-release.aab"
    $aabSize = (Get-Item $aabPath).Length / 1MB
    Write-Host "📍 Location: $aabPath" -ForegroundColor Cyan
    Write-Host "📊 Size: $([math]::Round($aabSize, 2)) MB" -ForegroundColor Cyan
} else {
    Write-Host "❌ AAB build failed!" -ForegroundColor Red
}

Write-Host ""
Write-Host "════════════════════════════════════════" -ForegroundColor Green
Write-Host "✅ BUILD COMPLETE!" -ForegroundColor Green
Write-Host "════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "📦 Outputs:" -ForegroundColor Cyan
Write-Host "  APK: build\app\outputs\flutter-apk\app-release.apk"
Write-Host "  AAB: build\app\outputs\bundle\release\app-release.aab"
Write-Host ""
Write-Host "🎯 Next:" -ForegroundColor Yellow
Write-Host "  1. Install APK on Android device: adb install build\app\outputs\flutter-apk\app-release.apk"
Write-Host "  2. Upload AAB to Google Play Console for store submission"
Write-Host ""
