class RedemptionItem {
  final String id;
  final String name;
  final int starsCost;
  final String? imageUrl;
  final String? emoji;
  final DateTime? expiryDate;
  final String parentId;
  final bool isActive;

  RedemptionItem({
    required this.id,
    required this.name,
    required this.starsCost,
    this.imageUrl,
    this.emoji,
    this.expiryDate,
    required this.parentId,
    this.isActive = true,
  });

  factory RedemptionItem.fromJson(Map<String, dynamic> json) {
    return RedemptionItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      starsCost: json['stars_cost'] ?? 0,
      imageUrl: json['image_url'],
      emoji: json['emoji'],
      expiryDate: json['expiry_date'] != null 
          ? DateTime.tryParse(json['expiry_date']) 
          : null,
      parentId: json['parent_id'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stars_cost': starsCost,
      'image_url': imageUrl,
      'emoji': emoji,
      'expiry_date': expiryDate?.toIso8601String(),
      'parent_id': parentId,
      'is_active': isActive,
    };
  }

  RedemptionItem copyWith({
    String? id,
    String? name,
    int? starsCost,
    String? imageUrl,
    String? emoji,
    DateTime? expiryDate,
    String? parentId,
    bool? isActive,
  }) {
    return RedemptionItem(
      id: id ?? this.id,
      name: name ?? this.name,
      starsCost: starsCost ?? this.starsCost,
      imageUrl: imageUrl ?? this.imageUrl,
      emoji: emoji ?? this.emoji,
      expiryDate: expiryDate ?? this.expiryDate,
      parentId: parentId ?? this.parentId,
      isActive: isActive ?? this.isActive,
    );
  }
}
