import 'package:flutter/material.dart';

/// Simple Network Image Widget ที่ใช้ Image.network แต่มี error handling ดีกว่า
class SimpleNetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const SimpleNetworkImageWidget({
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
    Widget imageWidget;

    if (imageUrl.startsWith('http')) {
      // Network image
      imageWidget = Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? _buildLoadingPlaceholder(loadingProgress);
        },
        errorBuilder: (context, error, stackTrace) => 
          errorWidget ?? _buildErrorWidget(error),
      );
    } else {
      // Asset image
      imageWidget = Image.asset(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => 
          errorWidget ?? _buildErrorWidget(error),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildLoadingPlaceholder(ImageChunkEvent loadingProgress) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.grey),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'กำลังโหลด...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            if (loadingProgress.expectedTotalBytes != null) ...[
              const SizedBox(height: 4),
              Text(
                '${(loadingProgress.cumulativeBytesLoaded / 1024 / 1024).toStringAsFixed(1)} MB / ${(loadingProgress.expectedTotalBytes! / 1024 / 1024).toStringAsFixed(1)} MB',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(dynamic error) {
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
            const Text(
              'ไม่สามารถโหลดรูปภาพได้',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
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
            if (error != null) ...[
              const SizedBox(height: 4),
              Text(
                'Error: ${error.toString().length > 50 ? '${error.toString().substring(0, 50)}...' : error.toString()}',
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
}

/// Widget สำหรับแสดงรูปภาพที่รองรับทั้ง network และ asset (Simple version)
class SimpleSmartImageWidget extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const SimpleSmartImageWidget({
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

    return SimpleNetworkImageWidget(
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