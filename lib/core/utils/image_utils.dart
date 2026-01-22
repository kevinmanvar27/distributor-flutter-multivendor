// Image URL Utilities
//
// Centralized helper for building full image URLs from API paths.
// All product/category images must use this to ensure correct URL format.

/// Base storage URL for all images
const String _storageBaseUrl = 'https://hardware.rektech.work/storage';

/// Build full image URL from API path
/// 
/// API returns relative paths like:
/// - "products/abc.jpg"
/// - "/products/abc.jpg"
/// 
/// This function transforms them to:
/// - "https://hardware.rektech.work/storage/products/abc.jpg"
/// 
/// Returns null if path is null or empty.
String? buildImageUrl(String? path) {
  if (path == null || path.isEmpty) return null;
  
  // Already a full URL
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return path;
  }
  
  // Remove leading slash if present
  String cleanPath = path.startsWith('/') ? path.substring(1) : path;
  
  // Remove 'storage/' prefix if present (API sometimes returns paths with storage/)
  if (cleanPath.startsWith('storage/')) {
    cleanPath = cleanPath.substring(8); // Remove 'storage/'
  }
  
  return '$_storageBaseUrl/$cleanPath';
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
