import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nopcommerce_mobile/constants/app_constants.dart';

class SingleTopCategoryItem extends StatelessWidget {
  const SingleTopCategoryItem({
    super.key,
    required this.image,
    required this.title,
    this.isBottomOffer = false,
  });

  final String image;
  final String title;
  final bool isBottomOffer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isBottomOffer ? 0 : 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipOval(
            /*child: Image.network(
              image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),*/
            child: CachedNetworkImage(
              height: 60,
              width: 60,
              fit: BoxFit.cover,
              imageUrl: AppConstants.storeUrl+image,
              placeholder:
                  (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          /* Image.network(
            image,
            height: 60,
            width: 60,
            fit: BoxFit.cover,
          ), */
          Text(
            title,
            style:
                isBottomOffer
                    ? const TextStyle(fontSize: 11)
                    : const TextStyle(),
          ),
        ],
      ),
    );
  }
}
