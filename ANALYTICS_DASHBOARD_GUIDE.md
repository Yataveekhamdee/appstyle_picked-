# 📊 Analytics Dashboard Guide

## 🎯 ภาพรวมระบบ Analytics

ระบบ Analytics Dashboard เป็นเครื่องมือสำหรับ Admin ในการติดตามและวิเคราะห์ข้อมูลการขายของแอปพลิเคชัน โดยแสดงสถิติการขาย รายงาน และข้อมูลเชิงลึกต่างๆ

## 🚀 ฟีเจอร์หลัก

### 📈 สถิติหลัก (Main Statistics)
- **รายได้รวม**: ยอดขายทั้งหมดในช่วงเวลาที่เลือก
- **คำสั่งซื้อ**: จำนวนคำสั่งซื้อทั้งหมด
- **สินค้า**: จำนวนสินค้าทั้งหมดในระบบ
- **ลูกค้า**: จำนวนลูกค้าทั้งหมด

### 📊 สถิติหมวดหมู่ (Category Analytics)
- รายได้แยกตามหมวดหมู่สินค้า
- จำนวนคำสั่งซื้อต่อหมวดหมู่
- เปอร์เซ็นต์การขายของแต่ละหมวดหมู่
- เรียงลำดับตามยอดขาย

### 🏷️ สถิติแบรนด์ (Brand Analytics)
- รายได้แยกตามแบรนด์
- จำนวนคำสั่งซื้อต่อแบรนด์
- เปอร์เซ็นต์การขายของแต่ละแบรนด์
- เรียงลำดับตามยอดขาย

### 📅 สถิติรายเดือน (Monthly Analytics)
- รายได้แยกตามเดือน
- จำนวนคำสั่งซื้อต่อเดือน
- จำนวนสินค้าที่ขายต่อเดือน
- แสดงข้อมูล 6 เดือนล่าสุด

## 🎛️ การใช้งาน

### 1. เข้าถึง Analytics Dashboard
```
/admin/analytics
```

### 2. เลือกช่วงเวลา
- แตะที่ "วันที่เริ่มต้น" เพื่อเลือกวันที่เริ่มต้น
- แตะที่ "วันที่สิ้นสุด" เพื่อเลือกวันที่สิ้นสุด
- แตะ "อัปเดตข้อมูล" เพื่อรีเฟรชข้อมูล

### 3. ดูสถิติต่างๆ
- **สถิติหลัก**: แสดงในรูปแบบ Card แยกตามประเภท
- **สถิติหมวดหมู่**: แสดงรายการหมวดหมู่พร้อมยอดขาย
- **สถิติแบรนด์**: แสดงรายการแบรนด์พร้อมยอดขาย
- **สถิติรายเดือน**: แสดงข้อมูลแยกตามเดือน

## 🔧 เมนูการจัดการ

### Navigation Menu
- **Analytics**: หน้าปัจจุบัน
- **Dashboard หลัก**: กลับไปหน้า Admin Dashboard
- **จัดการสินค้า**: ไปหน้าจัดการสินค้า
- **จัดการหมวดหมู่**: ไปหน้าจัดการหมวดหมู่
- **จัดการแบรนด์**: ไปหน้าจัดการแบรนด์
- **ออกจากระบบ**: ออกจากระบบ Admin

### Popup Menu (ใน AppBar)
- **Analytics Dashboard**: ไปหน้า Analytics
- **จัดการสินค้า**: ไปหน้าจัดการสินค้า
- **จัดการหมวดหมู่**: ไปหน้าจัดการหมวดหมู่
- **จัดการแบรนด์**: ไปหน้าจัดการแบรนด์
- **โปรไฟล์**: ดูข้อมูล Admin
- **ออกจากระบบ**: ออกจากระบบ Admin

## 📁 ไฟล์ที่เกี่ยวข้อง

### Models
- `lib/models/analytics_model.dart`: ข้อมูล Analytics และ Order

### Services
- `lib/services/analytics_service.dart`: บริการคำนวณและดึงข้อมูล Analytics

### Pages
- `lib/pages/admin/admin_analytics_dashboard.dart`: หน้า Analytics Dashboard
- `lib/pages/admin/product_management_page.dart`: หน้าจัดการสินค้า

### Routes
```dart
'/admin/analytics': AdminAnalyticsDashboard
'/admin/products': ProductManagementPage
```

## 🔐 การเข้าถึง

### เงื่อนไขการเข้าถึง
- ต้องเข้าสู่ระบบเป็น Admin
- อีเมลต้องอยู่ใน whitelist ของ Admin
- ต้องมีสิทธิ์ในการเข้าถึง Firebase

### Admin Emails ที่อนุญาต
```dart
'admin@gmail.com'
'anucha.suks@gmail.com'
'yatawikhadi@gmail.com'
```

