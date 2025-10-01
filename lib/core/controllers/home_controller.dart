import 'package:get/get.dart';
import 'package:aptimaster/feature/home/model/aptitude_model.dart';
import 'package:aptimaster/core/models/api_models.dart';
import 'package:aptimaster/core/services/aptitude_repository.dart';
import 'package:aptimaster/core/services/notification_service.dart';
// Note: ProfileController import removed as refresh methods are no longer needed

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  final AptitudeRepository _repository = AptitudeRepository();

  final RxList<CategoryModel> _categories = <CategoryModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _errorMessage = ''.obs;
  var viewType = 'grid'.obs;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      // Initialize notifications when home screen loads
      final notificationService = Get.find<NotificationService>();
      await notificationService.initialize();
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final categories = await _repository.getAllCategories();
      _categories.value = categories;
    } catch (e) {
      _errorMessage.value = e.toString();
      print('Error loading categories: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void toggleCategoryExpansion(String categoryId) {
    final index = _categories.indexWhere((cat) => cat.id == categoryId);
    if (index != -1) {
      final category = _categories[index];
      _categories[index] = category.copyWith(isExpanded: !category.isExpanded);
    }
  }

  void expandAllCategories() {
    for (int i = 0; i < _categories.length; i++) {
      _categories[i] = _categories[i].copyWith(isExpanded: true);
    }
  }

  void collapseAllCategories() {
    for (int i = 0; i < _categories.length; i++) {
      _categories[i] = _categories[i].copyWith(isExpanded: false);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    _filterCategories();
  }

  void _filterCategories() {
    if (_searchQuery.value.isEmpty) {
      // Reload from API when search is cleared
      _loadCategories();
    } else {
      // Filter categories based on search query
      final filteredCategories = _categories.where((category) {
        return category.name.toLowerCase().contains(
              _searchQuery.value.toLowerCase(),
            ) ||
            (category.description?.toLowerCase().contains(
                  _searchQuery.value.toLowerCase(),
                ) ??
                false);
      }).toList();
      _categories.value = filteredCategories;
    }
  }

  void clearSearch() {
    _searchQuery.value = '';
    _loadCategories();
  }

  int getTotalQuestions() {
    // Since we don't have question counts in the main categories,
    // we'll return the total subcategories count as a proxy
    return _categories.fold(
      0,
      (sum, category) => sum + category.subcategoriesCount,
    );
  }

  int getTotalCategories() {
    return _categories.length;
  }

  int getTotalSubCategories() {
    return _categories.fold(
      0,
      (sum, category) => sum + category.subcategoriesCount,
    );
  }

  Future<void> refreshCategories() async {
    await _loadCategories();
  }

  void toggleViewType() {
    viewType.value = viewType.value == 'grid' ? 'list' : 'grid';
  }

  // Load subcategories for a specific category
  Future<List<SubcategoryModel>> loadSubcategories(String categoryId) async {
    try {
      return await _repository.getSubcategories(categoryId);
    } catch (e) {
      print('Error loading subcategories: $e');
      return [];
    }
  }

  // Refresh test statistics (call this when returning to home after completing a test)
  Future<void> refreshTestStatistics() async {
    try {
      // Note: Refresh functionality moved to TestStatisticsService
      // Statistics are now automatically updated when tests are completed
      print('Statistics are automatically managed by TestStatisticsService');
    } catch (e) {
      print('Error refreshing test statistics: $e');
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}