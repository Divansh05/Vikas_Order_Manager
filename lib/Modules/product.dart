class Product {
  final String serial;
  final String type;
  final int gauge;
  final String boxSize;
  final String size;
  final int height;
  final int length;
  final double weight;

  Product({
    required this.serial,
    required this.type,
    required this.gauge,
    required this.boxSize,
    required this.size,
    required this.height,
    required this.length,
    required this.weight,
  });
  //getting the product from firestore and converting it into a product object
  factory Product.fromFirestore(String id, Map<String, dynamic> data) {
    return Product(
      serial: id,
      type: data['type'],
      gauge: data['gauge'],
      boxSize: data['boxSize'],
      size: data['size'],
      height: data['height'],
      length: data['length'],
      weight: (data['weight'] as num).toDouble(),
    );
  }
}
