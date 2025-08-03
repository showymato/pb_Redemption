import 'package:flutter/material.dart';
import '../models/redemption_item.dart';
import '../services/mock_redemption_api_service.dart';

class AddItemDialog extends StatefulWidget {
  final VoidCallback onItemAdded;

  const AddItemDialog({Key? key, required this.onItemAdded}) : super(key: key);

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _starsController = TextEditingController();
  final _emojiController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  // Predefined emoji suggestions
  final List<String> _emojiSuggestions = [
    '🍦', '🍕', '🎬', '📱', '🧸', '🎮', '📚', '🎨', '⚽', '🚲',
    '🍰', '🛍️', '🎪', '🎠', '🎯', '🎲', '🧩', '🪀', '🎸', '🎭'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _starsController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text('🎁 Add New Reward',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF6C63FF),
                      )
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey[400]),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                
                // Item Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    labelStyle: TextStyle(fontFamily: 'Poppins'),
                    hintText: 'e.g., Extra Screen Time',
                    hintStyle: TextStyle(fontFamily: 'Poppins'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF6C63FF)),
                    ),
                    prefixIcon: Icon(Icons.card_giftcard, color: Color(0xFF6C63FF)),
                  ),
                  style: TextStyle(fontFamily: 'Poppins'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Item name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                // Stars Cost and Emoji Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _starsController,
                        decoration: InputDecoration(
                          labelText: 'Stars Cost',
                          labelStyle: TextStyle(fontFamily: 'Poppins'),
                          hintText: '50',
                          hintStyle: TextStyle(fontFamily: 'Poppins'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF6C63FF)),
                          ),
                          prefixIcon: Icon(Icons.star, color: Colors.amber),
                        ),
                        style: TextStyle(fontFamily: 'Poppins'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Cost is required';
                          }
                          final cost = int.tryParse(value.trim());
                          if (cost == null) {
                            return 'Enter a valid number';
                          }
                          if (cost <= 0) {
                            return 'Cost must be greater than 0';
                          }
                          if (cost > 1000) {
                            return 'Cost cannot exceed 1000';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _emojiController,
                        decoration: InputDecoration(
                          labelText: 'Emoji',
                          labelStyle: TextStyle(fontFamily: 'Poppins'),
                          hintText: '🎁',
                          hintStyle: TextStyle(fontFamily: 'Poppins'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF6C63FF)),
                          ),
                          prefixIcon: Icon(Icons.emoji_emotions, color: Color(0xFF6C63FF)),
                        ),
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 18),
                        textAlign: TextAlign.center,
                        validator: (value) {
                          if (value != null && value.trim().length > 2) {
                            return 'Use only 1-2 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Emoji Suggestions
                Text('Quick Emoji Selection:',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey[600],
                  )
                ),
                SizedBox(height: 8),
                Container(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _emojiSuggestions.length,
                    itemBuilder: (context, index) {
                      final emoji = _emojiSuggestions[index];
                      return GestureDetector(
                        onTap: () {
                          _emojiController.text = emoji;
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 8),
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(emoji, style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                
                // Expiry Date Field
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Expiry Date (Optional)',
                      labelStyle: TextStyle(fontFamily: 'Poppins'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF6C63FF)),
                      ),
                      prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF6C63FF)),
                    ),
                    child: Text(
                      _selectedDate == null 
                          ? 'No expiry date' 
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: _selectedDate == null ? Colors.grey[600] : Colors.black,
                      ),
                    ),
                  ),
                ),
                if (_selectedDate != null) ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.orange),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Item will automatically expire on the selected date',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _selectedDate = null),
                        child: Text('Remove', 
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.red,
                          )
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
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
                        onPressed: _isLoading ? null : _addItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isLoading 
                          ? SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white, 
                                strokeWidth: 2
                              )
                            )
                          : Text('Add Item', 
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
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF6C63FF),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _addItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final item = RedemptionItem(
      id: '', // Will be set by service
      name: _nameController.text.trim(),
      starsCost: int.parse(_starsController.text.trim()),
      emoji: _emojiController.text.trim().isEmpty ? '🎁' : _emojiController.text.trim(),
      expiryDate: _selectedDate,
      parentId: 'parent_1', // Replace with actual parent ID
    );

    final success = await MockRedemptionApiService.createRedemptionItem(item);
    
    setState(() => _isLoading = false);
    
    if (success) {
      Navigator.pop(context);
      widget.onItemAdded();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text('✅', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text('Item added successfully!', 
                style: TextStyle(fontFamily: 'Poppins')
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text('❌', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text('Failed to add item. Please try again!', 
                style: TextStyle(fontFamily: 'Poppins')
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
      );
    }
  }
}
