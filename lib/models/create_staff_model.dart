class CreateStaffModel {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String? image;

  CreateStaffModel({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    this.image,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
    };

    if (image != null) {
      data['image'] = image;
    }

    return data;
  }

  factory CreateStaffModel.fromJson(Map<String, dynamic> json) {
    return CreateStaffModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'],
    );
  }

  // Create a copy with updated fields
  CreateStaffModel copyWith({
    String? name,
    String? email,
    String? password,
    String? phone,
    String? image,
  }) {
    return CreateStaffModel(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      image: image ?? this.image,
    );
  }

  @override
  String toString() {
    return 'CreateStaffModel(name: $name, email: $email, phone: $phone, image: $image)';
  }
}
