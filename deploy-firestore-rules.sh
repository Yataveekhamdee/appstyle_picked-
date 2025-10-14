#!/bin/bash

echo "🚀 Deploying Firestore Security Rules..."

# ตรวจสอบว่า Firebase CLI ติดตั้งแล้วหรือไม่
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI ไม่ได้ติดตั้ง"
    echo "📦 ติดตั้ง Firebase CLI:"
    echo "npm install -g firebase-tools"
    exit 1
fi

# ตรวจสอบว่า login แล้วหรือไม่
if ! firebase projects:list &> /dev/null; then
    echo "🔐 กรุณา login Firebase CLI:"
    echo "firebase login"
    exit 1
fi

# ตั้งค่า project
echo "⚙️  ตั้งค่า Firebase project..."
firebase use appstyle-picked

# Deploy production rules
echo "📤 Deploying production rules..."
firebase deploy --only firestore:rules

echo "✅ Firestore Rules deployed successfully!"
echo ""
echo "📋 ขั้นตอนต่อไป:"
echo "1. ทดสอบการเข้าถึง Admin Management Page"
echo "2. ตรวจสอบว่าสามารถอ่านข้อมูล admins collection ได้"
echo "3. ทดสอบการสร้าง admin user ใหม่"
echo ""
echo "🔧 หากต้องการใช้ development rules:"
echo "firebase deploy --only firestore:rules --project appstyle-picked-dev"






