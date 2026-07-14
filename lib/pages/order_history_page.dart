// this is the main page which shows a compact list of all the orders that have been placed
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:order_manager/pages/order_detail_page.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  // ---- theme constants (matches OrderSummaryPage / HomePage / AddOrderPage) ----
  static const Color _primary = Color(0xFF1E3A8A); // deep steel blue
  static const Color _primaryLight = Color(0xFF2563EB);
  static const Color _bg = Color(0xFFF4F6FA);
  static const Color _cardBorder = Color(0xFFE5E9F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
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
          "Order History",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),

      //creating a list of the orders
      body: StreamBuilder(
        //extracting info from firebase
        stream: FirebaseFirestore.instance
            .collection('Orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        //building the list of orders
        builder: (context, snapshot) {

          //waiting and validation of data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_primary),
              ),
            );
          }

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

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 60,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No Orders Found",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Orders you create will show up here",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          //storing order data in a variable
          final orders = snapshot.data!.docs;

          //building cards to show each order in a list view
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            itemCount: orders.length,

            itemBuilder: (context, index) {
              final order = orders[index];

              Timestamp? timeStamp = order['createdAt'];

              DateTime date = timeStamp!.toDate();

              final grandTotal = order['totalAmount'] * (1.18);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),

                    //navigating to the order details page when an order is tapped
                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) =>
                              OrderDetailsPage(billNumber: order.id),
                        ),
                      );
                    },

                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // header row: receipt icon + bill number + chevron
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.receipt_long_rounded,
                                  color: _primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Bill No. ${order['billNumber']}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(Icons.business_rounded,
                                            size: 14,
                                            color: Colors.grey.shade500),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            order['companyName'],
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.grey.shade400,
                                size: 16,
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),
                          const Divider(height: 1, color: _cardBorder),
                          const SizedBox(height: 12),

                          // details row: weight + date
                          Row(
                            children: [
                              Icon(Icons.scale_rounded,
                                  size: 16, color: Colors.grey.shade500),
                              const SizedBox(width: 6),
                              Text(
                                "${order['totalWeight']} kg",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Icon(Icons.calendar_today_rounded,
                                  size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 6),
                              Text(
                                "${date.day}/${date.month}/${date.year}",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          const Divider(height: 1, color: _cardBorder),
                          const SizedBox(height: 12),

                          // totals row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Subtotal",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    "₹${order['totalAmount'].toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Grand Total",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    "₹${grandTotal.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: _primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}