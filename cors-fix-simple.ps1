Write-Host "🔧 Firebase Storage CORS Fix" -ForegroundColor Cyan
Write-Host ""

# ตรวจสอบ gsutil
try {
    $null = & gsutil --version 2>$null
    Write-Host "✅ gsutil found" -ForegroundColor Green
    
    # ตั้งค่า CORS
    Write-Host "📝 Setting CORS..." -ForegroundColor Yellow
    & gsutil cors set firebase-storage-cors.json gs://appstyle-picked.firebasestorage.app
    Write-Host "✅ CORS setup completed!" -ForegroundColor Green
    
} catch {
    Write-Host "❌ gsutil not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "🚀 Quick Fix: Use Firebase Console" -ForegroundColor Yellow
    Write-Host "1. Go to https://console.firebase.google.com/" -ForegroundColor White
    Write-Host "2. Select project 'appstyle-picked'" -ForegroundColor White
    Write-Host "3. Go to Storage > Rules" -ForegroundColor White
    Write-Host "4. Set rules to allow access:" -ForegroundColor White
    Write-Host ""
    Write-Host "rules_version = '2';" -ForegroundColor Green
    Write-Host "service firebase.storage {" -ForegroundColor Green
    Write-Host "  match /b/{bucket}/o {" -ForegroundColor Green
    Write-Host "    match /{allPaths=**} {" -ForegroundColor Green
    Write-Host "      allow read, write: if true;" -ForegroundColor Green
    Write-Host "    }" -ForegroundColor Green
    Write-Host "  }" -ForegroundColor Green
    Write-Host "}" -ForegroundColor Green
}

Write-Host ""
Write-Host "📋 Next: Test upload in browser" -ForegroundColor Cyan
Read-Host "Press Enter to continue"






