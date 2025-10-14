# 🔒 Firebase Storage Rules Setup Guide

## 📋 ภาพรวม

ไฟล์ `firebase-storage.rules` ประกอบด้วย Firebase Storage Security Rules ที่ครอบคลุมทุกโฟลเดอร์และ use case ในแอปพลิเคชัน Style Picked

## 🎯 โครงสร้างโฟลเดอร์ที่รองรับ

```
gs://your-project.appspot.com/
├── products/                    # รูปภาพสินค้า
│   ├── product_123_1640995200000.jpg
│   └── thumbnails/              # Thumbnail สินค้า
├── brands/                      # โลโก้แบรนด์
│   ├── brand_456_1640995300000.png
│   └── thumbnails/              # Thumbnail แบรนด์
├── categories/                  # รูปภาพหมวดหมู่
│   ├── cat_789_1640995400000.jpg
│   └── thumbnails/              # Thumbnail หมวดหมู่
├── users/                       # รูปภาพผู้ใช้
│   ├── user_001_1640995500000.jpg
│   ├── profile/                 # รูปโปรไฟล์
│   └── avatar/                  # รูป Avatar
├── thumbnails/                  # Thumbnail ทั่วไป
├── temp/                        # ไฟล์ชั่วคราว
├── backups/                     # ไฟล์สำรองข้อมูล
├── analytics/                   # รูปภาพ Analytics
├── banners/                     # รูปภาพ Banner
├── promotions/                  # รูปภาพโปรโมชั่น
├── orders/{orderId}/receipts/   # ใบเสร็จคำสั่งซื้อ
├── reviews/{reviewId}/images/   # รูปรีวิว
└── support/{ticketId}/attachments/ # ไฟล์แนบ Support
```

## 🚀 การติดตั้ง Rules

### 1. ผ่าน Firebase Console

