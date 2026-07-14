import 'package:flutter/material.dart';
import 'package:order_manager/Modules/product.dart';
import 'package:order_manager/Widgets/product_catalog.dart';

class ProductCatalogPage extends StatefulWidget {
  //declaring the final list and passing it as an argument
  final List<Product> catalog;
  const ProductCatalogPage({super.key, required this.catalog});

  @override
  State<ProductCatalogPage> createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends State<ProductCatalogPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Product Catalog",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          //displaying the product catalog as a scrollable list
          child: ProductCatalog(catalog: widget.catalog),
        ),
      ),
    );
  }
}