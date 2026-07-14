class OrderItem {
  // Selected Product Specifications
  String serialNumber = "";

  String type = "";
  String size = "";
  String boxSize = "";
  int gauge = 0;
  int height = 0;
  int length = 0;

  // Order Details
  int quantity = 0;
  double rate = 0;

  // Product Details
  double weight = 0;

  // Calculated Values
  double totalWeight = 0;
  double amount = 0;

  OrderItem();

  /// Calculates total weight and amount
  void calculateTotals() {
    totalWeight = quantity * weight;
    amount = totalWeight * rate;
  }

  /// Clears the currently selected product
  void clearProduct() {
    serialNumber = "";
    weight = 0;
    totalWeight = 0;
    amount = 0;
  }

  /// Clears every specification below Type
  void resetAfterType() {
    size = "";
    boxSize = "";
    gauge = 0;
    height = 0;
    length = 0;

    clearProduct();
  }

  /// Clears every specification below Gauge
  void resetAfterGauge() {
    size = "";
    boxSize = "";
    height = 0;
    length = 0;

    clearProduct();
  }

  /// Clears every specification below Size
  void resetAfterSize() {
    boxSize = "";
    height = 0;
    length = 0;

    clearProduct();
  }

  /// Clears every specification below Box Size
  void resetAfterBoxSize() {
    height = 0;
    length = 0;

    clearProduct();
  }
  /// Clears every specification below Height
  void resetAfterHeight() {
    length = 0;

    clearProduct();
  }

  /// Copies the selected product's information
  void selectProduct({
    required String serial,
    required double productWeight,
  }) {
    serialNumber = serial;
    weight = productWeight;

    calculateTotals();
  }
}