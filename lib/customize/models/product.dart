class Product {
  final int id;
  final String name;
  final String? shortDescription;
  final double price;
  final String? defaultPictureUrl;

  Product({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.price,
    required this.defaultPictureUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['Id'] ?? 0,
      name: json['Name'] ?? '',
      shortDescription: json['ShortDescription'], // may be null
      price: (json['Price'] ?? 0).toDouble(),
      defaultPictureUrl: json['DefaultPictureUrl'], // safe cast,
    );
  }
}
