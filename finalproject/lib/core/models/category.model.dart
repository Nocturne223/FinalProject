class CategoryModel {
  final String categoryId;
  final String name;

  CategoryModel({required this.categoryId, required this.name});

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      categoryId: map['category_id'] ?? '',
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'category_id': categoryId, 'name': name};
  }
}
