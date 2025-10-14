import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:typed_data';

/// Fallback Image Widget สำหรับกรณีที่ CORS มีปัญหา
class FallbackImageWidget extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const FallbackImageWidget({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildEmptyWidget();
    }

    if (imageUrl.startsWith('http')) {
      if (kIsWeb) {
        return _buildWebImage();
      } else {
        return _buildMobileImage();
      }
    } else {
      return _buildAssetImage();
    }
  }

  Widget _buildWebImage() {
    return FutureBuilder<Uint8List?>(
      future: _loadImageBytesWeb(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder ?? _buildLoadingPlaceholder();
        }

        if (snapshot.hasError) {
          return errorWidget ?? _buildErrorWidget(snapshot.error);
        }

        if (snapshot.hasData && snapshot.data != null) {
          Widget imageWidget = Image.memory(
            snapshot.data!,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) => 
              errorWidget ?? _buildErrorWidget(error),
          );

          if (borderRadius != null) {
            return ClipRRect(
              borderRadius: borderRadius!,
              child: imageWidget,
            );
          }

          return imageWidget;
        }

        return errorWidget ?? _buildErrorWidget('No image data received');
      },
    );
  }

  Widget _buildMobileImage() {
    return Image.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildLoadingPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) => 
        errorWidget ?? _buildErrorWidget(error),
    );
  }

  Widget _buildAssetImage() {
    Widget imageWidget = Image.asset(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) => 
        errorWidget ?? _buildErrorWidget(error),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Future<Uint8List?> _loadImageBytesWeb() async {
    try {
      // ตรวจสอบ URL format
      if (!_isValidUrl(imageUrl)) {
        throw Exception('Invalid URL format');
      }

      // ใช้ HTML5 fetch API สำหรับ web
      final response = await html.window.fetch(imageUrl);

      // ตรวจสอบ response status (HTML fetch response ไม่มี .ok property)
      if (response.status != 200) {
        throw Exception('HTTP ${response.status}: ${response.statusText}');
      }

      final blob = await response.blob();
      final bytes = await blob.arrayBuffer();
      
      return Uint8List.fromList(bytes);
    } catch (e) {
      print('FallbackImageWidget - Error loading image: $e');
      rethrow;
    }
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'กำลังโหลด...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(dynamic error) {
    String errorMessage = 'ไม่สามารถโหลดรูปภาพได้';
    String errorDetail = '';

    if (error != null) {
      final errorString = error.toString();
      
      if (errorString.contains('XMLHttpRequest')) {
        errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ';
        errorDetail = 'CORS or Network error';
      } else if (errorString.contains('ProgressEvent')) {
        errorMessage = 'เกิดข้อผิดพลาดในการโหลดรูปภาพ';
        errorDetail = 'Network connection error';
      } else if (errorString.contains('404')) {
        errorMessage = 'ไม่พบรูปภาพ';
        errorDetail = 'Image not found';
      } else if (errorString.contains('403')) {
        errorMessage = 'ไม่มีสิทธิ์เข้าถึงรูปภาพ';
        errorDetail = 'Access denied';
      } else if (errorString.contains('timeout')) {
        errorMessage = 'การโหลดใช้เวลานานเกินไป';
        errorDetail = 'Request timeout';
      } else {
        errorDetail = errorString.length > 50 
            ? '${errorString.substring(0, 50)}...' 
            : errorString;
      }
    }

    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[300],
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'URL: ${imageUrl.length > 30 ? '${imageUrl.substring(0, 30)}...' : imageUrl}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (errorDetail.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Error: $errorDetail',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                // Retry loading - rebuild widget
                // Note: This will trigger a rebuild when the widget is used
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('ลองใหม่'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                textStyle: const TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'ไม่มีรูปภาพ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fallback Smart Image Widget
class FallbackSmartImageWidget extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const FallbackSmartImageWidget({
    super.key,
    this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildEmptyWidget();
    }

    return FallbackImageWidget(
      imageUrl: imageUrl!,
      fit: fit,
      width: width,
      height: height,
      placeholder: placeholder,
      errorWidget: errorWidget,
      borderRadius: borderRadius,
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'ไม่มีรูปภาพ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
