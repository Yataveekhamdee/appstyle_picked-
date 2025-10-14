# 🔒 Firebase Storage Security Rules

## 📋 ภาพรวม Security Rules

ไฟล์นี้ประกอบด้วย Firebase Storage Security Rules สำหรับระบบจัดการรูปภาพในแอปพลิเคชัน Style Picked

## 🎯 โครงสร้างโฟลเดอร์

```
gs://your-project.appspot.com/
├── products/           # รูปภาพสินค้า
├── brands/            # โลโก้แบรนด์
├── categories/        # รูปภาพหมวดหมู่
├── users/             # รูปภาพผู้ใช้
└── thumbnails/        # รูปภาพขนาดย่อ
```

## 🔐 Security Rules

```javascript
rules_version = '2';

// Firebase Storage Security Rules
service firebase.storage {
  match /b/{bucket}/o {
    
    // Function to check if user is admin
    function isAdmin(email) {
      return email in [
        'admin@stylepicked.com',
        'admin@gmail.com',
        'anucha.suks@gmail.com',
        'yatawikhadi@gmail.com'
      ];
    }

    // Function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }

    // Function to check if file is image
    function isImage() {
      return resource.contentType.matches('image/.*');
    }

    // Function to check file size (max 10MB)
    function isValidSize() {
      return resource.size < 10 * 1024 * 1024; // 10MB
    }

    // Function to check file name format
    function isValidFileName() {
      return resource.name.matches('.*\\.(jpg|jpeg|png|gif|webp)');
    }

    // Products images - Read for all, Write for admins only
    match /products/{productId} {
      allow read: if true; // ทุกคนสามารถดูรูปสินค้าได้
      allow write: if isAuthenticated() 
                     && isAdmin(request.auth.token.email)
                     && isImage()
                     && isValidSize()
                     && isValidFileName();
      allow delete: if isAuthenticated() 
                      && isAdmin(request.auth.token.email);
    }

    // Brand logos - Read for all, Write for admins only
    match /brands/{brandId} {
      allow read: if true; // ทุกคนสามารถดูโลโก้แบรนด์ได้
      allow write: if isAuthenticated() 
                     && isAdmin(request.auth.token.email)
                     && isImage()
                     && isValidSize()
                     && isValidFileName();
      allow delete: if isAuthenticated() 
                      && isAdmin(request.auth.token.email);
    }

    // Category images - Read for all, Write for admins only
    match /categories/{categoryId} {
      allow read: if true; // ทุกคนสามารถดูรูปหมวดหมู่ได้
      allow write: if isAuthenticated() 
                     && isAdmin(request.auth.token.email)
                     && isImage()
                     && isValidSize()
                     && isValidFileName();
      allow delete: if isAuthenticated() 
                      && isAdmin(request.auth.token.email);
    }

    // User images - Read/Write for authenticated users only
    match /users/{userId} {
      allow read: if isAuthenticated() && (
        request.auth.uid == userId || // เจ้าของรูป
        isAdmin(request.auth.token.email) // Admin
      );
      allow write: if isAuthenticated() 
                     && request.auth.uid == userId
                     && isImage()
                     && isValidSize()
                     && isValidFileName();
      allow delete: if isAuthenticated() && (
        request.auth.uid == userId || // เจ้าของรูป
        isAdmin(request.auth.token.email) // Admin
      );
    }

    // Thumbnails - Read for all, Write for admins only
    match /thumbnails/{thumbnailId} {
      allow read: if true; // ทุกคนสามารถดู thumbnail ได้
      allow write: if isAuthenticated() 
                     && isAdmin(request.auth.token.email)
                     && isImage()
                     && isValidSize()
                     && isValidFileName();
      allow delete: if isAuthenticated() 
                      && isAdmin(request.auth.token.email);
    }

    // Default rule - Deny all other access
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

## 🔧 การติดตั้ง Rules

### 1. ผ่าน Firebase Console
1. ไปที่ [Firebase Console](https://console.firebase.google.com)
2. เลือกโปรเจคของคุณ
3. ไปที่ **Storage** > **Rules**
4. คัดลอก Rules ด้านบนไปวาง
5. กด **Publish**

### 2. ผ่าน Firebase CLI
```bash
# ติดตั้ง Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# ตั้งค่าโปรเจค
firebase use your-project-id

# Deploy rules
firebase deploy --only storage
```

## 📊 การทดสอบ Rules

### 1. ทดสอบการอ่าน (Read)
```javascript
// ทดสอบอ่านรูปสินค้า
const productImageRef = storage.ref('products/product_123.jpg');
await productImageRef.getDownloadURL(); // ควรสำเร็จ

// ทดสอบอ่านโลโก้แบรนด์
const brandLogoRef = storage.ref('brands/brand_456.jpg');
await brandLogoRef.getDownloadURL(); // ควรสำเร็จ
```

### 2. ทดสอบการเขียน (Write)
```javascript
// ทดสอบอัปโหลดรูปสินค้า (ต้องเป็น Admin)
const productImageRef = storage.ref('products/product_789.jpg');
await productImageRef.put(imageFile); // สำเร็จถ้าเป็น Admin

