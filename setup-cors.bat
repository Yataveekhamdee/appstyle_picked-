@echo off
REM Firebase Storage CORS Setup Script for Windows
REM สำหรับแก้ไข CORS error ใน Web development

echo 🔧 Setting up Firebase Storage CORS...

REM ตรวจสอบว่า gsutil ติดตั้งแล้วหรือไม่
where gsutil >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ gsutil not found. Please install Google Cloud SDK:
    echo    - Download from https://cloud.google.com/sdk/docs/install
    echo    - Run the installer and restart your command prompt
    pause
    exit /b 1
)

REM ตรวจสอบว่าไฟล์ CORS configuration มีอยู่หรือไม่
if not exist "firebase-storage-cors.json" (
    echo ❌ firebase-storage-cors.json not found!
    pause
    exit /b 1
)

REM ตั้งค่า CORS
echo 📝 Setting CORS configuration...
gsutil cors set firebase-storage-cors.json gs://appstyle-picked.firebasestorage.app

REM ตรวจสอบ CORS settings
echo 🔍 Checking CORS configuration...
gsutil cors get gs://appstyle-picked.firebasestorage.app

echo ✅ CORS setup completed!
echo.
echo 📋 Next steps:
echo 1. Run 'flutter run -d chrome' to test in browser
echo 2. Try uploading an image
echo 3. Check console for any remaining errors
echo.
echo 🔧 If you still see CORS errors:
echo 1. Check Firebase Storage Security Rules
echo 2. Verify Admin email is in the whitelist
echo 3. Make sure you're authenticated as Admin
echo.
pause






