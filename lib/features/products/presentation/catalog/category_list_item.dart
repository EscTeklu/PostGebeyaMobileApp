import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_image.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';

class CategoryListItem extends StatelessWidget {
  const CategoryListItem({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryPictureUrl,
  });

  final int categoryId;
  final String? categoryName;
  final String? categoryPictureUrl;

  @override
  Widget build(BuildContext context) {
    final initials = (categoryName?.isNotEmpty ?? false)
        ? categoryName!.trim()[0].toUpperCase()
        : '?';

    return GestureDetector(
      onTap: () => context.pushNamed(
        Routes.category.name,
        pathParameters: {'id': categoryId.toString()},
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2C2E7B).withValues(alpha: 0.13),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full-bleed image or branded placeholder
              categoryPictureUrl != null
                  ? CustomImage(
                      url: categoryPictureUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2C2E7B), Color(0xFF3A3D9E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white30,
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

              // Gradient overlay for text legibility
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.70),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),

              // Category name + orange arrow badge
              Positioned(
                left: 10,
                right: 8,
                bottom: 10,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        categoryName ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 6),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5AD00),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 11,
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
  }
}
