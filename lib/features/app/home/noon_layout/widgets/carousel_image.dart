import 'package:flutter/material.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/features/app/home/noon_layout/widgets/background_white_gradient.dart';
import 'package:nopcommerce_mobile/features/app/home/noon_layout/widgets/custom_carousel_slider.dart';
import 'package:nopcommerce_mobile/features/app/home/noon_layout/widgets/dots_indicator.dart';

class CarouselImage extends StatefulWidget {
  const CarouselImage({super.key});

  @override
  State<CarouselImage> createState() => _CarouselImageState();
}

class _CarouselImageState extends State<CarouselImage> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomCarouselSliderMap(
          sliderImages: GlobalVariables.carouselImages,
          onPageChanged: (index, reason) {
            setState(() {
              _current = index;
            });
          },
        ),
        Positioned(
          top: 150,
          left: MediaQuery.sizeOf(context).width / 3.3,
          child: DotsIndicatorMap(
            controller: _controller,
            current: _current,
            sliderImages: GlobalVariables.carouselImages,
          ),
        ),
        const Positioned(
          bottom: 0,
          child: BackgroundWhiteGradient(),
        ),
         /*const Positioned(
          bottom: 0,
          child: BottomOffers(),
        ), */
      ],
    );
  }
}
