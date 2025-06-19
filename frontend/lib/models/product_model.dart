// Cetakan data Product di sisi Flutter. Strukturnya harus cocok dengan di Go.
class Product {
  final String id;
  final String name;

  Product({required this.id, required this.name});

  // Fungsi untuk mengubah data JSON dari server menjadi objek Product.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
    );
  }
}