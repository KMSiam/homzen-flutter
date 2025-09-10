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
      
      // Cart saved to Firestore
    } catch (e) {
      // Failed to save cart
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
      
      // Cart cleared from Firestore
    } catch (e) {
      // Failed to clear cart
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
      // Loading cart from Firestore
      
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data();
        final cartArray = userData?['cart'] as List<dynamic>? ?? [];
        
        // Found items in saved cart
        _cartItems.clear();
        
        for (final itemData in cartArray) {
          final item = Map<String, dynamic>.from(itemData);
          _cartItems.add(item);
        }
        
        // Loaded items into cart
      } else {
        // No saved cart found
      }
    } catch (e) {
      // Error loading cart
    }
  }
}
