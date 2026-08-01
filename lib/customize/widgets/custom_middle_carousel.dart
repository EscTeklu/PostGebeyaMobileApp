import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nopcommerce_mobile/common_widgets/skeleton_loaders.dart';
import 'package:nopcommerce_mobile/customize/models/banner_model.dart';
import 'package:nopcommerce_mobile/customize/services/slide_api_service.dart';

class CustomCarouselMiddleSlider extends StatefulWidget {
  //final BannerCarousel carousel;

  const CustomCarouselMiddleSlider({super.key});

  @override
  State<CustomCarouselMiddleSlider> createState() => _CustomCarouselMiddleSliderState();
}

class _CustomCarouselMiddleSliderState extends State<CustomCarouselMiddleSlider> {
  int _current = 0;
  //added for Sliders
  final ApiServiceSlider _apiServiceSlider = ApiServiceSlider();
  List<BannerCarousel>? carousels;
  String? error;
  //end for sliders

  Future<void> _loadSliders() async {
    try {
      final data = await _apiServiceSlider.getSliders();
      setState(() {
        carousels = data;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        carousels = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSliders();
  }

  @override
  Widget build(BuildContext context) {
    //_loadSliders();
    //for sliders
    if (error != null) {
      //return Center(child: Text('Error: $error'));
    }

    if (carousels == null) {
      // return const Center(child: CircularProgressIndicator());
    }
    // Empty state
    if (carousels == null) {
      return Center(child: const HomeTopSkeleton());
      //return const Center(child: CircularProgressIndicator());
      //return const Center(child: Text("No sliders available"));
    }

    // Find the middle Page Slider
    final middleSlider = carousels!.firstWhere(
          (c) => c.systemName.contains("Home Page Top Banner"),
      orElse: () => carousels!.first,
    );
    //
    final slides = middleSlider.slides;// widget.carousel.slides;

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: slides.length,
          options: CarouselOptions(
            height: 60,
            viewportFraction: 1.0,
            autoPlay: middleSlider.autoplay,
            autoPlayInterval: Duration(milliseconds: middleSlider.autoplaySpeed),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() => _current = index);
            },
          ),
          itemBuilder: (context, index, realIndex) {
            return _buildSlide(slides[index]);
          },
        ),

        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: slides.asMap().entries.map((entry) {
            return Container(
              width: _current == entry.key ? 28 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: _current == entry.key
                    ? Theme.of(context).primaryColor
                    : Colors.grey.withOpacity(0.5),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSlide(BannerSlide slide) {
    final imageUrl = slide.mobileImageUrl ?? slide.imageUrl;

    return GestureDetector(
      onTap: slide.url != null && slide.url!.isNotEmpty
          ? () {
        // Handle navigation here (GoRouter, Navigator, GetX, etc.)
        print("Navigate to: ${slide.url}");
      }
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 60),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.grey.withOpacity(0.25)],
                  ),
                ),
              ),
              if (slide.alt != null && slide.alt!.isNotEmpty)
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Text(
                    slide.alt!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}