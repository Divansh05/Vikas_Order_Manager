import 'package:flutter/material.dart';
import '../Modules/product.dart';
import '../Modules/order_item.dart';

class ProductCard extends StatefulWidget {
  // passing these variables as argumets for the product card
  final int index;
  final List<Product> catalog;
  final List<OrderItem> orderItems;
  final VoidCallback refresh;

  const ProductCard({
    super.key,
    required this.index,
    required this.catalog,
    required this.orderItems,
    required this.refresh,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  //declaring variables to be used in the product card
  OrderItem get orderItem => widget.orderItems[widget.index];
  List<Product> get catalog => widget.catalog;


  // function which filters the products
  List<Product> get filteredProducts {
    return catalog.where((product) {
      if (orderItem.type.isNotEmpty && product.type != orderItem.type) {
        return false;
      }
      if (orderItem.gauge != 0 && product.gauge != orderItem.gauge) {
        return false;
      }
      if (orderItem.size.isNotEmpty && product.size != orderItem.size) {
        return false;
      }
      if (orderItem.boxSize.isNotEmpty &&
          product.boxSize != orderItem.boxSize) {
        return false;
      }
      
      if (orderItem.height != 0 && product.height != orderItem.height) {
        return false;
      }
      if (orderItem.length != 0 && product.length != orderItem.length) {
        return false;
      }
      return true;
    }).toList();
  }

  //callling the filtered products by passing it the list after sorting
  List<T> uniqueValues<T>(T Function(Product) selector) {
    return filteredProducts
        .map(selector)
        .toSet()
        .toList()
      ..sort((a, b) => a.toString().compareTo(b.toString()));
  }

  // Get unique options for each attribute
  List<String> get typeOptions =>
    uniqueValues((p) => p.type);
  
  List<int> get gaugeOptions =>
      uniqueValues((p) => p.gauge);

  List<String> get sizeOptions =>
      uniqueValues((p) => p.size);

  List<String> get boxSizeOptions =>
      uniqueValues((p) => p.boxSize);

  List<int> get heightOptions =>
      uniqueValues((p) => p.height);

  List<int> get lengthOptions =>
      uniqueValues((p) => p.length);


  //function which updates the dropdown values based on previous selections
  void updateSelectedProduct() {
    // Only continue when every dropdown has been selected
    if (orderItem.type.isEmpty ||
        orderItem.gauge == 0 ||
        orderItem.size.isEmpty ||
        orderItem.boxSize.isEmpty ||
        orderItem.height == 0 ||
        orderItem.length == 0) {
      orderItem.clearProduct();
      widget.refresh();
      return;
  }


  //fiunding the product from all the dropdown values
  try {
    final product = catalog.firstWhere(
      (p) =>
          p.type == orderItem.type &&
          p.gauge == orderItem.gauge &&
          p.size == orderItem.size &&
          p.boxSize == orderItem.boxSize &&
          p.height == orderItem.height &&
          p.length == orderItem.length,
    );

    orderItem.selectProduct(
      serial: product.serial,
      productWeight: product.weight,
    );
  } catch (e) {
    orderItem.clearProduct();
  }

  widget.refresh();
}
  @override
  Widget build(BuildContext context) {
    //returning the product card
    return Card(
      shadowColor: Colors.black,
      elevation: 9,
      margin: const EdgeInsets.only(top: 16),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
              Text(
              "Product ${widget.index + 1}",
              style: const TextStyle(fontSize: 20),
              ),

              //delete button for the product card
              IconButton(
                onPressed: () {
                  widget.orderItems.removeAt(widget.index);
                  widget.refresh();
                },
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ]
          ),

            const SizedBox(height: 16),

            const Text(
              "Type",
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 6),


            //creating the dropdown button for the product type
            DropdownButtonFormField<String>(
              initialValue: orderItem.type.isEmpty ? null : orderItem.type,

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),

              hint: const Text("Select Type"),

              //getting the type option list
              items: typeOptions.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              
              //resets the list for the dropdown below
              onChanged: (value) {
                setState(() {
                  orderItem.type = value!;
                  orderItem.resetAfterType();
                  
                });
                updateSelectedProduct();
              },
            ),

            const SizedBox(height: 16),

            const Text(
              "Gauge",
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 6),

            //creating the dropdown button for the product gauge
            DropdownButtonFormField<int>(
              initialValue: orderItem.gauge == 0 ? null : orderItem.gauge,

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),

              hint: const Text("Select Gauge"),

              items: gaugeOptions.map((gauge) {
                return DropdownMenuItem(
                  value: gauge,
                  child: Text(gauge.toString()),
                );
              }).toList(),

              onChanged: orderItem.type.isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        orderItem.gauge = value!;
                        orderItem.resetAfterGauge();
                        
                      });
                      updateSelectedProduct();
                    },
            ),

            const SizedBox(height: 16),

            const Text(
              "Size",
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 6),

            //creating the dropdown button for the product size
            DropdownButtonFormField<String>(
              initialValue: orderItem.size.isEmpty ? null : orderItem.size,

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),

              hint: const Text("Select Size"),

              items: sizeOptions.map((size) {
                return DropdownMenuItem(
                  value: size,
                  child: Text(size),
                );
              }).toList(),

              onChanged: orderItem.gauge == 0
                  ? null
                  : (value) {
                      setState(() {
                        orderItem.size = value!;
                        orderItem.resetAfterSize();
                        
                      });
                      updateSelectedProduct();
                    },
            ),

            const SizedBox(height: 16),

            const Text(
              "Box Size",
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 6),

            //creating the dropdown button for the product box size
            DropdownButtonFormField<String>(
              initialValue: orderItem.boxSize.isEmpty ? null : orderItem.boxSize,

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),

              hint: const Text("Select Box Size"),

              items: boxSizeOptions.map((box) {
                return DropdownMenuItem(
                  value: box,
                  child: Text(box),
                );
              }).toList(),

              onChanged: orderItem.size.isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        orderItem.boxSize = value!;
                        orderItem.resetAfterBoxSize();
                        
                      });
                      updateSelectedProduct();
                    },
            ),
            const SizedBox(height: 16),

            const Text(
              "Height",
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 6),


            //creating the dropdown button for the product height
            DropdownButtonFormField<int>(
              initialValue: orderItem.height == 0 ? null : orderItem.height,

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),

              hint: const Text("Select Height"),

              items: heightOptions.map((height) {
                return DropdownMenuItem(
                  value: height,
                  child: Text(height.toString()),
                );
              }).toList(),

              onChanged: orderItem.gauge == 0
                  ? null
                  : (value) {
                      setState(() {
                        orderItem.height = value!;
                        orderItem.resetAfterHeight();
                        updateSelectedProduct();
                      });
                    },
            ),

            const SizedBox(height: 16),

            const Text(
              "Length",
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 6),

            //creating the dropdown button for the product length
            DropdownButtonFormField<int>(
              initialValue: orderItem.length == 0 ? null : orderItem.length,

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),

              hint: const Text("Select Length"),

              items: lengthOptions.map((length) {
                return DropdownMenuItem(
                  value: length,
                  child: Text(length.toString()),
                );
              }).toList(),

              onChanged: orderItem.height == 0
                  ? null
                  : (value) {
                      setState(() {
                        orderItem.length = value!;
                        updateSelectedProduct();
                      });
                    },
            ),

            //dropdown finishes here
            //inputting all the other information for the product and giving the amount for the card with the total weight
            const SizedBox(height: 8),

            const Text(
              "Bundle Amount",
              style: TextStyle(fontSize: 15),
            ),

            TextFormField(
              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter amount of bundle",
              ),

              onChanged: (value) {

                widget.orderItems[widget.index].quantity =
                    int.tryParse(value) ?? 0;

                orderItem.calculateTotals();

                widget.refresh();
              },
            ),

            const SizedBox(height: 12),

            const Text(
              "Rate",
              style: TextStyle(fontSize: 15),
            ),

            TextFormField(
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),

              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter Rate",
              ),

              onChanged: (value) {
                orderItem.rate = double.tryParse(value) ?? 0;

                orderItem.calculateTotals();

                widget.refresh();
              },
            ),

            Text(
              widget.orderItems[widget.index].weight == 0
                  ? "Weight per bundle: -"
                  : "Weight per bundle: ${widget.orderItems[widget.index].weight.toStringAsFixed(2)} kg",
              style: const TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              widget.orderItems[widget.index].totalWeight == 0
                  ? "Total Weight: -"
                  : "Total Weight: ${widget.orderItems[widget.index].totalWeight.toStringAsFixed(2)} kg",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              widget.orderItems[widget.index].amount == 0
                  ? "Total Amount: -"
                  : "Total Amount: ₹${widget.orderItems[widget.index].amount.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}