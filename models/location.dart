class PostLocation {
  final String id;
  final String name;
  final String? address;
  final double? latitude;
  final double? longitude;

  const PostLocation({
    required this.id,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory PostLocation.fromJson(Map<String, dynamic> json) {
    return PostLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}