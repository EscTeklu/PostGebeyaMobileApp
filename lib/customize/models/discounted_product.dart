/*
class DiscountedProduct {
  final DiscountedDto dto;
  final String defaultPictureUrl;

  DiscountedProduct({required this.dto, required this.defaultPictureUrl});

  factory DiscountedProduct.fromJson(Map<String, dynamic> json) {
    return DiscountedProduct(
      dto: DiscountedDto.fromJson(json['dto']),
      defaultPictureUrl: json['DefaultPictureUrl'],
    );
  }
}

class DiscountedDto {
  final int id;
  final String name;
  final String shortDescription;
  final String fullDescription;
  final double price;
  final double oldPrice;
  final int stockQuantity;

  DiscountedDto({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.fullDescription,
    required this.price,
    required this.oldPrice,
    required this.stockQuantity,
  });

  factory DiscountedDto.fromJson(Map<String, dynamic> json) {
    return DiscountedDto(
      id: json['Id'],
      name: json['Name'],
      shortDescription: json['ShortDescription'],
      fullDescription: json['FullDescription'],
      price: (json['Price'] as num).toDouble(),
      oldPrice: (json['OldPrice'] as num).toDouble(),
      stockQuantity: json['StockQuantity'],
    );
  }
}
*/
class DiscountProduct {
  final int id;
  final String name;
  final String? shortDescription;
  final String? fullDescription;
  final double price;
  final double oldPrice;
  final int stockQuantity;
  final bool displayStockAvailability;
  final bool allowCustomerReviews;
  final int approvedRatingSum;
  final int approvedTotalReviews;
  final String? vendor;
  final String? defaultPictureUrl;

  DiscountProduct({
    required this.id,
    required this.name,
    this.shortDescription,
    this.fullDescription,
    required this.price,
    required this.oldPrice,
    required this.stockQuantity,
    required this.displayStockAvailability,
    required this.allowCustomerReviews,
    required this.approvedRatingSum,
    required this.approvedTotalReviews,
    this.vendor,
    this.defaultPictureUrl,
  });

  factory DiscountProduct.fromJson(Map<String, dynamic> json) {
    final dto = json['dto'] ?? {};
    return DiscountProduct(
      id: dto['Id'] ?? 0,
      name: dto['Name'] ?? '',
      shortDescription: dto['ShortDescription'],
      fullDescription: dto['FullDescription'],
      price: (dto['Price'] ?? 0).toDouble(),
      oldPrice: (dto['OldPrice'] ?? 0).toDouble(),
      stockQuantity: dto['StockQuantity'] ?? 0,
      displayStockAvailability: dto['DisplayStockAvailability'] ?? false,
      allowCustomerReviews: dto['AllowCustomerReviews'] ?? false,
      approvedRatingSum: dto['ApprovedRatingSum'] ?? 0,
      approvedTotalReviews: dto['ApprovedTotalReviews'] ?? 0,
      vendor: dto['Vendor'],
      defaultPictureUrl: json['DefaultPictureUrl'],
    );
  }
}
