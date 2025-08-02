import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_loan/controllers/change_password_controller.dart';
import 'package:staff_loan/utils/app_colors.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => controller.resetForm(),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primaryPurple,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Password Requirements',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('• Password must be at least 8 characters long'),
                    const Text(
                      '• Use a combination of letters, numbers, and symbols',
                    ),
                    const Text(
                      '• New password must be different from current password',
                    ),
                    const Text(
                      '• Enter your current password for verification',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Password Form
            _buildPasswordForm(context, controller),

            const SizedBox(height: 30),

            // Change Password Button
            _buildChangePasswordButton(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordForm(
    BuildContext context,
    ChangePasswordController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Change Password',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryPurple,
          ),
        ),

        const SizedBox(height: 20),

        // Current Password Field
        Text(
          'Current Password *',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextField(
            controller: controller.currentPasswordController,
            obscureText: !controller.showCurrentPassword.value,
            decoration: InputDecoration(
              hintText: 'Enter your current password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: controller.toggleCurrentPasswordVisibility,
                icon: Icon(
                  controller.showCurrentPassword.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // New Password Field
        Text(
          'New Password *',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextField(
            controller: controller.newPasswordController,
            obscureText: !controller.showNewPassword.value,
            decoration: InputDecoration(
              hintText: 'Enter your new password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                onPressed: controller.toggleNewPasswordVisibility,
                icon: Icon(
                  controller.showNewPassword.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Confirm Password Field
        Text(
          'Confirm New Password *',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextField(
            controller: controller.confirmPasswordController,
            obscureText: !controller.showConfirmPassword.value,
            decoration: InputDecoration(
              hintText: 'Confirm your new password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.lock_reset),
              suffixIcon: IconButton(
                onPressed: controller.toggleConfirmPasswordVisibility,
                icon: Icon(
                  controller.showConfirmPassword.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          '* Required fields',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildChangePasswordButton(
    BuildContext context,
    ChangePasswordController controller,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Obx(
        () => ElevatedButton.icon(
          onPressed:
              controller.isLoading.value ? null : controller.changePassword,
          icon:
              controller.isLoading.value
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.lock_reset),
          label: Text(
            controller.isLoading.value ? 'Changing...' : 'Change Password',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
