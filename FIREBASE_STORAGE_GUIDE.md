# 📁 Firebase Storage Integration Guide

## 🎯 ภาพรวมระบบ

ระบบ Firebase Storage Integration ช่วยให้สามารถอัปโหลดและจัดการรูปภาพในแอปพลิเคชัน Style Picked ได้อย่างมีประสิทธิภาพ โดยรองรับการอัปโหลดรูปภาพสินค้า แบรนด์ หมวดหมู่ และผู้ใช้

## 🚀 ฟีเจอร์หลัก

### 📤 การอัปโหลดรูปภาพ
- **รูปภาพสินค้า**: อัปโหลดไปยังโฟลเดอร์ `products/`
- **โลโก้แบรนด์**: อัปโหลดไปยังโฟลเดอร์ `brands/`
- **รูปภาพหมวดหมู่**: อัปโหลดไปยังโฟลเดอร์ `categories/`
- **รูปภาพผู้ใช้**: อัปโหลดไปยังโฟลเดอร์ `users/`
- **Thumbnail**: สร้างรูปภาพขนาดย่อในโฟลเดอร์ `thumbnails/`

### 🔒 ความปลอดภัย
- ตรวจสอบสิทธิ์ผู้ใช้ (Admin/User)
- จำกัดประเภทไฟล์ (JPG, PNG, GIF, WebP)
- จำกัดขนาดไฟล์ (สูงสุด 10MB)
- Firebase Security Rules

### 🎨 UI/UX
- Image Picker ที่ใช้งานง่าย
- Progress Indicator ขณะอัปโหลด
- Error Handling ที่ชัดเจน
- Preview รูปภาพก่อนอัปโหลด

## 📱 การใช้งาน

### 1. ผ่าน Image Picker Page

#### เข้าถึง Image Picker:
```dart
// ในการเพิ่ม/แก้ไขสินค้า
final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ImagePickerPage(),
  ),
);
```

#### ฟีเจอร์ใน Image Picker:
- **เลือกรูปจากแกลเลอรี่**: เลือกรูปภาพจากอุปกรณ์
- **ถ่ายรูปด้วยกล้อง**: ถ่ายรูปใหม่ด้วยกล้อง
- **อัปโหลดไป Firebase Storage**: อัปโหลดรูปที่เลือกไปยัง Firebase
- **ใส่ URL รูปภาพ**: ใส่ URL ของรูปภาพจากแหล่งอื่น

### 2. ผ่าน Storage Service

#### อัปโหลดรูปภาพสินค้า:
```dart
import '../../services/storage_service.dart';

// อัปโหลดรูปภาพสินค้า
final downloadUrl = await StorageService.uploadProductImage(
  imageFile,
  productId: 'product_123', // optional
);
```

#### อัปโหลดโลโก้แบรนด์:
```dart
// อัปโหลดโลโก้แบรนด์
final downloadUrl = await StorageService.uploadBrandImage(
  imageFile,
  brandId: 'brand_456', // optional
);
```

#### อัปโหลดรูปภาพหมวดหมู่:
```dart
// อัปโหลดรูปภาพหมวดหมู่
final downloadUrl = await StorageService.uploadCategoryImage(
  imageFile,
  categoryId: 'cat_789', // optional
);
```

#### อัปโหลดรูปภาพผู้ใช้:
```dart
// อัปโหลดรูปภาพผู้ใช้
final downloadUrl = await StorageService.uploadUserImage(
  imageFile,
  userId: 'user_001', // optional
);
```

## 🔧 การจัดการไฟล์

### 1. ลบไฟล์
```dart
// ลบไฟล์เดียว
await StorageService.deleteImage(imageUrl);

// ลบไฟล์หลายไฟล์
await StorageService.deleteMultipleImages([
  'https://firebasestorage.googleapis.com/...',
  'https://firebasestorage.googleapis.com/...',
]);
```

