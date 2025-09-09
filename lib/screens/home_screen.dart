import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/booking_service.dart';
import 'service_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildPromoBanner(context),
              _buildQuickServices(context),
              _buildQuickGroceries(context),
              _buildFeaturedGroceries(context),
              _buildPopularServices(context),
              _buildRecentOrders(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: user != null 
                  ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
                  : null,
              builder: (context, snapshot) {
                String name = 'Guest';
                
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  name = data['name'] ?? 'Guest';
                } else if (user != null) {
                  name = user.displayName ?? 'Guest';
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $name!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Text(
                      'What do you need today?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
            ),
            child: const Icon(Icons.notifications_rounded, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    final banners = [
      {
        'title': '30% OFF',
        'subtitle': 'On your first grocery order',
        'emoji': '🛒',
        'colors': [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)],
        'type': 'grocery',
      },
      {
        'title': 'FREE Delivery',
        'subtitle': 'On orders above \$50',
        'emoji': '🚚',
        'colors': [const Color(0xFF4ECDC4), const Color(0xFF4ECDC4).withValues(alpha: 0.8)],
        'type': 'grocery',
      },
      {
        'title': '24/7 Service',
        'subtitle': 'Emergency repairs available',
        'emoji': '🔧',
        'colors': [const Color(0xFFFECA57), const Color(0xFFFECA57).withValues(alpha: 0.8)],
        'type': 'service',
      },
      {
        'title': 'Best Prices',
        'subtitle': 'Guaranteed lowest rates',
        'emoji': '💰',
        'colors': [const Color(0xFF45B7D1), const Color(0xFF45B7D1).withValues(alpha: 0.8)],
        'type': 'service',
      },
    ];

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return Container(
            width: 280,
            margin: EdgeInsets.only(right: index < banners.length - 1 ? 15 : 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: banner['colors'] as List<Color>,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (banner['colors'] as List<Color>)[0].withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        banner['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        banner['subtitle'] as String,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          final mainScreen = context.findAncestorStateOfType<MainScreenState>();
                          if (mainScreen != null) {
                            mainScreen.navigateToTab(
                                banner['type'] == 'grocery' ? 1 : 3
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Get Now',
                            style: TextStyle(
                              color: (banner['colors'] as List<Color>)[0],
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(banner['emoji'] as String, style: const TextStyle(fontSize: 40)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickServices(BuildContext context) {
    final quickServices = [
      {'name': 'Cleaning', 'icon': Icons.cleaning_services_rounded, 'color': const Color(0xFF4ECDC4), 'tab': 3, 'category': 'Cleaning'},
      {'name': 'Plumbing', 'icon': Icons.plumbing_rounded, 'color': const Color(0xFF45B7D1), 'tab': 3, 'category': 'Plumbing'},
      {'name': 'Electric', 'icon': Icons.electrical_services_rounded, 'color': const Color(0xFFFECA57), 'tab': 3, 'category': 'Electrical'},
      {'name': 'AC Repair', 'icon': Icons.ac_unit_rounded, 'color': const Color(0xFF96CEB4), 'tab': 3, 'category': 'AC Repair'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Services',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Row(
            children: quickServices.map((service) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    final mainScreen = context.findAncestorStateOfType<MainScreenState>();
                    if (mainScreen != null) {
                      mainScreen.navigateToTab(service['tab'] as int, category: service['category'] as String);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (service['color'] as Color).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            service['icon'] as IconData,
                            color: service['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          service['name'] as String,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickGroceries(BuildContext context) {
    final quickGroceries = [
      {'name': 'Fruits', 'icon': Icons.apple_rounded, 'color': const Color(0xFFFF6B6B), 'tab': 1, 'category': 'Fruits'},
      {'name': 'Vegetables', 'icon': Icons.eco_rounded, 'color': const Color(0xFF4ECDC4), 'tab': 1, 'category': 'Vegetables'},
      {'name': 'Dairy', 'icon': Icons.local_drink_rounded, 'color': const Color(0xFF45B7D1), 'tab': 1, 'category': 'Dairy'},
      {'name': 'Meat', 'icon': Icons.restaurant_rounded, 'color': const Color(0xFFFECA57), 'tab': 1, 'category': 'Meat'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Groceries',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Row(
            children: quickGroceries.map((grocery) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    final mainScreen = context.findAncestorStateOfType<MainScreenState>();
                    if (mainScreen != null) {
                      mainScreen.navigateToTab(grocery['tab'] as int, category: grocery['category'] as String);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (grocery['color'] as Color).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            grocery['icon'] as IconData,
                            color: grocery['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          grocery['name'] as String,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedGroceries(BuildContext context) {
    final groceries = [
      {'name': 'Organic Apples', 'price': '\$3.99/kg', 'image': '🍎', 'discount': '15% OFF'},
      {'name': 'Fresh Bananas', 'price': '\$2.49/kg', 'image': '🍌', 'discount': ''},
      {'name': 'Baby Carrots', 'price': '\$1.99/kg', 'image': '🥕', 'discount': '20% OFF'},
      {'name': 'Almond Milk', 'price': '\$4.99', 'image': '🥛', 'discount': '10% OFF'},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fresh Groceries (${groceries.length})',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              GestureDetector(
                onTap: () {
                  final mainScreen = context.findAncestorStateOfType<MainScreenState>();
                  if (mainScreen != null) {
                    mainScreen.navigateToTab(1);
                  }
                },
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: groceries.length,
              itemBuilder: (context, index) => _buildGroceryCard(context, groceries[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroceryCard(BuildContext context, Map<String, String> grocery) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: Text(grocery['image']!, style: const TextStyle(fontSize: 40)),
                ),
              ),
              if (grocery['discount']!.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      grocery['discount']!,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grocery['name']!,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  grocery['price']!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      CartService().addToCart(grocery);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${grocery['name']} added to cart!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularServices(BuildContext context) {
    final popularServices = [
      {
        'name': 'House Cleaning',
        'desc': 'Professional deep cleaning service',
        'icon': Icons.cleaning_services_rounded,
        'color': const Color(0xFF4ECDC4),
        'price': 'From \$25/hr',
        'rating': 4.9,
        'category': 'Cleaning',
        'image': '🏠'
      },
      {
        'name': 'AC Repair',
        'desc': 'Air conditioning repair and maintenance',
        'icon': Icons.ac_unit_rounded,
        'color': const Color(0xFF45B7D1),
        'price': 'From \$35/hr',
        'rating': 4.8,
        'category': 'Repair',
        'image': '❄️'
      },
      {
        'name': 'Plumbing',
        'desc': 'Professional plumbing services',
        'icon': Icons.plumbing_rounded,
        'color': const Color(0xFFFECA57),
        'price': 'From \$40/hr',
        'rating': 4.7,
        'category': 'Repair',
        'image': '🔧'
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Popular Services',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              GestureDetector(
                onTap: () {
                  final mainScreen = context.findAncestorStateOfType<MainScreenState>();
                  if (mainScreen != null) {
                    mainScreen.navigateToTab(3);
                  }
                },
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: popularServices.length,
              itemBuilder: (context, index) {
                final service = popularServices[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceDetailsScreen(service: service),
                      ),
                    );
                  },
                  child: Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: (service['color'] as Color).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(service['image']! as String, style: const TextStyle(fontSize: 24)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                service['name']! as String,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                  Text('${service['rating']}', style: const TextStyle(fontSize: 12)),
                                  const Spacer(),
                                  Text(
                                    service['price']! as String,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(BuildContext context) {
    final orders = OrderService().orders;
    final bookings = BookingService().bookings;
    
    // Get the most recent item (order or booking)
    Map<String, dynamic>? recentItem;
    bool isOrder = false;
    
    if (orders.isNotEmpty && bookings.isNotEmpty) {
      final recentOrder = orders.first;
      final recentBooking = bookings.first;
      
      if ((recentOrder['date'] as DateTime).isAfter(recentBooking['bookedAt'] as DateTime)) {
        recentItem = recentOrder;
        isOrder = true;
      } else {
        recentItem = recentBooking;
      }
    } else if (orders.isNotEmpty) {
      recentItem = orders.first;
      isOrder = true;
    } else if (bookings.isNotEmpty) {
      recentItem = bookings.first;
    }
    
    // Don't show section if no orders or bookings
    if (recentItem == null) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Orders',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      isOrder ? '🛒' : '🧹',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOrder 
                          ? 'Grocery Order (${(recentItem['items'] as List?)?.length ?? 0} items)'
                          : recentItem['serviceName'] ?? 'Service',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      Text(
                        '${recentItem['status'] ?? 'Processing'} • \$${(recentItem[isOrder ? 'total' : 'totalPrice'] ?? 0.0).toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      final mainScreen = context.findAncestorStateOfType<MainScreenState>();
                      if (mainScreen != null) {
                        mainScreen.navigateToTab(isOrder ? 1 : 3);
                      }
                    },
                    child: Text(
                      'Reorder',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
