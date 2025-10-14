#!/bin/bash

# Firebase Storage CORS Setup Script
# สำหรับแก้ไข CORS error ใน Web development

echo "🔧 Setting up Firebase Storage CORS..."

# ตรวจสอบว่า gsutil ติดตั้งแล้วหรือไม่
if ! command -v gsutil &> /dev/null; then
    echo "❌ gsutil not found. Please install Google Cloud SDK:"
    echo "   - Windows: Download from https://cloud.google.com/sdk/docs/install"
    echo "   - macOS: brew install google-cloud-sdk"
    echo "   - Linux: curl https://sdk.cloud.google.com | bash"
    exit 1
fi

# ตรวจสอบว่าไฟล์ CORS configuration มีอยู่หรือไม่
if [ ! -f "firebase-storage-cors.json" ]; then
    echo "❌ firebase-storage-cors.json not found!"
    exit 1
fi

# ตั้งค่า CORS
echo "📝 Setting CORS configuration..."
gsutil cors set firebase-storage-cors.json gs://appstyle-picked.firebasestorage.app

# ตรวจสอบ CORS settings
echo "🔍 Checking CORS configuration..."
gsutil cors get gs://appstyle-picked.firebasestorage.app

echo "✅ CORS setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Run 'flutter run -d chrome' to test in browser"
echo "2. Try uploading an image"
echo "3. Check console for any remaining errors"
echo ""
echo "🔧 If you still see CORS errors:"
echo "1. Check Firebase Storage Security Rules"
echo "2. Verify Admin email is in the whitelist"
echo "3. Make sure you're authenticated as Admin"






