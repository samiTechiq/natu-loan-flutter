import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_loan/controllers/profile_controller.dart';
import 'package:staff_loan/utils/app_colors.dart';
import 'package:staff_loan/utils/constants.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image Section
              _buildProfileImageSection(context, controller),

              const SizedBox(height: 30),

              // Form Fields
              _buildFormFields(context, controller),

              const SizedBox(height: 30),

              // Save Button
              _buildSaveButton(context, controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileImageSection(
    BuildContext context,
    ProfileController controller,
  ) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Obx(() {
                Widget imageWidget;

                if (controller.selectedImage.value != null) {
                  // Show selected image
                  imageWidget = CircleAvatar(
                    radius: 60,
                    backgroundImage: FileImage(controller.selectedImage.value!),
                  );
                } else if (controller.imageUrl.value.isNotEmpty) {
                  // Show existing profile image
                  imageWidget = CircleAvatar(
                    radius: 60,
                    backgroundImage: CachedNetworkImageProvider(
                      "${AppConstants.assetUrl}${controller.imageUrl.value}",
                    ),
                  );
                } else {
                  // Show placeholder
                  imageWidget = CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primaryPurple,
                    child: Text(
                      controller.nameController.text.isNotEmpty
                          ? controller.nameController.text
                              .substring(0, 1)
                              .toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryPurple,
                      width: 3,
                    ),
                  ),
                  child: imageWidget,
                );
              }),

              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    onPressed: controller.selectImage,
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (controller.selectedImage.value != null)
            TextButton.icon(
              onPressed: controller.removeSelectedImage,
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text(
                'Remove Selected Image',
                style: TextStyle(color: Colors.red),
              ),
            ),

          Text(
            'Tap camera icon to change profile picture',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(BuildContext context, ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryPurple,
          ),
        ),

        const SizedBox(height: 20),

        // Name Field
        Text(
          'Full Name *',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.nameController,
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.person),
          ),
          textCapitalization: TextCapitalization.words,
        ),

        const SizedBox(height: 20),

        // Email Field
        Text(
          'Email Address *',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.emailController,
          decoration: InputDecoration(
            hintText: 'Enter your email address',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 20),

        // Phone Field
        Text(
          'Phone Number',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.phoneController,
          decoration: InputDecoration(
            hintText: 'Enter your phone number',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
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

  Widget _buildSaveButton(BuildContext context, ProfileController controller) {
    return SizedBox(
      width: double.infinity,
      child: Obx(
        () => ElevatedButton.icon(
          onPressed:
              controller.isSaving.value ? null : controller.updateProfile,
          icon:
              controller.isSaving.value
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.save),
          label: Text(controller.isSaving.value ? 'Saving...' : 'Save Changes'),
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
