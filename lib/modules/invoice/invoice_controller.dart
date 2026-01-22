// Invoice Controller
//
// Manages invoice display and actions:
// - Receives invoice data from cart
// - Formats dates and currency
// - Handles PDF download
// - Implements mobile download functionality

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/cart_invoince.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';

class InvoiceController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────────────────────────────────────

  final Rxn<GenerateInvoice> _invoiceResponse = Rxn<GenerateInvoice>();
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  // ─────────────────────────────────────────────────────────────────────────────
  // Getters
  // ─────────────────────────────────────────────────────────────────────────────

  GenerateInvoice? get invoiceResponse => _invoiceResponse.value;
  Invoice? get invoice => _invoiceResponse.value?.data.invoice;
  InvoiceData? get invoiceData => _invoiceResponse.value?.data.invoiceData;
  Customer? get customer => invoiceData?.customer;
  List<CartItem> get items => invoiceData?.cartItems ?? [];

  // ─────────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadInvoiceData();
  }

  void _loadInvoiceData() {
    try {
      // Get invoice data from arguments
      final args = Get.arguments;
      debugPrint('InvoiceController: Received arguments type: ${args.runtimeType}');
      
      if (args is GenerateInvoice) {
        _invoiceResponse.value = args;
        debugPrint('InvoiceController: Invoice loaded successfully!');
        debugPrint('  - Invoice Number: ${args.data.invoice.invoiceNumber}');
        debugPrint('  - Status: ${args.data.invoice.status}');
        debugPrint('  - Total Amount: ${args.data.invoice.totalAmount}');
        debugPrint('  - Items count: ${args.data.invoiceData.cartItems.length}');
        debugPrint('  - Invoice Date: ${args.data.invoiceData.invoiceDate}');
        debugPrint('  - Customer: ${args.data.invoiceData.customer.name}');
        
        // Print each item for debugging
        for (var i = 0; i < args.data.invoiceData.cartItems.length; i++) {
          final item = args.data.invoiceData.cartItems[i];
          debugPrint('  - Item $i: ${item.productName} x${item.quantity} @ ${item.price} = ${item.total}');
        }
        
        hasError.value = false;
      } else {
        debugPrint('InvoiceController: Invalid arguments received - Expected GenerateInvoice, got ${args.runtimeType}');
        hasError.value = true;
        Get.snackbar(
          'Error',
          'No invoice data available',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.errorColor.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('InvoiceController: Error loading invoice - $e');
      debugPrint('Stack trace: $stackTrace');
      hasError.value = true;
    } finally {
      isLoading.value = false;
      debugPrint('InvoiceController: Loading complete - isLoading: false, hasError: ${hasError.value}');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Formatting Helpers
  // ─────────────────────────────────────────────────────────────────────────────

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
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
      case 'paid':
      case 'approved':
        return AppTheme.successColor;
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
  // Actions
  // ─────────────────────────────────────────────────────────────────────────────

  void downloadPdf() async {
    // Early return if data is not available
    final currentInvoice = invoice;
    final currentInvoiceData = invoiceData;
    final currentCustomer = customer;
    
    if (currentInvoice == null || currentInvoiceData == null || currentCustomer == null) {
      Get.snackbar(
        'Error',
        'Invoice data not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }
    
    try {
      // Load a font that supports Unicode (including Rupee symbol)
      final font = await PdfGoogleFonts.notoSansRegular();
      final fontBold = await PdfGoogleFonts.notoSansBold();
      
      // Create a PDF document
      final pdf = pw.Document();
      
      // Helper to format currency for PDF (using Rs. for better compatibility)
      String pdfCurrency(double amount) {
        return 'Rs. ${amount.toStringAsFixed(2)}';
      }
      
      String pdfCurrencyFromString(String amount) {
        final value = double.tryParse(amount) ?? 0.0;
        return pdfCurrency(value);
      }
      
      // Add a page to the document
      pdf.addPage(
        pw.Page(
          theme: pw.ThemeData.withFont(
            base: font,
            bold: fontBold,
          ),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Text(
                    'INVOICE',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 20),
                // Invoice details and customer info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Invoice #: ${currentInvoice.invoiceNumber}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text('Date: ${formatDate(currentInvoiceData.invoiceDate)}'),
                        pw.Text('Status: ${currentInvoice.status}'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text(currentCustomer.name),
                        pw.Text(currentCustomer.email),
                        if (currentCustomer.address != null && currentCustomer.address.toString().isNotEmpty) 
                          pw.Text(currentCustomer.address.toString()),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                // Items table
                pw.TableHelper.fromTextArray(
                  headers: ['Product', 'Qty', 'Price', 'Total'],
                  data: [
                    ...items.map((item) => [
                      item.productName,
                      item.quantity.toString(),
                      pdfCurrencyFromString(item.price),
                      pdfCurrency(item.total),
                    ]),
                  ],
                  cellAlignment: pw.Alignment.centerLeft,
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  cellPadding: const pw.EdgeInsets.all(6),
                ),
                pw.SizedBox(height: 20),
                // Totals
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Subtotal: ${pdfCurrency(currentInvoiceData.total)}'),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Total: ${pdfCurrencyFromString(currentInvoice.totalAmount)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                // Footer note
                pw.Text(
                  'This is a proforma invoice and not a tax invoice.',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            );
          },
        ),
      );

      // Save and share the PDF
      await Printing.layoutPdf(onLayout: (_) async => pdf.save());
      
      Get.snackbar(
        'Success',
        'Invoice downloaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.successColor.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download invoice: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  void shareInvoice() {
    Get.snackbar(
      'Coming Soon',
      'Share feature will be available soon',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.surfaceColor,
      colorText: AppTheme.textPrimary,
    );
  }

  /// Go back to previous screen (cart for Draft, main for Approved)
  void goBack() {
    final status = invoice?.status.toLowerCase() ?? '';
    if (status == 'draft') {
      // For draft invoices, go back to cart
      Get.back();
    } else {
      // For approved invoices (COD/Payment), go to main screen
      Get.offAllNamed(Routes.main);
    }
  }

  /// Navigate to home/main screen
  void goToHome() {
    Get.offAllNamed(Routes.main);
  }
}