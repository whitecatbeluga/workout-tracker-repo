class Exercise {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String category;
  final bool withoutEquipment;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.withoutEquipment,
  });
}
