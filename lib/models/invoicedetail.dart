// To parse this JSON data, do
//
//     final invoicedetail = invoicedetailFromJson(jsonString);

import 'dart:convert';

Invoicedetail invoicedetailFromJson(String str) => Invoicedetail.fromJson(json.decode(str));

String invoicedetailToJson(Invoicedetail data) => json.encode(data.toJson());

class Invoicedetail {
  bool success;
  InvoicedetailData data;
  String message;

  Invoicedetail({
    required this.success,
    required this.data,
    required this.message,
  });

  factory Invoicedetail.fromJson(Map<String, dynamic> json) => Invoicedetail(
    success: json["success"],
    data: InvoicedetailData.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.toJson(),
    "message": message,
  };
}

class InvoicedetailData {
  Invoice invoice;
  InvoiceDataClass data;

  InvoicedetailData({
    required this.invoice,
    required this.data,
  });

  factory InvoicedetailData.fromJson(Map<String, dynamic> json) => InvoicedetailData(
    invoice: Invoice.fromJson(json["invoice"]),
    data: InvoiceDataClass.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "invoice": invoice.toJson(),
    "data": data.toJson(),
  };
}

class InvoiceDataClass {
  List<CartItem> cartItems;
  int subtotal;
  int discountPercentage;
  int discountAmount;
  int shipping;
  int taxPercentage;
  double taxAmount;
  double total;
  String notes;

  InvoiceDataClass({
    required this.cartItems,
    required this.subtotal,
    required this.discountPercentage,
    required this.discountAmount,
    required this.shipping,
    required this.taxPercentage,
    required this.taxAmount,
    required this.total,
    required this.notes,
  });

  factory InvoiceDataClass.fromJson(Map<String, dynamic> json) => InvoiceDataClass(
    cartItems: List<CartItem>.from(json["cart_items"].map((x) => CartItem.fromJson(x))),
    subtotal: json["subtotal"],
    discountPercentage: json["discount_percentage"],
    discountAmount: json["discount_amount"],
    shipping: json["shipping"],
    taxPercentage: json["tax_percentage"],
    taxAmount: json["tax_amount"]?.toDouble(),
    total: json["total"]?.toDouble(),
    notes: json["notes"],
  );

  Map<String, dynamic> toJson() => {
    "cart_items": List<dynamic>.from(cartItems.map((x) => x.toJson())),
    "subtotal": subtotal,
    "discount_percentage": discountPercentage,
    "discount_amount": discountAmount,
    "shipping": shipping,
    "tax_percentage": taxPercentage,
    "tax_amount": taxAmount,
    "total": total,
    "notes": notes,
  };
}

class CartItem {
  int productId;
  String name;
  int quantity;
  int price;

  CartItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    productId: json["product_id"],
    name: json["name"],
    quantity: json["quantity"],
    price: json["price"],
  );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "name": name,
    "quantity": quantity,
    "price": price,
  };
}

class Invoice {
  int id;
  String invoiceNumber;
  int userId;
  String sessionId;
  String totalAmount;
  InvoiceDataClass invoiceData;
  String status;
  DateTime createdAt;
  DateTime updatedAt;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.userId,
    required this.sessionId,
    required this.totalAmount,
    required this.invoiceData,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    id: json["id"],
    invoiceNumber: json["invoice_number"],
    userId: json["user_id"],
    sessionId: json["session_id"],
    totalAmount: json["total_amount"],
    invoiceData: InvoiceDataClass.fromJson(json["invoice_data"]),
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "invoice_number": invoiceNumber,
    "user_id": userId,
    "session_id": sessionId,
    "total_amount": totalAmount,
    "invoice_data": invoiceData.toJson(),
    "status": status,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
