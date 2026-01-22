// OTP Verification View
//
// Screen for entering OTP received via email.
// Premium UI with gradient hero section and dynamic colors.
// StatefulWidget to fix keyboard focus issues.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import 'forgot_password_controller.dart';

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({super.key});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final ForgotPasswordController controller = Get.find<ForgotPasswordController>();
  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
    
    // Clear any previous messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.clearMessages();
    });
  }

  @override
  void dispose() {
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpValue => _otpControllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium Gradient Hero Section
          SliverToBoxAdapter(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.dynamicPrimaryColor,
                    AppTheme.dynamicPrimaryColor.withValues(alpha: 0.8),
                    AppTheme.dynamicSecondaryColor.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    // Back button
                    Positioned(
                      top: AppTheme.spacingMd,
                      left: AppTheme.spacingMd,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Get.back(),
                        ),
                      ),
                    ),
                    // Hero content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon container
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.mark_email_read,
                              size: 48,
                              color: AppTheme.dynamicPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingLg),
                          Text(
                            'Verify OTP',
                            style: AppTheme.headlineLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingXs),
                          Obx(() => Text(
                            'Code sent to ${controller.email.value}',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            textAlign: TextAlign.center,
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Form Section
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusXl),
                  topRight: Radius.circular(AppTheme.radiusXl),
                ),
              ),
              transform: Matrix4.translationValues(0, -24, 0),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppTheme.spacingMd),
                      // Info card
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.dynamicPrimaryColor.withValues(alpha: 0.1),
                              AppTheme.dynamicSecondaryColor.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(
                            color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppTheme.spacingSm),
                              decoration: BoxDecoration(
                                color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              ),
                              child: Icon(
                                Icons.timer_outlined,
                                color: AppTheme.dynamicPrimaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingMd),
                            Expanded(
                              child: Text(
                                'Enter the 6-digit verification code sent to your email.',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      // Error message
                      Obx(() {
                        if (controller.errorMessage.value.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          padding: const EdgeInsets.all(AppTheme.spacingMd),
                          margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                              color: AppTheme.errorColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppTheme.errorColor),
                              const SizedBox(width: AppTheme.spacingSm),
                              Expanded(
                                child: Text(
                                  controller.errorMessage.value,
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.errorColor,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: controller.clearError,
                                color: AppTheme.errorColor,
                              ),
                            ],
                          ),
                        );
                      }),
                      // Success message
                      Obx(() {
                        if (controller.successMessage.value.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          padding: const EdgeInsets.all(AppTheme.spacingMd),
                          margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                              color: AppTheme.successColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, color: AppTheme.successColor),
                              const SizedBox(width: AppTheme.spacingSm),
                              Expanded(
                                child: Text(
                                  controller.successMessage.value,
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.successColor,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: controller.clearSuccess,
                                color: AppTheme.successColor,
                              ),
                            ],
                          ),
                        );
                      }),
                      // OTP input fields - Premium styled
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 48,
                            child: TextFormField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: AppTheme.headingMedium.copyWith(
                                color: AppTheme.dynamicPrimaryColor,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: '',
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: AppTheme.spacingMd,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                  borderSide: BorderSide(
                                    color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                  borderSide: BorderSide(
                                    color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                  borderSide: BorderSide(
                                    color: AppTheme.dynamicPrimaryColor,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: _otpControllers[index].text.isNotEmpty
                                    ? AppTheme.dynamicPrimaryColor.withValues(alpha: 0.05)
                                    : Colors.white,
                              ),
                              onChanged: (value) {
                                setState(() {}); // Rebuild to update fill color
                                if (value.isNotEmpty && index < 5) {
                                  _focusNodes[index + 1].requestFocus();
                                } else if (value.isEmpty && index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '';
                                }
                                return null;
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: AppTheme.spacingXl),
                      // Verify OTP button - Premium gradient style
                      Obx(() => Container(
                        height: 56,
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
                              color: AppTheme.dynamicPrimaryColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            onTap: controller.isLoading.value
                                ? null
                                : () async {
                                    final otp = _otpValue;
                                    if (otp.length != 6) {
                                      controller.errorMessage.value = 'Please enter complete OTP';
                                      return;
                                    }
                                    final success = await controller.verifyOtp(otp);
                                    if (success) {
                                      Get.toNamed(Routes.resetPassword);
                                    }
                                  },
                            child: Center(
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.verified_user, color: Colors.white),
                                        const SizedBox(width: AppTheme.spacingSm),
                                        Text(
                                          'Verify OTP',
                                          style: AppTheme.bodyLarge.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      )),
                      const SizedBox(height: AppTheme.spacingLg),
                      // Resend OTP section
                      Obx(() => Container(
                        padding: const EdgeInsets.all(AppTheme.spacingMd),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(
                            color: AppTheme.borderColor,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.refresh,
                              size: 18,
                              color: controller.canResendOtp.value
                                  ? AppTheme.dynamicPrimaryColor
                                  : AppTheme.textTertiary,
                            ),
                            const SizedBox(width: AppTheme.spacingSm),
                            Text(
                              "Didn't receive the code?",
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: controller.canResendOtp.value
                                  ? () async {
                                      final success = await controller.resendOtp();
                                      if (success) {
                                        for (var c in _otpControllers) {
                                          c.clear();
                                        }
                                        _focusNodes[0].requestFocus();
                                      }
                                    }
                                  : null,
                              child: Text(
                                controller.canResendOtp.value
                                    ? 'Resend OTP'
                                    : 'Resend in ${controller.resendCooldown.value}s',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: controller.canResendOtp.value
                                      ? AppTheme.dynamicPrimaryColor
                                      : AppTheme.textTertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
