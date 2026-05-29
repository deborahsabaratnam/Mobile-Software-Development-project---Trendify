import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  // ➕ Increase quantity
  Future<void> increaseQty(String docId, int qty) async {
    await FirebaseFirestore.instance
        .collection('cart')
        .doc(userId)
        .collection('items')
        .doc(docId)
        .update({'quantity': qty + 1});
  }

  // ➖ Decrease quantity
  Future<void> decreaseQty(String docId, int qty) async {
    if (qty <= 1) return;

    await FirebaseFirestore.instance
        .collection('cart')
        .doc(userId)
        .collection('items')
        .doc(docId)
        .update({'quantity': qty - 1});
  }

  // 🗑 Remove item
  Future<void> removeItem(String docId) async {
    await FirebaseFirestore.instance
        .collection('cart')
        .doc(userId)
        .collection('items')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Cart",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .doc(userId)
            .collection('items')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;

          if (items.isEmpty) {
            return const Center(
              child: Text("Your cart is empty"),
            );
          }

          // 💰 TOTAL CALCULATION
          double total = 0;

          for (var item in items) {
            total += (item['price'] * item['quantity']);
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                // HEADER
                const Row(
                  children: [
                    Expanded(flex: 3, child: Text("Item", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text("Price", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text("Total", style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),

                const SizedBox(height: 10),

                // LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final data = item.data() as Map<String, dynamic>;

                      final name = data['name'] ?? '';
                      final price = data['price'] ?? 0;
                      final qty = data['quantity'] ?? 1;
                      final image = data['image'] ?? '';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [

                            // IMAGE
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // NAME
                            Expanded(
                              flex: 3,
                              child: Text(
                                name,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),

                            // PRICE
                            Expanded(
                              flex: 2,
                              child: Text("Rs. $price"),
                            ),

                            // QTY CONTROLS
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        decreaseQty(item.id, qty),
                                    child: const Icon(Icons.remove, size: 18),
                                  ),
                                  const SizedBox(width: 5),
                                  Text("$qty"),
                                  const SizedBox(width: 5),
                                  GestureDetector(
                                    onTap: () =>
                                        increaseQty(item.id, qty),
                                    child: const Icon(Icons.add, size: 18),
                                  ),
                                ],
                              ),
                            ),

                            // TOTAL
                            Expanded(
                              flex: 2,
                              child: Text("Rs. ${price * qty}"),
                            ),

                            // DELETE
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removeItem(item.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // TOTAL PRICE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Rs. $total",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // CHECKOUT BUTTON
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CheckoutScreen(subtotal: total),
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "Checkout",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}