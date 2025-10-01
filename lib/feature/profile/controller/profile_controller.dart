import 'package:aptimaster/core/services/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aptimaster/core/services/storage_service.dart';
import 'package:aptimaster/core/services/api_service.dart';
import 'package:aptimaster/core/services/test_statistics_service.dart';
import 'package:aptimaster/core/widgets/app_snackbar.dart';
import 'dart:io';

class ProfileController extends GetxController {
  final StorageService _storageService = StorageService.instance;
  final ApiService _apiService = ApiService();
  final TestStatisticsService _testStatsService =
      TestStatisticsService.instance;

  final RxBool _isLoading = false.obs;
  final RxString _userName = ''.obs;
  final RxString _userEmail = ''.obs;
  final RxString _userPhone = ''.obs;
  final RxString _userAvatar = ''.obs;
  final RxInt _testsTaken = 0.obs;
  final RxInt _questionsSolved = 0.obs;
  final RxDouble _accuracy = 0.0.obs;

  bool get isLoading => _isLoading.value;
  String get userName => _userName.value;
  String get userEmail => _userEmail.value;
  String get userPhone => _userPhone.value;
  String get userAvatar => _userAvatar.value;
  int get testsTaken => _testsTaken.value;
  int get questionsSolved => _questionsSolved.value;
  double get accuracy => _accuracy.value;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      _isLoading.value = true;

      // Load user data from storage
      final userId = await _storageService.getUserId();
      if (userId != null) {
        // Load user profile from API
        await _loadUserProfile(userId);

        // Load test statistics from local storage
        await _loadTestStatistics();
      }

      // Load local user preferences
      _loadLocalUserData();
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId/profile');
      if (response.statusCode == 200) {
        final userData = response.data;
        _userName.value = userData['name'] ?? '';
        _userEmail.value = userData['email'] ?? '';
        _userPhone.value = userData['phone'] ?? '';
        _userAvatar.value = userData['avatar'] ?? '';
        _testsTaken.value = userData['testsTaken'] ?? 0;
        _questionsSolved.value = userData['questionsSolved'] ?? 0;
        _accuracy.value = (userData['accuracy'] ?? 0.0).toDouble();
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  void _loadLocalUserData() {
    // Load any local user preferences
    // This can be expanded based on your needs
  }

  Future<void> _loadTestStatistics() async {
    try {
      final userId = await _storageService.getUserId() ?? 'anonymous';

      // Get comprehensive test statistics from backend
      final stats = await _testStatsService.getUserTestStatistics(userId);

      // Update the reactive variables with backend data
      _testsTaken.value = (stats['testsCompleted'] ?? 0) is int
          ? (stats['testsCompleted'] ?? 0) as int
          : (stats['testsCompleted'] ?? 0).toInt();
      _questionsSolved.value = (stats['totalQuestions'] ?? 0) is int
          ? (stats['totalQuestions'] ?? 0) as int
          : (stats['totalQuestions'] ?? 0).toInt();
      _accuracy.value = (stats['accuracy'] ?? 0.0) is double
          ? (stats['accuracy'] ?? 0.0) as double
          : (stats['accuracy'] ?? 0.0).toDouble();

      print('📊 Loaded test statistics from backend:');
      print('   - Tests attended: ${_testsTaken.value}');
      print('   - Questions attempted: ${_questionsSolved.value}');
      print('   - Accuracy: ${_accuracy.value.toStringAsFixed(2)}%');
    } catch (e) {
      print('Error loading test statistics from backend: $e');
      // No fallback - backend-only approach
      _testsTaken.value = 0;
      _questionsSolved.value = 0;
      _accuracy.value = 0.0;
    }
  }

  Future<void> rateApp() async {
    try {
      const url =
          'https://play.google.com/store/apps/details?id=com.aptimaster.app';
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppSnackbar.showError(
          title: 'Error',
          message: 'Could not open Play Store',
        );
      }
    } catch (e) {
      AppSnackbar.showError(
        title: 'Error',
        message: 'Failed to open Play Store',
      );
    }
  }

  Future<void> sendFeedback() async {
    _showFeedbackForm();
  }

