# 🔐 Firebase Security Rules สำหรับระบบ Admin

## 📋 Security Rules ที่แนะนำ

### 1. **Firestore Rules สำหรับระบบ Admin**

ไปที่ [Firebase Console](https://console.firebase.google.com/) → เลือกโปรเจค → Firestore Database → Rules

#### **Rules แบบปลอดภัย (แนะนำ)**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ===== PRODUCTS COLLECTION =====
    match /products/{productId} {
      // ทุกคนอ่านได้
      allow read: if true;
      
      // เฉพาะ Admin ที่เข้าสู่ระบบแล้วเท่านั้นที่เขียนได้
      allow write: if request.auth != null && 
        isAdmin(request.auth.token.email);
    }
    
    // ===== CATEGORIES COLLECTION =====
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if request.auth != null && 
        isAdmin(request.auth.token.email);
    }
    
    // ===== BRANDS COLLECTION =====
    match /brands/{brandId} {
      allow read: if true;
      allow write: if request.auth != null && 
        isAdmin(request.auth.token.email);
    }
    
    // ===== ADMINS COLLECTION =====
    match /admins/{adminId} {
      // เฉพาะ Admin ที่เข้าสู่ระบบแล้วเท่านั้น
      allow read, write: if request.auth != null && 
        request.auth.uid == adminId &&
        isAdmin(request.auth.token.email);
    }
    
    // ===== USERS COLLECTION =====
    match /users/{userId} {
      // เฉพาะเจ้าของข้อมูลเท่านั้น
      allow read, write: if request.auth != null && 
        request.auth.uid == userId;
      
      // Cart subcollection
      match /cart/{cartItemId} {
        allow read, write: if request.auth != null && 
          request.auth.uid == userId;
      }
      
      // Orders subcollection
      match /orders/{orderId} {
        allow read, write: if request.auth != null && 
          request.auth.uid == userId;
      }
    }
  }
  
  // ===== HELPER FUNCTIONS =====
  
  // ตรวจสอบว่าเป็น Admin email หรือไม่
  function isAdmin(email) {
    return email in [
      'admin@stylepicked.com',
      'admin@gmail.com', 
      'admin@example.com'
    ];
  }
}
```

#### **Rules แบบ Development/Testing (ไม่แนะนำสำหรับ Production)**
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

### 2. **Authentication Configuration**

#### **เปิดใช้งาน Authentication**
1. ไปที่ Firebase Console → Authentication → Sign-in method
2. เปิดใช้งาน **Email/Password**
3. เปิดใช้งาน **Google** (ถ้าต้องการ)

#### **ตั้งค่า Authorized Domains**
1. ไปที่ Authentication → Settings → Authorized domains
2. เพิ่ม domain ที่อนุญาต:
   - `localhost` (สำหรับ development)
   - Domain ของเว็บไซต์ (ถ้ามี)

### 3. **Admin Email Whitelist**

ในไฟล์ `lib/services/admin_auth_service.dart` กำหนด admin emails ที่อนุญาต:

```dart
static const List<String> _adminEmails = [
  'admin@stylepicked.com',
  'admin@gmail.com',
  'admin@example.com',
  // เพิ่ม admin emails อื่นๆ ที่นี่
];
```

### 4. **การทดสอบ Security Rules**

#### **ทดสอบการอ่านข้อมูล**
- ✅ ผู้ใช้ทั่วไปสามารถอ่านสินค้าได้
- ✅ ผู้ใช้ทั่วไปสามารถอ่านหมวดหมู่และแบรนด์ได้
- ❌ ผู้ใช้ทั่วไปไม่สามารถเขียนข้อมูลสินค้าได้

#### **ทดสอบการเขียนข้อมูล (Admin)**
- ✅ Admin ที่เข้าสู่ระบบแล้วสามารถเพิ่มสินค้าได้
- ✅ Admin ที่เข้าสู่ระบบแล้วสามารถแก้ไขสินค้าได้
- ✅ Admin ที่เข้าสู่ระบบแล้วสามารถลบสินค้าได้
- ❌ User ทั่วไปไม่สามารถเขียนข้อมูลสินค้าได้

### 5. **การจัดการ Admin Users**

#### **เพิ่ม Admin ใหม่**
1. เพิ่ม email ใน `_adminEmails` ใน `admin_auth_service.dart`
2. เพิ่ม email ใน Security Rules function `isAdmin()`
3. ให้ Admin สมัครสมาชิกด้วย email ที่อนุญาต

#### **ลบ Admin**
1. ลบ email จาก `_adminEmails`
2. ลบ email จาก Security Rules
3. ลบข้อมูลจาก Firestore collection `admins`

### 6. **Firebase Console Setup**

#### **สร้าง Collection ตัวอย่าง**
```javascript
// Collection: products
{
  "name": "สินค้าตัวอย่าง",
  "brand": "stylish",
  "category": "เสื้อผ้า", 
  "price": 299,
  "stock": 50,
  "image": "assets/images/example.jpg",
  "description": "รายละเอียดสินค้า",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}

