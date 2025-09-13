class AnimationItem {
  final String name;
  final String path;
  final String description;

  AnimationItem({
    required this.name,
    required this.path,
    required this.description,
  });

  factory AnimationItem.fromJson(Map<String, dynamic> json) {
    return AnimationItem(
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'description': description,
    };
  }
}
