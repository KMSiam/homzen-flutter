import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/category_service.dart';
import '../main.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  String selectedCategory = 'All';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final categories = ['All', 'Fruits', 'Vegetables', 'Dairy', 'Meat'];
  
  @override
  void initState() {
    super.initState();
    // Check if a category was passed from home screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final category = CategoryService().getGroceryCategory();
      if (category != null) {
        setState(() {
          selectedCategory = category;
        });
      }
    });
  }
  
  final products = [
    {'name': 'Organic Apples', 'price': 3.99, 'rating': 4.8, 'category': 'Fruits', 'image': '🍎', 'discount': 15},
    {'name': 'Fresh Bananas', 'price': 2.49, 'rating': 4.6, 'category': 'Fruits', 'image': '🍌', 'discount': 0},
    {'name': 'Baby Carrots', 'price': 1.99, 'rating': 4.7, 'category': 'Vegetables', 'image': '🥕', 'discount': 20},
    {'name': 'Almond Milk', 'price': 4.99, 'rating': 4.5, 'category': 'Dairy', 'image': '🥛', 'discount': 10},
    {'name': 'Artisan Bread', 'price': 2.99, 'rating': 4.9, 'category': 'Dairy', 'image': '🍞', 'discount': 0},
    {'name': 'Farm Eggs', 'price': 3.49, 'rating': 4.8, 'category': 'Dairy', 'image': '🥚', 'discount': 5},
    {'name': 'Fresh Oranges', 'price': 2.99, 'rating': 4.7, 'category': 'Fruits', 'image': '🍊', 'discount': 0},
    {'name': 'Spinach Leaves', 'price': 1.49, 'rating': 4.6, 'category': 'Vegetables', 'image': '🥬', 'discount': 0},
    {'name': 'Ground Beef', 'price': 8.99, 'rating': 4.8, 'category': 'Meat', 'image': '🥩', 'discount': 15},
    {'name': 'Chicken Breast', 'price': 6.99, 'rating': 4.9, 'category': 'Meat', 'image': '🍗', 'discount': 10},
  ];

  List<Map<String, dynamic>> get filteredProducts {
    return products.where((product) {
      final matchesCategory = selectedCategory == 'All' || product['category'] == selectedCategory;
      final matchesSearch = searchQuery.isEmpty || 
          product['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          product['category'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryTabs(),
            Expanded(child: _buildProductGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fresh Groceries',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${filteredProducts.length} items available',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              // Navigate to cart screen
              final mainScreen = context.findAncestorStateOfType<MainScreenState>();
              if (mainScreen != null) {
                mainScreen.navigateToTab(2); // Navigate to cart tab
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
              ),
              child: Stack(
                children: [
                  const Icon(Icons.shopping_cart_rounded, size: 20),
                  if (CartService().itemCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${CartService().itemCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value;
            if (value.isNotEmpty) {
              selectedCategory = 'All';
            }
          });
        },
        decoration: const InputDecoration(
          hintText: 'Search groceries...',
          hintStyle: TextStyle(fontSize: 14),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey, size: 20),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
                if (category != 'All') {
                  searchQuery = '';
                  _searchController.clear(); // Clear search box when selecting category
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    final filtered = filteredProducts;
    
    if (filtered.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No products found', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildProductCard(filtered[index]),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: Text(product['image'], style: const TextStyle(fontSize: 32)),
                ),
              ),
              if (product['discount'] > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '-${product['discount']}%',
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '\$${product['price'].toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final groceryItem = {
                          'name': product['name'].toString(),
                          'price': '\$${product['price'].toStringAsFixed(2)}',
                          'image': product['image'].toString(),
                        };
                        CartService().addToCart(groceryItem);
                        setState(() {}); // Refresh to update cart count
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product['name']} added to cart!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