## 📊 ข้อมูลที่แสดง

### สถิติหมวดหมู่
```
หมวดหมู่ | รายได้ | เปอร์เซ็นต์
เสื้อผ้า  | ฿50,000 | 45.2%
รองเท้า   | ฿30,000 | 27.1%
กระเป๋า   | ฿25,000 | 22.6%
```

### สถิติแบรนด์
```
แบรนด์    | รายได้ | เปอร์เซ็นต์
Stylish  | ฿60,000 | 54.1%
Duex     | ฿25,000 | 22.6%
Feelfree | ฿20,000 | 18.0%
```

### สถิติรายเดือน
```
เดือน     | รายได้ | คำสั่งซื้อ
ม.ค. 2024 | ฿45,000 | 25 รายการ
ก.พ. 2024 | ฿52,000 | 30 รายการ
มี.ค. 2024 | ฿48,000 | 28 รายการ
```

## 🔄 การอัปเดตข้อมูล

### อัตโนมัติ
- ข้อมูลจะอัปเดตเมื่อมีการเปลี่ยนแปลงใน Firebase
- Real-time updates ผ่าน Firestore listeners

### Manual
- แตะปุ่ม "อัปเดตข้อมูล" ในส่วนฟิลเตอร์วันที่
- แตะไอคอน refresh ใน AppBar
- Pull-to-refresh (ถ้ามีการ implement)

## 🚨 การจัดการข้อผิดพลาด

### กรณีไม่มีข้อมูล
- แสดงข้อความ "ไม่มีข้อมูล"
- แสดงข้อความ "ไม่พบข้อมูล Analytics"

### กรณีเกิดข้อผิดพลาด
- แสดงข้อความ error
- แสดงปุ่ม "ลองใหม่"
- Log error ใน console

## 📱 Responsive Design

### Mobile
- Grid 2 คอลัมน์สำหรับสถิติหลัก
- List view สำหรับรายการต่างๆ
- Touch-friendly buttons

### Tablet
- Grid 3-4 คอลัมน์สำหรับสถิติหลัก
- Larger cards และ text
- Better spacing

## 🎨 UI/UX Features

### Loading States
- CircularProgressIndicator ขณะโหลดข้อมูล
- Skeleton loading (ถ้ามีการ implement)

### Error States
- Error icons และ messages
- Retry buttons
- User-friendly error messages

### Success States
- Smooth animations
- Clear visual feedback
- Intuitive navigation

## 🔧 การปรับแต่ง

### เพิ่มฟิลเตอร์ใหม่
```dart
// ใน AnalyticsService
static Future<SalesAnalytics> getSalesAnalytics({
  DateTime? startDate,
  DateTime? endDate,
  String? category, // เพิ่มฟิลเตอร์หมวดหมู่
  String? brand,    // เพิ่มฟิลเตอร์แบรนด์
}) async {
  // Implementation
}
```

### เพิ่มสถิติใหม่
```dart
// ใน analytics_model.dart
class SalesAnalytics {
  final double totalRevenue;
  final int totalOrders;
  final double conversionRate; // เพิ่มสถิติใหม่
  // ... other fields
}
```

## 📈 การวิเคราะห์ข้อมูล

### การตีความข้อมูล
- **รายได้สูง**: หมวดหมู่/แบรนด์ที่ขายดี
- **เปอร์เซ็นต์ต่ำ**: โอกาสในการขยายตลาด
- **แนวโน้มรายเดือน**: การเติบโตหรือลดลง

### การตัดสินใจทางธุรกิจ
- เพิ่มสินค้าในหมวดหมู่ที่ขายดี
- ปรับปรุงหมวดหมู่ที่ขายไม่ดี
- วางแผนการตลาดตามแนวโน้ม

## 🔒 ความปลอดภัย

### การเข้าถึงข้อมูล
- เฉพาะ Admin ที่ได้รับอนุญาต
- ตรวจสอบสิทธิ์ผ่าน Firebase Auth
- Whitelist email addresses

### การป้องกันข้อมูล
- ไม่แสดงข้อมูลส่วนบุคคล
- กรองข้อมูลที่ละเอียดอ่อน
- ใช้ HTTPS สำหรับการเชื่อมต่อ

---

## 📞 การสนับสนุน

หากมีปัญหาหรือข้อสงสัยเกี่ยวกับระบบ Analytics Dashboard:

1. ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต
2. ตรวจสอบสิทธิ์การเข้าถึง Firebase
3. ตรวจสอบ email whitelist
4. ดู logs ใน Firebase Console

---

**สร้างโดย**: AI Assistant  
**วันที่**: $(date)  
**เวอร์ชัน**: 1.0.0






