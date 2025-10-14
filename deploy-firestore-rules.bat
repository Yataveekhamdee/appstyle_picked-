@echo off
echo 🚀 Deploying Firestore Security Rules...

REM ตรวจสอบว่า Firebase CLI ติดตั้งแล้วหรือไม่
firebase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Firebase CLI ไม่ได้ติดตั้ง
    echo 📦 ติดตั้ง Firebase CLI:
    echo npm install -g firebase-tools
    pause
    exit /b 1
)

REM ตรวจสอบว่า login แล้วหรือไม่
firebase projects:list >nul 2>&1
if %errorlevel% neq 0 (
    echo 🔐 กรุณา login Firebase CLI:
    echo firebase login
    pause
    exit /b 1
)

REM ตั้งค่า project
echo ⚙️  ตั้งค่า Firebase project...
firebase use appstyle-picked

REM Deploy production rules
echo 📤 Deploying production rules...
firebase deploy --only firestore:rules

echo ✅ Firestore Rules deployed successfully!
echo.
echo 📋 ขั้นตอนต่อไป:
echo 1. ทดสอบการเข้าถึง Admin Management Page
echo 2. ตรวจสอบว่าสามารถอ่านข้อมูล admins collection ได้
echo 3. ทดสอบการสร้าง admin user ใหม่
echo.
echo 🔧 หากต้องการใช้ development rules:
echo firebase deploy --only firestore:rules --project appstyle-picked-dev

pause






