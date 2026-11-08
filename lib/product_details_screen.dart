import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final String productId;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.productId,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool isAdding = false;
  String? selectedSize;
  int quantity = 1;

  final List<String> sizes = ['S', 'M', 'L', 'XL'];

  Future<void> addToCart() async {
    if (selectedSize == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a size")));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please sign in first")));
      return;
    }

    setState(() => isAdding = true);

    try {
      final cartRef = FirebaseFirestore.instance
          .collection('cart')
          .doc(user.uid)
          .collection('items')
          .doc('${widget.productId}_$selectedSize');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(cartRef);

        if (snapshot.exists) {
          final existingQuantity =
              (snapshot.data()?['quantity'] as num?)?.toInt() ?? 0;

          transaction.update(cartRef, {
            'quantity': existingQuantity + quantity,
          });
        } else {
          transaction.set(cartRef, {
            'productId': widget.productId,
            'name': widget.product['Name'] ?? '',
            'price': widget.product['Price'] ?? 0,
            'image': widget.product['Image'] ?? '',
            'size': selectedSize,
            'quantity': quantity,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Added to cart")));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add to cart: $e")));
    } finally {
      if (mounted) {
        setState(() => isAdding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final name = (product['Name'] ?? '').toString();
    final image = (product['Image'] ?? '').toString();
    final price = product['Price'] ?? 0;
    final description = (product['Description'] ?? '').toString();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Product Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 70,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "LKR $price",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              if (description.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  "Description",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(description),
              ],
              const SizedBox(height: 24),

              const Text(
                "Select Size",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                children: sizes.map((size) {
                  final isSelected = selectedSize == size;

                  return ChoiceChip(
                    label: Text(size),
                    selected: isSelected,
                    selectedColor: Colors.black,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    onSelected: (_) {
                      setState(() {
                        selectedSize = size;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              const Text(
                "Quantity",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  IconButton(
                    onPressed: quantity > 1
                        ? () {
                            setState(() {
                              quantity--;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),

                  Text(
                    "$quantity",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      setState(() {
                        quantity++;
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isAdding ? null : addToCart,
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: Text(isAdding ? "Adding..." : "Add to Cart"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
