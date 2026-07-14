import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:order_manager/Modules/product.dart';
import 'package:order_manager/pages/add_order_page.dart';
import 'package:order_manager/pages/order_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> catalog = [];

  // ---- theme constants (matches OrderSummaryPage) ----
  static const Color _primary = Color(0xFF1E3A8A); // deep steel blue
  static const Color _primaryLight = Color(0xFF2563EB);
  static const Color _bg = Color(0xFFF4F6FA);
  static const Color _cardBorder = Color(0xFFE5E9F2);

  Future<void> loadCatalog() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Products').get();

    catalog = snapshot.docs.map((doc) {
      return Product.fromFirestore(doc.id, doc.data());
    }).toList();

    catalog.sort((a, b) {
      final aSerial = int.tryParse(a.serial) ?? 0;
      final bSerial = int.tryParse(b.serial) ?? 0;

      return aSerial.compareTo(bSerial);
    });

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadCatalog();
  }

  @override
  Widget build(BuildContext context) {
    if (catalog.isEmpty) {
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
          "Order Manager",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 0.2,
          ),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    size: 72,
                    color: _primary,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Steel Order Management",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Manage orders quickly and efficiently",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 44),

                _homeButton(
                  context,
                  title: "Add New Order",
                  subtitle: "Create and save a new customer order",
                  icon: Icons.add_box_rounded,
                  color: _primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddOrderPage(catalog: catalog),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                _homeButton(
                  context,
                  title: "Order History",
                  subtitle: "View previously created orders",
                  icon: Icons.history_rounded,
                  color: _primaryLight,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderHistoryPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _homeButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
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
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 22,
          ),
          child: Row(
            children: [

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade400,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}