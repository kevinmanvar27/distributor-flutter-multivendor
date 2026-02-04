// Image URL Utilities
//
// Centralized helper for building full image URLs from API paths.
// All product/category images must use this to ensure correct URL format.

import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

/// Production storage base URL
/// https://hardware.rektech.work/storage
String get _storageBaseUrl {
  // Extract base URL without /api/v1
  String baseUrl = ApiService.baseUrl;
  // Remove /api/v1 suffix to get root URL
  if (baseUrl.endsWith('/api/v1')) {
    baseUrl = baseUrl.substring(0, baseUrl.length - 7);
  } else if (baseUrl.endsWith('/api')) {
    baseUrl = baseUrl.substring(0, baseUrl.length - 4);
  }
  return '$baseUrl/storage';
}

/// Build full image URL from API path
/// 
/// API returns paths like:
/// - "products/abc.jpg" (relative)
/// - "/products/abc.jpg" (relative with leading slash)
/// - "vendor/1/products/abc.jpg" (relative)
/// - "https://hardware.rektech.work/storage/vendor/1/image.png" (full URL from API)
/// 
/// This function transforms them to use the correct base URL:
/// - "https://hardware.rektech.work/storage/products/abc.jpg"
/// 
/// Returns null if path is null or empty.
String? buildImageUrl(String? path) {
  if (path == null || path.isEmpty) {
    if (kDebugMode) {
      debugPrint('buildImageUrl: Path is null or empty');
    }
    return null;
  }
  
  String cleanPath = path;
  
  // If it's already a full URL with https, check if it's valid
  if (cleanPath.startsWith('https://')) {
    if (kDebugMode) {
      debugPrint('buildImageUrl: Already HTTPS URL: $cleanPath');
    }
    return cleanPath;
  }
  
  // If it's a full URL from localhost (http://), extract the path
  if (cleanPath.startsWith('http://')) {
    if (kDebugMode) {
      debugPrint('buildImageUrl: Converting HTTP URL: $cleanPath');
    }
    // Find /storage/ in the URL and extract everything after it
    final storageIndex = cleanPath.indexOf('/storage/');
    if (storageIndex != -1) {
      // Extract path after /storage/
      cleanPath = cleanPath.substring(storageIndex + 9); // +9 for '/storage/'
    } else {
      // No /storage/ found, try to extract path from URL
      try {
        final uri = Uri.parse(cleanPath);
        cleanPath = uri.path;
        if (cleanPath.startsWith('/')) {
          cleanPath = cleanPath.substring(1);
        }
      } catch (_) {
        // If parsing fails, return original URL
        return path;
      }
    }
  }
  
  // Remove leading slash if present
  if (cleanPath.startsWith('/')) {
    cleanPath = cleanPath.substring(1);
  }
  
  // Remove 'storage/' prefix if present (API sometimes returns paths with storage/)
  if (cleanPath.startsWith('storage/')) {
    cleanPath = cleanPath.substring(8); // Remove 'storage/'
  }
  
  final fullUrl = '$_storageBaseUrl/$cleanPath';
  
  if (kDebugMode) {
    debugPrint('buildImageUrl: "$path" -> "$fullUrl"');
  }
  
  return fullUrl;
}

/// Build full image URL, returns empty string instead of null
/// Useful for widgets that don't accept null
String buildImageUrlOrEmpty(String? path) {
  return buildImageUrl(path) ?? '';
}

/// Check if a path is a valid image path
bool isValidImagePath(String? path) {
  if (path == null || path.isEmpty) return false;
  return true;
}
