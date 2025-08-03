import 'package:flutter/material.dart';
import '../models/redemption_item.dart';
import '../models/redemption_request.dart';
import '../services/mock_redemption_api_service.dart';

class ChildRedemptionPage extends StatefulWidget {
  final String childId;
  final int starBalance;

  const ChildRedemptionPage({
    Key? key,
    required this.childId,
    required this.starBalance,
  }) : super(key: key);

  @override
  _ChildRedemptionPageState createState() => _ChildRedemptionPageState();
}

class _ChildRedemptionPageState extends State<ChildRedemptionPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<RedemptionItem> _availableItems = [];
  List<RedemptionRequest> _myRequests = [];
  bool _isLoading = true;
  int _currentStarBalance = 0;

  @override
  void initState() {
    super.initState();
    _currentStarBalance = widget.starBalance;
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final items = await MockRedemptionApiService.getRedemptionItems('parent_1');
      final requests = await MockRedemptionApiService.getRedemptionRequests(
        childId: widget.childId
      );
      
      setState(() {
        _availableItems = items.where((item) => 
          item.isActive && 
          (item.expiryDate == null || item.expiryDate!.isAfter(DateTime.now()))
        ).toList();
        _myRequests = requests;
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
        title: Text('🛍️ Reward Store', 
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF6C63FF)
          )
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber, Colors.orange],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text('$_currentStarBalance',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  )
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF6C63FF),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFF6C63FF),
          labelStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          tabs: [
            Tab(
              icon: Icon(Icons.store), 
              text: 'Store (${_availableItems.length})'
            ),
            Tab(
              icon: Icon(Icons.receipt_long), 
              text: 'My Requests (${_myRequests.length})'
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
                Text('Loading your rewards...', 
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
              _buildStoreTab(),
              _buildMyRequestsTab(),
            ],
          ),
    );
  }

  Widget _buildStoreTab() {
    if (_availableItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🏪', style: TextStyle(fontSize: 80)),
            SizedBox(height: 16),
            Text('Store is empty!',
              style: TextStyle(
                fontFamily: 'Poppins', 
                fontSize: 20, 
                fontWeight: FontWeight.w600,
                color: Color(0xFF6C63FF)
              )
            ),
            Text('Ask your parent to add some rewards 🎁',
              textAlign: TextAlign.center,
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
      child: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _availableItems.length,
        itemBuilder: (context, index) => _buildStoreItemCard(_availableItems[index]),
      ),
    );
  }

  Widget _buildStoreItemCard(RedemptionItem item) {
    final canAfford = _currentStarBalance >= item.starsCost;
    final hasActivePendingRequest = _myRequests.any((r) => 
      r.itemId == item.id && r.status == 'pending'
    );

    return GestureDetector(
      onTap: () => _showItemDetails(item),
      child: Container(
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Item emoji/icon
              Hero(
                tag: 'item_${item.id}',
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(0xFFE6E6FA),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(item.emoji ?? '🎁', style: TextStyle(fontSize: 28)),
                  ),
                ),
              ),
              SizedBox(height: 12),
              
              // Item name
              Text(item.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              
              // Star cost
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 14),
                    SizedBox(width: 4),
                    Text('${item.starsCost}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[800],
                        fontSize: 12,
                      )
                    ),
                  ],
                ),
              ),
              
              if (item.expiryDate != null) ...[
                SizedBox(height: 4),
                Text('⏰ ${item.expiryDate!.day}/${item.expiryDate!.month}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: Colors.orange,
                  )
                ),
              ],
              
              Spacer(),
              
              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: hasActivePendingRequest 
                    ? null 
                    : canAfford 
                      ? () => _requestItem(item) 
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasActivePendingRequest 
                      ? Colors.orange 
                      : canAfford 
                        ? Color(0xFF6C63FF) 
                        : Colors.grey[300],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)
                    ),
                    elevation: hasActivePendingRequest || canAfford ? 2 : 0,
                  ),
                  child: Text(
                    hasActivePendingRequest 
                      ? 'Pending ⏳' 
                      : canAfford 
                        ? 'Request 🛒' 
                        : 'Need ${item.starsCost - _currentStarBalance} ⭐',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: hasActivePendingRequest || canAfford 
                        ? Colors.white 
                        : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyRequestsTab() {
    final groupedRequests = {
      'pending': _myRequests.where((r) => r.status == 'pending').toList(),
      'approved': _myRequests.where((r) => r.status == 'approved').toList(),
      'rejected': _myRequests.where((r) => r.status == 'rejected').toList(),
    };

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Color(0xFF6C63FF),
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          if (groupedRequests['pending']!.isNotEmpty) ...[
            _buildSectionTitle('⏳ Pending Requests', Colors.orange),
            ...groupedRequests['pending']!.map(_buildRequestCard),
            SizedBox(height: 16),
          ],
          if (groupedRequests['approved']!.isNotEmpty) ...[
            _buildSectionTitle('✅ Approved', Colors.green),
            ...groupedRequests['approved']!.map(_buildRequestCard),
            SizedBox(height: 16),
          ],
          if (groupedRequests['rejected']!.isNotEmpty) ...[
            _buildSectionTitle('❌ Rejected', Colors.red),
            ...groupedRequests['rejected']!.map(_buildRequestCard),
            SizedBox(height: 16),
          ],
          if (_myRequests.isEmpty)
            Center(
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Text('📝', style: TextStyle(fontSize: 80)),
                  SizedBox(height: 16),
                  Text('No requests yet!',
                    style: TextStyle(
                      fontFamily: 'Poppins', 
                      fontSize: 20, 
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6C63FF)
                    )
                  ),
                  Text('Start browsing the store 🛍️',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins', 
                      fontSize: 16, 
                      color: Colors.grey[600]
                    )
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _tabController.animateTo(0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6C63FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)
                      ),
                    ),
                    icon: Icon(Icons.store, color: Colors.white),
                    label: Text('Browse Store', 
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontWeight: FontWeight.w600
                      )
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Text(title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: color,
            )
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(RedemptionRequest request) {
    Color statusColor = request.status == 'approved' 
        ? Colors.green 
        : request.status == 'rejected' 
          ? Colors.red 
          : Colors.orange;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide()),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(request.item.emoji ?? '🎁', style: TextStyle(fontSize: 24)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.item.name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  )
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(request.status.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        )
                      ),
                    ),
                    if (request.status == 'approved') ...[
                      SizedBox(width: 8),
                      Text('🎉', style: TextStyle(fontSize: 14)),
                    ] else if (request.status == 'rejected') ...[
                      SizedBox(width: 8),
                      Text('😔', style: TextStyle(fontSize: 14)),
                    ],
                  ],
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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber[800],
                    )
                  ),
                ],
              ),
              SizedBox(height: 2),
              Text('${DateTime.now().difference(request.requestedAt).inDays}d ago',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: Colors.grey[500]
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showItemDetails(RedemptionItem item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(
                tag: 'item_${item.id}',
                child: Text(item.emoji ?? '🎁', style: TextStyle(fontSize: 48)),
              ),
              SizedBox(height: 16),
              Text(item.name,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                )
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    SizedBox(width: 4),
                    Text('${item.starsCost} stars required',
                      style: TextStyle(
                        fontFamily: 'Poppins', 
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber[800],
                      )
                    ),
                  ],
                ),
              ),
              if (item.expiryDate != null) ...[
                SizedBox(height: 8),
                Text('⏰ Expires: ${item.expiryDate!.day}/${item.expiryDate!.month}/${item.expiryDate!.year}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.orange,
                    fontSize: 14
                  )
                ),
              ],
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', 
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey[600],
                        )
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentStarBalance >= item.starsCost 
                        ? () {
                            Navigator.pop(context);
                            _requestItem(item);
                          }
                        : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)
                        ),
                      ),
                      child: Text('Request', 
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestItem(RedemptionItem item) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF6C63FF)),
              SizedBox(height: 16),
              Text('Sending request...', 
                style: TextStyle(fontFamily: 'Poppins')
              ),
            ],
          ),
        ),
      ),
    );

    final success = await MockRedemptionApiService.createRedemptionRequest(
      widget.childId, 
      item.id
    );
    
    Navigator.pop(context); // Close loading dialog
    
    if (success) {
      _showSuccessAnimation('🎉 Request sent to parent!');
      _loadData();
    } else {
      _showErrorMessage('Failed to send request. Try again!');
    }
  }

  void _showSuccessAnimation(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🎉', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 16),
                  Text(message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16
                    )
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
