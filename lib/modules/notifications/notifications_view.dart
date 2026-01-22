//
// Notifications Screen - Premium UI
// Full notifications screen with:
// - Premium gradient header
// - Filter tabs with dynamic colors
// - Notification list with pagination
// - Pull-to-refresh
// - Mark as read functionality
// - Premium empty/error states

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../models/notification_model.dart';
import 'notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium Gradient AppBar
          _buildSliverAppBar(),
          
          // Filter Tabs
          SliverToBoxAdapter(
            child: _buildFilterTabs(),
          ),
          
          // Notifications Content
          SliverFillRemaining(
            child: Obx(() {
              if (controller.isLoading.value && controller.notifications.isEmpty) {
                return _buildLoadingState();
              }

              if (controller.hasError.value && controller.notifications.isEmpty) {
                return _buildErrorState();
              }

              if (controller.isEmpty) {
                return _buildEmptyState();
              }

              return _buildNotificationsList();
            }),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Premium Sliver AppBar
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 60,
      floating: false,
      pinned: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        // Mark all as read button
        Obx(() => controller.hasUnread
            ? Container(
                margin: const EdgeInsets.only(right: AppTheme.spacingSm),
                child: TextButton.icon(
                  onPressed: controller.markAllAsRead,
                  icon: const Icon(Icons.done_all, color: Colors.white, size: 18),
                  label: Text(
                    'Mark All Read',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink()),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Text(
          'Notifications',
          style: AppTheme.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Filter Tabs - Premium Design
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() => Row(
        children: [
          _buildFilterChip(
            label: 'All',
            filter: NotificationFilter.all,
            count: controller.notifications.length,
            icon: Icons.all_inbox_outlined,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          _buildFilterChip(
            label: 'Unread',
            filter: NotificationFilter.unread,
            count: controller.unreadCount.value,
            icon: Icons.mark_email_unread_outlined,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          _buildFilterChip(
            label: 'Read',
            filter: NotificationFilter.read,
            count: controller.notifications.where((n) => n.isRead).length,
            icon: Icons.mark_email_read_outlined,
          ),
        ],
      )),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required NotificationFilter filter,
    required int count,
    required IconData icon,
  }) {
    final isSelected = controller.currentFilter.value == filter;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setFilter(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingSm,
            vertical: AppTheme.spacingMd,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AppTheme.dynamicPrimaryColor,
                      AppTheme.dynamicSecondaryColor,
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: isSelected 
                  ? Colors.transparent 
                  : AppTheme.borderColor.withValues(alpha: 0.5),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppTheme.dynamicPrimaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.dynamicPrimaryColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Loading State
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.dynamicPrimaryColor),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'Loading notifications...',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Notifications List
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildNotificationsList() {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: AppTheme.dynamicPrimaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
        itemCount: controller.filteredNotifications.length,
        itemBuilder: (context, index) {
          final notification = controller.filteredNotifications[index];
          return _buildNotificationTile(notification);
        },
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.horizontal,
      // Swipe right to mark as read (green background)
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppTheme.spacingLg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.successColor,
              AppTheme.successColor.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check, color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text(
              'Mark Read',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      // Swipe left to delete (red background)
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppTheme.spacingLg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.errorColor.withValues(alpha: 0.8),
              AppTheme.errorColor,
            ],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right - mark as read
          controller.markAsRead(notification);
          return false; // Don't dismiss, just mark as read
        } else {
          // Swipe left - delete
          controller.deleteNotification(notification);
          return true; // Dismiss the item
        }
      },
      child: InkWell(
        onTap: () => controller.markAsRead(notification),
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingXs,
          ),
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: notification.isRead 
                ? Colors.white 
                : AppTheme.dynamicPrimaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: notification.isRead
                  ? AppTheme.borderColor.withValues(alpha: 0.3)
                  : AppTheme.dynamicPrimaryColor.withValues(alpha: 0.2),
            ),
            boxShadow: notification.isRead
                ? null
                : [
                    BoxShadow(
                      color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              _buildNotificationIcon(notification),
              const SizedBox(width: AppTheme.spacingMd),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTheme.titleSmall.copyWith(
                              fontWeight: notification.isRead 
                                  ? FontWeight.w500 
                                  : FontWeight.w700,
                              color: notification.isRead
                                  ? AppTheme.textSecondary
                                  : AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            notification.timeAgo,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    
                    // Message
                    Text(
                      notification.message,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Unread indicator
              if (!notification.isRead) ...[
                const SizedBox(width: AppTheme.spacingSm),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.dynamicPrimaryColor,
                        AppTheme.dynamicSecondaryColor,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationModel notification) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.order:
        icon = Icons.local_shipping_outlined;
        color = AppTheme.dynamicPrimaryColor;
        break;
      case NotificationType.promotion:
        icon = Icons.local_offer_outlined;
        color = AppTheme.warningColor;
        break;
      case NotificationType.payment:
        icon = Icons.payment_outlined;
        color = AppTheme.successColor;
        break;
      case NotificationType.system:
        icon = Icons.notifications_outlined;
        color = AppTheme.textSecondary;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: 22,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Empty & Error States - Premium Design
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    String message;
    String subtitle;
    IconData icon;

    switch (controller.currentFilter.value) {
      case NotificationFilter.unread:
        message = 'All Caught Up!';
        subtitle = 'You have no unread notifications';
        icon = Icons.mark_email_read_outlined;
        break;
      case NotificationFilter.read:
        message = 'No Read Notifications';
        subtitle = 'Notifications you\'ve read will appear here';
        icon = Icons.mark_email_unread_outlined;
        break;
      case NotificationFilter.all:
        message = 'No Notifications Yet';
        subtitle = 'We\'ll notify you when something important happens';
        icon = Icons.notifications_none_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with gradient background
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.dynamicPrimaryColor.withValues(alpha: 0.1),
                    AppTheme.dynamicSecondaryColor.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              message,
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              subtitle,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            // Refresh hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.swipe_down_outlined,
                  size: 16,
                  color: AppTheme.textTertiary,
                ),
                const SizedBox(width: AppTheme.spacingXs),
                Text(
                  'Pull down to refresh',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon with gradient background
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.errorColor.withValues(alpha: 0.1),
                    AppTheme.errorColor.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppTheme.errorColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              'Failed to Load',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Unable to load notifications. Please try again.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXl),
            // Premium retry button
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.dynamicPrimaryColor,
                    AppTheme.dynamicSecondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: controller.refresh,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingXl,
                      vertical: AppTheme.spacingMd,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.refresh, color: Colors.white, size: 20),
                        const SizedBox(width: AppTheme.spacingSm),
                        Text(
                          'Retry',
                          style: AppTheme.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
