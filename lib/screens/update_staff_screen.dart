import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/update_staff_controller.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

class UpdateStaffScreen extends StatelessWidget {
  final int staffId;
  final String staffName;
  final String staffEmail;
  final String staffPhone;
  final String? staffImageUrl;

  const UpdateStaffScreen({
    super.key,
    required this.staffId,
    required this.staffName,
    required this.staffEmail,
    required this.staffPhone,
    this.staffImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateStaffController());

    // Initialize with staff data
    controller.initializeStaffData(
      id: staffId,
      name: staffName,
      email: staffEmail,
      phone: staffPhone,
      imageUrl: staffImageUrl,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Staff'),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Image Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Obx(
                          () => Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient:
                                  controller.selectedImage.value != null ||
                                          controller
                                              .currentImageUrl
                                              .value
                                              .isNotEmpty
                                      ? null
                                      : LinearGradient(
                                        colors: [
                                          AppColors.primaryPurple.withValues(
                                            alpha: 0.1,
                                          ),
                                          AppColors.primaryPurple.withValues(
                                            alpha: 0.05,
                                          ),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                              border: Border.all(
                                color:
                                    controller.selectedImage.value != null ||
                                            controller
                                                .currentImageUrl
                                                .value
                                                .isNotEmpty
                                        ? AppColors.primaryPurple.withValues(
                                          alpha: 0.3,
                                        )
                                        : AppColors.primaryPurple.withValues(
                                          alpha: 0.5,
                                        ),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryPurple.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child:
                                controller.selectedImage.value != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(70),
                                      child: Image.file(
                                        controller.selectedImage.value!,
                                        fit: BoxFit.cover,
                                        width: 140,
                                        height: 140,
                                      ),
                                    )
                                    : controller
                                        .currentImageUrl
                                        .value
                                        .isNotEmpty
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(70),
                                      child: Image.network(
                                        '${AppConstants.assetUrl}/storage/${controller.currentImageUrl.value}',
                                        fit: BoxFit.cover,
                                        width: 140,
                                        height: 140,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.broken_image,
                                                size: 50,
                                                color: AppColors.primaryPurple
                                                    .withValues(alpha: 0.6),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Image not found',
                                                style: TextStyle(
                                                  color: AppColors.primaryPurple
                                                      .withValues(alpha: 0.7),
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    )
                                    : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 50,
                                          color: AppColors.primaryPurple
                                              .withValues(alpha: 0.6),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Add Photo',
                                          style: TextStyle(
                                            color: AppColors.primaryPurple
                                                .withValues(alpha: 0.7),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                        Obx(
                          () =>
                              controller.selectedImage.value != null ||
                                      controller
                                          .currentImageUrl
                                          .value
                                          .isNotEmpty
                                  ? Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.2,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        onPressed: controller.removeImage,
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  )
                                  : Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryPurple,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.2,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        onPressed: controller.pickImage,
                                        icon: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () =>
                          controller.selectedImage.value != null
                              ? Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.green.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'New Image Selected',
                                          style: TextStyle(
                                            color: Colors.green[700],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  FutureBuilder<int>(
                                    future:
                                        controller.selectedImage.value!
                                            .length(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        final sizeInBytes = snapshot.data!;
                                        final sizeInKB = (sizeInBytes / 1024)
                                            .toStringAsFixed(1);
                                        final sizeInMB = (sizeInBytes /
                                                (1024 * 1024))
                                            .toStringAsFixed(2);
                                        final displaySize =
                                            sizeInBytes > 1024 * 1024
                                                ? '$sizeInMB MB'
                                                : '$sizeInKB KB';

                                        return Text(
                                          displaySize,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 11,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ],
                              )
                              : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryPurple.withValues(
                                    alpha: 0.05,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primaryPurple.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ),
                                child: GestureDetector(
                                  onTap: controller.pickImage,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate_outlined,
                                        color: AppColors.primaryPurple,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Tap to change photo',
                                        style: TextStyle(
                                          color: AppColors.primaryPurple,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Name Field
              TextFormField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'Enter staff full name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: controller.validateName,
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address *',
                  hintText: 'Enter email address',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: controller.validateEmail,
              ),

              const SizedBox(height: 16),

              // Phone Field
              TextFormField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number *',
                  hintText: 'Enter phone number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: controller.validatePhone,
              ),

              const SizedBox(height: 16),

              // Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => TextFormField(
                      controller: controller.passwordController,
                      obscureText: !controller.isPasswordVisible.value,
                      decoration: InputDecoration(
                        labelText: 'Password (leave empty to keep current)',
                        hintText: 'Enter new password or leave empty',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: controller.togglePasswordVisibility,
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: controller.validatePassword,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 12),
                    child: Text(
                      'Leave empty to keep current password',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Update Button
              Obx(
                () => ElevatedButton(
                  onPressed:
                      controller.isLoading.value
                          ? null
                          : controller.updateStaff,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      controller.isLoading.value
                          ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Updating Staff...'),
                            ],
                          )
                          : const Text(
                            'Update Staff',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel Button
              OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryPurple),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Required fields note
              const Text(
                '* Required fields',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
