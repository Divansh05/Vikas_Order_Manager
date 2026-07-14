//creates the product catalog table

import 'package:flutter/material.dart';
import 'package:order_manager/Modules/product.dart';

class ProductCatalog extends StatelessWidget {
  final List<Product> catalog;
  const ProductCatalog({super.key, required this.catalog});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('S. NO', style: TextStyle(fontSize: 10))),
          DataColumn(label: Text('TYPE', style: TextStyle(fontSize: 10))),
          DataColumn(label: Text('GAUGE', style: TextStyle(fontSize: 10))),
          DataColumn(label: Text('MESH', style: TextStyle(fontSize: 10))),
          DataColumn(label: Text('SIZE', style: TextStyle(fontSize: 10))),
          DataColumn(label: Text('HEIGHT', style: TextStyle(fontSize: 10))),
          DataColumn(label: Text('LENGTH', style: TextStyle(fontSize: 10))),
          DataColumn(label: Text('WEIGHT', style: TextStyle(fontSize: 10))),
        ],
        rows: catalog.map((product) {
          return DataRow(
            cells: [
              DataCell(Text(product.serial)),
              DataCell(Text(product.type)),
              DataCell(Text(product.gauge.toString())),
              DataCell(Text(product.boxSize)),
              DataCell(Text(product.size)),
              DataCell(Text('${product.height}')),
              DataCell(Text('${product.length}')),
              DataCell(Text('${product.weight}')),
            ],
          );
        }).toList(),
      ),
    );
  }
}
