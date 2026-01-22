// My Invoices Controller
// Manages invoice list display and navigation

import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/invoice_list.dart';
import '../../models/cart_invoince.dart' as cart_invoice;
import '../../models/invoice.dart' as api_invoice;
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
  // Data Loading
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
      
      // Make API call
      final response = await _apiService.get(
        '/my-invoices',
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
  // Navigation
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
      
      // Fetch invoice details from API
      final response = await _apiService.get('/my-invoices/${invoice.id}');
      
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
        
        // Create GenerateInvoice from API response
        final generateInvoice = cart_invoice.GenerateInvoice(
          success: true,
          message: responseMap['message'] ?? 'Invoice retrieved successfully',
          data: cart_invoice.GenerateInvoiceData(
            invoice: cart_invoice.Invoice(
              id: responseMap['data']['invoice']['id'],
              invoiceNumber: responseMap['data']['invoice']['invoice_number'],
              userId: responseMap['data']['invoice']['user_id'],
              totalAmount: responseMap['data']['invoice']['total_amount']?.toString() ?? '0',
              invoiceData: jsonEncode(responseMap['data']['data']),
              status: responseMap['data']['invoice']['status'],
              createdAt: DateTime.parse(responseMap['data']['invoice']['created_at']),
              updatedAt: DateTime.parse(responseMap['data']['invoice']['updated_at']),
            ),
            invoiceData: cart_invoice.InvoiceData(
              cartItems: (responseMap['data']['data']['cart_items'] as List).map((item) {
                return cart_invoice.CartItem(
                  id: item['product_id'] ?? 0,
                  productId: item['product_id'] ?? 0,
                  productName: item['name'] ?? '',
                  productDescription: '',
                  quantity: item['quantity'] ?? 0,
                  price: item['price']?.toString() ?? '0',
                  total: ((item['quantity'] ?? 0) * (item['price'] ?? 0)).toDouble(),
                );
              }).toList(),
              total: (responseMap['data']['data']['total'] ?? 0).toDouble(),
              invoiceDate: DateTime.parse(responseMap['data']['invoice']['created_at']),
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