// Collection: admins (จะสร้างอัตโนมัติเมื่อ Admin สมัครสมาชิก)
{
  "uid": "user_id",
  "email": "admin@example.com",
  "name": "ชื่อ Admin",
  "role": "admin",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "isActive": true,
  "lastLoginAt": "timestamp"
}
```

### 7. **การตรวจสอบและแก้ไขปัญหา**

#### **ตรวจสอบ Rules**
```bash
# ใช้ Firebase CLI
firebase deploy --only firestore:rules
```

#### **ตรวจสอบ Authentication**
- ไปที่ Firebase Console → Authentication → Users
- ตรวจสอบว่ามี Admin users ที่ถูกต้อง

#### **ตรวจสอบ Firestore**
- ไปที่ Firebase Console → Firestore Database
- ตรวจสอบ collections และ documents

### 8. **Security Best Practices**

#### **✅ ควรทำ**
- ใช้ authentication สำหรับการเขียนข้อมูล
- จำกัด admin emails ที่อนุญาต
- ตรวจสอบสิทธิ์ใน Security Rules
- ใช้ field validation
- บันทึก log การเข้าถึง

#### **❌ อย่าทำ**
- อย่าใช้ `allow read, write: if true` ใน production
- อย่าเก็บ admin credentials ใน code
- อย่าเปิดสิทธิ์กว้างเกินไป
- อย่าลืมอัปเดต rules เมื่อเปลี่ยน admin emails

### 9. **การ Monitor และ Logging**

#### **Firebase Console → Usage**
- ตรวจสอบการใช้งาน Firestore
- ตรวจสอบ Authentication usage

#### **Firebase Console → Functions (ถ้าใช้)**
- ตรวจสอบ Cloud Functions logs

### 10. **การ Backup และ Recovery**

#### **Firestore Backup**
- ไปที่ Firebase Console → Firestore → Backup
- ตั้งค่า automatic backup

#### **Admin Data Backup**
- Export collection `admins`
- เก็บ admin emails list แยกต่างหาก

---

## 🚀 **ขั้นตอนการตั้งค่า**

### **1. ตั้งค่า Security Rules**
1. คัดลอก Security Rules ด้านบน
2. ไปที่ Firebase Console → Firestore → Rules
3. แทนที่ rules เดิม
4. คลิก "Publish"

### **2. ตั้งค่า Authentication**
1. เปิดใช้งาน Email/Password authentication
2. เพิ่ม admin emails ที่อนุญาต

### **3. ทดสอบระบบ**
1. สมัครสมาชิกด้วย admin email
2. เข้าสู่ระบบ Admin
3. ทดสอบเพิ่ม/แก้ไข/ลบสินค้า

### **4. ตรวจสอบความปลอดภัย**
1. ทดสอบด้วย user ทั่วไป (ไม่ควรเข้าถึง Admin)
2. ตรวจสอบ logs ใน Firebase Console
3. ทดสอบการเข้าถึงข้อมูล

---

**หมายเหตุ**: Rules เหล่านี้เป็นตัวอย่างสำหรับการพัฒนา ควรปรับแต่งตามความต้องการของโปรเจคจริง