  void _showFeedbackForm() {
    final feedbackController = TextEditingController();
    final subjectController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Get.theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Send Feedback',
                    style: Get.theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Get.theme.colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.close,
                      color: Get.theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Subject Field
              TextField(
                controller: subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  labelStyle: TextStyle(
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.subject,
                    color: Get.theme.colorScheme.primary,
                  ),
                  filled: true,
                  fillColor: Get.theme.colorScheme.surfaceVariant.withOpacity(
                    0.3,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Feedback Field
              TextField(
                controller: feedbackController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Your Feedback',
                  labelStyle: TextStyle(
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.feedback,
                    color: Get.theme.colorScheme.primary,
                  ),
                  filled: true,
                  fillColor: Get.theme.colorScheme.surfaceVariant.withOpacity(
                    0.3,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Send Button
              ElevatedButton(
                onPressed: () async {
                  if (feedbackController.text.trim().isEmpty) {
                    AppSnackbar.showError(
                      title: 'Error',
                      message: 'Please enter your feedback',
                    );
                    return;
                  }

                  // Check if user has email
                  if (_userEmail.value.isEmpty) {
                    AppSnackbar.showError(
                      title: 'Email Required',
                      message:
                          'Please update your email first in profile settings',
                    );
                    return;
                  }

                  final subject = subjectController.text.trim().isEmpty
                      ? 'AptiMaster Feedback'
                      : subjectController.text.trim();

                  final body =
                      'Feedback from AptiMaster App:\n\nUser: ${_userName.value}\nEmail: ${_userEmail.value}\n\nSubject: $subject\n\nMessage:\n${feedbackController.text.trim()}\n\n---\nSent from AptiMaster App';

                  try {
                    final Uri emailUri = Uri(
                      scheme: 'mailto',
                      path: 'dinesh@dhigrowth.com',
                      query:
                          'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
                    );

                    await launchUrl(emailUri);
                    Get.back();
                    AppSnackbar.showSuccess(
                      title: 'Success',
                      message:
                          'Email client opened. Please send the email to complete feedback.',
                    );
                  } catch (e) {
                    AppSnackbar.showError(
                      title: 'Error',
                      message: 'Failed to open email client',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Get.theme.colorScheme.primary,
                  foregroundColor: Get.theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Send Feedback',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void showAboutUs() {
    Get.dialog(
      AlertDialog(
        title: const Text('About AptiMaster'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'AptiMaster - Master Aptitude, Master Success',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'AptiMaster is a comprehensive aptitude preparation app designed to help you excel in interviews and competitive exams.',
              ),
              SizedBox(height: 16),
              Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Comprehensive question bank'),
              Text('• Multiple difficulty levels'),
              Text('• Detailed explanations'),
              Text('• Progress tracking'),
              Text('• Offline support'),
              SizedBox(height: 16),
              Text(
                'Version: 1.0.0',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void showPrivacyPolicy() {
    Get.dialog(
      AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Last updated: September 2024',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 16),
              Text(
                'Information We Collect',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Device information for notifications'),
              Text('• Usage statistics to improve the app'),
              Text('• Progress data to sync across devices'),
              SizedBox(height: 16),
              Text(
                'How We Use Your Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• To provide personalized learning experience'),
              Text('• To send important notifications'),
              Text('• To improve app performance'),
              SizedBox(height: 16),
              Text(
                'Data Security',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'We implement appropriate security measures to protect your personal information.',
              ),
              SizedBox(height: 16),
              Text('Contact Us', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                'For any privacy concerns, contact us at dinesh@dhigrowth.com',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> showMoreApps() async {
    try {
      const url = 'https://play.google.com/store/apps/developer?id=AptiMaster';
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppSnackbar.showInfo(
          title: 'More Apps',
          message: 'Visit our developer page on Play Store',
        );
      }
    } catch (e) {
      AppSnackbar.showError(
        title: 'Error',
        message: 'Failed to open Play Store',
      );
    }
  }

  Future<void> shareApp() async {
    try {
      const text =
          'Check out AptiMaster - the best aptitude preparation app! '
          'Master your skills and ace your exams. '
          'Download now: https://play.google.com/store/apps/details?id=com.aptimaster.app';

      await Share.share(text);
    } catch (e) {
      AppSnackbar.showError(title: 'Error', message: 'Failed to share app');
    }
  }

  void showEditProfileSheet() {
    final nameController = TextEditingController(text: _userName.value);
    final emailController = TextEditingController(text: _userEmail.value);
    final phoneController = TextEditingController(text: _userPhone.value);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Get.theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Profile',
                    style: Get.theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Get.theme.colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.close,
                      color: Get.theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Profile Picture Section
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showImagePickerSheet(),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Get.theme.colorScheme.primary.withOpacity(
                              0.3,
                            ),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Get.theme.colorScheme.shadow.withOpacity(
                                0.1,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Get.theme.colorScheme.surfaceVariant,
                          backgroundImage: _userAvatar.value.isNotEmpty
                              ? NetworkImage(
                                  '${ApiEndpoints.imageUrl}/${_userAvatar.value}',
                                )
                              : null,
                          child: _userAvatar.value.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Get.theme.colorScheme.onSurfaceVariant,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showImagePickerSheet(),
                      icon: Icon(
                        Icons.camera_alt,
                        color: Get.theme.colorScheme.onPrimary,
                      ),
                      label: Text(
                        'Change Profile Picture',
                        style: TextStyle(
                          color: Get.theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Name Field
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.person,
                    color: Get.theme.colorScheme.primary,
                  ),
                  filled: true,
                  fillColor: Get.theme.colorScheme.surfaceVariant.withOpacity(
                    0.3,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Email Field
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.email,
                    color: Get.theme.colorScheme.primary,
                  ),
                  filled: true,
                  fillColor: Get.theme.colorScheme.surfaceVariant.withOpacity(
                    0.3,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Phone Field
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  labelStyle: TextStyle(
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Get.theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.phone,
                    color: Get.theme.colorScheme.primary,
                  ),
                  filled: true,
                  fillColor: Get.theme.colorScheme.surfaceVariant.withOpacity(
                    0.3,
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: () async {
                  await updateUserProfile(
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    phone: phoneController.text.trim(),
                  );
                  Get.back(); // Hide bottom sheet after successful update
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Get.theme.colorScheme.primary,
                  foregroundColor: Get.theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showImagePickerSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Get.theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Profile Picture',
                style: Get.theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Get.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Get.back();
                      _pickImage(ImageSource.camera);
                      Get.back();
                    },
                  ),
                  _buildImageOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Get.back();
                      _pickImage(ImageSource.gallery);
                      Get.back();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Get.theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Icon(icon, size: 40, color: Get.theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Get.theme.textTheme.bodyMedium?.copyWith(
              color: Get.theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        print('Image picked: ${image.path}');
        await _uploadImage(File(image.path));
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Error picking image: $e');
      AppSnackbar.showError(
        title: 'Error',
        message: 'Failed to pick image: $e',
      );
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      _isLoading.value = true;
      print('Starting image upload...');

      final userId = await _storageService.getUserId();
      if (userId == null) {
        print('No user ID found');
        AppSnackbar.showError(title: 'Error', message: 'User not found');
        return;
      }

      print('Uploading image for user: $userId');
      final result = await _apiService.uploadAvatar(userId, imageFile);

      if (result != null) {
        final fileName = result['fileName'];
        print('Upload successful, filename: $fileName');

        // Update local avatar value
        _userAvatar.value = fileName;

        // Update user profile in database with new avatar
        await updateUserProfile(avatar: fileName);
      } else {
        print('Upload failed - no result');
        AppSnackbar.showError(
          title: 'Error',
          message: 'Failed to upload image',
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
      AppSnackbar.showError(
        title: 'Error',
        message: 'Failed to upload image: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    try {
      _isLoading.value = true;
      print('Updating user profile...');

      final userId = await _storageService.getUserId();
      if (userId != null) {
        final response = await _apiService.put(
          '/users/$userId/profile',
          data: {
            if (name != null) 'name': name,
            if (email != null) 'email': email,
            if (phone != null) 'phone': phone,
            if (avatar != null) 'avatar': avatar,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );

        if (response.statusCode == 200) {
          // Update local data
          if (name != null) _userName.value = name;
          if (email != null) _userEmail.value = email;
          if (phone != null) _userPhone.value = phone;
          if (avatar != null) _userAvatar.value = avatar;

          AppSnackbar.showSuccess(
            title: 'Success',
            message: response.data['message'],
          );
        } else {
          print('Profile update failed with status: ${response.statusCode}');
          AppSnackbar.showError(
            title: 'Error',
            message: response.data['message'],
          );
        }
      } else {
        print('No user ID found for profile update');
        AppSnackbar.showError(title: 'Error', message: 'User not found');
      }
    } catch (e) {
      print('Error updating profile: $e');
      AppSnackbar.showError(
        title: 'Error',
        message: 'Failed to update profile: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
