import 'dart:convert';

/// Top-level response model
class SlidesResponse {
  final List<Slide> slides;

  SlidesResponse({required this.slides});

  factory SlidesResponse.fromJson(Map<String, dynamic> json) {
    return SlidesResponse(
      slides: (json['slides'] as List<dynamic>?)
          ?.map((e) => Slide.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slides': slides.map((e) => e.toJson()).toList(),
    };
  }

  /// Helper to parse raw JSON string
  static SlidesResponse fromRawJson(String str) =>
      SlidesResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}

/// Individual Slide item
class Slide {
  final String imageUrl;
  final String title;
  final String link;
  final String altText;

  Slide({
    required this.imageUrl,
    required this.title,
    required this.link,
    required this.altText,
  });

  factory Slide.fromJson(Map<String, dynamic> json) {
    return Slide(
      imageUrl: json['ImageUrl'] ?? '',
      title: json['Title'] ?? '',
      link: json['Link'] ?? '',
      altText: json['AltText'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ImageUrl': imageUrl,
      'Title': title,
      'Link': link,
      'AltText': altText,
    };
  }
}