import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import 'my_orders_screen.dart';
import 'profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  bool _isCheckingOut = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: _cartService.isEmpty ? _buildEmptyCart() : _buildCartWithItems(),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some groceries to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Navigate to grocery screen
              final mainScreen = context.findAncestorStateOfType<MainScreenState>();
              if (mainScreen != null) {
                mainScreen.navigateToTab(1); // Navigate to grocery tab
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Start Shopping',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartWithItems() {
    final cartItems = _cartService.cartItems;
    
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: cartItems.length,
            itemBuilder: (context, index) => _buildCartItem(cartItems[index]),
          ),
        ),
        _buildCheckoutSection(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text(
            'My Cart',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade800,
            ),
          ),
          const Spacer(),
          Text(
            '${_cartService.itemCount} items',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(item['image'], style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  item['price'],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _cartService.updateQuantity(item['name'], item['quantity'] - 1);
                  });
                },
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '${item['quantity']}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _cartService.updateQuantity(item['name'], item['quantity'] + 1);
                  });
                },
                icon: const Icon(Icons.add_circle_outline),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _cartService.removeFromCart(item['name']);
                  });
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              Text(
                '\$${_calculateTotal().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Check if user is logged in
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  // Navigate to profile screen (guest mode) to login
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                  return;
                }

                setState(() => _isCheckingOut = true);
                
                final cartItems = _cartService.cartItems.map((item) => Map<String, dynamic>.from(item)).toList();
                final total = _calculateTotal();
                
                // Add order to order service
                await OrderService().addOrder(cartItems, total);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order placed successfully!'),
                    duration: Duration(seconds: 2),
                  ),
                );
                
                setState(() {
                  _cartService.clearCart();
                  _isCheckingOut = false;
                });
                
                // Navigate to My Orders screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyOrdersScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isCheckingOut
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Checkout',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    double total = 0;
    for (var item in _cartService.cartItems) {
      String priceStr = item['price'].replaceAll('\$', '').replaceAll('/kg', '');
      double price = double.tryParse(priceStr) ?? 0;
      total += price * item['quantity'];
    }
    return total;
  }
}
