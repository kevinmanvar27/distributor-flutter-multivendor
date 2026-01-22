// Notifications Controller
//
// Manages notifications state and operations:
// - Load notifications from API
// - Mark single notification as read
// - Mark all notifications as read
// - Delete notification
// - Get unread count

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/notification_model.dart';

/// Filter options for notifications
enum NotificationFilter { all, unread, read }

class NotificationsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // ─────────────────────────────────────────────────────────────────────────────
  // Reactive State
  // ─────────────────────────────────────────────────────────────────────────────

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<NotificationFilter> currentFilter = NotificationFilter.all.obs;

  // Unread count for badge
  final RxInt unreadCount = 0.obs;

  // ─────────────────────────────────────────────────────────────────────────────
  // Computed Properties
  // ─────────────────────────────────────────────────────────────────────────────

  /// Get filtered notifications based on current filter
  List<NotificationModel> get filteredNotifications {
    switch (currentFilter.value) {
      case NotificationFilter.unread:
        return notifications.where((n) => !n.isRead).toList();
      case NotificationFilter.read:
        return notifications.where((n) => n.isRead).toList();
      case NotificationFilter.all:
        return notifications.toList();
    }
  }

  bool get isEmpty => filteredNotifications.isEmpty;
  bool get hasUnread => notifications.any((n) => !n.isRead);

  // ─────────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Load Notifications
  // ─────────────────────────────────────────────────────────────────────────────

  /// Load notifications from API
  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      notifications.clear();
    }

    if (isLoading.value) return;

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final response = await _apiService.get('/notifications');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle different response formats
        List<dynamic> notificationsList;
        if (data is Map && data.containsKey('data')) {
          notificationsList = data['data'] as List? ?? [];
        } else if (data is List) {
          notificationsList = data;
        } else {
          notificationsList = [];
        }

        // Parse notifications
        notifications.value = notificationsList
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        // Update unread count
        _updateUnreadCount();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load notifications. Please try again.';
      // ignore: avoid_print
      print('NotificationsController.loadNotifications error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch unread count from API
  Future<void> fetchUnreadCount() async {
    try {
      final response = await _apiService.get('/notifications/unread-count');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('count')) {
          unreadCount.value = data['count'] as int? ?? 0;
        } else if (data is int) {
          unreadCount.value = data;
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('NotificationsController.fetchUnreadCount error: $e');
    }
  }

  /// Refresh notifications
  @override
  Future<void> refresh() async {
    await loadNotifications(refresh: true);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Filter Operations
  // ─────────────────────────────────────────────────────────────────────────────

  /// Change filter (local filtering only)
  void setFilter(NotificationFilter filter) {
    if (currentFilter.value == filter) return;
    currentFilter.value = filter;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Mark as Read Operations
  // ─────────────────────────────────────────────────────────────────────────────

  /// Mark a single notification as read
  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      final response = await _apiService.post(
        '/notifications/${notification.id}/mark-read',
      );

      if (response.statusCode == 200) {
        // Update local state
        final index = notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          notifications[index] = notification.copyWith(isRead: true);
          _updateUnreadCount();
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('NotificationsController.markAsRead error: $e');
      // Still update locally for better UX
      final index = notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        notifications[index] = notification.copyWith(isRead: true);
        _updateUnreadCount();
      }
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (!hasUnread) return;

    try {
      final response = await _apiService.post('/notifications/mark-all-read');

      if (response.statusCode == 200) {
        // Update all local notifications
        notifications.value = notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        _updateUnreadCount();
        
        _showSnackbar('Success', 'All notifications marked as read');
      }
    } catch (e) {
      // ignore: avoid_print
      print('NotificationsController.markAllAsRead error: $e');
      // Still update locally
      notifications.value = notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      _updateUnreadCount();
      _showSnackbar('Success', 'All notifications marked as read');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Delete Operations
  // ─────────────────────────────────────────────────────────────────────────────

  /// Delete a notification
  Future<void> deleteNotification(NotificationModel notification) async {
    try {
      final response = await _apiService.delete(
        '/notifications/${notification.id}',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Remove from local state
        notifications.removeWhere((n) => n.id == notification.id);
        _updateUnreadCount();
        _showSnackbar('Success', 'Notification deleted');
      }
    } catch (e) {
      // ignore: avoid_print
      print('NotificationsController.deleteNotification error: $e');
      // Still remove locally for better UX
      notifications.removeWhere((n) => n.id == notification.id);
      _updateUnreadCount();
      _showSnackbar('Success', 'Notification deleted');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Helper Methods
  // ─────────────────────────────────────────────────────────────────────────────

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
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
      duration: const Duration(seconds: 2),
    );
  }
}
