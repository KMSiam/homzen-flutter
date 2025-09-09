import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => List.unmodifiable(_cartItems);

  void addToCart(Map<String, String> grocery) {
    // Check if item already exists
    final existingIndex = _cartItems.indexWhere((item) => item['name'] == grocery['name']);
    
    if (existingIndex != -1) {
      // Increase quantity
      _cartItems[existingIndex]['quantity']++;
    } else {
      // Add new item
      _cartItems.add({
        'name': grocery['name']!,
        'price': grocery['price']!,
        'image': grocery['image']!,
        'quantity': 1,
      });
    }
    
    _saveCartToFirestore();
  }

  void removeFromCart(String itemName) {
    _cartItems.removeWhere((item) => item['name'] == itemName);
    _saveCartToFirestore();
  }

  void updateQuantity(String itemName, int quantity) {
    final index = _cartItems.indexWhere((item) => item['name'] == itemName);
    if (index != -1) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index]['quantity'] = quantity;
      }
    }
    _saveCartToFirestore();
  }

  void clearCart() {
    _cartItems.clear();
    _clearCartFromFirestore();
  }

  bool get isEmpty => _cartItems.isEmpty;
  int get itemCount => _cartItems.length;

  // Save cart to Firestore
  Future<void> _saveCartToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'cart': _cartItems.map((item) => Map<String, dynamic>.from(item)).toList(),
        'cartUpdatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
      
      print('✅ Cart saved to Firestore');
    } catch (e) {
      print('❌ Failed to save cart: $e');
    }
  }

  // Clear cart from Firestore
  Future<void> _clearCartFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'cart': FieldValue.delete(),
        'cartUpdatedAt': FieldValue.delete(),
      });
      
      print('✅ Cart cleared from Firestore');
    } catch (e) {
      print('❌ Failed to clear cart: $e');
    }
  }

  // Load cart from Firestore when user logs in
  Future<void> loadCartFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _cartItems.clear();
      return;
    }

    try {
      print('🛒 Loading cart from Firestore for user: ${user.uid}');
      
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data();
        final cartArray = userData?['cart'] as List<dynamic>? ?? [];
        
        print('Found ${cartArray.length} items in saved cart');
        _cartItems.clear();
        
        for (final itemData in cartArray) {
          final item = Map<String, dynamic>.from(itemData);
          _cartItems.add(item);
        }
        
        print('✅ Loaded ${_cartItems.length} items into cart');
      } else {
        print('No saved cart found');
      }
    } catch (e) {
      print('❌ Error loading cart: $e');
    }
  }
}
