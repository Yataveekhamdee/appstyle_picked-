@echo off
echo 🔧 Firebase Storage CORS Fix
echo.

REM ตรวจสอบ gsutil
where gsutil >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ gsutil found
    echo 📝 Setting CORS...
    gsutil cors set firebase-storage-cors.json gs://appstyle-picked.firebasestorage.app
    echo ✅ CORS setup completed!
) else (
    echo ❌ gsutil not found!
    echo.
    echo 🚀 Quick Fix: Use Firebase Console
    echo 1. Go to https://console.firebase.google.com/
    echo 2. Select project 'appstyle-picked'
    echo 3. Go to Storage ^> Rules
    echo 4. Set rules to allow access:
    echo.
    echo rules_version = '2';
    echo service firebase.storage {
    echo   match /b/{bucket}/o {
    echo     match /{allPaths=**} {
    echo       allow read, write: if true;
    echo     }
    echo   }
    echo }
    echo.
    echo 5. Click Publish
)

echo.
echo 📋 Next: Test upload in browser
echo Run: flutter run -d chrome
echo.
pause






