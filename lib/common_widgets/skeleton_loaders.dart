import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({required this.width, required this.height, this.radius = 8});
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

Widget _shimmerWrap({required Widget child}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: child,
  );
}

// Section 1: Carousel + Categories + Filter row
class HomeTopSkeleton extends StatelessWidget {
  const HomeTopSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carousel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _ShimmerBox(
              width: double.infinity,
              height: 180,
              radius: 16,
            ),
          ),
          const SizedBox(height: 8),
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => Container(
                width: i == 0 ? 12 : 8,
                height: i == 0 ? 12 : 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Category circles row
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  children: [
                    const _ShimmerBox(width: 56, height: 56, radius: 28),
                    const SizedBox(height: 6),
                    _ShimmerBox(width: 50, height: 10, radius: 4),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Filter chips row
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: _ShimmerBox(width: 90, height: 30, radius: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Section 2: Product cards (horizontal scroll per category)
class ProductSectionSkeleton extends StatelessWidget {
  const ProductSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(3, (_) => _categorySkeletonBlock()),
      ),
    );
  }

  Widget _categorySkeletonBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        // Banner placeholder
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: _ShimmerBox(width: double.infinity, height: 70, radius: 10),
        ),
        const SizedBox(height: 8),
        // Category header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const _ShimmerBox(width: 40, height: 40, radius: 6),
              const SizedBox(width: 8),
              _ShimmerBox(width: 120, height: 16, radius: 4),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Product cards row
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (_, __) => Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ShimmerBox(width: 140, height: 140, radius: 10),
                  const SizedBox(height: 8),
                  _ShimmerBox(width: 100, height: 12, radius: 4),
                  const SizedBox(height: 6),
                  _ShimmerBox(width: 70, height: 12, radius: 4),
                  const SizedBox(height: 6),
                  _ShimmerBox(width: 80, height: 28, radius: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
