import 'dart:convert';

ProformaInvoices proformaInvoicesFromJson(String str) => ProformaInvoices.fromJson(json.decode(str));

String proformaInvoicesToJson(ProformaInvoices data) => json.encode(data.toJson());

class ProformaInvoices {
  bool success;
  Data data;
  String message;

  ProformaInvoices({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ProformaInvoices.fromJson(Map<String, dynamic> json) => ProformaInvoices(
    success: json["success"],
    data: Data.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.toJson(),
    "message": message,
  };
}

class Data {
  int userId;
  String sessionId;
  String invoiceNumber;
  String totalAmount;
  InvoiceData invoiceData;
  String status;
  DateTime updatedAt;
  DateTime createdAt;
  int id;
  User user;

  Data({
    required this.userId,
    required this.sessionId,
    required this.invoiceNumber,
    required this.totalAmount,
    required this.invoiceData,
    required this.status,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
    required this.user,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userId: json["user_id"] ?? 0,
    sessionId: json["session_id"] ?? '',
    invoiceNumber: json["invoice_number"] ?? '',
    totalAmount: json["total_amount"]?.toString() ?? '0',
    invoiceData: json["invoice_data"] != null 
        ? InvoiceData.fromJson(json["invoice_data"]) 
        : InvoiceData(cartItems: [], subtotal: 0, discountPercentage: 0, discountAmount: 0, shipping: 0, taxPercentage: 0, taxAmount: 0, total: 0.0, notes: ''),
    status: json["status"] ?? 'pending',
    updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : DateTime.now(),
    createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : DateTime.now(),
    id: json["id"] ?? 0,
    user: json["user"] != null 
        ? User.fromJson(json["user"]) 
        : User(id: 0, name: '', email: '', deviceToken: null, dateOfBirth: null, avatar: null, address: null, mobileNumber: null, emailVerifiedAt: null, userRole: '', createdAt: DateTime.now(), updatedAt: DateTime.now(), isApproved: 0, discountPercentage: '0'),
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "session_id": sessionId,
    "invoice_number": invoiceNumber,
    "total_amount": totalAmount,
    "invoice_data": invoiceData.toJson(),
    "status": status,
    "updated_at": updatedAt.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "id": id,
    "user": user.toJson(),
  };
}

class InvoiceData {
  List<CartItem> cartItems;
  int subtotal;
  int discountPercentage;
  int discountAmount;
  int shipping;
  int taxPercentage;
  int taxAmount;
  double total;
  String notes;

  InvoiceData({
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

  factory InvoiceData.fromJson(Map<String, dynamic> json) => InvoiceData(
    cartItems: List<CartItem>.from(json["cart_items"].map((x) => CartItem.fromJson(x))),
    subtotal: json["subtotal"] ?? 0,
    discountPercentage: json["discount_percentage"] ?? 0,
    discountAmount: json["discount_amount"] ?? 0,
    shipping: json["shipping"] ?? 0,
    taxPercentage: json["tax_percentage"] ?? 0,
    taxAmount: json["tax_amount"] ?? 0,
    total: json["total"]?.toDouble() ?? 0.0,
    notes: json["notes"] ?? '',
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
    productId: json["product_id"] ?? 0,
    name: json["name"] ?? '',
    quantity: json["quantity"] ?? 0,
    price: json["price"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "name": name,
    "quantity": quantity,
    "price": price,
  };
}

class User {
  int id;
  String name;
  String email;
  dynamic deviceToken;
  dynamic dateOfBirth;
  dynamic avatar;
  dynamic address;
  dynamic mobileNumber;
  dynamic emailVerifiedAt;
  String userRole;
  DateTime createdAt;
  DateTime updatedAt;
  int isApproved;
  String discountPercentage;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.deviceToken,
    required this.dateOfBirth,
    required this.avatar,
    required this.address,
    required this.mobileNumber,
    required this.emailVerifiedAt,
    required this.userRole,
    required this.createdAt,
    required this.updatedAt,
    required this.isApproved,
    required this.discountPercentage,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"] ?? 0,
    name: json["name"] ?? '',
    email: json["email"] ?? '',
    deviceToken: json["device_token"],
    dateOfBirth: json["date_of_birth"],
    avatar: json["avatar"],
    address: json["address"],
    mobileNumber: json["mobile_number"],
    emailVerifiedAt: json["email_verified_at"],
    userRole: json["user_role"] ?? '',
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    isApproved: json["is_approved"] ?? 0,
    discountPercentage: json["discount_percentage"] ?? '0',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "device_token": deviceToken,
    "date_of_birth": dateOfBirth,
    "avatar": avatar,
    "address": address,
    "mobile_number": mobileNumber,
    "email_verified_at": emailVerifiedAt,
    "user_role": userRole,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "is_approved": isApproved,
    "discount_percentage": discountPercentage,
  };
}
