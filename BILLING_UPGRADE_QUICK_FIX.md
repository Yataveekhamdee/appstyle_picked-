# 🚀 Firebase Billing Upgrade - Quick Fix

## 🚨 ปัญหาที่พบ

```
Storage: To use Storage, upgrade your project's billing plan
```

## ✅ วิธีแก้ไขด่วน (5 นาที)

### ขั้นตอนที่ 1: อัปเกรดเป็น Blaze Plan

1. **ไปที่ Firebase Console**
   - เปิด [https://console.firebase.google.com/](https://console.firebase.google.com/)
   - เลือกโปรเจค **appstyle-picked**

2. **ไปที่ Billing Settings**
   - คลิก **Settings** (⚙️) > **Usage and billing**
   - คลิก **"Upgrade to Blaze"**

3. **ตั้งค่า Billing Account**
   - สร้าง billing account ใหม่ (ถ้ายังไม่มี)
   - เพิ่มบัตรเครดิต
   - เลือก **Country**: Thailand

4. **ยืนยันการอัปเกรด**
   - คลิก **"Purchase"** หรือ **"Upgrade"**
   - รอการยืนยัน (1-2 นาที)

### ขั้นตอนที่ 2: เปิดใช้งาน Firebase Storage

1. **ไปที่ Storage**
   - คลิก **Storage** ในเมนูด้านซ้าย
   - คลิก **"Get started"**

2. **ตั้งค่า Storage**
   - เลือก **"Start in test mode"**
   - เลือก **Cloud Storage location**: asia-southeast1 (Singapore)
   - คลิก **"Done"**

3. **ตั้งค่า Storage Rules**
   - คลิก **Rules** tab
   - แทนที่ด้วย rules นี้:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Function to check if user is admin
    function isAdmin(email) {
      return email in [
        'admin@gmail.com',
        'anucha.suks@gmail.com',
        'yatawikhadi@gmail.com'
      ];
    }

    // Products images
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null 
                     && isAdmin(request.auth.token.email);
    }

    // Brand logos
    match /brands/{brandId} {
      allow read: if true;
      allow write: if request.auth != null 
                     && isAdmin(request.auth.token.email);
    }

    // Category images
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if request.auth != null 
                     && isAdmin(request.auth.token.email);
    }

    // User images
    match /users/{userId} {
      allow read: if request.auth != null && (
        request.auth.uid == userId || 
        isAdmin(request.auth.token.email)
      );
      allow write: if request.auth != null 
                     && request.auth.uid == userId;
    }

    // Default rule
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

4. **Publish Rules**
   - คลิก **"Publish"**

### ขั้นตอนที่ 3: ทดสอบการอัปโหลด

1. **รันแอป**
   ```cmd
   flutter run -d chrome
   ```

2. **ทดสอบการอัปโหลด**
   - ไปที่หน้า Admin Management
   - ลองอัปโหลดรูปภาพ
   - ตรวจสอบ console

## 💰 ข้อมูลต้นทุน

### Free Tier (ยังคงมี)
- **Storage**: 5GB
- **Download**: 1GB/วัน
- **Upload**: 1GB/วัน

### ราคา (เมื่อใช้เกิน Free Tier)
- **Storage**: $0.026/GB/เดือน
- **Download**: $0.12/GB
- **Upload**: $0.05/GB

### ตัวอย่างต้นทุนสำหรับแอปเล็ก
- **รวม**: ~$0.09/เดือน (ประมาณ 3 บาท)

## 🔧 ตั้งค่า Budget Alert (แนะนำ)

1. **ไปที่ Billing**
   - คลิก **Settings** > **Usage and billing**
   - คลิก **"Manage billing account"**

2. **ตั้งค่า Budget**
   - ไปที่ **Budgets & alerts**
   - คลิก **"Create budget"**
   - ตั้งค่า: $5 USD/เดือน
   - ตั้งค่า Alert: 80%, 90%, 100%

## 📋 ขั้นตอนสรุป

1. ✅ อัปเกรดเป็น Blaze Plan
2. ✅ เปิดใช้งาน Firebase Storage
3. ✅ ตั้งค่า Storage Rules
4. ✅ ทดสอบการอัปโหลด

---

**ใช้เวลาประมาณ 5 นาที** 🚀





