// Cart Controller - Multi-Vendor Customer Cart
// 
// Manages shopping cart state and operations using customer APIs:
// - Fetch cart items from /customer/cart API
// - Add to cart via /customer/cart/add
// - Update cart item quantity via /customer/cart/{id}
// - Delete cart item via /customer/cart/{id}
// - Clear cart via /customer/cart/clear
// - Generate invoice via /customer/cart/generate-invoice
// 
// All cart operations are vendor-scoped (customers only see their vendor's products)
// Customer discount is automatically applied by the API

import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../core/services/storage_service.dart';
import '../../models/cart_item.dart';
import '../../models/category.dart';
import '../../models/cart_invoince.dart' as invoice_model;
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CartController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // ─────────────────────────────────────────────────────────────────────────────
  // Reactive State
  // ─────────────────────────────────────────────────────────────────────────────

  final RxList<Item> cartItems = <Item>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCheckingOut = false.obs;
  final RxBool isGeneratingInvoice = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isUpdating = false.obs;
  final RxString cartTotal = '0'.obs;
  final RxDouble customerDiscount = 0.0.obs; // Customer's discount percentage
  
  late Razorpay _razorpay;
  final StorageService _storageService = Get.find<StorageService>();

  // Tax rate (configurable)
  final double taxRate = 0.10; // 10%

  // ─────────────────────────────────────────────────────────────────────────────
  // Computed Properties
  // ─────────────────────────────────────────────────────────────────────────────

  /// Total number of items in cart (sum of quantities)
  int get cartCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  /// Reactive cart count for badge updates
  RxInt get cartCountRx => cartCount.obs;

  /// Number of unique products in cart
  int get uniqueItemsCount => cartItems.length;

  /// Cart subtotal (before tax)
  double get subtotal => cartItems.fold(
    0.0, 
    (sum, item) => sum + item.totalPrice,
  );

  /// Tax amount
  double get taxAmount => subtotal * taxRate;

  /// Total discount applied
  double get totalDiscount => cartItems.fold(
    0.0,
    (sum, item) => sum + item.discountAmount,
  );

  /// Cart total (after tax)
  double get total => subtotal + taxAmount;

  /// Check if cart is empty
  bool get isEmpty => cartItems.isEmpty;

  /// Check if cart has items
  bool get hasItems => cartItems.isNotEmpty;

  // ─────────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    fetchCart();
    
    // Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Razorpay Handlers
  // ─────────────────────────────────────────────────────────────────────────────

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _showSnackbar('Payment Successful', 'Transaction ID: ${response.paymentId}');
    // Generate Invoice with 'Approved' status after successful payment
    _generateInvoiceAfterPayment(paymentId: response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showSnackbar('Payment Failed', 'Error: ${response.message}', isError: true);
    isCheckingOut.value = false;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showSnackbar('External Wallet', 'Wallet: ${response.walletName}');
    // Treat external wallet as successful payment
    _generateInvoiceAfterPayment();
  }

  /// Generate invoice after successful online payment
  Future<void> _generateInvoiceAfterPayment({String? paymentId}) async {
    try {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('GENERATING INVOICE AFTER PAYMENT SUCCESS');
      debugPrint('Payment ID: $paymentId');
      debugPrint('═══════════════════════════════════════════════════════════');

      final response = await _apiService.post('/customer/cart/generate-invoice');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData['success'] == true && responseData['data'] != null) {
          // Build invoice response from API response
          final invoiceResponse = _buildInvoiceFromAPIResponse(responseData['data']);
          
          // Clear local cart (API already cleared it)
          cartItems.clear();
          cartItems.refresh();
          cartTotal.value = '0';
          
          // Navigate to Invoice screen with data
          Get.toNamed(Routes.invoice, arguments: invoiceResponse);
          
          // Show success message
          final invoiceNumber = responseData['data']['invoice']?['invoice_number'] ?? 'N/A';
          _showSnackbar('Invoice Generated', 'Invoice #$invoiceNumber created successfully');
        } else {
          throw Exception(responseData['message'] ?? 'Failed to generate invoice');
        }
      } else {
        throw Exception('Failed to generate invoice: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('ERROR generating invoice after payment: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('═══════════════════════════════════════════════════════════');
      _showSnackbar('Error', 'Payment successful but failed to generate invoice. Please contact support.', isError: true);
    } finally {
      isCheckingOut.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // API Operations - Using Customer Cart APIs
  // ─────────────────────────────────────────────────────────────────────────────

  /// Fetch cart items from API
  /// GET /api/v1/customer/cart
  Future<void> fetchCart() async {
    if (isLoading.value) {
      debugPrint('CartController: Already loading, skipping duplicate call');
      return;
    }
    
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    
    try {
      final response = await _apiService.get('/customer/cart');
      
      debugPrint('CartController: API Response: ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        List<Item> items = [];
        
        if (data is Map<String, dynamic>) {
          // Parse using CartItem model
          if (data['success'] == true && data['data'] != null) {
            final cartData = data['data'];
            
            if (cartData is Map<String, dynamic>) {
              // Get total from API response
              cartTotal.value = cartData['total']?.toString() ?? '0';
              
              // Get customer discount from API response
              customerDiscount.value = _parseDouble(cartData['customer_discount']) ?? 0.0;
              
              if (cartData['items'] is List) {
                final itemsList = cartData['items'] as List;
                items = _parseItemsList(itemsList);
              }
            }
          } else if (data['items'] is List) {
            items = _parseItemsList(data['items'] as List);
          }
        }
        
        cartItems.clear();
        cartItems.addAll(items);
        cartItems.refresh();
        debugPrint('CartController: Loaded ${cartItems.length} items from API');
        debugPrint('CartController: Customer discount: ${customerDiscount.value}%');
      }
    } catch (e, stackTrace) {
      debugPrint('CartController: Error fetching cart: $e');
      debugPrint('Stack trace: $stackTrace');
      hasError.value = true;
      errorMessage.value = 'Failed to load cart: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Alias for fetchCart (backward compatibility)
  Future<void> loadCartFromAPI() async {
    await fetchCart();
  }

  /// Refresh cart from API
  Future<void> refreshCart() async {
    await fetchCart();
  }

  /// Add a product to the cart
  /// POST /api/v1/customer/cart/add
  Future<void> addToCart(ProductItem product, {int quantity = 1}) async {
    try {
      // Check if product already exists in cart
      final existingItemIndex = cartItems.indexWhere((item) => item.productId == product.id);
      
      if (existingItemIndex != -1) {
        // Product already in cart, increase quantity
        final existingItem = cartItems[existingItemIndex];
        final newQuantity = existingItem.quantity + quantity;
        
        // Update quantity via API
        await updateCartItem(existingItem.id, newQuantity);
        
        // Update local state
        cartItems[existingItemIndex] = existingItem.copyWith(quantity: newQuantity);
      } else {
        // New product, add to cart via API
        final newItem = await _addNewItemToCart(product, quantity);
        cartItems.add(newItem);
      }
      
      cartItems.refresh();
      
      // Show success message
      _showSnackbar(
        'Added to Cart',
        '${product.name} added to your cart',
      );
      
      // Refresh cart to get updated totals
      await fetchCart();
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      _showSnackbar('Error', 'Failed to add item to cart', isError: true);
    }
  }

  /// Helper method to add a new item to cart via API
  /// POST /api/v1/customer/cart/add
  Future<Item> _addNewItemToCart(ProductItem product, int quantity) async {
    final payload = {
      'product_id': product.id,
      'quantity': quantity,
    };
    
    final response = await _apiService.post('/customer/cart/add', data: payload);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Parse the response to create a new Item
      final responseData = response.data;
      if (responseData['success'] == true && responseData['data'] != null) {
        final cartItemData = responseData['data']['cart_item'];
        if (cartItemData != null) {
          return _parseCartItemFromResponse(cartItemData, product);
        }
      }
      // Fallback: create item from product data
      return _createItemFromProduct(product, quantity);
    } else {
      throw Exception('Failed to add item to cart: ${response.data['message']}');
    }
  }

  /// Parse cart item from API response
  Item _parseCartItemFromResponse(Map<String, dynamic> cartItemData, ProductItem product) {
    return Item(
      id: cartItemData['id'] ?? 0,
      userId: 0,
      sessionId: null,
      productId: cartItemData['product_id'] ?? product.id,
      quantity: cartItemData['quantity'] ?? 1,
      price: cartItemData['price']?.toString() ?? product.discountedPrice,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      product: product,
    );
  }

  /// Create item from product (fallback)
  Item _createItemFromProduct(ProductItem product, int quantity) {
    return Item(
      id: 0, // Will be updated on refresh
      userId: 0,
      sessionId: null,
      productId: product.id,
      quantity: quantity,
      price: product.discountedPrice,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      product: product,
    );
  }

  /// Parse a list of items from the API response
  List<Item> _parseItemsList(List itemsList) {
    final List<Item> items = [];
    
    for (int i = 0; i < itemsList.length; i++) {
      debugPrint('CartController: Processing item $i: ${itemsList[i]}');
      if (itemsList[i] is Map<String, dynamic>) {
        final itemMap = itemsList[i] as Map<String, dynamic>;
        debugPrint('CartController: Item $i keys: ${itemMap.keys.toList()}');
        
        // Debug: Log all possible image URL fields
        debugPrint('CartController: Item $i image fields - main_photo_url: ${itemMap['main_photo_url']}, image: ${itemMap['image']}, product_image: ${itemMap['product_image']}, image_url: ${itemMap['image_url']}, photo_url: ${itemMap['photo_url']}');
        
        // Try to create an Item from this data
        try {
          final item = _parseCustomerCartItem(itemMap);
          debugPrint('CartController: Successfully created item: ${item.name}, quantity: ${item.quantity}, imageUrl: ${item.imageUrl}');
          items.add(item);
        } catch (e) {
          debugPrint('CartController: Error creating item from data: $e');
          // Try alternative parsing
          items.add(_parseItemFromMap(itemMap));
        }
      }
    }
    
    return items;
  }

  /// Parse customer cart item from API response
  /// Handles the /customer/cart response format
  Item _parseCustomerCartItem(Map<String, dynamic> json) {
    // Try to get image URL from various possible fields
    final imageUrl = json['main_photo_url']?.toString() ?? 
                     json['image']?.toString() ?? 
                     json['product_image']?.toString() ??
                     json['image_url']?.toString() ??
                     json['photo_url']?.toString();
    
    debugPrint('CartController: Parsing cart item image URL: $imageUrl');
    
    // Create ProductItem from the cart item data
    final product = ProductItem(
      id: json['product_id'] ?? 0,
      name: json['product_name'] ?? 'Unknown Product',
      slug: json['product_slug'] ?? '',
      description: json['product_description'] ?? '',
      mrp: json['mrp']?.toString() ?? json['price']?.toString() ?? '0',
      sellingPrice: json['selling_price']?.toString() ?? json['price']?.toString() ?? '0',
      inStock: json['in_stock'] ?? true,
      stockQuantity: json['stock_quantity'] ?? 999,
      status: 'active',
      productGallery: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      discountedPrice: json['price']?.toString() ?? '0',
      mainPhoto: null,
      mainPhotoId: null,
      mainPhotoUrl: imageUrl,
    );

    return Item(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      sessionId: json['session_id'],
      productId: json['product_id'] ?? product.id,
      quantity: json['quantity'] ?? 1,
      price: json['price']?.toString() ?? product.discountedPrice,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      product: product,
    );
  }

  /// Parse item from map with more flexible approach
  Item _parseItemFromMap(Map<String, dynamic> json) {
    debugPrint('CartController: Parsing item with flexible approach: $json');
    
    // Try to extract product information
    ProductItem? product;
    if (json['product'] is Map<String, dynamic>) {
      try {
        product = ProductItem.fromJson(json['product'] as Map<String, dynamic>);
      } catch (e) {
        debugPrint('CartController: Error parsing product: $e');
      }
    }
    
    // If no product, create a minimal one from flat data
    if (product == null) {
      // Try to get image URL from various possible fields
      final imageUrl = json['main_photo_url']?.toString() ?? 
                       json['image']?.toString() ?? 
                       json['product_image']?.toString() ??
                       json['image_url']?.toString() ??
                       json['photo_url']?.toString();
      
      debugPrint('CartController: Parsing item (flexible) image URL: $imageUrl');
      
      // Try to get product info from flat structure (not nested in 'product' key)
      product = ProductItem(
        id: json['product_id'] ?? json['productId'] ?? json['id'] ?? 0,
        name: json['product_name'] ?? json['productName'] ?? json['name'] ?? 'Unknown Product',
        slug: json['product_slug'] ?? json['slug'] ?? '',
        description: json['product_description'] ?? json['description'] ?? '',
        mrp: json['mrp']?.toString() ?? json['original_price']?.toString() ?? json['price']?.toString() ?? '0',
        sellingPrice: json['selling_price']?.toString() ?? json['price']?.toString() ?? '0',
        inStock: json['in_stock'] ?? json['inStock'] ?? true,
        stockQuantity: json['stock_quantity'] ?? json['stockQuantity'] ?? json['quantity'] ?? 999,
        status: json['status'] ?? 'active',
        productGallery: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        discountedPrice: json['discounted_price']?.toString() ?? json['price']?.toString() ?? '0',
        mainPhotoUrl: imageUrl,
      );
    }
    
    return Item(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? json['userId'] ?? 0,
      sessionId: json['session_id'] ?? json['sessionId'],
      productId: json['product_id'] ?? json['productId'] ?? product.id,
      quantity: json['quantity'] ?? 1,
      price: json['price']?.toString() ?? product.sellingPrice,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      product: product,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Cart Item Operations (using cart item id)
  // ─────────────────────────────────────────────────────────────────────────────

  /// Update cart item quantity
  /// PUT /api/v1/customer/cart/{id}
  Future<void> updateCartItem(int cartItemId, int newQuantity) async {
    if (isUpdating.value) {
      debugPrint('CartController: Already updating cart, skipping duplicate call');
      return;
    }
    
    if (newQuantity <= 0) {
      await deleteCartItem(cartItemId);
      return;
    }
    
    isUpdating.value = true;
    
    try {
      final response = await _apiService.put(
        '/customer/cart/$cartItemId',
        data: {'quantity': newQuantity},
      );
      
      if (response.statusCode == 200) {
        await fetchCart(); // Refresh cart
      } else {
        throw Exception('Failed to update cart item');
      }
    } catch (e) {
      debugPrint('CartController: Error updating cart item: $e');
      _showSnackbar(
        'Error',
        'Failed to update item quantity',
        isError: true,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  /// Delete cart item
  /// DELETE /api/v1/customer/cart/{id}
  Future<void> deleteCartItem(int cartItemId) async {
    if (isUpdating.value) {
      debugPrint('CartController: Already updating cart, skipping duplicate call');
      return;
    }
    
    isUpdating.value = true;
    
    try {
      final response = await _apiService.delete('/customer/cart/$cartItemId');
      
      if (response.statusCode == 200) {
        await fetchCart(); // Refresh cart
      } else {
        throw Exception('Failed to delete cart item');
      }
    } catch (e) {
      debugPrint('CartController: Error deleting cart item: $e');
      _showSnackbar(
        'Error',
        'Failed to remove item',
        isError: true,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  /// Increment item quantity by 1 (uses cart item id)
  Future<void> incrementQuantity(int cartItemId) async {
    final item = cartItems.firstWhereOrNull((item) => item.id == cartItemId);
    if (item != null) {
      await updateCartItem(cartItemId, item.quantity + 1);
    }
  }

  /// Decrement item quantity by 1 (uses cart item id)
  Future<void> decrementQuantity(int cartItemId) async {
    final item = cartItems.firstWhereOrNull((item) => item.id == cartItemId);
    if (item != null) {
      if (item.quantity <= 1) {
        await deleteCartItem(cartItemId);
      } else {
        await updateCartItem(cartItemId, item.quantity - 1);
      }
    }
  }

  /// Remove from cart by product ID (for backward compatibility)
  Future<void> removeFromCart(int productId) async {
    final item = cartItems.firstWhereOrNull((item) => item.productId == productId);
    if (item != null) {
      await deleteCartItem(item.id);
    }
  }

  /// Clear entire cart
  /// DELETE /api/v1/customer/cart/clear
  Future<void> clearCart() async {
    if (isUpdating.value) {
      debugPrint('CartController: Already updating cart, skipping clear');
      return;
    }
    
    isUpdating.value = true;
    
    try {
      final response = await _apiService.delete('/customer/cart/clear');
      
      if (response.statusCode == 200) {
        cartItems.clear();
        cartItems.refresh();
        cartTotal.value = '0';
        _showSnackbar('Cart Cleared', 'All items have been removed');
      } else {
        throw Exception('Failed to clear cart');
      }
    } catch (e) {
      debugPrint('CartController: Error clearing cart: $e');
      _showSnackbar(
        'Error',
        'Failed to clear cart',
        isError: true,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  /// Check if product is in cart
  bool isInCart(int productId) {
    return cartItems.any((item) => item.productId == productId);
  }

  /// Get quantity of specific product in cart
  int getQuantityInCart(int productId) {
    final item = cartItems.firstWhereOrNull((item) => item.productId == productId);
    return item?.quantity ?? 0;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Checkout
  // ─────────────────────────────────────────────────────────────────────────────

  /// Initiate checkout process with options
  void checkout() {
    if (isEmpty) {
      _showSnackbar('Empty Cart', 'Add items to your cart first', isError: true);
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLG)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Checkout Method',
              style: AppTheme.headingSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLG),
            
            // COD Option
            ElevatedButton.icon(
              onPressed: () {
                Get.back(); // Close sheet
                _processCOD();
              },
              icon: const Icon(Icons.money),
              label: const Text('Cash on Delivery (COD)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMD),
            
            // Payment Option
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                _processRazorpayPayment();
              },
              icon: const Icon(Icons.payment),
              label: const Text('Online Payment (Razorpay)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
             const SizedBox(height: AppTheme.spacingMD),
            
            // Invoice Option
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                _processDirectInvoice();
              },
              icon: const Icon(Icons.description),
              label: const Text('Generate Invoice Only'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLG),
          ],
        ),
      ),
    );
  }

  /// Process direct invoice generation (without payment)
  /// Uses /customer/cart/generate-invoice API
  Future<void> _processDirectInvoice() async {
    await _generateInvoiceFromAPI();
  }

  /// Process COD (Cash on Delivery)
  /// Generate invoice automatically with status = Approved
  Future<void> _processCOD() async {
    await _generateInvoiceFromAPI();
  }

  /// Process Razorpay Payment
  void _processRazorpayPayment() {
    isCheckingOut.value = true;
    
    // Calculate amount in paise (multiply by 100)
    final amountInPaise = (total * 100).toInt();

    var options = {
      'key': 'rzp_test_Go3jN8rdNmRJ7P',
      'amount': amountInPaise,
      'name': 'Hardware Distributor',
      'description': 'Hardware Supplies',
      // 'prefill': {
      //   'contact': '8888888888',
      //   'email': 'test@razorpay.com'
      // }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
      isCheckingOut.value = false;
      _showSnackbar('Error', 'Unable to start payment', isError: true);
    }
  }

  /// Generate invoice using customer API
  /// POST /api/v1/customer/cart/generate-invoice
  Future<void> _generateInvoiceFromAPI() async {
    isCheckingOut.value = true;
    
    try {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('GENERATING INVOICE FROM CUSTOMER API');
      debugPrint('═══════════════════════════════════════════════════════════');

      final response = await _apiService.post('/customer/cart/generate-invoice');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('INVOICE API RESPONSE:');
        debugPrint('Response Type: ${response.data.runtimeType}');
        debugPrint('Response Data: ${response.data}');
        debugPrint('═══════════════════════════════════════════════════════════');
        
        final responseData = response.data;
        if (responseData['success'] == true && responseData['data'] != null) {
          // Build invoice response from API response
          final invoiceResponse = _buildInvoiceFromAPIResponse(responseData['data']);
          
          // Clear local cart (API already cleared it)
          cartItems.clear();
          cartItems.refresh();
          cartTotal.value = '0';
          
          // Navigate to Invoice screen with data
          Get.toNamed(Routes.invoice, arguments: invoiceResponse);
          
          // Show success message
          final invoiceNumber = responseData['data']['invoice']?['invoice_number'] ?? 'N/A';
          _showSnackbar('Invoice Generated', 'Invoice #$invoiceNumber created successfully');
        } else {
          throw Exception(responseData['message'] ?? 'Failed to generate invoice');
        }
      } else {
        throw Exception('Failed to generate invoice: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('ERROR generating invoice: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('═══════════════════════════════════════════════════════════');
      _showSnackbar('Error', 'Failed to generate invoice', isError: true);
    } finally {
      isCheckingOut.value = false;
    }
  }

  /// Build GenerateInvoice object from API response
  invoice_model.GenerateInvoice _buildInvoiceFromAPIResponse(Map<String, dynamic> data) {
    final invoiceData = data['invoice'] ?? {};
    final invoiceDetails = data['invoice_data'] ?? data['data'] ?? {};
    
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('Building invoice from API response:');
    debugPrint('Invoice Data: $invoiceData');
    debugPrint('Invoice Details: $invoiceDetails');
    debugPrint('Cart Items Raw: ${invoiceDetails['cart_items']}');
    debugPrint('═══════════════════════════════════════════════════════════');
    
    // Parse cart items
    final cartItemsList = (invoiceDetails['cart_items'] as List<dynamic>?)
        ?.map((item) {
          debugPrint('Parsing cart item: $item');
          debugPrint('  - name field: ${item['name']}');
          debugPrint('  - product_name field: ${item['product_name']}');
          return invoice_model.CartItem(
              id: item['id'] ?? item['product_id'] ?? 0,
              productId: item['product_id'] ?? 0,
              // Check both 'name' and 'product_name' fields
              productName: item['name']?.toString() ?? item['product_name']?.toString() ?? '',
              productDescription: item['product_description']?.toString() ?? item['description']?.toString() ?? '',
              quantity: item['quantity'] ?? 1,
              price: item['price']?.toString() ?? '0',
              total: (item['total'] ?? ((item['quantity'] ?? 1) * (double.tryParse(item['price']?.toString() ?? '0') ?? 0))).toDouble(),
            );
        })
        .toList() ?? [];
    
    // Parse customer info
    final customerData = invoiceDetails['customer'] ?? {};
    final customer = invoice_model.Customer(
      id: customerData['id'] ?? 0,
      name: customerData['name'] ?? '',
      email: customerData['email'] ?? '',
      address: customerData['address'] ?? '',
      mobileNumber: customerData['mobile_number'] ?? '',
    );
    
    return invoice_model.GenerateInvoice(
      success: true,
      message: 'Invoice generated successfully',
      data: invoice_model.GenerateInvoiceData(
        invoice: invoice_model.Invoice(
          id: invoiceData['id'] ?? 0,
          invoiceNumber: invoiceData['invoice_number'] ?? '',
          userId: 0,
          totalAmount: invoiceData['total_amount']?.toString() ?? '0',
          invoiceData: invoiceDetails.toString(),
          status: invoiceData['status'] ?? 'Draft',
          createdAt: DateTime.tryParse(invoiceData['created_at']?.toString() ?? '') ?? DateTime.now(),
          updatedAt: DateTime.tryParse(invoiceData['updated_at']?.toString() ?? '') ?? DateTime.now(),
        ),
        invoiceData: invoice_model.InvoiceData(
          cartItems: cartItemsList,
          total: (invoiceDetails['total'] ?? 0).toDouble(),
          invoiceDate: DateTime.tryParse(invoiceDetails['invoice_date']?.toString() ?? '') ?? DateTime.now(),
          customer: customer,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────────

  /// Parse double from dynamic value
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  void _showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError 
          ? AppTheme.errorColor.withValues(alpha: 0.9)
          : AppTheme.successColor.withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(AppTheme.spacingMD),
      borderRadius: AppTheme.radiusMD,
      duration: const Duration(seconds: 2),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
    );
  }
}