import 'package:nopcommerce_mobile/constants/app_constants.dart';

class Product {
  final String name;
  final String shortDescription;
  final String? fullDescription;
  final String seName;
  final String? sku;
  final String productType;
  final bool markAsNew;
  final ProductPrice productPrice;
  final List<PictureModel> pictureModels;
  final ProductSpecificationModel productSpecificationModel;
  final ReviewOverviewModel reviewOverviewModel;
  final bool hasRequiredAttributes;
  final int id;
  final Map<String, dynamic> customProperties;

  Product({
    required this.name,
    required this.shortDescription,
    this.fullDescription,
    required this.seName,
    this.sku,
    required this.productType,
    required this.markAsNew,
    required this.productPrice,
    required this.pictureModels,
    required this.productSpecificationModel,
    required this.reviewOverviewModel,
    required this.hasRequiredAttributes,
    required this.id,
    required this.customProperties,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['Name']?.toString() ?? '',
      shortDescription: json['ShortDescription']?.toString() ?? '',
      fullDescription: json['FullDescription']?.toString(),
      seName: json['SeName']?.toString() ?? '',
      sku: json['Sku']?.toString(),
      productType: json['ProductType']?.toString() ?? '',
      markAsNew: json['MarkAsNew'] == true,
      productPrice: ProductPrice.fromJson(
          (json['ProductPrice'] ?? {}) as Map<String, dynamic>),
      pictureModels: (json['PictureModels'] as List<dynamic>? ?? [])
          .map((e) => PictureModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      productSpecificationModel: ProductSpecificationModel.fromJson(
          (json['ProductSpecificationModel'] ?? {}) as Map<String, dynamic>),
      reviewOverviewModel: ReviewOverviewModel.fromJson(
          (json['ReviewOverviewModel'] ?? {}) as Map<String, dynamic>),
      hasRequiredAttributes: json['HasRequiredAttributes'] == true,
      id: int.tryParse(json['Id']?.toString() ?? '0') ?? 0,
      customProperties: (json['CustomProperties'] ?? {}) as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'ShortDescription': shortDescription,
      'FullDescription': fullDescription,
      'SeName': seName,
      'Sku': sku,
      'ProductType': productType,
      'MarkAsNew': markAsNew,
      'ProductPrice': productPrice.toJson(),
      'PictureModels': pictureModels.map((e) => e.toJson()).toList(),
      'ProductSpecificationModel': productSpecificationModel.toJson(),
      'ReviewOverviewModel': reviewOverviewModel.toJson(),
      'HasRequiredAttributes': hasRequiredAttributes,
      'Id': id,
      'CustomProperties': customProperties,
    };
  }
}

class ProductPrice {
  final String? oldPrice;
  final double? oldPriceValue;
  final String? price;
  final double? priceValue;
  final String? basePricePAngV;
  final double? basePricePAngVValue;
  final bool disableBuyButton;
  final bool disableWishlistButton;
  final bool disableAddToCompareListButton;
  final bool availableForPreOrder;
  final String? preOrderAvailabilityStartDateTimeUtc;
  final bool isRental;
  final bool forceRedirectionAfterAddingToCart;
  final bool displayTaxShippingInfo;
  final Map<String, dynamic> customProperties;

  ProductPrice({
    this.oldPrice,
    this.oldPriceValue,
    this.price,
    this.priceValue,
    this.basePricePAngV,
    this.basePricePAngVValue,
    required this.disableBuyButton,
    required this.disableWishlistButton,
    required this.disableAddToCompareListButton,
    required this.availableForPreOrder,
    this.preOrderAvailabilityStartDateTimeUtc,
    required this.isRental,
    required this.forceRedirectionAfterAddingToCart,
    required this.displayTaxShippingInfo,
    required this.customProperties,
  });

