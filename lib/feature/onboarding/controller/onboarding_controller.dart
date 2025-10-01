import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aptimaster/core/services/storage_service.dart';

class OnboardingController extends GetxController {
  static OnboardingController get to => Get.find();

  final PageController pageController = PageController();
  final RxInt currentPageIndex = 0.obs;
  final RxBool isLastPage = false.obs;
  final StorageService _storageService = StorageService.instance;

  @override
  void onInit() {
    super.onInit();
  }

  void onPageChanged(int index) {
    currentPageIndex.value = index;
    isLastPage.value = index == 4; // Last page index
  }

  void nextPage() {
    if (currentPageIndex.value < 4) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (currentPageIndex.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipOnboarding() async {
    await _storageService.setOnboardingCompleted();
    Get.offAllNamed('/home');
  }

  void completeOnboarding() async {
    await _storageService.setOnboardingCompleted();
    Get.offAllNamed('/home');
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
