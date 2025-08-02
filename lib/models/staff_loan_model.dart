class StaffLoan {
  final int id;
  final String name;
  final String email;
  final int phone;
  final String? image;
  final String createdAt;

  final double totalOutstanding;

  StaffLoan({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.image,
    required this.totalOutstanding,
    this.createdAt = '',
  });

  factory StaffLoan.fromJson(Map<String, dynamic> json) {
    return StaffLoan(
      id: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? 0,
      image: json['image'],
      createdAt: json['created_at'] ?? '',
      totalOutstanding: (json['total_outstanding'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'total_outstanding': totalOutstanding,
    };
  }
}