### 2. ดึงข้อมูลไฟล์
```dart
// ดึงข้อมูลไฟล์
final metadata = await StorageService.getFileMetadata(imageUrl);
print('ขนาดไฟล์: ${StorageService.formatFileSize(metadata.size ?? 0)}');
print('ประเภทไฟล์: ${metadata.contentType}');
```

### 3. ดาวน์โหลดไฟล์
```dart
// ดาวน์โหลดไฟล์ไปยังอุปกรณ์
final file = await StorageService.downloadFile(
  imageUrl,
  '/path/to/local/file.jpg',
);
```

### 4. ตรวจสอบไฟล์
```dart
// ตรวจสอบประเภทไฟล์
bool isValid = StorageService.isAllowedImageType(filePath);
// รองรับ: .jpg, .jpeg, .png, .gif, .webp

// ตรวจสอบขนาดไฟล์
bool isValidSize = StorageService.isValidFileSize(file);
// จำกัดไม่เกิน 10MB
```

## 🎨 UI Components

### 1. Image Picker Button
```dart
ElevatedButton.icon(
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePickerPage(
          initialImage: currentImageUrl,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        imageUrl = result;
      });
    }
  },
  icon: const Icon(Icons.add_photo_alternate),
  label: const Text('เลือกรูปภาพ'),
),
```

### 2. Image Preview
```dart
Widget buildImagePreview(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.image, size: 64, color: Colors.grey),
      ),
    );
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: imageUrl.startsWith('http')
        ? Image.network(
            imageUrl,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 200,
              color: Colors.red[100],
              child: const Center(
                child: Text('ไม่สามารถโหลดรูปภาพได้'),
              ),
            ),
          )
        : Image.asset(
            imageUrl,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 200,
              color: Colors.red[100],
              child: const Center(
                child: Text('ไม่พบไฟล์รูปภาพ'),
              ),
            ),
          ),
  );
}
```

### 3. Upload Progress
```dart
bool _isUploading = false;

Widget buildUploadButton() {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: _isUploading ? null : _uploadImage,
      icon: _isUploading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.cloud_upload),
      label: Text(_isUploading ? 'กำลังอัปโหลด...' : 'อัปโหลดรูปภาพ'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
    ),
  );
}
```

## 🔒 Security & Permissions

### 1. Firebase Security Rules
```javascript
// ตัวอย่าง Security Rules
match /products/{productId} {
  allow read: if true; // ทุกคนอ่านได้
  allow write: if isAuthenticated() 
                 && isAdmin(request.auth.token.email)
                 && isImage()
                 && isValidSize();
}
```

### 2. Admin Email Whitelist
```dart
// ในไฟล์ admin_auth_service.dart
static const List<String> _adminEmails = [
  'admin@gmail.com',
  'anucha.suks@gmail.com',
  'yatawikhadi@gmail.com',
];
```

### 3. File Validation
```dart
// ตรวจสอบก่อนอัปโหลด
if (!StorageService.isAllowedImageType(file.path)) {
  throw Exception('ประเภทไฟล์ไม่รองรับ');
}

if (!StorageService.isValidFileSize(file)) {
  throw Exception('ขนาดไฟล์ใหญ่เกินไป');
}
```

## 📊 การจัดการข้อมูล

### 1. โครงสร้างโฟลเดอร์
```
gs://your-project.appspot.com/
├── products/
│   ├── product_123_1640995200000.jpg
│   └── product_456_1640995300000.png
├── brands/
│   ├── brand_789_1640995400000.jpg
│   └── brand_012_1640995500000.png
├── categories/
│   ├── cat_345_1640995600000.jpg
│   └── cat_678_1640995700000.png
├── users/
│   ├── user_901_1640995800000.jpg
│   └── user_234_1640995900000.png
└── thumbnails/
    ├── thumb_product_123_1640996000000.jpg
    └── thumb_brand_789_1640996100000.jpg
```

### 2. การตั้งชื่อไฟล์
```dart
// รูปแบบ: {type}_{id}_{timestamp}.{extension}
// ตัวอย่าง: product_123_1640995200000.jpg
final fileName = '${type}_${id}_${DateTime.now().millisecondsSinceEpoch}.${extension}';
```

