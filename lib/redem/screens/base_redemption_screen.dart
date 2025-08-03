import 'package:flutter/material.dart';
import '../pages/parent_redemption_page.dart';
import '../pages/child_redemption_page.dart';

class BaseRedemptionScreen extends StatefulWidget {
  final String userId;
  final bool isParent;
  final int? childStarBalance;

  const BaseRedemptionScreen({
    Key? key,
    required this.userId,
    required this.isParent,
    this.childStarBalance,
  }) : super(key: key);

  @override
  _BaseRedemptionScreenState createState() => _BaseRedemptionScreenState();
}

class _BaseRedemptionScreenState extends State<BaseRedemptionScreen>
    with TickerProviderStateMixin {
  bool _isParentMode = true;
  late AnimationController _toggleController;
  late Animation<double> _toggleAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _isParentMode = widget.isParent;
    
    // Toggle animation controller
    _toggleController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _toggleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _toggleController, curve: Curves.easeInOut),
    );

    // Slide animation controller
    _slideController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeInOut));

    if (!_isParentMode) {
      _toggleController.forward();
    }
  }

  @override
  void dispose() {
    _toggleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isParentMode = !_isParentMode;
    });

    // Animate the toggle
    if (_isParentMode) {
      _toggleController.reverse();
    } else {
      _toggleController.forward();
    }

    // Slide animation for smooth transition
    _slideAnimation = Tween<Offset>(
      begin: _isParentMode ? Offset(-1, 0) : Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeInOut));

    _slideController.reset();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FF),
      body: Column(
        children: [
          _buildHeader(),
          _buildToggleSwitch(),
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: _isParentMode 
                ? ParentRedemptionPage()
                : ChildRedemptionPage(
                    childId: widget.userId,
                    starBalance: widget.childStarBalance ?? 150,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6C63FF),
            Color(0xFF9C88FF),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _toggleAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          _isParentMode ? '👨‍👩‍👦' : '🧒',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: Text(
                          _isParentMode ? 'Parent Dashboard' : 'My Rewards',
                          key: ValueKey(_isParentMode),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: Text(
                          _isParentMode 
                            ? 'Manage rewards & approve requests' 
                            : 'Browse and request your rewards',
                          key: ValueKey('${_isParentMode}_subtitle'),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isParentMode && widget.childStarBalance != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.yellow, size: 16),
                        SizedBox(width: 4),
                        Text('${widget.childStarBalance}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_isParentMode) _toggleMode();
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isParentMode ? Color(0xFF6C63FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('👨‍👩‍👦', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text(
                      'Parent',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: _isParentMode ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isParentMode) _toggleMode();
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isParentMode ? Color(0xFF6C63FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🧒', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text(
                      'Child',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: !_isParentMode ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
