import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  //declaring billNumber and passing it as an argument
  final String billNumber;

  const OrderDetailsPage({
    super.key,
    required this.billNumber,
  });

  static const Color _primary = Color(0xFF1E3A8A);
  static const Color _primaryLight = Color(0xFF2563EB);
  static const Color _bg = Color(0xFFF4F6FA);
  static const Color _cardBorder = Color(0xFFE5E9F2);

  //function to load order data from Firebase
  Future<Map<String, dynamic>> loadOrderData() async {
    //retriving the specific order document from firebase
    final orderDoc = await FirebaseFirestore.instance
        .collection('Orders')
        .doc(billNumber)
        .get();

    //storing order details in a variable
    final orderData = orderDoc.data()!;

    //making a list of products in the order and storing it in a variable
    List<dynamic> orderProducts = orderData['products'];

    //declaring of mapping the list with the specific details of each order
    List<Map<String, dynamic>> detailedProducts = [];

    // retrieving the specific product details from firebase and storing it in a variable
    for (var item in orderProducts) {
      final productDoc = await FirebaseFirestore.instance
          .collection('Products')
          .doc(item['serialNumber'])
          .get();

      //putting them in the mapped list
      if (productDoc.exists) {
        detailedProducts.add({
          ...item,
          ...productDoc.data()!,
        });
      }
    }
    //finally returning the order details and the list of products in the order
    return {
      'order': orderData,
      'products': detailedProducts,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_primary, _primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Order $billNumber",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        //delete button to delete the order from firebase
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    icon: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.delete_outline_rounded,
                          color: Colors.red.shade600, size: 26),
                    ),
                    title: const Text(
                      "Delete Order",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    //confirmation popup
                    content: const Text(
                      "Are you sure you want to delete this order?",
                      textAlign: TextAlign.center,
                    ),
                    actionsAlignment: MainAxisAlignment.center,
                    actions: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel"),
                      ),
                      //deleting the order from firebase
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                        ),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('Orders')
                              .doc(billNumber)
                              .delete();
                          //exiting to home page after deletion
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: const Text("Delete"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),

      //displaying the order details and the list of products in the order
      body: FutureBuilder<Map<String, dynamic>>(
        future: loadOrderData(),

        builder: (context, snapshot) {
          //waiting
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_primary),
              ),
            );
          }
          //validation of data
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 60, color: Colors.red.shade300),
                  const SizedBox(height: 12),
                  Text(
                    "Error: ${snapshot.error}",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha:0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.search_off_rounded,
                      size: 56,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Order not found",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            );
          }

          //putting the order in a variuable
          final order = snapshot.data!['order'];

          //putting the list of products in a variable
          final products =
              snapshot.data!['products'] as List<Map<String, dynamic>>;

          Timestamp timestamp = order['createdAt'];

          DateTime date = timestamp.toDate();

          double grandTotal = order['totalAmount'] * (1.18);

          //building the list for the details of the order and the products in the order
          return ListView(
            padding: const EdgeInsets.all(20),

            children: [

              // ---------------- Order info card ----------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: _primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Order Information",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _infoRow(Icons.business_rounded, "Company",
                        "${order['companyName']}"),
                    const SizedBox(height: 10),
                    _infoRow(Icons.confirmation_number_outlined,
                        "Bill Number", billNumber),
                    const SizedBox(height: 10),
                    _infoRow(Icons.calendar_today_rounded, "Date",
                        "${date.day}/${date.month}/${date.year}"),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ---------------- Products label ----------------
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: _primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Products (${products.length})",
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              //mapping the list of products
              ...products.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final product = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Product ${index + 1}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "${product['type']}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _primary,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          const Divider(height: 1, color: _cardBorder),
                          const SizedBox(height: 12),

                          _detailRow("Item No.", "${product['serialNumber']}"),
                          _detailRow("Gauge", "${product['gauge']}"),
                          _detailRow("Mesh", "${product['boxSize']}"),
                          _detailRow("Size", "${product['size']}"),
                          _detailRow("Height", "${product['height']}"),
                          _detailRow("Length", "${product['length']}"),

                          const SizedBox(height: 10),
                          const Divider(height: 1, color: _cardBorder),
                          const SizedBox(height: 10),

                          _detailRow("Bundles", "${product['quantity']}"),
                          _detailRow("Weight / Bundle",
                              "${product['weight']} kg"),
                          _detailRow("Total Weight",
                              "${product['totalWeight']} kg"),
                          _detailRow("Rate", "₹${product['rate']}"),

                          const SizedBox(height: 10),
                          const Divider(height: 1, color: _cardBorder),
                          const SizedBox(height: 10),

                          //amount "WITHOUT TAX"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Amount",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                              Text(
                                "₹${product['amount']}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              // ---------------- Totals card ----------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _totalRow("Total Weight", "${order['totalWeight']} kg"),
                    const SizedBox(height: 8),
                    //amount "WITHOUT TAX"
                    _totalRow(
                        "Amount", "₹${order['totalAmount']}"),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: _cardBorder),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total (incl. tax)",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        //amount "WITH TAX"
                        Text(
                          "₹${grandTotal.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }

  // helper for the rows inside the Order Information card
  static Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(fontSize: 14.5, color: Colors.grey.shade600),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }

  // helper for the label/value rows inside each product card
  static Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF6B7280)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  // helper for rows in the totals card
  static Widget _totalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.5, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}