### 3. Metadata
```dart
// ข้อมูลที่เก็บในไฟล์
SettableMetadata(
  contentType: 'image/jpeg',
  customMetadata: {
    'uploadedAt': DateTime.now().toIso8601String(),
    'originalName': 'my_image.jpg',
    'uploadedBy': currentUserId,
    'category': 'product',
  },
)
```

## 🚨 Error Handling

### 1. การจัดการ Error
```dart
try {
  final downloadUrl = await StorageService.uploadProductImage(imageFile);
  // สำเร็จ
} on FirebaseException catch (e) {
  switch (e.code) {
    case 'storage/unauthorized':
      showError('ไม่มีสิทธิ์อัปโหลด');
      break;
    case 'storage/invalid-argument':
      showError('ข้อมูลไม่ถูกต้อง');
      break;
    case 'storage/object-not-found':
      showError('ไม่พบไฟล์');
      break;
    default:
      showError('เกิดข้อผิดพลาด: ${e.message}');
  }
} catch (e) {
  showError('เกิดข้อผิดพลาดที่ไม่คาดคิด: $e');
}
```

### 2. การแสดง Error
```dart
void showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    ),
  );
}
```

## 📈 Performance Optimization

### 1. การบีบอัดรูปภาพ
```dart
// ใน Image Picker
final XFile? image = await _picker.pickImage(
  source: source,
  maxWidth: 1024,
  maxHeight: 1024,
  imageQuality: 85, // บีบอัดเป็น 85%
);
```

### 2. การสร้าง Thumbnail
```dart
// สร้าง thumbnail สำหรับแสดงผล
final thumbnailUrl = await StorageService.uploadThumbnail(
  imageFile: thumbnailFile,
  originalUrl: originalUrl,
  quality: 50, // คุณภาพ 50%
);
```

### 3. การ Cache รูปภาพ
```dart
// ใช้ cached_network_image สำหรับ cache
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

## 🔄 การย้ายข้อมูล

### 1. ย้ายรูปภาพจาก Local Assets
```dart
// อัปโหลดรูปภาพจาก assets
final assetImage = await rootBundle.load('assets/images/product.jpg');
final tempFile = File('${Directory.systemTemp.path}/temp_image.jpg');
await tempFile.writeAsBytes(assetImage.buffer.asUint8List());

final downloadUrl = await StorageService.uploadProductImage(tempFile);
```

### 2. ย้ายรูปภาพจาก URL
```dart
// ดาวน์โหลดและอัปโหลดรูปภาพจาก URL
final response = await http.get(Uri.parse(imageUrl));
final tempFile = File('${Directory.systemTemp.path}/downloaded_image.jpg');
await tempFile.writeAsBytes(response.bodyBytes);

final downloadUrl = await StorageService.uploadProductImage(tempFile);
```

## 📞 การแก้ไขปัญหา

### ปัญหาที่พบบ่อย

1. **อัปโหลดไม่สำเร็จ**
   - ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต
   - ตรวจสอบสิทธิ์ผู้ใช้
   - ตรวจสอบขนาดและประเภทไฟล์

2. **รูปภาพไม่แสดง**
   - ตรวจสอบ URL
   - ตรวจสอบ Firebase Security Rules
   - ตรวจสอบการเชื่อมต่อ

3. **อัปโหลดช้า**
   - บีบอัดรูปภาพก่อนอัปโหลด
   - ใช้ thumbnail สำหรับแสดงผล
   - ตรวจสอบขนาดไฟล์

4. **Error Permission Denied**
   - ตรวจสอบว่าเป็น Admin หรือไม่
   - ตรวจสอบ email ใน whitelist
   - ตรวจสอบ Firebase Security Rules

---

**สร้างโดย**: AI Assistant  
**วันที่**: $(date)  
**เวอร์ชัน**: 1.0.0






