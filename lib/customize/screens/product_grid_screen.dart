
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nopcommerce_mobile/customize/models/product_model.dart';

class ProductGridScreen extends StatefulWidget {
  @override
  _ProductGridScreenState createState() => _ProductGridScreenState();
}

class _ProductGridScreenState extends State<ProductGridScreen> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    // Simulate loading API data (replace with actual API call in production)
    loadProducts();
  }

  void loadProducts() {
    // Sample JSON data (in production, fetch from API)
    String jsonString = '''
    [
      {
        "Name": "Build your own computer",
        "ShortDescription": "Build it",
        "FullDescription": "<p>Fight back against cluttered workspaces...</p>",
        "SeName": "build-your-own-computer",
        "Sku": "COMP_CUST",
        "ProductType": "SimpleProduct",
        "MarkAsNew": true,
        "ProductPrice": {
          "OldPrice": null,
          "OldPriceValue": null,
          "Price": "\$1,200.00",
          "PriceValue": 1200.0000,
          "BasePricePAngV": null,
          "BasePricePAngVValue": 1200.0000,
          "DisableBuyButton": false,
          "DisableWishlistButton": false,
          "DisableAddToCompareListButton": false,
          "AvailableForPreOrder": false,
          "PreOrderAvailabilityStartDateTimeUtc": null,
          "IsRental": false,
          "ForceRedirectionAfterAddingToCart": false,
          "DisplayTaxShippingInfo": false,
          "CustomProperties": {}
        },
        "PictureModels": [
          {
            "ImageUrl": "https://956f998d7a21.ngrok-free.app/images/thumbs/0000080_build-your-own-computer_415.png",
            "ThumbImageUrl": null,
            "FullSizeImageUrl": "https://956f998d7a21.ngrok-free.app/images/thumbs/0000080_build-your-own-computer.png",
            "Title": "Show details for Build your own computer",
            "AlternateText": "Picture of Build your own computer",
            "Id": 0,
            "CustomProperties": {}
          }
        ],
        "ProductSpecificationModel": {
          "Groups": [],
          "CustomProperties": {}
        },
        "ReviewOverviewModel": {
          "ProductId": 1,
          "RatingSum": 5,
          "TotalReviews": 1,
          "AllowCustomerReviews": true,
          "CanAddNewReview": true,
          "CanCurrentCustomerLeaveReview": false,
          "CustomProperties": {}
        },
        "HasRequiredAttributes": true,
        "Id": 1,
        "CustomProperties": {}
      },
      {
        "Name": "HTC smartphone",
        "ShortDescription": "HTC - One (M8) 4G LTE Cell Phone with 32GB Memory - Gunmetal (Sprint)",
        "FullDescription": "<p><b>HTC One (M8) Cell Phone for Sprint:</b>...</p>",
        "SeName": "htc-smartphone",
        "Sku": "M8_HTC_5L",
        "ProductType": "SimpleProduct",
        "MarkAsNew": true,
        "ProductPrice": {
          "OldPrice": null,
          "OldPriceValue": null,
          "Price": "\$245.00",
          "PriceValue": 245.0000,
          "BasePricePAngV": null,
          "BasePricePAngVValue": 245.0000,
          "DisableBuyButton": false,
          "DisableWishlistButton": false,
          "DisableAddToCompareListButton": false,
          "AvailableForPreOrder": false,
          "PreOrderAvailabilityStartDateTimeUtc": null,
          "IsRental": false,
          "ForceRedirectionAfterAddingToCart": false,
          "DisplayTaxShippingInfo": false,
          "CustomProperties": {}
        },
        "PictureModels": [
          {
            "ImageUrl": "https://956f998d7a21.ngrok-free.app/images/thumbs/0000041_htc-smartphone_415.jpeg",
            "ThumbImageUrl": null,
            "FullSizeImageUrl": "https://956f998d7a21.ngrok-free.app/images/thumbs/0000041_htc-smartphone.jpeg",
            "Title": "Show details for HTC smartphone",
            "AlternateText": "Picture of HTC smartphone",
            "Id": 0,
            "CustomProperties": {}
          }
        ],
        "ProductSpecificationModel": {
          "Groups": [],
          "CustomProperties": {}
        },
        "ReviewOverviewModel": {
          "ProductId": 18,
          "RatingSum": 5,
          "TotalReviews": 1,
          "AllowCustomerReviews": true,
          "CanAddNewReview": true,
          "CanCurrentCustomerLeaveReview": false,
          "CustomProperties": {}
        },
        "HasRequiredAttributes": false,
        "Id": 18,
        "CustomProperties": {}
      }
    ]
    '''; // Truncated for brevity, include full JSON as needed

    List<dynamic> jsonData = jsonDecode(jsonString);
    setState(() {
      products = jsonData.map((json) => Product.fromJson(json)).toList();
    });
  }

  void showProductDetails(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (product.pictureModels.isNotEmpty)
                Image.network(
                  product.pictureModels[0].imageUrl,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 100),
                ),
              SizedBox(height: 10),
              Text('Price: ${product.productPrice.price}', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('Description: ${product.shortDescription}'),
              SizedBox(height: 10),
              Text('Rating: ${product.reviewOverviewModel.ratingSum} (${product.reviewOverviewModel.totalReviews} reviews)'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: Text('Products'),
      ),*/
      body: products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () => showProductDetails(context, product),
            child: Card(
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: product.pictureModels.isNotEmpty
                        ? Image.network(
                      product.pictureModels[0].imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 100),
                    )
                        : Icon(Icons.image, size: 100),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5),
                        Text(
                          product.productPrice.price,
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          product.shortDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
//

class ProductGridWidget extends StatelessWidget {
  final List<Product> products;

  const ProductGridWidget({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.network(
                    p.pictureModels.first.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (p.shortDescription.isNotEmpty)
                      Text(p.shortDescription, maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (p.productPrice.price.isNotEmpty)
                      Text(p.productPrice.price, style: const TextStyle(color: Colors.green)),
                    if (p.fullDescription.isNotEmpty)
                      Text('Description available', style: const TextStyle(fontSize: 12)),
                    if (p.seName.isNotEmpty) Text('Slug: ${p.seName}', style: const TextStyle(fontSize: 12)),
                    if (p.sku.isNotEmpty) Text('SKU: ${p.sku}', style: const TextStyle(fontSize: 12)),
                    Text('Type: ${p.productType}'),
                    Text('New: ${p.markAsNew ? "Yes" : "No"}'),
                    Text('Required Attributes: ${p.hasRequiredAttributes ? "Yes" : "No"}'),
                    Text('Rating: ${p.reviewOverviewModel.ratingSum}'),
                    Text('Reviews: ${p.reviewOverviewModel.totalReviews}'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
