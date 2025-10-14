# 🔒 Firebase Security Rules - Style Picked App

## ❌ ปัญหาที่เจอ
```
FirebaseError: [code=permission-denied]: Missing or insufficient permissions.
```

## 🔧 วิธีแก้ไข

### 1. ตั้งค่า Firestore Security Rules

ไปที่ [Firebase Console](https://console.firebase.google.com/) → เลือกโปรเจค → Firestore Database → Rules

### 2. ใช้ Security Rules นี้

#### **สำหรับ Development/Testing (อนุญาตทุกอย่าง)**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // อนุญาตให้อ่านและเขียนได้ทุกคน (สำหรับทดสอบเท่านั้น)
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

#### **สำหรับ Production (ปลอดภัย)**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Products Collection - อนุญาตให้อ่านได้ทุกคน, เขียนต้องเข้าสู่ระบบ
    match /products/{productId} {
      allow read: if true;  // ทุกคนอ่านได้
      allow write: if request.auth != null;  // ต้องเข้าสู่ระบบ
    }
    
    // Categories Collection
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Brands Collection  
    match /brands/{brandId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Users Collection - เฉพาะเจ้าของข้อมูล
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Cart subcollection
      match /cart/{cartItemId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Orders subcollection
      match /orders/{orderId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### 3. ตั้งค่า Authentication (ถ้ายังไม่ได้ทำ)

#### เปิดใช้งาน Authentication
1. ไปที่ Firebase Console → Authentication → Sign-in method
2. เปิดใช้งาน **Email/Password**
3. เปิดใช้งาน **Google** (ถ้าต้องการ)

#### ตั้งค่า Authentication Rules (ถ้าใช้)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // อนุญาตให้อ่านสินค้าได้ทุกคน
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // ต้องเข้าสู่ระบบเท่านั้น
    match /admin/{document} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 🚀 วิธีตั้งค่าแบบทีละขั้นตอน

### ขั้นตอนที่ 1: ตั้งค่า Rules พื้นฐาน
1. เปิด [Firebase Console](https://console.firebase.google.com/)
2. เลือกโปรเจคของคุณ
3. ไปที่ **Firestore Database** → **Rules**
4. แทนที่ rules เดิมด้วย:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

5. คลิก **Publish**

### ขั้นตอนที่ 2: ทดสอบการทำงาน
1. รันแอป
2. ลองใช้ Admin UI เพิ่มสินค้า
3. ถ้าทำงานได้ แสดงว่า rules ถูกต้อง

### ขั้นตอนที่ 3: ปรับ Security (ถ้าต้องการ)
เปลี่ยนเป็น rules ที่ปลอดภัยกว่า:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## 🔍 การตรวจสอบปัญหา

### 1. ตรวจสอบ Firebase Project
- ✅ โปรเจค Firebase ถูกต้อง
- ✅ Firestore Database เปิดใช้งานแล้ว
- ✅ App ได้เชื่อมต่อ Firebase แล้ว

### 2. ตรวจสอบ Rules
- ✅ Rules ได้ publish แล้ว
- ✅ ไม่มี syntax error
- ✅ มีสิทธิ์ read/write ที่เหมาะสม

### 3. ตรวจสอบ Authentication
- ✅ Authentication เปิดใช้งาน
- ✅ User เข้าสู่ระบบแล้ว (ถ้า rules ต้องการ)

## 🛠️ การแก้ไขเพิ่มเติม

### ถ้ายังมีปัญหา ให้ลอง:

#### 1. ลบและสร้าง Collection ใหม่
```javascript
// ลบ collection products ทั้งหมด
// แล้วสร้างใหม่ด้วย rules ใหม่
```

#### 2. ตรวจสอบ Firebase Configuration
```dart
// ใน firebase_options.dart
// ตรวจสอบว่า configuration ถูกต้อง
```

#### 3. ใช้ Firebase CLI
```bash
# ติดตั้ง Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# ตั้งค่า rules
firebase deploy --only firestore:rules
```

## 📝 หมายเหตุ

### ⚠️ ข้อควรระวัง
- **อย่าใช้ `allow read, write: if true` ใน production**
- **ใช้ authentication ใน production**
- **ทดสอบ rules อย่างละเอียด**

### 🔐 Security Best Practices
1. **ใช้ authentication** สำหรับการเขียนข้อมูล
2. **จำกัดการเข้าถึง** ตาม role ของ user
3. **ตรวจสอบข้อมูล** ก่อนบันทึก
4. **ใช้ field validation** ใน rules

### 🎯 สำหรับ Admin UI
```javascript
// Rules เฉพาะสำหรับ Admin
match /products/{productId} {
  allow read: if true;  // ทุกคนอ่านได้
  allow write: if request.auth != null && 
    request.auth.token.admin == true;  // เฉพาะ Admin
}
```

## 📞 การขอความช่วยเหลือ

ถ้ายังมีปัญหา:
1. ตรวจสอบ Firebase Console → Rules → ไม่มี error
2. ตรวจสอบ Firebase Console → Usage → มีการใช้งาน
3. ตรวจสอบ Log ใน Firebase Console
4. ลองใช้ Firebase Emulator สำหรับทดสอบ

---

**หมายเหตุ**: กฎเหล่านี้เป็นตัวอย่างสำหรับการพัฒนา ควรปรับแต่งตามความต้องการของโปรเจคจริง

