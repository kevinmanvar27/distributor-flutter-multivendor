// Invoice List Model
// Model for /api/v1/my-invoices endpoint response

import 'dart:convert';

InvoiceListResponse invoiceListResponseFromJson(String str) => 
    InvoiceListResponse.fromJson(json.decode(str));

String invoiceListResponseToJson(InvoiceListResponse data) => 
    json.encode(data.toJson());

class InvoiceListResponse {
  bool success;
  InvoiceListData data;
  String message;

  InvoiceListResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory InvoiceListResponse.fromJson(Map<String, dynamic> json) => 
      InvoiceListResponse(
        success: json["success"] ?? false,
        data: InvoiceListData.fromJson(json["data"] ?? {}),
        message: json["message"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data.toJson(),
        "message": message,
      };
}

class InvoiceListData {
  int currentPage;
  List<InvoiceItem> data;
  String firstPageUrl;
  int from;
  int lastPage;
  String lastPageUrl;
  List<Link> links;
  String? nextPageUrl;
  String path;
  int perPage;
  String? prevPageUrl;
  int to;
  int total;

  InvoiceListData({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory InvoiceListData.fromJson(Map<String, dynamic> json) => 
      InvoiceListData(
        currentPage: json["current_page"] ?? 1,
        data: json["data"] != null 
            ? List<InvoiceItem>.from(json["data"].map((x) => InvoiceItem.fromJson(x)))
            : [],
        firstPageUrl: json["first_page_url"] ?? "",
        from: json["from"] ?? 0,
        lastPage: json["last_page"] ?? 1,
        lastPageUrl: json["last_page_url"] ?? "",
        links: json["links"] != null
            ? List<Link>.from(json["links"].map((x) => Link.fromJson(x)))
            : [],
        nextPageUrl: json["next_page_url"],
        path: json["path"] ?? "",
        perPage: json["per_page"] ?? 10,
        prevPageUrl: json["prev_page_url"],
        to: json["to"] ?? 0,
        total: json["total"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "links": List<dynamic>.from(links.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
        "path": path,
        "per_page": perPage,
        "prev_page_url": prevPageUrl,
        "to": to,
        "total": total,
      };
}

class InvoiceItem {
  int id;
  int userId;
  String sessionId;
  String invoiceNumber;
  String totalAmount;
  dynamic invoiceData;
  String status;
  DateTime createdAt;
  DateTime updatedAt;

  InvoiceItem({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.invoiceNumber,
    required this.totalAmount,
    required this.invoiceData,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
        id: json["id"] ?? 0,
        userId: json["user_id"] ?? 0,
        sessionId: json["session_id"] ?? "",
        invoiceNumber: json["invoice_number"] ?? "",
        totalAmount: json["total_amount"]?.toString() ?? "0",
        invoiceData: json["invoice_data"],
        status: json["status"] ?? "draft",
        createdAt: json["created_at"] != null 
            ? DateTime.parse(json["created_at"])
            : DateTime.now(),
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "session_id": sessionId,
        "invoice_number": invoiceNumber,
        "total_amount": totalAmount,
        "invoice_data": invoiceData,
        "status": status,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class Link {
  String? url;
  String label;
  bool active;

  Link({
    this.url,
    required this.label,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json["url"],
        label: json["label"] ?? "",
        active: json["active"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "label": label,
        "active": active,
      };
}
