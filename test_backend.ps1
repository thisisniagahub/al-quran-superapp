# Test Backend API Script
param(
    [Parameter(Mandatory=$true)]
    [string]$ApiUrl
)

Write-Host "🧪 Testing Al-Quran SuperApp Backend..." -ForegroundColor Green
Write-Host "API URL: $ApiUrl" -ForegroundColor Cyan
Write-Host ""

function Test-Endpoint {
    param($Name, $Url)
    
    Write-Host "Testing $Name..." -ForegroundColor Yellow
    try {
        $response = Invoke-RestMethod -Uri $Url -Method Get -TimeoutSec 10
        Write-Host "  ✅ SUCCESS" -ForegroundColor Green
        $response | ConvertTo-Json -Depth 2 | Write-Host
        return $true
    } catch {
        Write-Host "  ❌ FAILED: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    Write-Host ""
}

$results = @()

# Test Health
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
$results += Test-Endpoint "Health Check" "$ApiUrl/health"

# Test Quran API
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
$results += Test-Endpoint "Quran - List Surahs" "$ApiUrl/api/quran/surahs"

Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
$results += Test-Endpoint "Quran - Get Surah 1" "$ApiUrl/api/quran/surah/1?translation=ms"

# Test Prayer API
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
$results += Test-Endpoint "Prayer - Malaysia Times" "$ApiUrl/api/prayer/times/malaysia?zone=SGR01"

Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
$results += Test-Endpoint "Prayer - Malaysia Zones" "$ApiUrl/api/prayer/zones/malaysia"

# Test Streaming API
Write-Host "════════════════════════════════════════" -ForegroundColor Cyan
$results += Test-Endpoint "Streaming - Categories" "$ApiUrl/api/streaming/categories"

# Summary
Write-Host ""
Write-Host "════════════════════════════════════════" -ForegroundColor Green
Write-Host "📊 TEST SUMMARY" -ForegroundColor Green
Write-Host "════════════════════════════════════════" -ForegroundColor Green

$passed = ($results | Where-Object { $_ -eq $true }).Count
$failed = ($results | Where-Object { $_ -eq $false }).Count
$total = $results.Count

Write-Host "Total Tests: $total" -ForegroundColor Cyan
Write-Host "Passed: $passed" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor Red
Write-Host ""

if ($failed -eq 0) {
    Write-Host "✅ ALL TESTS PASSED!" -ForegroundColor Green
} else {
    Write-Host "⚠️ Some tests failed. Check logs above." -ForegroundColor Yellow
}
Write-Host ""
