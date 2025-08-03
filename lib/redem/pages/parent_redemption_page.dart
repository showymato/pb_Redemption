import 'package:flutter/material.dart';
import '../models/redemption_item.dart';
import '../models/redemption_request.dart';
import '../services/mock_redemption_api_service.dart';
import '../widgets/add_item_dialog.dart';

class ParentRedemptionPage extends StatefulWidget {
  @override
  _ParentRedemptionPageState createState() => _ParentRedemptionPageState();
}

class _ParentRedemptionPageState extends State<ParentRedemptionPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<RedemptionItem> _items = [];
  List<RedemptionRequest> _pendingRequests = [];
  List<RedemptionRequest> _historyRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final items = await MockRedemptionApiService.getRedemptionItems('parent_1');
      final allRequests = await MockRedemptionApiService.getRedemptionRequests();
      
      setState(() {
        _items = items;
        _pendingRequests = allRequests.where((r) => r.status == 'pending').toList();
        _historyRequests = allRequests.where((r) => r.status != 'pending').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorMessage('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FF),
      appBar: AppBar(
        title: Text('🎁 Redemption Center', 
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF6C63FF)
          )
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF6C63FF),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFF6C63FF),
          labelStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          tabs: [
            Tab(
              icon: Icon(Icons.inventory_2), 
              text: 'Items (${_items.length})'
            ),
            Tab(
              icon: Icon(Icons.pending_actions), 
              text: 'Requests (${_pendingRequests.length})'
            ),
            Tab(
              icon: Icon(Icons.history), 
              text: 'History'
            ),
          ],
        ),
      ),
      body: _isLoading 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF6C63FF)),
                SizedBox(height: 16),
                Text('Loading...', 
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey[600]
                  )
                )
              ],
            ),
          )
        : TabBarView(
            controller: _tabController,
            children: [
              _buildItemsTab(),
              _buildRequestsTab(),
              _buildHistoryTab(),
            ],
          ),
      floatingActionButton: _tabController.index == 0 
        ? FloatingActionButton.extended(
            onPressed: _showAddItemDialog,
            backgroundColor: Color(0xFF6C63FF),
            label: Text('Add Item', 
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600
              )
            ),
            icon: Icon(Icons.add),
          )
        : null,
    );
  }

  Widget _buildItemsTab() {
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎁', style: TextStyle(fontSize: 80)),
            SizedBox(height: 16),
            Text('No rewards yet!',
              style: TextStyle(
                fontFamily: 'Poppins', 
                fontSize: 20, 
                fontWeight: FontWeight.w600,
                color: Color(0xFF6C63FF)
              )
            ),
            SizedBox(height: 8),
            Text('Add your first reward item',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins', 
                fontSize: 16, 
                color: Colors.grey[600]
              )
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddItemDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12)
              ),
              icon: Icon(Icons.add, color: Colors.white),
              label: Text('Add First Item', 
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.w600
                )
              ),
            )
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Color(0xFF6C63FF),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, index) => _buildItemCard(_items[index]),
      ),
    );
  }

  Widget _buildItemCard(RedemptionItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFFE6E6FA),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(item.emoji ?? '🎁', style: TextStyle(fontSize: 24)),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16
                    )
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text('${item.starsCost} stars',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                          fontSize: 14
                        )
                      ),
                    ],
                  ),
                  if (item.expiryDate != null) ...[
                    SizedBox(height: 4),
                    Text('Expires: ${item.expiryDate!.day}/${item.expiryDate!.month}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.orange,
                        fontSize: 12
                      )
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteItem(item.id);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(fontFamily: 'Poppins')),
                    ],
                  ),
                ),
              ],
              child: Icon(Icons.more_vert, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsTab() {
    if (_pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('⏰', style: TextStyle(fontSize: 80)),
            SizedBox(height: 16),
            Text('No pending requests',
              style: TextStyle(
                fontFamily: 'Poppins', 
                fontSize: 20, 
                fontWeight: FontWeight.w600,
                color: Color(0xFF6C63FF)
              )
            ),
            Text('Requests will appear here',
              style: TextStyle(
                fontFamily: 'Poppins', 
                fontSize: 16, 
                color: Colors.grey[600]
              )
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Color(0xFF6C63FF),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _pendingRequests.length,
        itemBuilder: (context, index) => _buildRequestCard(_pendingRequests[index]),
      ),
    );
  }

  Widget _buildRequestCard(RedemptionRequest request) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFFB2EBF2),
                  child: Text(request.childName[0].toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Poppins', 
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800]
                    )
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${request.childName} wants:',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                          fontSize: 12
                        )
                      ),
                      Text(request.item.name,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16
                        )
                      ),
                    ],
                  ),
                ),
                Text(request.item.emoji ?? '🎁', style: TextStyle(fontSize: 24)),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text('${request.item.starsCost} stars',
                  style: TextStyle(
                    fontFamily: 'Poppins', 
                    color: Colors.grey[600]
                  )
                ),
                Spacer(),
                Text('${DateTime.now().difference(request.requestedAt).inHours}h ago',
                  style: TextStyle(
                    fontFamily: 'Poppins', 
                    color: Colors.grey[400], 
                    fontSize: 12
                  )
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveRequest(request),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)
                      ),
                    ),
                    icon: Icon(Icons.check),
                    label: Text('Approve', 
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600
                      )
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rejectRequest(request),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)
                      ),
                    ),
                    icon: Icon(Icons.close),
                    label: Text('Reject', 
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600
                      )
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_historyRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📜', style: TextStyle(fontSize: 80)),
            SizedBox(height: 16),
            Text('No history yet',
              style: TextStyle(
                fontFamily: 'Poppins', 
                fontSize: 20, 
                fontWeight: FontWeight.w600,
                color: Color(0xFF6C63FF)
              )
            ),
            Text('Approved/rejected requests will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins', 
                fontSize: 16, 
                color: Colors.grey[600]
              )
            )
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Color(0xFF6C63FF),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _historyRequests.length,
        itemBuilder: (context, index) {
          final request = _historyRequests[index];
          return Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border(left: BorderSide()),
            ),
            child: Row(
              children: [
                Icon(
                  request.status == 'approved' ? Icons.check_circle : Icons.cancel,
                  color: request.status == 'approved' ? Colors.green : Colors.red,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${request.childName} - ${request.item.name}',
                        style: TextStyle(
                          fontFamily: 'Poppins', 
                          fontWeight: FontWeight.w500
                        )
                      ),
                      Text('${request.status.toUpperCase()}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: request.status == 'approved' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600
                        )
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        Text('${request.item.starsCost}',
                          style: TextStyle(
                            fontFamily: 'Poppins', 
                            color: Colors.grey[600],
                            fontSize: 12
                          )
                        ),
                      ],
                    ),
                    if (request.processedAt != null)
                      Text('${DateTime.now().difference(request.processedAt!).inDays}d ago',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: Colors.grey[400]
                        )
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AddItemDialog(onItemAdded: _loadData),
    );
  }

  Future<void> _approveRequest(RedemptionRequest request) async {
    final success = await MockRedemptionApiService.updateRequestStatus(
      request.id, 'approved'
    );
    if (success) {
      _showSuccessMessage('🎉 Request Approved!');
      _loadData();
    } else {
      _showErrorMessage('Failed to approve request');
    }
  }

  Future<void> _rejectRequest(RedemptionRequest request) async {
    final success = await MockRedemptionApiService.updateRequestStatus(
      request.id, 'rejected'
    );
    if (success) {
      _showSuccessMessage('❌ Request Rejected');
      _loadData();
    } else {
      _showErrorMessage('Failed to reject request');
    }
  }

  Future<void> _deleteItem(String itemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Item?', style: TextStyle(fontFamily: 'Poppins')),
        content: Text('This action cannot be undone.', 
          style: TextStyle(fontFamily: 'Poppins')
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await MockRedemptionApiService.deleteRedemptionItem(itemId);
      if (success) {
        _showSuccessMessage('Item deleted');
        _loadData();
      } else {
        _showErrorMessage('Failed to delete item');
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
