//displays the order information once again to verify if the details were correctly entered

import 'package:flutter/material.dart';
import '../Modules/order_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderSummaryPage extends StatelessWidget {
  //declaring variables
  final String companyName;
  final String billNumber;
  final double totalWeight;
  final double totalAmount;
  final List<OrderItem> orderItems;

  const OrderSummaryPage({
    super.key,
    required this.companyName,
    required this.billNumber,
    required this.totalWeight,
    required this.totalAmount,
    required this.orderItems,
  });

  // ---- theme constants (kept local so this file stays drop-in) ----
  static const Color _primary = Color(0xFF1E3A8A); // deep steel blue
  static const Color _primaryLight = Color(0xFF2563EB);
  static const Color _bg = Color(0xFFF4F6FA);
  static const Color _cardBorder = Color(0xFFE5E9F2);

  Future<bool> uploadOrder() async {
    //getting the bill number data from firebase
    final existingOrder = await FirebaseFirestore.instance
        .collection('Orders')
        .doc(billNumber)
        .get();

    //validation
    if (existingOrder.exists) {
      return false;
    }
    if(companyName.isEmpty){
      return false;
    }

    //creating a bill in firebase format and uploading it to the database
    await FirebaseFirestore.instance.collection('Orders').doc(billNumber).set({
      'companyName': companyName,
      'billNumber': billNumber,
      'totalWeight': totalWeight,
      'totalAmount': totalAmount * (1.18), //including GST 18% in the total amount
      'createdAt': FieldValue.serverTimestamp(),
      'products': orderItems.map((item) {
        return {
          'serialNumber': item.serialNumber,
          'type': item.type,
          'quantity': item.quantity,
          'weight': item.weight,
          'totalWeight': item.totalWeight,
          'rate': item.rate,
          'amount': item.amount,
        };
      }).toList(),
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final gst = totalAmount * 0.18;
    final grandTotal = totalAmount * 1.18;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_primary, _primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Order Summary",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.2,
          ),
        ),
      ),

      body: Column(
        children: [
          // ---------------- Header card: company / bill info ----------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_primary, _primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.business_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            companyName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Bill No. $billNumber",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ---------------- Products label ----------------
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined,
                    size: 18, color: _primary),
                const SizedBox(width: 8),
                Text(
                  "Products (${orderItems.length})",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),

          // ---------------- Product list ----------------
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              itemCount: orderItems.length,
              itemBuilder: (context, index) {
                final item = orderItems[index];

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
                        // header row: product number + type chip
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
                                item.type,
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

                        // details grid
                        _detailRow("Item No.", item.serialNumber.toString()),
                        _detailRow("Bundles", item.quantity.toString()),
                        _detailRow("Weight / Bundle",
                            "${item.weight.toStringAsFixed(2)} kg"),
                        _detailRow("Total Weight",
                            "${item.totalWeight.toStringAsFixed(2)} kg"),
                        _detailRow(
                            "Rate", "₹${item.rate.toStringAsFixed(2)}"),

                        const SizedBox(height: 10),
                        const Divider(height: 1, color: _cardBorder),
                        const SizedBox(height: 10),

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
                              "₹${item.amount.toStringAsFixed(2)}",
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
          ),

          // ---------------- Totals + confirm button ----------------
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _totalRow("Total Weight",
                      "${totalWeight.toStringAsFixed(2)} kg"),
                  const SizedBox(height: 6),
                  _totalRow("Subtotal (excl. GST 18%)",
                      "₹${totalAmount.toStringAsFixed(2)}"),
                  const SizedBox(height: 6),
                  _totalRow("GST (18%)", "₹${gst.toStringAsFixed(2)}"),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, color: _cardBorder),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Grand Total",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        "₹${grandTotal.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      //calls upload function and uploads the order to firebase
                      onPressed: () async {
                        bool success = await uploadOrder();
                        if (!context.mounted) return;

                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Bill Number already exists"),
                              backgroundColor: Color(0xFFDC2626),
                            ),
                          );

                          return;
                        }

                        if (companyName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please mention a company name"),
                              backgroundColor: Color(0xFFDC2626),
                            ),
                          );

                          return;
                        }


                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Order Uploaded Successfully"),
                            backgroundColor: Color(0xFF16A34A),
                          ),
                        );

                        Navigator.popUntil(context, (route) => route.isFirst);
                      },

                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Confirm Order",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // small helper for the label/value rows inside each product card
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

  // helper for rows in the totals section
  static Widget _totalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}