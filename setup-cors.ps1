# Firebase Storage CORS Setup Script for PowerShell
# สำหรับแก้ไข CORS error ใน Web development

Write-Host "🔧 Setting up Firebase Storage CORS..." -ForegroundColor Cyan

# ตรวจสอบว่า gsutil ติดตั้งแล้วหรือไม่
try {
    $gsutilVersion = & gsutil --version 2>$null
    Write-Host "✅ gsutil found: $gsutilVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ gsutil not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "📦 Please install Google Cloud SDK:" -ForegroundColor Yellow
    Write-Host "   1. Download from https://cloud.google.com/sdk/docs/install" -ForegroundColor Yellow
    Write-Host "   2. Run the installer and restart PowerShell" -ForegroundColor Yellow
    Write-Host "   3. Or use Firebase Console method (see CORS_SETUP_MANUAL_GUIDE.md)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🚀 Alternative: Use Firebase Console method" -ForegroundColor Cyan
    Write-Host "   1. Go to https://console.firebase.google.com/" -ForegroundColor Cyan
    Write-Host "   2. Select project 'appstyle-picked'" -ForegroundColor Cyan
    Write-Host "   3. Go to Storage > Rules" -ForegroundColor Cyan
    Write-Host "   4. Set rules to allow access" -ForegroundColor Cyan
    Read-Host "Press Enter to continue"
    exit 1
}

# ตรวจสอบว่าไฟล์ CORS configuration มีอยู่หรือไม่
if (-not (Test-Path "firebase-storage-cors.json")) {
    Write-Host "❌ firebase-storage-cors.json not found!" -ForegroundColor Red
    Read-Host "Press Enter to continue"
    exit 1
}

# ตั้งค่า CORS
Write-Host "📝 Setting CORS configuration..." -ForegroundColor Yellow
try {
    & gsutil cors set firebase-storage-cors.json gs://appstyle-picked.firebasestorage.app
    Write-Host "✅ CORS configuration set successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to set CORS configuration: $_" -ForegroundColor Red
    Read-Host "Press Enter to continue"
    exit 1
}

# ตรวจสอบ CORS settings
Write-Host "🔍 Checking CORS configuration..." -ForegroundColor Yellow
try {
    & gsutil cors get gs://appstyle-picked.firebasestorage.app
    Write-Host "✅ CORS verification completed!" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Could not verify CORS settings: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ CORS setup completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "   1. Run 'flutter run -d chrome' to test in browser" -ForegroundColor White
Write-Host "   2. Try uploading an image" -ForegroundColor White
Write-Host "   3. Check console for any remaining errors" -ForegroundColor White
Write-Host ""
Write-Host "🔧 If you still see CORS errors:" -ForegroundColor Yellow
Write-Host "   1. Check Firebase Storage Security Rules" -ForegroundColor White
Write-Host "   2. Verify Admin email is in the whitelist" -ForegroundColor White
Write-Host "   3. Make sure you're authenticated as Admin" -ForegroundColor White
Write-Host ""
Write-Host "📚 For more help, see CORS_SETUP_MANUAL_GUIDE.md" -ForegroundColor Cyan
Write-Host ""

Read-Host "Press Enter to continue"






