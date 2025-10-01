import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aptimaster/core/services/localization_service.dart';
import 'package:aptimaster/core/services/storage_service.dart';
import 'package:aptimaster/core/services/translation_service.dart';
import 'package:aptimaster/core/theme/app_colors.dart';
import 'package:aptimaster/core/widgets/app_snackbar.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationService = Get.find<LocalizationService>();
    final storageService = StorageService.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.translate('select_language')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              AppTranslations.translate('language_subtitle'),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 24),

            // Current Language
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Text(
                    AppTranslations.translate('current_language'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    localizationService.currentLanguage.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    localizationService.currentLanguage.nativeName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Language List
            Expanded(
              child: ListView.builder(
                itemCount: localizationService.availableLanguages.length,
                itemBuilder: (context, index) {
                  final language =
                      localizationService.availableLanguages[index];
                  final isSelected =
                      language.code == localizationService.currentLanguage.code;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Text(
                        language.flag,
                        style: const TextStyle(fontSize: 32),
                      ),
                      title: Text(
                        language.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                      ),
                      subtitle: Text(
                        language.nativeName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 24,
                            )
                          : Icon(
                              Icons.radio_button_unchecked,
                              color: AppColors.textSecondary,
                              size: 24,
                            ),
                      onTap: () async {
                        if (!isSelected) {
                          // Change language
                          localizationService.changeLanguage(language);

                          // Save to storage
                          await storageService.setSelectedLanguage(
                            language.code,
                          );

                          // Show success message
                          AppSnackbar.showSuccess(
                            title: AppTranslations.translate('success'),
                            message:
                                '${AppTranslations.translate('language_changed')} ${language.nativeName}',
                            icon: Icons.language,
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppTranslations.translate('continue'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
