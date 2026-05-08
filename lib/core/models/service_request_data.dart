class ServiceRequestData {
  final String id;
  final String clientName;
  final String categoryName;
  final String? serviceCategoryId;
  final String description;
  final String address;
  final DateTime serviceDate;
  final double? estimatedPrice;
  final double? finalPrice;
  final String status;
  final String? providerProfileId;
  final bool isPaid;
  final DateTime createdAt;

  const ServiceRequestData({
    required this.id,
    required this.clientName,
    required this.categoryName,
    required this.serviceCategoryId,
    required this.description,
    required this.address,
    required this.serviceDate,
    required this.estimatedPrice,
    required this.finalPrice,
    required this.status,
    required this.providerProfileId,
    required this.isPaid,
    required this.createdAt,
  });

  double get displayPrice =>
      (finalPrice ?? estimatedPrice ?? 0).toDouble();

  bool get isOpen => providerProfileId == null;

  factory ServiceRequestData.fromMap(Map<String, dynamic> map) {
    final category = map['service_categories'] as Map<String, dynamic>?;
    final addr = map['addresses'] as Map<String, dynamic>?;
    final client = map['client'] as Map<String, dynamic>?;

    return ServiceRequestData(
      id: map['id'] as String,
      clientName: client?['full_name'] as String? ?? '-',
      categoryName: category?['name'] as String? ?? '-',
      serviceCategoryId: map['service_category_id'] as String?,
      description: map['description'] as String? ?? '',
      address: addr?['formatted_address'] as String? ?? '-',
      serviceDate: DateTime.parse(
        map['service_date'] as String? ?? DateTime.now().toIso8601String(),
      ),
      estimatedPrice: (map['estimated_price'] as num?)?.toDouble(),
      finalPrice: (map['final_price'] as num?)?.toDouble(),
      status: map['status'] as String? ?? 'open',
      providerProfileId: map['provider_profile_id'] as String?,
      isPaid: map['is_paid'] as bool? ?? false,
      createdAt: DateTime.parse(
        map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
