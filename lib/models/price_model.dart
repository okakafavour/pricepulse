class PriceModel {
  final String? id;
  final String productName;   // Go: "name"
  final String market;        // Go: "category"
  final String location;      // Go: "area"
  final double price;         // Go: "price"
  final bool isVerified;      // Go: "is_verified"
  final String? imageUrl;     // Go: "image_url"
  final String? dateReported; // Go: "created_at"

  PriceModel({
    this.id,
    required this.productName,
    required this.market,
    required this.location,
    required this.price,
    this.isVerified = false,
    this.imageUrl,
    this.dateReported,
  });

  // ✅ JSON → Dart
  factory PriceModel.fromJson(Map<String, dynamic> json) {
    double parsePrice(dynamic value) {
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return (value ?? 0).toDouble();
    }

    return PriceModel(
      id: json['_id'] ?? json['id'] ?? '',
      productName: json['name'] ?? json['productName'] ?? '',
      market: json['category'] ?? json['market'] ?? '',
      location: json['area'] ?? json['location'] ?? '',
      price: parsePrice(json['price']),
      isVerified: json['isVerified'] ?? json['is_verified'] ?? false,
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      dateReported: json['createdAt'] ?? json['created_at'] ?? '',
    );
  }

  // ✅ Dart → JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': productName,
      'category': market,
      'area': location,
      'price': price,
      'is_verified': isVerified,
      'image_url': imageUrl,
      'created_at': dateReported,
    };
  }
}
