// Authenticated Image Widget
// 
// Custom image widget that loads images with authentication headers
// Required for protected resources like user avatars
// Uses CachedNetworkImage with Bearer token from StorageService

import 'dart:ui';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';

class AuthenticatedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AuthenticatedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final storageService = Get.find<StorageService>();
    final token = storageService.getToken();

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      httpHeaders: token != null ? {'Authorization': 'Bearer $token'} : null,
      placeholder: (context, url) =>
          placeholder ?? const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) =>
          errorWidget ?? const Icon(Icons.error_outline, size: 40),
    );
  }
}

/// Image Provider with authentication headers
/// Use this with DecorationImage or other widgets that need ImageProvider
class AuthenticatedImageProvider extends ImageProvider<AuthenticatedImageProvider> {
  final String imageUrl;
  final double scale;

  const AuthenticatedImageProvider(this.imageUrl, {this.scale = 1.0});

  @override
  Future<AuthenticatedImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AuthenticatedImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(AuthenticatedImageProvider key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      debugLabel: key.imageUrl,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<AuthenticatedImageProvider>('Image key', key),
      ],
    );
  }

  Future<Codec> _loadAsync(AuthenticatedImageProvider key, ImageDecoderCallback decode) async {
    try {
      final storageService = Get.find<StorageService>();
      final token = storageService.getToken();

      // Fetch image with authentication headers using http package
      final headers = <String, String>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.get(Uri.parse(imageUrl), headers: headers);
      
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        throw Exception('Failed to load image: HTTP ${response.statusCode}');
      }

      final buffer = await ImmutableBuffer.fromUint8List(response.bodyBytes);
      return decode(buffer);
    } catch (e) {
      throw Exception('Failed to load image: $e');
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is AuthenticatedImageProvider &&
        other.imageUrl == imageUrl &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(imageUrl, scale);

  @override
  String toString() => '${objectRuntimeType(this, 'AuthenticatedImageProvider')}("$imageUrl", scale: $scale)';
}
