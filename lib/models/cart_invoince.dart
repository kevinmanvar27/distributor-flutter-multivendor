import 'dart:convert';

GenerateInvoice generateInvoiceFromJson(String str) => GenerateInvoice.fromJson(json.decode(str));

String generateInvoiceToJson(GenerateInvoice data) => json.encode(data.toJson());

class GenerateInvoice {
  bool success;
  GenerateInvoiceData data;
  String message;

  GenerateInvoice({
    required this.success,
    required this.data,
    required this.message,
  });

  factory GenerateInvoice.fromJson(Map<String, dynamic> json) => GenerateInvoice(
    success: json["success"],
    data: GenerateInvoiceData.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.toJson(),
    "message": message,
  };
}

class GenerateInvoiceData {
  Invoice invoice;
  InvoiceData invoiceData;

  GenerateInvoiceData({
    required this.invoice,
    required this.invoiceData,
  });

  factory GenerateInvoiceData.fromJson(Map<String, dynamic> json) => GenerateInvoiceData(
    invoice: Invoice.fromJson(json["invoice"]),
    // Handle both "data" and "invoice_data" keys from different API responses
    invoiceData: InvoiceData.fromJson(json["data"] ?? json["invoice_data"]),
  );

  Map<String, dynamic> toJson() => {
    "invoice": invoice.toJson(),
    "invoice_data": invoiceData.toJson(),
  };
}

class Invoice {
  String invoiceNumber;
  int userId;
  String totalAmount;
  String invoiceData;
  String status;
  DateTime updatedAt;
  DateTime createdAt;
  int id;

  Invoice({
    required this.invoiceNumber,
    required this.userId,
    required this.totalAmount,
    required this.invoiceData,
    required this.status,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    invoiceNumber: json["invoice_number"]?.toString() ?? '',
    userId: json["user_id"] ?? 0,
    totalAmount: json["total_amount"]?.toString() ?? '0',
    invoiceData: json["invoice_data"]?.toString() ?? '',
    status: json["status"]?.toString() ?? '',
    updatedAt: DateTime.parse(json["updated_at"]),
    createdAt: DateTime.parse(json["created_at"]),
    id: json["id"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "invoice_number": invoiceNumber,
    "user_id": userId,
    "total_amount": totalAmount,
    "invoice_data": invoiceData,
    "status": status,
    "updated_at": updatedAt.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "id": id,
  };
}

class InvoiceData {
  List<CartItem> cartItems;
  double total;
  DateTime invoiceDate;
  Customer customer;

  InvoiceData({
    required this.cartItems,
    required this.total,
    required this.invoiceDate,
    required this.customer,
  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) => InvoiceData(
    cartItems: List<CartItem>.from(
      (json["cart_items"] ?? []).map((x) => CartItem.fromJson(x))
    ),
    total: (json["total"] ?? 0).toDouble(),
    // Use current date if invoice_date is not provided
    invoiceDate: json["invoice_date"] != null 
        ? DateTime.parse(json["invoice_date"])
        : DateTime.now(),
    // Create a default customer if not provided
    customer: json["customer"] != null 
        ? Customer.fromJson(json["customer"])
        : Customer(
            id: 0,
            name: 'N/A',
            email: 'N/A',
            address: null,
            mobileNumber: null,
          ),
  );

  Map<String, dynamic> toJson() => {
    "cart_items": List<dynamic>.from(cartItems.map((x) => x.toJson())),
    "total": total,
    "invoice_date": "${invoiceDate.year.toString().padLeft(4, '0')}-${invoiceDate.month.toString().padLeft(2, '0')}-${invoiceDate.day.toString().padLeft(2, '0')}",
    "customer": customer.toJson(),
  };
}

class CartItem {
  int id;
  int productId;
  String productName;
  String productDescription;
  int quantity;
  String price;
  double total;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json["id"] ?? json["product_id"] ?? 0,
    productId: json["product_id"] ?? 0,
    // Handle both "name" and "product_name" fields from different API responses
    productName: json["product_name"]?.toString() ?? json["name"]?.toString() ?? '',
    productDescription: json["product_description"]?.toString() ?? '',
    quantity: json["quantity"] ?? 0,
    price: json["price"]?.toString() ?? '0',
    // Calculate total if not provided (quantity * price)
    total: json["total"]?.toDouble() ?? 
           ((json["quantity"] ?? 0) * (json["price"] ?? 0)).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_id": productId,
    "product_name": productName,
    "product_description": productDescription,
    "quantity": quantity,
    "price": price,
    "total": total,
  };
}

class Customer {
  int id;
  String name;
  String email;
  dynamic address;
  dynamic mobileNumber;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.mobileNumber,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    address: json["address"],
    mobileNumber: json["mobile_number"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "address": address,
    "mobile_number": mobileNumber,
  };
}
