class Staff {
  final int id;
  final String name;
  final String? image;

  Staff({required this.id, required this.name, this.image});

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      name: json['name'],
      image: json['image'] ?? '',
    );
  }
}
