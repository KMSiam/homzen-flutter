import 'package:flutter/material.dart';
import '../services/category_service.dart';
import 'service_details_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<Offset>> _slideAnimations;
  String selectedCategory = 'All';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final categories = ['All', 'Cleaning', 'Repair', 'Maintenance', 'Installation'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Check if a category was passed from home screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final category = CategoryService().getServiceCategory();
      if (category != null) {
        // Map home screen categories to service screen categories
        String mappedCategory = category;
        if (category == 'Plumbing' || category == 'Electrical' || category == 'AC Repair') {
          mappedCategory = 'Repair';
        }
        setState(() {
          selectedCategory = mappedCategory;
        });
      }
    });
    
    _slideAnimations = List.generate(
      6,
      (index) => Tween<Offset>(
        begin: Offset(0, 0.3 + (index * 0.1)),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutBack),
      )),
    );
    
    _animationController.forward();
  }
  
  final services = [
    {
      'name': 'House Cleaning',
      'desc': 'Professional deep cleaning service',
      'icon': Icons.cleaning_services_rounded,
      'color': const Color(0xFF4ECDC4),
      'price': 'From \$25/hr',
      'rating': 4.9,
      'category': 'Cleaning',
    },
    {
      'name': 'Plumbing',
      'desc': 'Expert plumbing repairs & installation',
      'icon': Icons.plumbing_rounded,
      'color': const Color(0xFF45B7D1),
      'price': 'From \$40/hr',
      'rating': 4.8,
      'category': 'Repair',
    },
    {
      'name': 'Electrician',
      'desc': 'Licensed electrical work & repairs',
      'icon': Icons.electrical_services_rounded,
      'color': const Color(0xFFFECA57),
      'price': 'From \$50/hr',
      'rating': 4.9,
      'category': 'Repair',
    },
    {
      'name': 'AC Repair',
      'desc': 'Air conditioning service & maintenance',
      'icon': Icons.ac_unit_rounded,
      'color': const Color(0xFF96CEB4),
      'price': 'From \$35/hr',
      'rating': 4.7,
      'category': 'Maintenance',
    },
    {
      'name': 'Carpenter',
      'desc': 'Furniture repair & custom woodwork',
      'icon': Icons.handyman_rounded,
      'color': const Color(0xFFFF6B6B),
      'price': 'From \$30/hr',
      'rating': 4.8,
      'category': 'Repair',
    },
    {
      'name': 'Pest Control',
      'desc': 'Safe & effective pest elimination',
      'icon': Icons.pest_control_rounded,
      'color': const Color(0xFF6C5CE7),
      'price': 'From \$45/visit',
      'rating': 4.6,
      'category': 'Maintenance',
    },
    {
      'name': 'TV Installation',
      'desc': 'Professional TV mounting service',
      'icon': Icons.tv_rounded,
      'color': const Color(0xFF74B9FF),
      'price': 'From \$60/job',
      'rating': 4.8,
      'category': 'Installation',
    },
    {
      'name': 'Window Cleaning',
      'desc': 'Crystal clear window cleaning',
      'icon': Icons.window_rounded,
      'color': const Color(0xFF00CEC9),
      'price': 'From \$20/hr',
      'rating': 4.7,
      'category': 'Cleaning',
    },
  ];

  List<Map<String, dynamic>> get filteredServices {
    return services.where((service) {
      final matchesCategory = selectedCategory == 'All' || service['category'] == selectedCategory;
      final matchesSearch = searchQuery.isEmpty || 
          service['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          service['category'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          service['desc'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
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
            Expanded(child: _buildServicesList()),
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
                'Services',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              Text(
                'Professional services at your doorstep',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
            ),
            child: const Icon(Icons.headset_mic_rounded, size: 20),
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
              selectedCategory = 'All'; // Clear category filter when searching
            }
          });
        },
        decoration: InputDecoration(
          hintText: 'Search services...',
          hintStyle: const TextStyle(fontSize: 14),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.grey, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildServicesList() {
    final filtered = filteredServices;
    
    if (filtered.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No services found', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return SlideTransition(
          position: index < _slideAnimations.length ? _slideAnimations[index] : _slideAnimations.last,
          child: _buildServiceCard(filtered[index], index),
        );
      },
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServiceDetailsScreen(service: service),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: service['color'].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    service['icon'],
                    color: service['color'],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            service['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                Text(
                                  '${service['rating']}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service['desc'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            service['price'],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
