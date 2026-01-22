// Cart Controller
// Cart Controller
// 
// Manages shopping cart state and operations:
// - Fetch cart items from API
// - Update cart item quantity
// - Delete cart item
// - Cart totals calculation

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
    _generateAndSaveInvoice(status: 'Approved', paymentId: response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showSnackbar('Payment Failed', 'Error: ${response.message}', isError: true);
    isCheckingOut.value = false;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showSnackbar('External Wallet', 'Wallet: ${response.walletName}');
    // Treat external wallet as successful payment
    _generateAndSaveInvoice(status: 'Approved');
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // API Operations
  // ─────────────────────────────────────────────────────────────────────────────

  /// Fetch cart items from API
  /// GET https://hardware.rektech.work/api/v1/cart
  Future<void> fetchCart() async {
    if (isLoading.value) {
      debugPrint('CartController: Already loading, skipping duplicate call');
      return;
    }
    
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    
    try {
      final response = await _apiService.get('/cart');
      
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
  /// Creates a new cart item or increases quantity if already exists
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
  /// POST https://hardware.rektech.work/api/v1/cart/add
  Future<Item> _addNewItemToCart(ProductItem product, int quantity) async {
    final payload = {
      'product_id': product.id,
      'quantity': quantity,
    };
    
    final response = await _apiService.post('/cart/add', data: payload);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Parse the response to create a new Item
      final itemData = response.data['data'] ?? response.data;
      return Item.fromJson(itemData);
    } else {
      throw Exception('Failed to add item to cart: ${response.data['message']}');
    }
  }

  /// Parse a list of items from the API response
  List<Item> _parseItemsList(List itemsList) {
    final List<Item> items = [];
    
    for (int i = 0; i < itemsList.length; i++) {
      debugPrint('CartController: Processing item $i: ${itemsList[i]}');
      if (itemsList[i] is Map<String, dynamic>) {
        final itemMap = itemsList[i] as Map<String, dynamic>;
        debugPrint('CartController: Item $i keys: ${itemMap.keys.toList()}');
        
        // Try to create an Item from this data
        try {
          final item = Item.fromJson(itemMap);
          debugPrint('CartController: Successfully created item: ${item.name}, quantity: ${item.quantity}');
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
      // Try to get product info from flat structure (not nested in 'product' key)
      product = ProductItem(
        id: json['product_id'] ?? json['productId'] ?? json['id'] ?? 0,
        name: json['product_name'] ?? json['productName'] ?? json['name'] ?? 'Unknown Product',
        slug: json['slug'] ?? '',
        description: json['description'] ?? '',
        mrp: json['mrp']?.toString() ?? json['original_price']?.toString() ?? json['price']?.toString() ?? '0',
        sellingPrice: json['selling_price']?.toString() ?? json['price']?.toString() ?? '0',
        inStock: json['in_stock'] ?? json['inStock'] ?? true,
        stockQuantity: json['stock_quantity'] ?? json['stockQuantity'] ?? json['quantity'] ?? 999,
        status: json['status'] ?? 'active',
        productGallery: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        discountedPrice: json['discounted_price']?.toString() ?? json['price']?.toString() ?? '0',
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
        '/cart/$cartItemId',
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
  Future<void> deleteCartItem(int cartItemId) async {
    if (isUpdating.value) {
      debugPrint('CartController: Already updating cart, skipping duplicate call');
      return;
    }
    
    isUpdating.value = true;
    
    try {
      final response = await _apiService.delete('/cart/$cartItemId');
      
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
  Future<void> clearCart() async {
    if (isUpdating.value) {
      debugPrint('CartController: Already updating cart, skipping clear');
      return;
    }
    
    isUpdating.value = true;
    
    try {
      // Delete all items one by one
      for (final item in cartItems.toList()) {
        await _apiService.delete('/cart/${item.id}');
      }
      
      cartItems.clear();
      cartItems.refresh();
      _showSnackbar('Cart Cleared', 'All items have been removed');
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
  /// Invoice status = Draft
  Future<void> _processDirectInvoice() async {
    await _generateAndSaveInvoice(status: 'Draft', isDirectInvoice: true);
  }

  /// Process COD (Cash on Delivery)
  /// Generate invoice automatically with status = Approved
  Future<void> _processCOD() async {
    await _generateAndSaveInvoice(status: 'Approved');
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

  /// Core method to generate invoice via API and save to DB
  /// 
  /// Status values:
  /// - 'Approved' for COD and Payment flows
  /// - 'Draft' for Generate Invoice only flow
  Future<void> _generateAndSaveInvoice({required String status, String? paymentId, bool isDirectInvoice = false}) async {
    isCheckingOut.value = true;
    
    try {
      // 1. Get User ID
      final user = _storageService.getUser();
      final userId = user?['id'] ?? 1;
      
      // 2. Generate Invoice Number and Session ID
      final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';
      final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
      
      // 3. Calculate totals
      final invoiceSubtotal = cartItems.fold<double>(0, (sum, item) => sum + item.subtotal);
      final discountPercentage = 0;
      final discountAmount = 0;
      final shipping = 0.0;
      final taxPercentage = 18;
      final invoiceTaxAmount = (invoiceSubtotal * taxPercentage / 100);
      final invoiceTotal = invoiceSubtotal - discountAmount + shipping + invoiceTaxAmount;
      
      // 4. Build cart items for invoice
      final invoiceCartItems = cartItems.map((item) => {
        'product_id': item.productId,
        'name': item.product.name,
        'quantity': item.quantity,
        'price': item.priceValue,
      }).toList();
      
      // 5. Prepare full payload with invoice_data
      final payload = {
        'user_id': userId,
        'session_id': sessionId,
        'invoice_number': invoiceNumber,
        'total_amount': invoiceTotal,
        'status': status,
        if (paymentId != null) 'payment_id': paymentId,
        'invoice_data': {
          'cart_items': invoiceCartItems,
          'subtotal': invoiceSubtotal,
          'discount_percentage': discountPercentage,
          'discount_amount': discountAmount,
          'shipping': shipping,
          'tax_percentage': taxPercentage,
          'tax_amount': invoiceTaxAmount,
          'total': invoiceTotal,
          'notes': 'This is a proforma invoice and not a tax invoice.',
        },
      };

      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('GENERATE INVOICE - Payload:');
      debugPrint('Status: $status');
      debugPrint('Payload: $payload');
      debugPrint('═══════════════════════════════════════════════════════════');

      // 6. Call API
      final response = await _apiService.post(
        '/proforma-invoices',
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('INVOICE API RESPONSE:');
        debugPrint('Response Type: ${response.data.runtimeType}');
        debugPrint('Response Data: ${response.data}');
        debugPrint('═══════════════════════════════════════════════════════════');
        
        // 7. Build invoice response from local data + API response
        // The API may not return the full structure expected by GenerateInvoice model,
        // so we construct it from the payload we sent + any server-generated fields
        final invoice_model.GenerateInvoice invoiceResponse = _buildInvoiceFromPayload(
          payload: payload,
          apiResponse: response.data,
          invoiceNumber: invoiceNumber,
          status: status,
          invoiceTotal: invoiceTotal,
        );
        
        // 8. Clear cart from database for both Draft and Approved invoices
        await _clearCartFromDatabase();
        
        // 9. Navigate to Invoice screen with data
        Get.toNamed(Routes.invoice, arguments: invoiceResponse);
        
        // 10. Show success message
        _showSnackbar('Invoice Generated', 'Invoice #$invoiceNumber created successfully');
        
      } else {
        throw Exception('Failed to generate invoice API response: ${response.statusCode}');
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

  /// Build GenerateInvoice object from local payload and API response
  /// This handles cases where API doesn't return the full expected structure
  invoice_model.GenerateInvoice _buildInvoiceFromPayload({
    required Map<String, dynamic> payload,
    required dynamic apiResponse,
    required String invoiceNumber,
    required String status,
    required double invoiceTotal,
  }) {
    // Extract server-generated ID if available
    int invoiceId = 0;
    DateTime createdAt = DateTime.now();
    DateTime updatedAt = DateTime.now();
    
    if (apiResponse is Map<String, dynamic>) {
      // Try to get ID from various possible response structures
      if (apiResponse['data'] != null && apiResponse['data'] is Map) {
        final data = apiResponse['data'] as Map<String, dynamic>;
        if (data['invoice'] != null && data['invoice'] is Map) {
          invoiceId = data['invoice']['id'] ?? 0;
          if (data['invoice']['created_at'] != null) {
            createdAt = DateTime.tryParse(data['invoice']['created_at'].toString()) ?? DateTime.now();
          }
          if (data['invoice']['updated_at'] != null) {
            updatedAt = DateTime.tryParse(data['invoice']['updated_at'].toString()) ?? DateTime.now();
          }
        } else {
          invoiceId = data['id'] ?? 0;
        }
      } else if (apiResponse['invoice'] != null && apiResponse['invoice'] is Map) {
        invoiceId = apiResponse['invoice']['id'] ?? 0;
      } else {
        invoiceId = apiResponse['id'] ?? 0;
      }
    }
    
    // Get user info
    final user = _storageService.getUser();
    final userId = user?['id'] ?? 1;
    final userName = user?['name'] ?? 'Customer';
    final userEmail = user?['email'] ?? '';
    final userAddress = user?['address'] ?? '';
    final userMobile = user?['mobile_number'] ?? user?['phone'] ?? '';
    
    // Build cart items for invoice model
    final invoiceCartItems = cartItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return invoice_model.CartItem(
        id: index + 1,
        productId: item.productId,
        productName: item.product.name,
        productDescription: item.product.description,
        quantity: item.quantity,
        price: item.priceValue.toStringAsFixed(2),
        total: item.subtotal,
      );
    }).toList();
    
    // Build the complete GenerateInvoice object
    return invoice_model.GenerateInvoice(
      success: true,
      message: 'Invoice generated successfully',
      data: invoice_model.GenerateInvoiceData(
        invoice: invoice_model.Invoice(
          id: invoiceId,
          invoiceNumber: invoiceNumber,
          userId: userId,
          totalAmount: invoiceTotal.toStringAsFixed(2),
          invoiceData: payload['invoice_data'].toString(),
          status: status,
          createdAt: createdAt,
          updatedAt: updatedAt,
        ),
        invoiceData: invoice_model.InvoiceData(
          cartItems: invoiceCartItems,
          total: invoiceTotal,
          invoiceDate: DateTime.now(),
          customer: invoice_model.Customer(
            id: userId,
            name: userName,
            email: userEmail,
            address: userAddress,
            mobileNumber: userMobile,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Invoice Generation (Public method for direct invoice generation)
  // ─────────────────────────────────────────────────────────────────────────────

  /// Generate invoice from current cart (Draft status)
  /// This is called when user wants to generate invoice without payment
  Future<void> generateInvoice() async {
    await _processDirectInvoice();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────────

  /// Clear cart from database (used after successful checkout with Approved status)
  Future<void> _clearCartFromDatabase() async {
    try {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('CLEARING CART FROM DATABASE');
      debugPrint('═══════════════════════════════════════════════════════════');
      
      // Delete all cart items from database
      for (final item in cartItems.toList()) {
        await _apiService.delete('/cart/${item.id}');
      }
      
      // Clear local cart
      cartItems.clear();
      cartItems.refresh();
      
      debugPrint('Cart cleared successfully from database');
    } catch (e) {
      debugPrint('Error clearing cart from database: $e');
      // Don't throw - invoice was already generated successfully
    }
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