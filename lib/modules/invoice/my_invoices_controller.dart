// My Invoices Controller
// Manages invoice list display and navigation

import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/invoice_list.dart';
import '../../models/cart_invoince.dart' as cart_invoice;
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../routes/app_routes.dart';

class MyInvoicesController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────────
  // Dependencies
  // ─────────────────────────────────────────────────────────────────────────────

  final ApiService _apiService = Get.find<ApiService>();

  // ─────────────────────────────────────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────────────────────────────────────

  final isLoading = false.obs;
  final invoices = <InvoiceItem>[].obs;
  final selectedStatus = 'all'.obs; // all, draft, sent, paid, cancelled
  
  // Pagination
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final total = 0.obs;

  // ─────────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    loadInvoices();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Data Loading - Uses /customer/invoices API
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> loadInvoices({bool resetPage = false}) async {
    try {
      isLoading.value = true;
      
      if (resetPage) {
        currentPage.value = 1;
      }
      
      // Build query parameters
      final queryParams = <String, dynamic>{
        'page': currentPage.value,
      };
      
      // Add status filter if not 'all'
      if (selectedStatus.value != 'all') {
        queryParams['status'] = selectedStatus.value;
      }
      
      // Use customer invoices API - returns vendor-scoped invoices
      final response = await _apiService.get(
        '/customer/invoices',
        queryParameters: queryParams,
      );
      
      // Parse response
      final invoiceListResponse = InvoiceListResponse.fromJson(response.data);
      
      if (invoiceListResponse.success) {
        invoices.value = invoiceListResponse.data.data;
        currentPage.value = invoiceListResponse.data.currentPage;
        lastPage.value = invoiceListResponse.data.lastPage;
        total.value = invoiceListResponse.data.total;
      } else {
        throw Exception(invoiceListResponse.message);
      }
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load invoices: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshInvoices() async {
    await loadInvoices(resetPage: true);
  }
  
  // ─────────────────────────────────────────────────────────────────────────────
  // Filter Management
  // ─────────────────────────────────────────────────────────────────────────────

  void changeStatus(String status) {
    if (selectedStatus.value != status) {
      selectedStatus.value = status;
      loadInvoices(resetPage: true);
    }
  }
  
  String getStatusDisplayName(String status) {
    switch (status) {
      case 'all':
        return 'All';
      case 'draft':
        return 'Draft';
      case 'sent':
        return 'Sent';
      case 'paid':
        return 'Paid';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }
  
  int getStatusCount(String status) {
    if (status == 'all') {
      return total.value;
    }
    return invoices.where((inv) => inv.status.toLowerCase() == status).length;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Formatting Helpers
  // ─────────────────────────────────────────────────────────────────────────────

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(amount);
  }

  String formatCurrencyFromString(String amount) {
    final value = double.tryParse(amount) ?? 0.0;
    return formatCurrency(value);
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'all':
        return AppTheme.primaryColor;
      case 'paid':
      case 'approved':
        return AppTheme.successColor;
      case 'sent':
      case 'pending':
        return Colors.orange;
      case 'draft':
        return Colors.blue;
      case 'overdue':
        return AppTheme.errorColor;
      case 'cancelled':
        return AppTheme.textTertiary;
      default:
        return AppTheme.primaryColor;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Navigation - Uses /customer/invoices/{id} API
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> viewInvoiceDetail(InvoiceItem invoice) async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
      
      // Fetch invoice details from customer API
      final response = await _apiService.get('/customer/invoices/${invoice.id}');
      
      // Close loading dialog
      Get.back();
      
      // Check if response data is null or empty
      if (response.data == null) {
        Get.snackbar('Error', 'No data received from server',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      
      debugPrint('API Response: ${response.data}');
      // Parse response directly into GenerateInvoice format
      // The API response structure is: {success, data: {invoice, data}, message}
      final responseMap = response.data is String 
          ? json.decode(response.data) 
          : response.data;
      
      if (responseMap['success'] == true) {
        debugPrint('Success! Parsing invoice data...');
        
        // Get cart items from response
        final cartItemsRaw = responseMap['data']['data']?['cart_items'] ?? 
                             responseMap['data']['invoice_data']?['cart_items'] ?? [];
        
        debugPrint('═══════════════════════════════════════════════════════════');
        debugPrint('Cart Items Raw: $cartItemsRaw');
        
        // Parse cart items with debug logging
        final List<cart_invoice.CartItem> parsedCartItems = [];
        for (var item in cartItemsRaw) {
          debugPrint('Parsing item: $item');
          debugPrint('  - name: ${item['name']}');
          debugPrint('  - product_name: ${item['product_name']}');
          
          final productName = item['name']?.toString() ?? 
                              item['product_name']?.toString() ?? 
                              'Unknown Product';
          
          debugPrint('  - Final productName: $productName');
          
          parsedCartItems.add(cart_invoice.CartItem(
            id: item['product_id'] ?? item['id'] ?? 0,
            productId: item['product_id'] ?? 0,
            productName: productName,
            productDescription: item['description']?.toString() ?? item['product_description']?.toString() ?? '',
            quantity: item['quantity'] ?? 0,
            price: item['price']?.toString() ?? '0',
            total: ((item['quantity'] ?? 0) * (double.tryParse(item['price']?.toString() ?? '0') ?? 0)).toDouble(),
          ));
        }
        debugPrint('═══════════════════════════════════════════════════════════');
        
        // Create GenerateInvoice from API response
        final generateInvoice = cart_invoice.GenerateInvoice(
          success: true,
          message: responseMap['message'] ?? 'Invoice retrieved successfully',
          data: cart_invoice.GenerateInvoiceData(
            invoice: cart_invoice.Invoice(
              id: responseMap['data']['invoice']['id'] ?? 0,
              invoiceNumber: responseMap['data']['invoice']['invoice_number']?.toString() ?? '',
              userId: responseMap['data']['invoice']['user_id'] ?? 0,
              totalAmount: responseMap['data']['invoice']['total_amount']?.toString() ?? '0',
              invoiceData: jsonEncode(responseMap['data']['data'] ?? responseMap['data']['invoice_data'] ?? {}),
              status: responseMap['data']['invoice']['status']?.toString() ?? 'Draft',
              createdAt: DateTime.tryParse(responseMap['data']['invoice']['created_at']?.toString() ?? '') ?? DateTime.now(),
              updatedAt: DateTime.tryParse(responseMap['data']['invoice']['updated_at']?.toString() ?? '') ?? DateTime.now(),
            ),
            invoiceData: cart_invoice.InvoiceData(
              cartItems: parsedCartItems,
              total: (double.tryParse((responseMap['data']['data']?['total'] ?? responseMap['data']['invoice_data']?['total'] ?? 0).toString()) ?? 0),
              invoiceDate: DateTime.tryParse(responseMap['data']['invoice']['created_at']?.toString() ?? '') ?? DateTime.now(),
              customer: cart_invoice.Customer(
                id: 0,
                name: 'N/A',
                email: 'N/A',
                address: null,
                mobileNumber: null,
              ),
            ),
          ),
        );
        
        debugPrint('Invoice parsed successfully: ${generateInvoice.data.invoice.invoiceNumber}');
        debugPrint('Items count: ${generateInvoice.data.invoiceData.cartItems.length}');
        
        // Navigate to invoice detail screen
        Get.toNamed(Routes.invoice, arguments: generateInvoice);
      } else {
        throw Exception(responseMap['message'] ?? 'Failed to load invoice');
      }
    } catch (e, stackTrace) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      debugPrint('Error loading invoice: $e');
      debugPrint('Stack trace: $stackTrace');
      
      Get.snackbar(
        'Error',
        'Failed to load invoice details: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