#### ขั้นตอน:
1. ไปที่ [Firebase Console](https://console.firebase.google.com)
2. เลือกโปรเจค **Style Picked**
3. ไปที่ **Storage** > **Rules**
4. คัดลอกเนื้อหาจากไฟล์ `firebase-storage.rules`
5. วางใน Rules editor
6. กด **Publish**

#### ภาพหน้าจอ:
```
Firebase Console > Storage > Rules
┌─────────────────────────────────────┐
│ rules_version = '2';                │
│                                     │
│ service firebase.storage {          │
│   match /b/{bucket}/o {             │
│     // Rules content here...        │
│   }                                 │
│ }                                   │
└─────────────────────────────────────┘
```

### 2. ผ่าน Firebase CLI

#### ติดตั้ง Firebase CLI:
```bash
npm install -g firebase-tools
```

#### Login และตั้งค่า:
```bash
firebase login
firebase use your-project-id
```

#### Deploy Rules:
```bash
# Deploy เฉพาะ Storage Rules
firebase deploy --only storage

# หรือ Deploy ทั้งหมด
firebase deploy
```

### 3. ผ่าน GitHub Actions (แนะนำ)

#### สร้างไฟล์ `.github/workflows/deploy-storage-rules.yml`:
```yaml
name: Deploy Firebase Storage Rules

on:
  push:
    branches: [ main ]
    paths: [ 'firebase-storage.rules' ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install Firebase CLI
        run: npm install -g firebase-tools
        
      - name: Deploy Storage Rules
        run: firebase deploy --only storage --token ${{ secrets.FIREBASE_TOKEN }}
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

## 🔧 การกำหนดค่า

### 1. Admin Email Whitelist

#### แก้ไขในไฟล์ Rules:
```javascript
function isAdmin(email) {
  return email in [
    'admin@stylepicked.com',
    'admin@gmail.com',
    'anucha.suks@gmail.com',
    'yatawikhadi@gmail.com',
    'newadmin@example.com'  // เพิ่ม admin ใหม่
  ];
}
```

#### เพิ่ม Admin ใหม่:
1. เปิดไฟล์ `firebase-storage.rules`
2. เพิ่ม email ใน `isAdmin()` function
3. Deploy rules ใหม่

### 2. ไฟล์ Size Limit

#### เปลี่ยนขนาดไฟล์สูงสุด:
```javascript
function isValidSize() {
  return resource.size < 20 * 1024 * 1024; // เปลี่ยนเป็น 20MB
}
```

#### ขนาดที่แนะนำ:
- **รูปภาพสินค้า**: 10MB
- **โลโก้แบรนด์**: 5MB
- **รูปภาพหมวดหมู่**: 5MB
- **รูปภาพผู้ใช้**: 2MB
- **Thumbnail**: 1MB

### 3. ประเภทไฟล์ที่อนุญาต

#### เพิ่มประเภทไฟล์ใหม่:
```javascript
function isValidImageFileName() {
  return resource.name.matches('.*\\.(jpg|jpeg|png|gif|webp|svg|bmp)'); // เพิ่ม svg, bmp
}
```

#### ประเภทไฟล์ที่รองรับ:
- **JPG/JPEG**: รูปภาพทั่วไป
- **PNG**: รูปภาพโปร่งใส
- **GIF**: รูปภาพเคลื่อนไหว
- **WebP**: รูปภาพใหม่ Google
- **SVG**: เวกเตอร์กราฟิก
- **BMP**: Bitmap

## 🧪 การทดสอบ Rules

### 1. ใช้ Firebase Console Playground

#### ขั้นตอน:
1. ไปที่ **Storage** > **Rules**
2. เลือกแท็บ **Playground**
3. ทดสอบ scenarios ต่างๆ

#### ตัวอย่างการทดสอบ:
```javascript
// Test 1: อัปโหลดรูปสินค้า (Admin)
Authentication: Logged in as admin@gmail.com
Resource: products/product_123_1640995200000.jpg
Operation: Write
Expected: Allow ✅

// Test 2: อัปโหลดรูปสินค้า (User)
Authentication: Logged in as user@gmail.com
Resource: products/product_123_1640995200000.jpg
Operation: Write
Expected: Deny ❌

// Test 3: อ่านรูปสินค้า (ไม่ Login)
Authentication: Not logged in
Resource: products/product_123_1640995200000.jpg
Operation: Read
Expected: Allow ✅
```

### 2. ใช้ Firebase CLI Emulator

#### ติดตั้ง Emulator:
```bash
firebase init emulators
firebase emulators:start --only storage
```

#### ทดสอบในโค้ด:
```dart
// ทดสอบการอัปโหลด
try {
  final ref = FirebaseStorage.instance.ref('products/test.jpg');
  await ref.putFile(imageFile);
  print('✅ อัปโหลดสำเร็จ');
} catch (e) {
  print('❌ อัปโหลดไม่สำเร็จ: $e');
}
```

### 3. การทดสอบในแอป

#### สร้างไฟล์ทดสอบ:
```dart
// lib/test/storage_rules_test.dart
import 'package:firebase_storage/firebase_storage.dart';

class StorageRulesTest {
  static Future<void> testProductUpload() async {
    try {
      final ref = FirebaseStorage.instance.ref('products/test_product.jpg');
      await ref.putFile(testImageFile);
      print('✅ Product upload: PASS');
    } catch (e) {
      print('❌ Product upload: FAIL - $e');
    }
  }

  static Future<void> testUserUpload() async {
    try {
      final ref = FirebaseStorage.instance.ref('users/test_user.jpg');
      await ref.putFile(testImageFile);
      print('✅ User upload: PASS');
    } catch (e) {
      print('❌ User upload: FAIL - $e');
    }
  }

  static Future<void> testAdminUpload() async {
    // Login as admin first
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: 'admin@gmail.com',
      password: 'admin123',
    );

    try {
      final ref = FirebaseStorage.instance.ref('products/admin_test.jpg');
      await ref.putFile(testImageFile);
      print('✅ Admin upload: PASS');
    } catch (e) {
      print('❌ Admin upload: FAIL - $e');
    }
  }
}
```

## 📊 Monitoring และ Analytics

### 1. Firebase Console Monitoring

#### ตรวจสอบการใช้งาน:
1. ไปที่ **Storage** > **Usage**
2. ดูข้อมูลการใช้งาน Storage
3. ตรวจสอบไฟล์ที่อัปโหลด

#### ตรวจสอบ Rules:
1. ไปที่ **Storage** > **Rules**
2. ดู **Rules playground** logs
3. ตรวจสอบ error logs

### 2. Custom Analytics

#### เพิ่ม Analytics Events:
```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class StorageAnalytics {
  static Future<void> trackImageUpload({
    required String folder,
    required String fileName,
    required int fileSize,
    required String fileType,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'storage_image_upload',
      parameters: {
        'folder': folder,
        'file_name': fileName,
        'file_size': fileSize,
        'file_type': fileType,
        'upload_timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  static Future<void> trackImageDelete({
    required String folder,
    required String fileName,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'storage_image_delete',
      parameters: {
        'folder': folder,
        'file_name': fileName,
        'delete_timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
}
```

## 🚨 การแก้ไขปัญหา

### ปัญหาที่พบบ่อย

#### 1. Permission Denied
```
Error: [firebase_storage/unauthorized] User does not have permission to access this object
```

**วิธีแก้ไข:**
- ตรวจสอบว่าเป็น Admin หรือไม่
- ตรวจสอบ email ใน whitelist
- ตรวจสอบ authentication status

#### 2. Invalid File Type
```
Error: [firebase_storage/invalid-argument] Invalid argument provided
```

**วิธีแก้ไข:**
- ตรวจสอบประเภทไฟล์
- ตรวจสอบ file extension
- ใช้ image picker ที่รองรับ

#### 3. File Too Large
```
Error: [firebase_storage/invalid-argument] File too large
```

**วิธีแก้ไข:**
- บีบอัดรูปภาพก่อนอัปโหลด
- ตรวจสอบขนาดไฟล์
- ปรับขนาดไฟล์สูงสุดใน Rules

#### 4. Network Error
```
Error: [firebase_storage/network-request-failed] Network request failed
```

**วิธีแก้ไข:**
- ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต
- ใช้ retry mechanism
- แสดง progress indicator

### การ Debug Rules

#### 1. เปิด Debug Mode:
```javascript
// เพิ่มใน Rules สำหรับ debug
function debugLog(message) {
  return debug('Debug: ' + message);
}
```

#### 2. ใช้ Console Logs:
```javascript
// ใน Rules
allow write: if debugLog('Checking admin status') && isAdmin(request.auth.token.email);
```

#### 3. ตรวจสอบใน Firebase Console:
1. ไปที่ **Storage** > **Rules**
2. ดู **Rules playground** logs
3. ตรวจสอบ error messages

## 🔄 การอัปเดต Rules

### 1. การเพิ่มโฟลเดอร์ใหม่

#### ขั้นตอน:
1. เพิ่ม rules สำหรับโฟลเดอร์ใหม่
2. ทดสอบ rules ใน playground
3. Deploy rules
4. ทดสอบในแอปจริง

#### ตัวอย่าง:
```javascript
// เพิ่มโฟลเดอร์ใหม่
match /new_folder/{fileId} {
  allow read: if true;
  allow write: if isAuthenticated() && isAdmin(request.auth.token.email);
  allow delete: if isAuthenticated() && isAdmin(request.auth.token.email);
}
```

### 2. การเปลี่ยนสิทธิ์

#### ตัวอย่างการเปลี่ยนสิทธิ์:
```javascript
// เดิม: เฉพาะ Admin เท่านั้น
allow write: if isAuthenticated() && isAdmin(request.auth.token.email);

// ใหม่: ผู้ใช้ทั่วไปก็อัปโหลดได้
allow write: if isAuthenticated() && isImage() && isValidSize();
```

### 3. การเพิ่มเงื่อนไขใหม่

#### ตัวอย่าง:
```javascript
// เพิ่มเงื่อนไขการตรวจสอบ timestamp
function hasRecentTimestamp() {
  return resource.name.matches('.*_[0-9]{13}\\..*') &&
         int(resource.name.split('_')[1]) > (request.time.toMillis() - 86400000); // 24 ชั่วโมง
}

// ใช้ใน rules
allow write: if isAuthenticated() 
               && isAdmin(request.auth.token.email)
               && hasRecentTimestamp();
```

## 📞 การสนับสนุน

### ติดต่อทีมพัฒนา:
- **Email**: dev@stylepicked.com
- **Slack**: #firebase-support
- **GitHub**: Issues ใน repository

### เอกสารเพิ่มเติม:
- [Firebase Storage Documentation](https://firebase.google.com/docs/storage)
- [Firebase Security Rules Guide](https://firebase.google.com/docs/rules)
- [Firebase CLI Documentation](https://firebase.google.com/docs/cli)

---

**สร้างโดย**: AI Assistant  
**วันที่**: $(date)  
**เวอร์ชัน**: 1.0.0