  factory ProductPrice.fromJson(Map<String, dynamic> json) {
    return ProductPrice(
      oldPrice: json['OldPrice']?.toString(),
      oldPriceValue: (json['OldPriceValue'] is num)
          ? (json['OldPriceValue'] as num).toDouble()
          : double.tryParse(json['OldPriceValue']?.toString() ?? ''),
      price: json['Price']?.toString(),
      priceValue: (json['PriceValue'] is num)
          ? (json['PriceValue'] as num).toDouble()
          : double.tryParse(json['PriceValue']?.toString() ?? ''),
      basePricePAngV: json['BasePricePAngV']?.toString(),
      basePricePAngVValue: (json['BasePricePAngVValue'] is num)
          ? (json['BasePricePAngVValue'] as num).toDouble()
          : double.tryParse(json['BasePricePAngVValue']?.toString() ?? ''),
      disableBuyButton: json['DisableBuyButton'] == true,
      disableWishlistButton: json['DisableWishlistButton'] == true,
      disableAddToCompareListButton: json['DisableAddToCompareListButton'] == true,
      availableForPreOrder: json['AvailableForPreOrder'] == true,
      preOrderAvailabilityStartDateTimeUtc:
      json['PreOrderAvailabilityStartDateTimeUtc']?.toString(),
      isRental: json['IsRental'] == true,
      forceRedirectionAfterAddingToCart:
      json['ForceRedirectionAfterAddingToCart'] == true,
      displayTaxShippingInfo: json['DisplayTaxShippingInfo'] == true,
      customProperties: (json['CustomProperties'] ?? {}) as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'OldPrice': oldPrice,
      'OldPriceValue': oldPriceValue,
      'Price': price,
      'PriceValue': priceValue,
      'BasePricePAngV': basePricePAngV,
      'BasePricePAngVValue': basePricePAngVValue,
      'DisableBuyButton': disableBuyButton,
      'DisableWishlistButton': disableWishlistButton,
      'DisableAddToCompareListButton': disableAddToCompareListButton,
      'AvailableForPreOrder': availableForPreOrder,
      'PreOrderAvailabilityStartDateTimeUtc': preOrderAvailabilityStartDateTimeUtc,
      'IsRental': isRental,
      'ForceRedirectionAfterAddingToCart': forceRedirectionAfterAddingToCart,
      'DisplayTaxShippingInfo': displayTaxShippingInfo,
      'CustomProperties': customProperties,
    };
  }
}

class PictureModel {
  final String imageUrl;
  final String? thumbImageUrl;
  final String fullSizeImageUrl;
  final String title;
  final String alternateText;
  final int id;
  final Map<String, dynamic> customProperties;

  PictureModel({
    required this.imageUrl,
    this.thumbImageUrl,
    required this.fullSizeImageUrl,
    required this.title,
    required this.alternateText,
    required this.id,
    required this.customProperties,
  });

  factory PictureModel.fromJson(Map<String, dynamic> json) {
    return PictureModel(
      imageUrl: json['ImageUrl']?.toString() ?? '',
      thumbImageUrl: json['ThumbImageUrl']?.toString(),
      fullSizeImageUrl: json['FullSizeImageUrl']?.toString() ?? '',
      title: json['Title']?.toString() ?? '',
      alternateText: json['AlternateText']?.toString() ?? '',
      id: int.tryParse(json['Id']?.toString() ?? '0') ?? 0,
      customProperties: (json['CustomProperties'] ?? {}) as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ImageUrl': AppConstants.storeUrl+imageUrl,
      'ThumbImageUrl': thumbImageUrl,
      'FullSizeImageUrl': fullSizeImageUrl,
      'Title': title,
      'AlternateText': alternateText,
      'Id': id,
      'CustomProperties': customProperties,
    };
  }
}

class ProductSpecificationModel {
  final List<dynamic> groups;
  final Map<String, dynamic> customProperties;

  ProductSpecificationModel({
    required this.groups,
    required this.customProperties,
  });

  factory ProductSpecificationModel.fromJson(Map<String, dynamic> json) {
    return ProductSpecificationModel(
      groups: (json['Groups'] as List<dynamic>? ?? []),
      customProperties: (json['CustomProperties'] ?? {}) as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Groups': groups,
      'CustomProperties': customProperties,
    };
  }
}

class ReviewOverviewModel {
  final int productId;
  final int ratingSum;
  final int totalReviews;
  final bool allowCustomerReviews;
  final bool canAddNewReview;
  final bool canCurrentCustomerLeaveReview;
  final Map<String, dynamic> customProperties;

  ReviewOverviewModel({
    required this.productId,
    required this.ratingSum,
    required this.totalReviews,
    required this.allowCustomerReviews,
    required this.canAddNewReview,
    required this.canCurrentCustomerLeaveReview,
    required this.customProperties,
  });

  factory ReviewOverviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewOverviewModel(
      productId: int.tryParse(json['ProductId']?.toString() ?? '0') ?? 0,
      ratingSum: int.tryParse(json['RatingSum']?.toString() ?? '0') ?? 0,
      totalReviews: int.tryParse(json['TotalReviews']?.toString() ?? '0') ?? 0,
      allowCustomerReviews: json['AllowCustomerReviews'] == true,
      canAddNewReview: json['CanAddNewReview'] == true,
      canCurrentCustomerLeaveReview: json['CanCurrentCustomerLeaveReview'] == true,
      customProperties: (json['CustomProperties'] ?? {}) as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ProductId': productId,
      'RatingSum': ratingSum,
      'TotalReviews': totalReviews,
      'AllowCustomerReviews': allowCustomerReviews,
      'CanAddNewReview': canAddNewReview,
      'CanCurrentCustomerLeaveReview': canCurrentCustomerLeaveReview,
      'CustomProperties': customProperties,
    };
  }
}
