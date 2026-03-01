import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  final _supabase = Supabase.instance.client;

  List<CartItem> get items => [..._items];
  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    for (var item in _items) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  // Initial load from Supabase
  Future<void> fetchCart() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _supabase
          .from('cart_items')
          .select('*, products(*)')
          .eq('user_id', user.id);

      _items.clear();
      for (var row in data) {
        final product = Product.fromJson(row['products']);
        _items.add(CartItem(
          product: product,
          selectedSize: row['selected_size'],
          quantity: row['quantity'],
        ));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching cart: $e');
    }
  }

  Future<void> addItem(Product product, String size, int quantity) async {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id && item.selectedSize == size,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(
        product: product,
        selectedSize: size,
        quantity: quantity,
      ));
    }
    notifyListeners();

    // Sync to Supabase if logged in
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('cart_items').upsert({
          'user_id': user.id,
          'product_id': product.id,
          'selected_size': size,
          'quantity': existingIndex >= 0 ? _items[existingIndex].quantity : quantity,
        });
      } catch (e) {
        debugPrint('Error syncing to DB: $e');
      }
    }
  }

  Future<void> removeItem(dynamic productId, String size) async {
    _items.removeWhere(
      (item) => item.product.id == productId && item.selectedSize == size,
    );
    notifyListeners();

    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase
            .from('cart_items')
            .delete()
            .eq('user_id', user.id)
            .eq('product_id', productId)
            .eq('selected_size', size);
      } catch (e) {
        debugPrint('Error deleting from DB: $e');
      }
    }
  }

  Future<void> updateQuantity(dynamic productId, String size, int newQuantity) async {
    final index = _items.indexWhere(
      (item) => item.product.id == productId && item.selectedSize == size,
    );
    
    if (index >= 0) {
      if (newQuantity <= 0) {
        await removeItem(productId, size);
      } else {
        _items[index].quantity = newQuantity;
        notifyListeners();

        final user = _supabase.auth.currentUser;
        if (user != null) {
          try {
            await _supabase
                .from('cart_items')
                .update({'quantity': newQuantity})
                .eq('user_id', user.id)
                .eq('product_id', productId)
                .eq('selected_size', size);
          } catch (e) {
            debugPrint('Error updating DB: $e');
          }
        }
      }
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
