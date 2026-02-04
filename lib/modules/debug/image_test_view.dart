// Image Test Screen
// Debug screen to test image loading with different URLs

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/widgets/authenticated_image.dart';
import '../../core/utils/image_utils.dart';
import '../../core/theme/app_theme.dart';

class ImageTestView extends StatefulWidget {
  const ImageTestView({super.key});

  @override
  State<ImageTestView> createState() => _ImageTestViewState();
}

class _ImageTestViewState extends State<ImageTestView> {
  final TextEditingController _urlController = TextEditingController();
  String? _imageUrl;
  String? _convertedUrl;
  bool _useAuthentication = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill with example URL
    _urlController.text = 'https://hardware.rektech.work/storage/vendor/1/image.png';
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _loadImage() {
    final inputUrl = _urlController.text.trim();
    if (inputUrl.isEmpty) {
      Get.snackbar('Error', 'Please enter a URL');
      return;
    }

    setState(() {
      _imageUrl = inputUrl;
      _convertedUrl = buildImageUrl(inputUrl);
    });
  }

  void _clearImage() {
    setState(() {
      _imageUrl = null;
      _convertedUrl = null;
      _urlController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Test'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // URL Input
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Image URL',
                hintText: 'Enter image URL here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _urlController.clear(),
                ),
              ),
              maxLines: 3,
              minLines: 1,
            ),
            const SizedBox(height: 12),

            // Authentication Toggle
            SwitchListTile(
              title: const Text('Use Authentication'),
              subtitle: const Text('Send Bearer token with request'),
              value: _useAuthentication,
              onChanged: (value) {
                setState(() {
                  _useAuthentication = value;
                });
              },
            ),
            const SizedBox(height: 12),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loadImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Load Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _clearImage,
                  icon: const Icon(Icons.delete),
                  label: const Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // URL Info
            if (_imageUrl != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Input URL:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _imageUrl!,
                      style: const TextStyle(fontSize: 11, color: Colors.blue),
                    ),
                    const Divider(height: 16),
                    const Text(
                      'Converted URL (after buildImageUrl):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _convertedUrl ?? 'null',
                      style: const TextStyle(fontSize: 11, color: Colors.green),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Image Display
              const Text(
                'Image Preview:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _useAuthentication
                      ? AuthenticatedImage(
                          imageUrl: _convertedUrl ?? '',
                          fit: BoxFit.contain,
                          placeholder: const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: _buildErrorWidget(),
                        )
                      : Image.network(
                          _convertedUrl ?? '',
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildErrorWidget(error.toString());
                          },
                        ),
                ),
              ),
            ],

            // Quick Test URLs
            const SizedBox(height: 24),
            const Text(
              'Quick Test URLs:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildQuickUrlButton(
              'Production Storage',
              'https://hardware.rektech.work/storage/vendor/1/image.png',
            ),
            _buildQuickUrlButton(
              'Relative Path',
              'vendor/1/products/image.png',
            ),
            _buildQuickUrlButton(
              'Public Image (Google)',
              'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget([String? error]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          const Text(
            'Failed to load image',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          if (error != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                error,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickUrlButton(String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: () {
          _urlController.text = url;
          _loadImage();
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          alignment: Alignment.centerLeft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              url,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
