class ChargesModel {
  final String id;
  final String serviceType;
  final bool isPeakTime;
  final double baseFare;
  final double perKmRate;
  final double minimumFare;
  final double platformCommission;
  final double maxWeightKg;
  final double maxDistanceKm;
  final double gstPercentage;
  final double pickupRadiusKm;
  final String? createdAt;

  ChargesModel({
    required this.id,
    required this.serviceType,
    required this.isPeakTime,
    required this.baseFare,
    required this.perKmRate,
    required this.minimumFare,
    required this.platformCommission,
    required this.maxWeightKg,
    required this.maxDistanceKm,
    required this.gstPercentage,
    required this.pickupRadiusKm,
    this.createdAt,
  });

  factory ChargesModel.fromJson(Map<String, dynamic> json) {
    return ChargesModel(
      id: json['id']?.toString() ?? '',
      serviceType: json['service_type']?.toString() ?? '',
      isPeakTime: json['is_peak_time'] == true,
      baseFare: _toDouble(json['base_fare']),
      perKmRate: _toDouble(json['per_km_rate']),
      minimumFare: _toDouble(json['minimum_fare']),
      platformCommission: _toDouble(json['platform_commission']),
      maxWeightKg: _toDouble(json['max_weight_kg']),
      maxDistanceKm: _toDouble(json['max_distance_km']),
      gstPercentage: _toDouble(json['gst_percentage']),
      pickupRadiusKm: _toDouble(json['pickup_radius_km']),
      createdAt: json['created_at']?.toString(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_type': serviceType,
      'is_peak_time': isPeakTime,
      'base_fare': baseFare,
      'per_km_rate': perKmRate,
      'minimum_fare': minimumFare,
      'platform_commission': platformCommission,
      'max_weight_kg': maxWeightKg,
      'max_distance_km': maxDistanceKm,
      'gst_percentage': gstPercentage,
      'pickup_radius_km': pickupRadiusKm,
      'created_at': createdAt,
    };
  }
}
