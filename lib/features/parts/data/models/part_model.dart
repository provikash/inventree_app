class PartModel {
  final int pk;
  final String name;
  final String description;
  final String? ipn;
  final int? category;
  final String? categoryName;
  final double? stock;
  final String? image;

  PartModel({
    required this.pk,
    required this.name,
    required this.description,
    this.ipn,
    this.category,
    this.categoryName,
    this.stock,
    this.image,
  });

  factory PartModel.fromJson(Map<String, dynamic> json) {
    return PartModel(
      pk: json['pk'] as int,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      ipn: json['IPN'],
      category: json['category'],
      categoryName: json['category_name'],
      stock: (json['stock'] as num?)?.toDouble(),
      image: json['image'],
    );
  }
}
