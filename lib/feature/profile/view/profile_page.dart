import 'package:aptimaster/core/services/api_endpoints.dart';
import 'package:aptimaster/core/widgets/banner_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aptimaster/feature/profile/controller/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              // color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(
                Icons.edit,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
              onPressed: () => profileController.showEditProfileSheet(),
            ),
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.onSurface),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (profileController.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // User Data Card
                    _buildUserCard(profileController, theme),
                    const SizedBox(height: 24),

                    // Menu Items
                    _buildMenuSection(profileController, theme),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Banner Ad at bottom
            const BannerAdWidget(
              margin: EdgeInsets.only(bottom: 8),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildUserCard(ProfileController controller, ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Avatar
            GestureDetector(
              onTap: () => controller.showEditProfileSheet(),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: controller.userAvatar.isNotEmpty
                      ? NetworkImage(
                          '${ApiEndpoints.imageUrl}/${controller.userAvatar}',
                        )
                      : null,
                  child: controller.userAvatar.isEmpty
                      ? Icon(Icons.person, size: 70, color: Colors.white)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // User Name with Edit Icon
            Text(
              controller.userName.isNotEmpty
                  ? controller.userName
                  : 'AptiMaster User',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // User Email
            Text(
              controller.userEmail.isNotEmpty
                  ? controller.userEmail
                  : 'user@aptimaster.com',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '${controller.testsTaken}',
                  'Tests Taken',
                  theme,
                ),
                _buildStatItem(
                  '${controller.questionsSolved}',
                  'Questions Solved',
                  theme,
                ),
                _buildStatItem(
                  '${controller.accuracy.toStringAsFixed(1)}%',
                  'Accuracy',
                  theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            // color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(ProfileController controller, ThemeData theme) {
    return Column(
      children: [
        _buildMenuTile(
          icon: Icons.analytics_rounded,
          title: 'Statistics',
          subtitle: 'View your test performance',
          onTap: () => Get.toNamed('/statistics'),
          theme: theme,
        ),
        _buildMenuTile(
          icon: Icons.star_rate_rounded,
          title: 'Rate Now',
          subtitle: 'Rate us on Play Store',
          onTap: () => controller.rateApp(),
          theme: theme,
        ),
        _buildMenuTile(
          icon: Icons.feedback_rounded,
          title: 'Feedback',
          subtitle: 'Send us your feedback',
          onTap: () => controller.sendFeedback(),
          theme: theme,
        ),
        _buildMenuTile(
          icon: Icons.info_rounded,
          title: 'About Us',
          subtitle: 'Learn more about AptiMaster',
          onTap: () => controller.showAboutUs(),
          theme: theme,
        ),
        _buildMenuTile(
          icon: Icons.privacy_tip_rounded,
          title: 'Privacy Policy',
          subtitle: 'Read our privacy policy',
          onTap: () => controller.showPrivacyPolicy(),
          theme: theme,
        ),
        _buildMenuTile(
          icon: Icons.apps_rounded,
          title: 'More Apps',
          subtitle: 'Discover our other apps',
          onTap: () => controller.showMoreApps(),
          theme: theme,
        ),
        _buildMenuTile(
          icon: Icons.share_rounded,
          title: 'Share App',
          subtitle: 'Share AptiMaster with friends',
          onTap: () => controller.shareApp(),
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
