class NewProductDto {
  final int id;
  final String name;
  final String shortDescription;
  final String fullDescription;
  final double price;
  final double oldPrice;
  final int stockQuantity;
  final bool displayStockAvailability;
  final bool allowCustomerReviews;
  final int approvedRatingSum;
  final int approvedTotalReviews;
  final String? vendor;

  NewProductDto({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.fullDescription,
    required this.price,
    required this.oldPrice,
    required this.stockQuantity,
    required this.displayStockAvailability,
    required this.allowCustomerReviews,
    required this.approvedRatingSum,
    required this.approvedTotalReviews,
    this.vendor,
  });

  factory NewProductDto.fromJson(Map<String, dynamic> json) {
    return NewProductDto(
      id: json['Id'],
      name: json['Name'],
      shortDescription: json['ShortDescription'] ?? "",
      fullDescription: json['FullDescription'] ?? "",
      price: (json['Price'] as num).toDouble(),
      oldPrice: (json['OldPrice'] as num).toDouble(),
      stockQuantity: json['StockQuantity'],
      displayStockAvailability: json['DisplayStockAvailability'],
      allowCustomerReviews: json['AllowCustomerReviews'],
      approvedRatingSum: json['ApprovedRatingSum'],
      approvedTotalReviews: json['ApprovedTotalReviews'],
      vendor: json['Vendor'],
    );
  }
}

class NewProductModel {
  final NewProductDto dto;
  final String defaultPictureUrl;

  NewProductModel({
    required this.dto,
    required this.defaultPictureUrl,
  });

  factory NewProductModel.fromJson(Map<String, dynamic> json) {
    return NewProductModel(
      dto: NewProductDto.fromJson(json['dto']),
      defaultPictureUrl: json['DefaultPictureUrl'],
    );
  }
}
