import 'package:built_collection/built_collection.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_image.dart';
import 'package:nopcommerce_mobile/features/products/presentation/picture_indicator_widget.dart';

class ProductPictureGalery extends StatefulWidget {
  const ProductPictureGalery({
    super.key,
    required this.pictureModels,
    required this.showAddToWishlistButton,
    required this.isFavorite,
    required this.addToWishlistEvent,
  });

  final BuiltList<PictureModelDto> pictureModels;
  final bool showAddToWishlistButton;
  final bool isFavorite;
  final Function()? addToWishlistEvent;

  @override
  State<ProductPictureGalery> createState() => _ProductPictureGaleryState();
}

class _ProductPictureGaleryState extends State<ProductPictureGalery> {
  int _pictureIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // White background while image loads
        Container(color: const Color(0xFFF4F5FB)),

        CarouselSlider(
          options: CarouselOptions(
            aspectRatio: 1,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() => _pictureIndex = index);
            },
          ),
          items: widget.pictureModels.map((model) {
            return Builder(
              builder: (context) => SizedBox(
                width: MediaQuery.of(context).size.width,
                child: CustomImage(
                  url: model.imageUrl!,
                  fit: BoxFit.contain,
                ),
              ),
            );
          }).toList(),
        ),

        // Bottom gradient for dots readability
        if (widget.pictureModels.length > 1)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.25),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

        // Wishlist button — top-right
        if (widget.showAddToWishlistButton)
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: widget.addToWishlistEvent,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  widget.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: Colors.red.shade400,
                  size: 22,
                ),
              ),
            ),
          ),

        // Dots indicator
        if (widget.pictureModels.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: PictureIndicator(
                pictureCount: widget.pictureModels.length,
                selectedIndex: _pictureIndex,
              ),
            ),
          ),
      ],
    );
  }
}