// ทดสอบอัปโหลดรูปผู้ใช้ (ต้องเป็นเจ้าของ)
const userImageRef = storage.ref(`users/${currentUserId}/profile.jpg`);
await userImageRef.put(imageFile); // สำเร็จถ้าเป็นเจ้าของ
```

### 3. ทดสอบการลบ (Delete)
```javascript
// ทดสอบลบรูปสินค้า (ต้องเป็น Admin)
const productImageRef = storage.ref('products/product_123.jpg');
await productImageRef.delete(); // สำเร็จถ้าเป็น Admin
```

## 🚨 ข้อควรระวัง

### 1. ไฟล์ที่อนุญาต
- **ประเภทไฟล์**: JPG, JPEG, PNG, GIF, WebP เท่านั้น
- **ขนาดไฟล์**: ไม่เกิน 10MB
- **รูปแบบชื่อไฟล์**: ต้องมี extension ที่ถูกต้อง

### 2. สิทธิ์การเข้าถึง
- **รูปสินค้า/แบรนด์/หมวดหมู่**: อ่านได้ทุกคน, เขียนได้เฉพาะ Admin
- **รูปผู้ใช้**: อ่าน/เขียนได้เฉพาะเจ้าของและ Admin
- **Thumbnail**: อ่านได้ทุกคน, เขียนได้เฉพาะ Admin

### 3. Admin Email Whitelist
```javascript
function isAdmin(email) {
  return email in [
    'admin@stylepicked.com',
    'admin@gmail.com',
    'anucha.suks@gmail.com',
    'yatawikhadi@gmail.com'
    // เพิ่ม admin emails อื่นๆ ที่นี่
  ];
}
```

## 🔄 การอัปเดต Rules

### 1. เพิ่ม Admin Email ใหม่
```javascript
function isAdmin(email) {
  return email in [
    'admin@stylepicked.com',
    'admin@gmail.com',
    'anucha.suks@gmail.com',
    'yatawikhadi@gmail.com',
    'newadmin@example.com' // เพิ่มใหม่
  ];
}
```

### 2. เปลี่ยนขนาดไฟล์สูงสุด
```javascript
function isValidSize() {
  return resource.size < 20 * 1024 * 1024; // เปลี่ยนเป็น 20MB
}
```

### 3. เพิ่มประเภทไฟล์ใหม่
```javascript
function isValidFileName() {
  return resource.name.matches('.*\\.(jpg|jpeg|png|gif|webp|svg)'); // เพิ่ม SVG
}
```

## 📈 การตรวจสอบและ Monitoring

### 1. Firebase Console
- ไปที่ **Storage** > **Usage** เพื่อดูการใช้งาน
- ตรวจสอบ **Rules** > **Playground** เพื่อทดสอบ rules

### 2. Firebase Analytics
```javascript
// เพิ่ม custom events สำหรับ tracking
import { getAnalytics, logEvent } from 'firebase/analytics';

const analytics = getAnalytics();

// Track image upload
logEvent(analytics, 'image_upload', {
  folder: 'products',
  file_size: file.size,
  file_type: file.type
});

// Track image deletion
logEvent(analytics, 'image_delete', {
  folder: 'products',
  file_name: fileName
});
```

### 3. Error Handling
```dart
try {
  final ref = FirebaseStorage.instance.ref('products/image.jpg');
  await ref.putFile(imageFile);
} on FirebaseException catch (e) {
  switch (e.code) {
    case 'storage/unauthorized':
      print('ไม่มีสิทธิ์อัปโหลด');
      break;
    case 'storage/invalid-argument':
      print('ข้อมูลไม่ถูกต้อง');
      break;
    case 'storage/object-not-found':
      print('ไม่พบไฟล์');
      break;
    default:
      print('เกิดข้อผิดพลาด: ${e.message}');
  }
}
```

## 🛡️ ความปลอดภัย

### 1. การป้องกัน
- ตรวจสอบประเภทไฟล์ก่อนอัปโหลด
- จำกัดขนาดไฟล์
- ใช้ HTTPS สำหรับการเข้าถึง
- ตรวจสอบสิทธิ์ผู้ใช้

### 2. การลบไฟล์
- ลบไฟล์เก่าที่ไม่ได้ใช้
- ใช้ lifecycle rules สำหรับ auto-delete
- ตรวจสอบการใช้งานไฟล์

### 3. การสำรองข้อมูล
- ใช้ Firebase Storage backup
- เก็บ metadata ใน Firestore
- ใช้ versioning สำหรับไฟล์สำคัญ

## 📞 การแก้ไขปัญหา

### ปัญหาที่พบบ่อย

1. **Permission Denied**
   - ตรวจสอบว่าเป็น Admin หรือไม่
   - ตรวจสอบ email ใน whitelist
   - ตรวจสอบ authentication status

2. **Invalid File Type**
   - ตรวจสอบประเภทไฟล์
   - ตรวจสอบ extension
   - ใช้ image picker ที่รองรับ

3. **File Too Large**
   - ตรวจสอบขนาดไฟล์
   - บีบอัดรูปภาพก่อนอัปโหลด
   - ใช้ thumbnail สำหรับแสดงผล

4. **Network Error**
   - ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต
   - ใช้ retry mechanism
   - แสดง progress indicator

---

**สร้างโดย**: AI Assistant  
**วันที่**: $(date)  
**เวอร์ชัน**: 1.0.0






