import 'dart:convert';
import 'lib/models/cart_invoince.dart';

void main() {
  // Sample API response from /my-invoices/51
  final apiResponse = {
    "success": true,
    "data": {
      "invoice": {
        "id": 51,
        "invoice_number": "INV-1766209298296",
        "user_id": 17,
        "session_id": "session_1766209298296",
        "total_amount": "188.80",
        "invoice_data": {
          "cart_items": [
            {
              "product_id": 3,
              "name": "Test Product with Image",
              "quantity": 2,
              "price": 80
            }
          ],
          "subtotal": 160,
          "discount_percentage": 0,
          "discount_amount": 0,
          "shipping": 0,
          "tax_percentage": 18,
          "tax_amount": 28.8,
          "total": 188.8,
          "notes": "This is a proforma invoice and not a tax invoice."
        },
        "status": "Draft",
        "created_at": "2025-12-20T05:41:39.000000Z",
        "updated_at": "2025-12-20T05:41:39.000000Z"
      },
      "data": {
        "cart_items": [
          {
            "product_id": 3,
            "name": "Test Product with Image",
            "quantity": 2,
            "price": 80
          }
        ],
        "subtotal": 160,
        "discount_percentage": 0,
        "discount_amount": 0,
        "shipping": 0,
        "tax_percentage": 18,
        "tax_amount": 28.8,
        "total": 188.8,
        "notes": "This is a proforma invoice and not a tax invoice."
      }
    },
    "message": "Invoice retrieved successfully."
  };

  try {
    print('Testing invoice parsing...\n');
    
    // Cast to proper types
    final responseMap = apiResponse as Map<String, dynamic>;
    final dataMap = responseMap['data'] as Map<String, dynamic>;
    final invoiceMap = dataMap['invoice'] as Map<String, dynamic>;
    final invoiceDataMap = dataMap['data'] as Map<String, dynamic>;
    
    // Create GenerateInvoice from API response
    final generateInvoice = GenerateInvoice(
      success: true,
      message: responseMap['message'] as String,
      data: GenerateInvoiceData(
        invoice: Invoice(
          id: invoiceMap['id'] as int,
          invoiceNumber: invoiceMap['invoice_number'] as String,
          userId: invoiceMap['user_id'] as int,
          totalAmount: invoiceMap['total_amount']?.toString() ?? '0',
          invoiceData: jsonEncode(invoiceDataMap),
          status: invoiceMap['status'] as String,
          createdAt: DateTime.parse(invoiceMap['created_at'] as String),
          updatedAt: DateTime.parse(invoiceMap['updated_at'] as String),
        ),
        invoiceData: InvoiceData(
          cartItems: (invoiceDataMap['cart_items'] as List).map((item) {
            final itemMap = item as Map<String, dynamic>;
            return CartItem(
              id: itemMap['product_id'] as int? ?? 0,
              productId: itemMap['product_id'] as int? ?? 0,
              productName: itemMap['name'] as String? ?? '',
              productDescription: '',
              quantity: itemMap['quantity'] as int? ?? 0,
              price: itemMap['price']?.toString() ?? '0',
              total: ((itemMap['quantity'] ?? 0) * (itemMap['price'] ?? 0)).toDouble(),
            );
          }).toList(),
          total: (invoiceDataMap['total'] ?? 0).toDouble(),
          invoiceDate: DateTime.parse(invoiceMap['created_at'] as String),
          customer: Customer(
            id: 0,
            name: 'N/A',
            email: 'N/A',
            address: null,
            mobileNumber: null,
          ),
        ),
      ),
    );

    print('✅ Parsing successful!\n');
    print('Invoice Details:');
    print('  - Invoice Number: ${generateInvoice.data.invoice.invoiceNumber}');
    print('  - Status: ${generateInvoice.data.invoice.status}');
    print('  - Total Amount: ${generateInvoice.data.invoice.totalAmount}');
    print('  - Items count: ${generateInvoice.data.invoiceData.cartItems.length}');
    print('  - Invoice Date: ${generateInvoice.data.invoiceData.invoiceDate}');
    print('  - Customer: ${generateInvoice.data.invoiceData.customer.name}');
    print('\nCart Items:');
    for (var i = 0; i < generateInvoice.data.invoiceData.cartItems.length; i++) {
      final item = generateInvoice.data.invoiceData.cartItems[i];
      print('  - Item $i: ${item.productName} x${item.quantity} @ ${item.price} = ${item.total}');
    }
    
    print('\n✅ All tests passed!');
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}
