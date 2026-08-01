class BannerCarousel {
  final int id;
  final String systemName;
  final bool autoplay;
  final int autoplaySpeed;
  final List<BannerSlide> slides;

  BannerCarousel({
    required this.id,
    required this.systemName,
    required this.autoplay,
    required this.autoplaySpeed,
    required this.slides,
  });

  factory BannerCarousel.fromJson(Map<String, dynamic> json) {
    return BannerCarousel(
      id: json['Id'],
      systemName: json['SystemName'] ?? '',
      autoplay: json['Autoplay'] ?? true,
      autoplaySpeed: json['AutoplaySpeed'] ?? 3000,
      slides: (json['Slides'] as List<dynamic>? ?? [])
          .map((slide) => BannerSlide.fromJson(slide))
          .toList(),
    );
  }
}

class BannerSlide {
  final String imageUrl;
  final String? mobileImageUrl;
  final String? url;
  final String? alt;
  final String? systemName;

  BannerSlide({
    required this.imageUrl,
    this.mobileImageUrl,
    this.url,
    this.alt,
    this.systemName,
  });

  factory BannerSlide.fromJson(Map<String, dynamic> json) {
    return BannerSlide(
      imageUrl: json['ImageUrl'] ?? '',
      mobileImageUrl: json['MobileImageUrl'],
      url: json['Url'],
      alt: json['Alt'],
      systemName: json['SystemName'],
    );
  }
}