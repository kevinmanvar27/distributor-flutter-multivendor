// My Invoices View
// Displays a list of user's invoices with professional UI

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dynamic_appbar.dart';
import '../../models/invoice_list.dart';
import 'my_invoices_controller.dart';

class MyInvoicesView extends GetView<MyInvoicesController> {
  const MyInvoicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: 'My Invoices',
        useGradient: true,
      ),
      body: Column(
        children: [
          // Status filter tabs
          _buildStatusTabs(),
          // Invoice list
          Expanded(
            child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.invoices.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshInvoices,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            itemCount: controller.invoices.length,
            itemBuilder: (context, index) {
              final invoice = controller.invoices[index];
              return _buildInvoiceCard(invoice);
            },
          ),
        );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs() {
    final statuses = ['all', 'draft', 'sent', 'paid', 'cancelled'];
    
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: AppTheme.shadowSm,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMD,
          vertical: AppTheme.spacingSM,
        ),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          
          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingSM),
            child: Obx(() {
              final isSelected = controller.selectedStatus.value == status;
              return _buildStatusChip(status, isSelected);
            }),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isSelected) {
    final statusColor = controller.getStatusColor(status);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.changeStatus(status),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? statusColor.withValues(alpha: 0.15)
                : AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected 
                  ? statusColor
                  : AppTheme.borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            controller.getStatusDisplayName(status),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected 
                  ? statusColor
                  : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: AppTheme.spacingMD),
          Text(
            'No Invoices Yet',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSM),
          Text(
            'Your order invoices will appear here',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(InvoiceItem invoice) {
    // Extract invoice data
    final invoiceNumber = invoice.invoiceNumber;
    final status = invoice.status;
    final totalAmount = invoice.totalAmount;
    final createdAt = invoice.createdAt;
    
    // Format date
    final dateStr = controller.formatDate(createdAt);
    
    // Get status color
    final statusColor = controller.getStatusColor(status);
    debugPrint("jijfcia${invoiceNumber}");
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.viewInvoiceDetail(invoice),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with invoice number and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(

                        'Invoice #$invoiceNumber',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSM),
                    _buildStatusBadge(status, statusColor),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSM),
                // Date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppTheme.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateStr,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSM),
                // Divider
                const Divider(height: 1),
                const SizedBox(height: AppTheme.spacingSM),
                // Total amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      controller.formatCurrencyFromString(totalAmount),
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
