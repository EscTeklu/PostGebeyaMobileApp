class Product {
  final String name;
  final String shortDescription;
  final String fullDescription;
  final String seName;
  final String sku;
  final String productType;
  final bool markAsNew;
  final ProductPrice productPrice;
  final List<PictureModel> pictureModels;
  final ProductSpecificationModel productSpecificationModel;
  final ReviewOverviewModel reviewOverviewModel;
  final bool hasRequiredAttributes;
  final int id;

  Product({
    required this.name,
    required this.shortDescription,
    required this.fullDescription,
    required this.seName,
    required this.sku,
    required this.productType,
    required this.markAsNew,
    required this.productPrice,
    required this.pictureModels,
    required this.productSpecificationModel,
    required this.reviewOverviewModel,
    required this.hasRequiredAttributes,
    required this.id,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    name: json['Name'],
    shortDescription: json['ShortDescription'],
    fullDescription: json['FullDescription'],
    seName: json['SeName'],
    sku: json['Sku'],
    productType: json['ProductType'],
    markAsNew: json['MarkAsNew'],
    productPrice: ProductPrice.fromJson(json['ProductPrice']),
    pictureModels: (json['PictureModels'] as List)
        .map((e) => PictureModel.fromJson(e))
        .toList(),
    productSpecificationModel:
    ProductSpecificationModel.fromJson(json['ProductSpecificationModel']),
    reviewOverviewModel:
    ReviewOverviewModel.fromJson(json['ReviewOverviewModel']),
    hasRequiredAttributes: json['HasRequiredAttributes'],
    id: json['Id'],
  );
}

class ProductPrice {
  final String? oldPrice;
  final double? oldPriceValue;
  final String price;
  final double priceValue;
  final String? basePricePAngV;
  final double basePricePAngVValue;
  final bool disableBuyButton;
  final bool disableWishlistButton;
  final bool disableAddToCompareListButton;
  final bool availableForPreOrder;
  final String? preOrderAvailabilityStartDateTimeUtc;
  final bool isRental;
  final bool forceRedirectionAfterAddingToCart;
  final bool displayTaxShippingInfo;

  ProductPrice({
    this.oldPrice,
    this.oldPriceValue,
    required this.price,
    required this.priceValue,
    this.basePricePAngV,
    required this.basePricePAngVValue,
    required this.disableBuyButton,
    required this.disableWishlistButton,
    required this.disableAddToCompareListButton,
    required this.availableForPreOrder,
    this.preOrderAvailabilityStartDateTimeUtc,
    required this.isRental,
    required this.forceRedirectionAfterAddingToCart,
    required this.displayTaxShippingInfo,
  });

  factory ProductPrice.fromJson(Map<String, dynamic> json) => ProductPrice(
    oldPrice: json['OldPrice'],
    oldPriceValue: json['OldPriceValue'],
    price: json['Price'],
    priceValue: json['PriceValue'],
    basePricePAngV: json['BasePricePAngV'],
    basePricePAngVValue: json['BasePricePAngVValue'],
    disableBuyButton: json['DisableBuyButton'],
    disableWishlistButton: json['DisableWishlistButton'],
    disableAddToCompareListButton: json['DisableAddToCompareListButton'],
    availableForPreOrder: json['AvailableForPreOrder'],
    preOrderAvailabilityStartDateTimeUtc:
    json['PreOrderAvailabilityStartDateTimeUtc'],
    isRental: json['IsRental'],
    forceRedirectionAfterAddingToCart:
    json['ForceRedirectionAfterAddingToCart'],
    displayTaxShippingInfo: json['DisplayTaxShippingInfo'],
  );
}

class PictureModel {
  final String imageUrl;
  final String? thumbImageUrl;
  final String fullSizeImageUrl;
  final String title;
  final String alternateText;
  final int id;

  PictureModel({
    required this.imageUrl,
    this.thumbImageUrl,
    required this.fullSizeImageUrl,
    required this.title,
    required this.alternateText,
    required this.id,
  });

  factory PictureModel.fromJson(Map<String, dynamic> json) => PictureModel(
    imageUrl: json['ImageUrl'],
    thumbImageUrl: json['ThumbImageUrl'],
    fullSizeImageUrl: json['FullSizeImageUrl'],
    title: json['Title'],
    alternateText: json['AlternateText'],
    id: json['Id'],
  );
}

class ProductSpecificationModel {
  final List<dynamic> groups;

  ProductSpecificationModel({required this.groups});

  factory ProductSpecificationModel.fromJson(Map<String, dynamic> json) =>
      ProductSpecificationModel(groups: json['Groups']);
}

class ReviewOverviewModel {
  final int productId;
  final int ratingSum;
  final int totalReviews;
  final bool allowCustomerReviews;
  final bool canAddNewReview;
  final bool canCurrentCustomerLeaveReview;

  ReviewOverviewModel({
    required this.productId,
    required this.ratingSum,
    required this.totalReviews,
    required this.allowCustomerReviews,
    required this.canAddNewReview,
    required this.canCurrentCustomerLeaveReview,
  });

  factory ReviewOverviewModel.fromJson(Map<String, dynamic> json) =>
      ReviewOverviewModel(
        productId: json['ProductId'],
        ratingSum: json['RatingSum'],
        totalReviews: json['TotalReviews'],
        allowCustomerReviews: json['AllowCustomerReviews'],
        canAddNewReview: json['CanAddNewReview'],
        canCurrentCustomerLeaveReview: json['CanCurrentCustomerLeaveReview'],
      );
}
