import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_loan/utils/constants.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/profile_screen_controller.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();
    final profileController = Get.put(ProfileScreenController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => const EditProfileScreen());
            },
            icon: const Icon(Icons.edit),
          ),
          Obx(
            () => IconButton(
              onPressed:
                  () =>
                      profileController.isLoading.value
                          ? null
                          : profileController.refreshProfile(),
              icon:
                  profileController.isLoading.value
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => profileController.refreshProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Header
              Obx(() {
                if (profileController.isLoading.value) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Loading profile...'),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Obx(() {
                  final user = profileController.user.value;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          if (user?.image != null && user!.image!.isNotEmpty)
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: CachedNetworkImageProvider(
                                "${AppConstants.assetUrl}${user.image}",
                              ),
                            )
                          else
                            CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text(
                                (user?.name ?? 'U')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Text(
                            user?.name ?? 'User',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'user@example.com',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          if (user?.phone != null &&
                              user!.phone!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              user.phone!,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              (user?.role ?? 'user').toUpperCase(),
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              }),

              const SizedBox(height: 24),

              // Settings Section
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              // Theme Setting
              Card(
                child: Obx(
                  () => SwitchListTile(
                    title: Text(
                      'Dark Mode',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      themeController.isDarkMode.value
                          ? 'Currently using dark theme'
                          : 'Currently using light theme',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    value: themeController.isDarkMode.value,
                    onChanged: (value) => themeController.toggleTheme(),
                    secondary: Icon(
                      themeController.isDarkMode.value
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                  ),
                ),
              ),

              // Notifications Setting
              Card(
                child: SwitchListTile(
                  title: Text(
                    'Push Notifications',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    'Receive notifications for loan updates',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  value:
                      true, // This would be connected to a notifications controller
                  onChanged: (value) {
                    Get.snackbar(
                      'Notifications',
                      'Notification settings feature coming soon!',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  secondary: const Icon(Icons.notifications),
                ),
              ),

              const SizedBox(height: 24),

              // Account Section
              Text('Account', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),

              // Account Options
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: Text(
                        'Change Password',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        final result = await Get.to(
                          () => const ChangePasswordScreen(),
                        );

                        // Show success message if password was changed
                        if (result == true) {
                          Get.snackbar(
                            'Success',
                            'Password changed successfully',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green.withValues(
                              alpha: 0.9,
                            ),
                            colorText: Colors.white,
                          );
                        }
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.security),
                      title: Text(
                        'Security Settings',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Get.snackbar(
                          'Security',
                          'Security settings feature coming soon!',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: Text(
                        'Privacy Policy',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Get.snackbar(
                          'Privacy Policy',
                          'Privacy policy feature coming soon!',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await Get.dialog<bool>(
                      AlertDialog(
                        title: Text(
                          'Logout',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        content: Text(
                          'Are you sure you want to logout?',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(result: false),
                            child: Text(
                              'Cancel',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Get.back(result: true),
                            child: Text(
                              'Logout',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await authController.logout();
                      // Navigate back to login screen
                      Get.offAll(
                        () => const LoginScreen(),
                        transition: Transition.fadeIn,
                        duration: const Duration(milliseconds: 500),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ),

              const SizedBox(height: 16),

              // App Version
              Text(
                'Sammy Tech V1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
