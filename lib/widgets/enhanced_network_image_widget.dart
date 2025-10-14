import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

/// Enhanced Network Image Widget ที่จัดการ ProgressEvent errors
class EnhancedNetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const EnhancedNetworkImageWidget({
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
      return _buildNetworkImage();
    } else {
      return _buildAssetImage();
    }
  }

  Widget _buildNetworkImage() {
    return FutureBuilder<Uint8List?>(
      future: _loadImageBytes(),
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

  Future<Uint8List?> _loadImageBytes() async {
    try {
      // ตรวจสอบ URL format
      if (!_isValidUrl(imageUrl)) {
        throw Exception('Invalid URL format');
      }

      // ทำการ load image bytes
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'image/*,*/*;q=0.8',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('EnhancedNetworkImageWidget - Error loading image: $e');
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
      
      if (errorString.contains('ProgressEvent')) {
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

/// Enhanced Smart Image Widget ที่จัดการ ProgressEvent errors
class EnhancedSmartImageWidget extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const EnhancedSmartImageWidget({
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

    return EnhancedNetworkImageWidget(
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



