import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SingleImageOffer extends StatelessWidget {
  const SingleImageOffer({
    super.key,
    required this.headTitle,
    required this.subTitle,
    required this.productCategory,
    required this.image,
  });

  final String headTitle;
  final String subTitle;
  final String image;
  final String productCategory;

  @override
  Widget build(BuildContext context) {
    void goToCateogryDealsScreen() {
      //Navigator.pushNamed(context, CategoryDealsScreen.routeName,
      // arguments: productCategory);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*const SizedBox(height: 12),
        Text(
          headTitle,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, backgroundColor: Colors.white),
        ),
        Text(
          subTitle,
          style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14, backgroundColor: Colors.white),
        ),*/
        //const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.only(top: 12.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: () => goToCateogryDealsScreen(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                width: double.infinity,
                fit: BoxFit.contain,
                imageUrl: image,
                placeholder:
                    (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
