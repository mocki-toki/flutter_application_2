class ImageEntity {
  final String id;
  final List<ImageVariantEntity> variants;

  const ImageEntity({
    required this.id,
    required this.variants,
  });

  factory ImageEntity.fromJson(Map<String, dynamic> json) {
    final List variantsJson = json['variants'];
    final variants = variantsJson
        .map((variantJson) => ImageVariantEntity.fromJson(variantJson))
        .toList();

    return ImageEntity(
      id: json['id'],
      variants: variants,
    );
  }
}

class ImageVariantEntity {
  final int width;
  final int height;
  final String url;

  const ImageVariantEntity({
    required this.width,
    required this.height,
    required this.url,
  });

  factory ImageVariantEntity.fromJson(Map<String, dynamic> json) {
    return ImageVariantEntity(
      width: json['width'],
      height: json['height'],
      url: json['url'],
    );
  }
}
