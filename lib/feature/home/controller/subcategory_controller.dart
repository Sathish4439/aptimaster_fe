import 'package:aptimaster/core/models/api_models.dart';
import 'package:aptimaster/core/services/aptitude_repository.dart';
import 'package:get/get.dart';

class SubcategoryController extends GetxController {
  final RxBool loading = false.obs;
  final RxString error = ''.obs;
  final RxList<SubcategoryModel> subcategories = <SubcategoryModel>[].obs;
  
  // Repository for API calls
  final AptitudeRepository _repository = AptitudeRepository();
  
  // Load subcategories for a specific category
  Future<void> loadSubcategories(String categoryId) async {
    try {
      loading.value = true;
      error.value = '';
      
      final subcategoriesList = await _repository.getSubcategories(categoryId);
      subcategories.value = subcategoriesList;
    } catch (e) {
      error.value = e.toString();
      print('Error loading subcategories: $e');
    } finally {
      loading.value = false;
    }
  }
  
  // Clear subcategories
  void clearSubcategories() {
    subcategories.clear();
    error.value = '';
  }
}
