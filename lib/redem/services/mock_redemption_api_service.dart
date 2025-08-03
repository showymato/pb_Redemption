import 'dart:async';
import '../models/redemption_item.dart';
import '../models/redemption_request.dart';

class MockRedemptionApiService {
  // Mock data storage
  static List<RedemptionItem> _mockItems = [
    RedemptionItem(
      id: '1',
      name: 'Extra Screen Time',
      starsCost: 50,
      emoji: '📱',
      parentId: 'parent_1',
    ),
    RedemptionItem(
      id: '2', 
      name: 'Ice Cream Treat',
      starsCost: 30,
      emoji: '🍦',
      parentId: 'parent_1',
    ),
    RedemptionItem(
      id: '3',
      name: 'Movie Night',
      starsCost: 100,
      emoji: '🎬',
      parentId: 'parent_1',
    ),
    RedemptionItem(
      id: '4',
      name: 'Toy Shopping',
      starsCost: 200,
      emoji: '🧸',
      parentId: 'parent_1',
    ),
    RedemptionItem(
      id: '5',
      name: 'Pizza Party',
      starsCost: 80,
      emoji: '🍕',
      parentId: 'parent_1',
    ),
  ];

  static List<RedemptionRequest> _mockRequests = [
    // Add some initial requests for demo
  ];

  // Simulate network delay
  static Future<void> _delay() async {
    await Future.delayed(Duration(milliseconds: 800));
  }

  // Create redemption item
  static Future<bool> createRedemptionItem(RedemptionItem item) async {
    await _delay();
    try {
      final newItem = item.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      _mockItems.add(newItem);
      return true;
    } catch (e) {
      print('Error creating item: $e');
      return false;
    }
  }

  // Get redemption items
  static Future<List<RedemptionItem>> getRedemptionItems(String parentId) async {
    await _delay();
    return _mockItems
        .where((item) => item.parentId == parentId && item.isActive)
        .toList()
      ..sort((a, b) => a.starsCost.compareTo(b.starsCost));
  }

  // Create redemption request
  static Future<bool> createRedemptionRequest(String childId, String itemId) async {
    await _delay();
    try {
      final item = _mockItems.firstWhere(
        (item) => item.id == itemId,
        orElse: () => throw Exception('Item not found'),
      );
      
      // Check if there's already a pending request for this item
      final existingRequest = _mockRequests.any(
        (req) => req.childId == childId && 
                 req.itemId == itemId && 
                 req.status == 'pending'
      );
      
      if (existingRequest) {
        return false;
      }

      final newRequest = RedemptionRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        childId: childId,
        itemId: itemId,
        item: item,
        childName: _getChildName(childId),
        requestedAt: DateTime.now(),
        status: 'pending',
      );
      
      _mockRequests.add(newRequest);
      return true;
    } catch (e) {
      print('Error creating request: $e');
      return false;
    }
  }

  // Update redemption request status
  static Future<bool> updateRequestStatus(String requestId, String status) async {
    await _delay();
    try {
      final index = _mockRequests.indexWhere((req) => req.id == requestId);
      if (index != -1) {
        _mockRequests[index] = _mockRequests[index].copyWith(
          status: status,
          processedAt: DateTime.now(),
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating request: $e');
      return false;
    }
  }

  // Get redemption requests
  static Future<List<RedemptionRequest>> getRedemptionRequests({String? childId}) async {
    await _delay();
    if (childId != null) {
      return _mockRequests
          .where((req) => req.childId == childId)
          .toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    }
    return _mockRequests
      ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
  }

  // Delete redemption item
  static Future<bool> deleteRedemptionItem(String itemId) async {
    await _delay();
    try {
      _mockItems.removeWhere((item) => item.id == itemId);
      return true;
    } catch (e) {
      print('Error deleting item: $e');
      return false;
    }
  }

  // Helper method to get child name
  static String _getChildName(String childId) {
    final names = ['Alex', 'Emma', 'Noah', 'Olivia', 'Liam'];
    return names[childId.hashCode.abs() % names.length];
  }

  // Get child star balance (mock)
  static Future<int> getChildStarBalance(String childId) async {
    await _delay();
    return 150; // Mock balance
  }

  // Update child star balance (mock)
  static Future<bool> updateChildStarBalance(String childId, int newBalance) async {
    await _delay();
    return true; // Mock success
  }
}
