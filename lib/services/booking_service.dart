import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _bookings = [];

  List<Map<String, dynamic>> get bookings => List.unmodifiable(_bookings);

  Future<void> addBooking(Map<String, dynamic> service, int quantity, DateTime date, String time, double totalPrice) async {
    final user = FirebaseAuth.instance.currentUser;
    
    // Create local booking first
    final localBooking = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'serviceName': service['name'],
      'serviceIcon': service['icon'],
      'serviceColor': service['color'],
      'quantity': quantity,
      'date': date,
      'time': time,
      'totalPrice': totalPrice,
      'status': 'Scheduled',
      'bookedAt': DateTime.now(),
    };
    
    _bookings.insert(0, localBooking);
    // Added booking locally
    
    // Try to save to Firestore users collection if user is logged in
    if (user != null) {
      // User logged in
      
      // Booking data to add to user's document
      final bookingData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'booking',
        'serviceName': service['name'].toString(),
        'quantity': quantity,
        'serviceDate': Timestamp.fromDate(date),
        'serviceTime': time,
        'totalPrice': totalPrice,
        'status': 'Scheduled',
        'createdAt': Timestamp.now(),
      };

      try {
        // Adding booking to users collection
        
        // Add to bookings array in user's document
        await _firestore.collection('users').doc(user.uid).update({
          'bookings': FieldValue.arrayUnion([bookingData])
        });
        
        // SUCCESS! Booking added to user document
        localBooking['id'] = bookingData['id'] as String;
      } catch (e) {
        // FAILED to save booking
        
        // If update fails, try to create the field
        try {
          await _firestore.collection('users').doc(user.uid).set({
            'bookings': [bookingData]
          }, SetOptions(merge: true));
          // Created bookings field and added booking
        } catch (e2) {
          // Failed to create bookings field
        }
      }
    } else {
      // No user logged in
    }
  }

  Future<void> loadUserBookings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // No user logged in - clearing bookings
      _bookings.clear();
      return;
    }

    try {
      // Loading bookings from users collection
      
      // Get user document
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data();
        final bookingsArray = userData?['bookings'] as List<dynamic>? ?? [];
        
        // Found bookings in user document
        _bookings.clear();
        
        // Convert and sort locally
        final bookingsList = <Map<String, dynamic>>[];
        for (final bookingData in bookingsArray) {
          final booking = Map<String, dynamic>.from(bookingData);
          final processedBooking = {
            'id': booking['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            'serviceName': booking['serviceName'] ?? 'Unknown Service',
            'serviceIcon': _getIconFromString(''),
            'serviceColor': _getColorFromString(''),
            'quantity': booking['quantity'] ?? 1,
            'date': booking['serviceDate'] != null 
                ? (booking['serviceDate'] as Timestamp).toDate()
                : DateTime.now(),
            'time': booking['serviceTime'] ?? '9:00 AM',
            'totalPrice': booking['totalPrice'] ?? 0.0,
            'status': booking['status'] ?? 'Scheduled',
            'bookedAt': booking['createdAt'] != null 
                ? (booking['createdAt'] as Timestamp).toDate()
                : DateTime.now(),
          };
          bookingsList.add(processedBooking);
        }
        
        // Sort by booking date locally (newest first)
        bookingsList.sort((a, b) => (b['bookedAt'] as DateTime).compareTo(a['bookedAt'] as DateTime));
        _bookings.addAll(bookingsList);
        
        // Loaded bookings into local list
      } else {
        // User document does not exist
      }
    } catch (e) {
      // Error loading bookings from users collection
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final index = _bookings.indexWhere((booking) => booking['id'] == bookingId);
      if (index >= 0) {
        _bookings[index]['status'] = status;
      }
    } catch (e) {
      // Handle error silently
    }
  }

  dynamic _getIconFromString(String iconString) {
    // Return a default icon since we can't serialize IconData
    return 'cleaning_services_rounded';
  }

  dynamic _getColorFromString(String colorString) {
    // Return a default color since we can't serialize Color
    return Color(0xFF4ECDC4);
  }
}
