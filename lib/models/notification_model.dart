// Notification Model
//
// Data model for app notifications with:
// - Different notification types (order, promotion, payment, system)
// - Read/unread status
// - Timestamp formatting

import '../core/utils/image_utils.dart';

/// Types of notifications
enum NotificationType {
  order,
  promotion,
  payment,
  system,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final String? _image; // Raw image path from API
  final String? actionUrl;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    String? image,
    this.actionUrl,
    this.metadata,
  }) : _image = image;
  
  /// Get full image URL with storage path prepended
  String? get imageUrl => buildImageUrl(_image);

  /// Create from JSON response
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['subject'] ?? 'Notification',
      message: json['message'] ?? json['body'] ?? json['content'] ?? '',
      type: _parseType(json['type']),
      isRead: json['is_read'] ?? json['read'] ?? json['read_at'] != null,
      createdAt: _parseDateTime(json['created_at'] ?? json['timestamp']),
      image: json['image_url'] ?? json['image'],
      actionUrl: json['action_url'] ?? json['url'],
      metadata: json['metadata'] ?? json['data'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'image_url': _image,
      'action_url': actionUrl,
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
    String? image,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      image: image ?? _image,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Parse notification type from string
  static NotificationType _parseType(dynamic typeValue) {
    if (typeValue == null) return NotificationType.system;
    
    final typeStr = typeValue.toString().toLowerCase();
    
    if (typeStr.contains('order')) return NotificationType.order;
    if (typeStr.contains('promo') || typeStr.contains('sale') || typeStr.contains('offer')) {
      return NotificationType.promotion;
    }
    if (typeStr.contains('pay') || typeStr.contains('transaction')) {
      return NotificationType.payment;
    }
    
    return NotificationType.system;
  }

  /// Parse datetime from various formats
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    
    if (value is DateTime) return value;
    
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    
    if (value is int) {
      // Unix timestamp (seconds or milliseconds)
      if (value > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    
    return DateTime.now();
  }

  /// Get formatted time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
