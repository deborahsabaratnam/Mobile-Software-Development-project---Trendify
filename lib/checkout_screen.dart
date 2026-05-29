import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends StatefulWidget {
  final double subtotal;

  const CheckoutScreen({super.key, required this.subtotal});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String paymentMethod = "COD";
  final TextEditingController addressController = TextEditingController();
  bool isLoading = false;

  final user = FirebaseAuth.instance.currentUser;

  Future<void> placeOrder(List cartItems) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    if (addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter delivery address")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final orderRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(user!.uid)
          .collection('userOrders')
          .doc();

      await orderRef.set({
        'address': addressController.text,
        'paymentMethod': paymentMethod,
        'total': widget.subtotal,
        'status': "Processing",
        'createdAt': FieldValue.serverTimestamp(),
        'items': cartItems,
      });

      final cartRef = FirebaseFirestore.instance
          .collection('cart')
          .doc(user!.uid)
          .collection('items');

      final snapshot = await cartRef.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to place order")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("User not logged in"),
        ),
      );
    }

    double total = widget.subtotal;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Checkout"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .doc(user.uid)
            .collection('items')
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartDocs = snapshot.data!.docs;

          List<Map<String, dynamic>> cartItems = cartDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return {
              "name": data['name'] ?? '',
              "price": data['price'] ?? 0,
              "quantity": data['quantity'] ?? 1,
            };
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text("Delivery Address",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter your address",
                  ),
                ),

                const SizedBox(height: 20),

                const Text("Order Summary",
                    style: TextStyle(fontWeight: FontWeight.bold)),

                const SizedBox(height: 10),

                Column(
                  children: cartItems.map((item) {
                    int itemTotal =
                        (item['price'] as num).toInt() *
                        (item['quantity'] as num).toInt();

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${item['name']} x${item['quantity']}",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text("Rs. $itemTotal"),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Rs. $total"),
                  ],
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.all(15),
                    ),
                    onPressed:
                        isLoading ? null : () => placeOrder(cartItems),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Place Order"),
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