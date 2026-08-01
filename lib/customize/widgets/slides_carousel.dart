

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:nopcommerce_mobile/constants/app_constants.dart';
import 'package:nopcommerce_mobile/constants/global_variables.dart';
import 'package:nopcommerce_mobile/customize/models/nivo_slider_item.dart';
import 'package:nopcommerce_mobile/customize/services/api_service.dart';
import 'package:nopcommerce_mobile/common_widgets/skeleton_loaders.dart';

class SlidesCarousel extends StatefulWidget {
  //final String apiBaseUrl;

  const SlidesCarousel({super.key, });

  @override
  State<SlidesCarousel> createState() => _SlidesCarouselState();
}

class _SlidesCarouselState extends State<SlidesCarousel> {
  late Future<SlidesResponse> _slidesFuture;
  final CarouselSliderController _controller = CarouselSliderController();

  int _currentIndex = 0;

  final ApiService apiService = ApiService();
  @override
  void initState() {
    super.initState();
    _slidesFuture = apiService.fetchSlides();
  }

  Future<void> _openLink(String url) async {
    /*final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open $url")),
      );
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SlidesResponse>(
      future: _slidesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: const HomeTopSkeleton()
          //CircularProgressIndicator()
          );
        } else if (snapshot.hasError) {
          //return Center(child: Text("Error: ${snapshot.error}"));
          return Center(child: Text("Sorry : It Seems You don't have Stable Connecton"));
        } else if (!snapshot.hasData || snapshot.data!.slides.isEmpty) {
          return const Center(child: Text("No slides available"));
        }

        final slides = snapshot.data!.slides;

        return Column(
          children: [
            CarouselSlider.builder(
              carouselController: _controller,
              itemCount: slides.length,
              itemBuilder: (context, index, realIndex) {
                final slide = slides[index];

                // Calculate parallax offset
                final parallaxOffset = (index - _currentIndex) * 40.0;

                return GestureDetector(
                  onTap: () => _openLink(slide.link),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Parallax image
                          Transform.translate(
                            offset: Offset(parallaxOffset, 0),
                            child: CachedNetworkImage(
                              height: 40,
                              width: 60,
                              fit: BoxFit.fitWidth,
                              imageUrl: AppConstants.storeUrl+slide.imageUrl,
                              placeholder:
                                  (context, url) => const HomeTopSkeleton(),//const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                            /*Image.network(
                              AppConstants.storeUrl+slide.imageUrl,
                              fit: BoxFit.fitWidth,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 100),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            ),*/
                          ),
                          // Gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white10.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                          // Slide title & subtitle
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  slide.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                          color: Colors.black,
                                          blurRadius: 4,
                                          offset: Offset(1, 1))
                                    ],
                                  ),
                                ),
                                if (slide.altText.isNotEmpty)
                                  Text(
                                    slide.altText,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                aspectRatio: 2.37,
                enlargeCenterPage: true,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  setState(() => _currentIndex = index);
                },
              ),
            ),
            const SizedBox(height: 6),
            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: slides.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: _currentIndex == entry.key ? 12 : 8,
                    height: _currentIndex == entry.key ? 12 : 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == entry.key
                          ? GlobalVariables.accentColor
                          : Colors.grey.shade400,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}