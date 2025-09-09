class CategoryService {
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  String? _selectedGroceryCategory;
  String? _selectedServiceCategory;

  void setGroceryCategory(String category) {
    _selectedGroceryCategory = category;
  }

  void setServiceCategory(String category) {
    _selectedServiceCategory = category;
  }

  String? getGroceryCategory() {
    final category = _selectedGroceryCategory;
    _selectedGroceryCategory = null; // Clear after use
    return category;
  }

  String? getServiceCategory() {
    final category = _selectedServiceCategory;
    _selectedServiceCategory = null; // Clear after use
    return category;
  }
}
