import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aptimaster/core/theme/app_colors.dart';

class AppSnackbar {
  static void showTop({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor ?? AppColors.primary,
      colorText: textColor ?? AppColors.white,
      icon: icon != null
          ? Icon(icon, color: textColor ?? AppColors.white)
          : null,
      snackPosition: position,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 300),
      maxWidth: Get.width * 0.9,
      titleText: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(color: textColor ?? AppColors.white, fontSize: 14),
      ),
    );
  }

  static void showSuccess({
    required String title,
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    showTop(
      title: title,
      message: message,
      backgroundColor: AppColors.success,
      textColor: AppColors.white,
      icon: icon ?? Icons.check_circle,
      duration: duration,
    );
  }

  static void showError({
    required String title,
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 4),
  }) {
    showTop(
      title: title,
      message: message,
      backgroundColor: AppColors.error,
      textColor: AppColors.white,
      icon: icon ?? Icons.error,
      duration: duration,
    );
  }

  static void showWarning({
    required String title,
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    showTop(
      title: title,
      message: message,
      backgroundColor: AppColors.warning,
      textColor: AppColors.white,
      icon: icon ?? Icons.warning,
      duration: duration,
    );
  }

  static void showInfo({
    required String title,
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    showTop(
      title: title,
      message: message,
      backgroundColor: AppColors.info,
      textColor: AppColors.white,
      icon: icon ?? Icons.info,
      duration: duration,
    );
  }

  static void showCustom({
    required String title,
    required String message,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    showTop(
      title: title,
      message: message,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
      duration: duration,
    );
  }

  static void showBottom({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor ?? AppColors.primary,
      colorText: textColor ?? AppColors.white,
      icon: icon != null
          ? Icon(icon, color: textColor ?? AppColors.white)
          : null,
      snackPosition: SnackPosition.BOTTOM,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 300),
      maxWidth: Get.width * 0.9,
      titleText: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppColors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(color: textColor ?? AppColors.white, fontSize: 14),
      ),
    );
  }
}
