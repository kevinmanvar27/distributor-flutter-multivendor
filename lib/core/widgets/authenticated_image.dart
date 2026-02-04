// Authenticated Image Widget
// 
// Custom image widget that loads images from network
// Works with production URLs without authentication for public images

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthenticatedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double? width;
  final double? height;

  const AuthenticatedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Skip if URL is empty
    if (imageUrl.isEmpty) {
      if (kDebugMode) {
        debugPrint('AuthenticatedImage: Empty URL provided');
      }
      return errorWidget ?? _buildDefaultError();
    }

    // Debug log in development
    if (kDebugMode) {
      debugPrint('AuthenticatedImage loading: $imageUrl');
    }

    return Image.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return placeholder ?? _buildDefaultPlaceholder(loadingProgress);
      },
      errorBuilder: (context, error, stackTrace) {
        if (kDebugMode) {
          debugPrint('AuthenticatedImage error for $imageUrl: $error');
        }
        return errorWidget ?? _buildDefaultError();
      },
    );
  }

  Widget _buildDefaultPlaceholder([ImageChunkEvent? loadingProgress]) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[100],
      child: Center(
        child: loadingProgress != null
            ? CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              )
            : const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[100],
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 32,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}

/// Cached version using CachedNetworkImage for better performance
/// Use this when you need caching
class CachedAuthenticatedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double? width;
  final double? height;

  const CachedAuthenticatedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // For now, use the simple Image.network version
    return AuthenticatedImage(
      imageUrl: imageUrl,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      width: width,
      height: height,
    );
  }
}
