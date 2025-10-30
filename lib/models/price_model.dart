class PriceModel {
  final String? id;
  final String productName; // corresponds to Go 'Name'
  final String market;      // corresponds to Go 'Category'
  final String location;    // corresponds to Go 'Area'
  final double price;
  final bool isVerified;
  final String? imageUrl;   // corresponds to Go 'ImageURL'
  final String? dateReported; // corresponds to Go 'CreatedAt'

  PriceModel({
    this.id,
    required this.productName,
    required this.market,
    required this.location,
    required this.price,
    required this.isVerified,
    this.imageUrl,
    this.dateReported,
  });

  // ✅ Convert JSON from backend → Dart object
  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      id: json['_id'] ?? json['id'] ?? '',
      productName: json['name'] ?? json['productName'] ?? '',
      market: json['category'] ?? json['market'] ?? '',
      location: json['area'] ?? json['location'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      isVerified: json['isVerified'] ?? true, // default true since verified products
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      dateReported: json['createdAt'] ?? json['dateReported'] ?? '',
    );
  }

  // ✅ Convert Dart object → JSON (for posting to backend)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': productName,
      'category': market,
      'area': location,
      'price': price,
      'isVerified': isVerified,
      'image_url': imageUrl,
      'createdAt': dateReported,
    };
  }
}
