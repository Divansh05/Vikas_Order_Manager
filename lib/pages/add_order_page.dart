import 'package:flutter/material.dart';
import 'package:order_manager/Modules/order_item.dart';
import 'package:order_manager/Modules/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:order_manager/Widgets/product_card.dart';
import 'package:order_manager/pages/order_summary_page.dart';
import 'package:order_manager/pages/product_catalog_page.dart';

class AddOrderPage extends StatefulWidget {
  final List<Product> catalog;

  const AddOrderPage({
    super.key,
    required this.catalog,
  });

  @override
  State<AddOrderPage> createState() => _AddOrderPageState();
}

class _AddOrderPageState extends State<AddOrderPage> {
  List<OrderItem> orderItems = [OrderItem()];

  bool billNumberExists = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController companyController =
      TextEditingController();

  final TextEditingController billController =
      TextEditingController();

  static const Color _primary = Color(0xFF1E3A8A); // deep steel blue
  static const Color _primaryLight = Color(0xFF2563EB);
  static const Color _bg = Color(0xFFF4F6FA);
  static const Color _cardBorder = Color(0xFFE5E9F2);

  double calculateTotalAmount() {
    double total = 0;

    for (var item in orderItems) {
      total += item.amount;
    }

    return total;
  }

  double calculateTotalWeight() {
    double total = 0;

    for (var item in orderItems) {
      total += item.totalWeight;
    }

    return total;
  }

  bool validateProducts() {
    for (var item in orderItems) {
      if (item.type.isEmpty ||
          item.gauge == 0 ||
          item.size.isEmpty ||
          item.boxSize.isEmpty ||
          item.height == 0 ||
          item.length == 0) {
        return false;
      }

      if (item.quantity <= 0) return false;

      if (item.rate <= 0) return false;

      if (item.serialNumber.isEmpty) return false;
    }

    return true;
  }

  Future<void> checkBillNumber(String billNumber) async {
    final doc = await FirebaseFirestore.instance
        .collection("Orders")
        .doc(billNumber)
        .get();

    setState(() {
      billNumberExists = doc.exists;
    });
  }

  @override
  void dispose() {
    companyController.dispose();
    billController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.catalog.isEmpty) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_primary),
          ),
        ),
      );
    }

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
        title: const Text(
          "Add Order",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Product Catalog",
            icon: const Icon(Icons.inventory_2_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductCatalogPage(
                    catalog: widget.catalog,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        elevation: 2,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          "Add Product",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          setState(() {
            orderItems.add(OrderItem());
          });
        },
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          children: [

            const Text(
              "Create New Order",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Enter customer details and add products to the order.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 24),

            Container(
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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
                            Icons.business,
                            color: _primary,
                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Text(
                          "Customer Details",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    TextFormField(
                      controller: companyController,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return "Company name is required";
                        }

                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Company Name",
                        prefixIcon:
                            const Icon(Icons.business_center, color: _primary),
                        filled: true,
                        fillColor: _bg,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: _primary, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: billController,
                      keyboardType:
                          TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return "Bill number is required";
                        }

                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Bill Number",
                        prefixIcon:
                            const Icon(Icons.receipt_long, color: _primary),
                        filled: true,
                        fillColor: _bg,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: _primary, width: 1.5),
                        ),
                      ),
                      onFieldSubmitted: (value) {
                        checkBillNumber(value);
                      },
                    ),

                    if (billNumberExists)
                      Container(
                        margin:
                            const EdgeInsets.only(top: 18),
                        padding:
                            const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [

                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                            ),

                            SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                "Bill number already exists.",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            Row(
              children: [

                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: _primary,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                const Text(
                  "Products",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              "Select products from the catalogue below.",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14.5,
              ),
            ),

            const SizedBox(height: 15),

            ...orderItems.asMap().entries.map(
              (entry) => ProductCard(
                index: entry.key,
                catalog: widget.catalog,
                orderItems: orderItems,
                refresh: () {
                  setState(() {});
                },
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text(
                  "Continue to Summary",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  if (!validateProducts()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.red.shade600,
                        content: const Text(
                          "Please complete all product details.",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderSummaryPage(
                        companyName: companyController.text,
                        billNumber: billController.text,
                        totalWeight: calculateTotalWeight(),
                        totalAmount: calculateTotalAmount(),
                        orderItems: orderItems,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                "${orderItems.length} Product${orderItems.length == 1 ? "" : "s"} Added",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}