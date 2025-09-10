import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _orders = [];

  List<Map<String, dynamic>> get orders => List.unmodifiable(_orders);

  Future<void> addOrder(List<Map<String, dynamic>> cartItems, double total) async {
    // Starting addOrder process
    final user = FirebaseAuth.instance.currentUser;
    
    // Create local order first
    final localOrder = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'items': List.from(cartItems),
      'total': total,
      'date': DateTime.now(),
      'status': 'Processing',
    };
    
    _orders.insert(0, localOrder);
    // Added order locally
    
    // Try to save to Firestore users collection if user is logged in
    if (user != null) {
      // User logged in for order
      
      // Order data to add to user's document
      final orderData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'order',
        'items': List.from(cartItems),
        'totalAmount': total,
        'itemCount': cartItems.length,
        'status': 'Processing',
        'createdAt': Timestamp.now(),
      };

      try {
        // Adding order to users collection
        
        // Add to orders array in user's document
        await _firestore.collection('users').doc(user.uid).update({
          'orders': FieldValue.arrayUnion([orderData])
        });
        
        // SUCCESS! Order added to user document
        localOrder['id'] = orderData['id'] as String;
      } catch (e) {
        // FAILED to save order
        
        // If update fails, try to create the field
        try {
          await _firestore.collection('users').doc(user.uid).set({
            'orders': [orderData]
          }, SetOptions(merge: true));
          // Created orders field and added order
        } catch (e2) {
          // Failed to create orders field
        }
      }
    } else {
      // No user logged in for order
    }
  }

  Future<void> loadUserOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // No user logged in - clearing orders
      _orders.clear();
      return;
    }

    try {
      // Loading orders from users collection
      
      // Get user document
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data();
        final ordersArray = userData?['orders'] as List<dynamic>? ?? [];
        
        // Found orders in user document
        _orders.clear();
        
        // Convert and sort locally
        final ordersList = <Map<String, dynamic>>[];
        for (final orderData in ordersArray) {
          final order = Map<String, dynamic>.from(orderData);
          final processedOrder = {
            'id': order['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            'items': order['items'] ?? [],
            'total': order['totalAmount'] ?? 0.0,
            'status': order['status'] ?? 'Processing',
            'date': order['createdAt'] != null 
                ? (order['createdAt'] as Timestamp).toDate()
                : DateTime.now(),
          };
          ordersList.add(processedOrder);
        }
        
        // Sort by date locally (newest first)
        ordersList.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
        _orders.addAll(ordersList);
        
        // Loaded orders into local list
      } else {
        // User document does not exist
      }
    } catch (e) {
      // Error loading orders from users collection
    }
  }

  int get orderCount => _orders.length;

  double get totalSpent {
    return _orders.fold(0.0, (total, order) => total + (order['total'] as double));
  }
}
