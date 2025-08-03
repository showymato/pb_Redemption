import 'redemption_item.dart';

class RedemptionRequest {
  final String id;
  final String childId;
  final String itemId;
  final RedemptionItem item;
  final String childName;
  final DateTime requestedAt;
  final String status; // pending, approved, rejected
  final DateTime? processedAt;

  RedemptionRequest({
    required this.id,
    required this.childId,
    required this.itemId,
    required this.item,
    required this.childName,
    required this.requestedAt,
    required this.status,
    this.processedAt,
  });

  factory RedemptionRequest.fromJson(Map<String, dynamic> json) {
    return RedemptionRequest(
      id: json['id'] ?? '',
      childId: json['child_id'] ?? '',
      itemId: json['item_id'] ?? '',
      item: RedemptionItem.fromJson(json['item'] ?? {}),
      childName: json['child_name'] ?? '',
      requestedAt: DateTime.tryParse(json['requested_at'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'pending',
      processedAt: json['processed_at'] != null 
          ? DateTime.tryParse(json['processed_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'item_id': itemId,
      'item': item.toJson(),
      'child_name': childName,
      'requested_at': requestedAt.toIso8601String(),
      'status': status,
      'processed_at': processedAt?.toIso8601String(),
    };
  }

  RedemptionRequest copyWith({
    String? id,
    String? childId,
    String? itemId,
    RedemptionItem? item,
    String? childName,
    DateTime? requestedAt,
    String? status,
    DateTime? processedAt,
  }) {
    return RedemptionRequest(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      itemId: itemId ?? this.itemId,
      item: item ?? this.item,
      childName: childName ?? this.childName,
      requestedAt: requestedAt ?? this.requestedAt,
      status: status ?? this.status,
      processedAt: processedAt ?? this.processedAt,
    );
  }
}
