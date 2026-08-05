class AdvertisementModel {
  final String id;
  final String title;
  final String imageUrl;
  final String? targetUrl;
  final bool isActive;
  final DateTime createdAt;

  AdvertisementModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.targetUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory AdvertisementModel.fromJson(Map<String, dynamic> json) {
    return AdvertisementModel(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image_url'],
      targetUrl: json['target_url'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'target_url': targetUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
