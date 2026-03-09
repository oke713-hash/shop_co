import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/product.dart';
import '../../main.dart'; // Colors
import '../login_screen.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const SellerOverviewStats(),
    const SellerOrdersView(),
    const SellerMembersView(),
    const SellerInventory(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการร้านค้า (Sakuraya)'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: kDarkBrown),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: kPink,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'ภาพรวม',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            activeIcon: Icon(Icons.local_shipping),
            label: 'ออเดอร์',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'สมาชิก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'คลังสินค้า',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 3
          ? FloatingActionButton.extended(
              onPressed: () => _showAddProductDialog(context),
              backgroundColor: kPink,
              icon: const Icon(Icons.add, color: kDarkBrown),
              label: const Text(
                'เพิ่มสินค้า',
                style: TextStyle(
                  color: kDarkBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final imageUrlController = TextEditingController();
    final stockController = TextEditingController();
    String selectedCategory = categories.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'เพิ่มสินค้าใหม่',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อสินค้า',
                      ),
                    ),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'ราคา (บาท)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'หมวดหมู่'),
                      items: categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          if (val != null) selectedCategory = val;
                        });
                      },
                    ),
                    TextField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL รูปภาพสินค้า',
                      ),
                    ),
                    TextField(
                      controller: stockController,
                      decoration: const InputDecoration(
                        labelText: 'จำนวนสต๊อกสินค้า',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'ยกเลิก',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final productData = {
                        'name': nameController.text,
                        'price': double.parse(priceController.text),
                        'category': selectedCategory,
                        'image_url': imageUrlController.text.isNotEmpty
                            ? imageUrlController.text
                            : 'https://picsum.photos/400/500',
                        'stock': int.parse(stockController.text),
                      };
                      await Supabase.instance.client
                          .from('products')
                          .insert(productData);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('เพิ่มสินค้าเรียบร้อย!'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                        );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'บันทึก',
                    style: TextStyle(
                      color: kDarkBrown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class SellerOverviewStats extends StatelessWidget {
  const SellerOverviewStats({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Supabase.instance.client.from('orders').select(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final List orders = snapshot.data as List;
        final totalSales = orders
            .where((o) => o['status'] != 'cancelled')
            .fold(0.0, (sum, o) => sum + (o['total_amount'] as num));
        final orderCount = orders.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ภาพรวมความสำเร็จ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatCard(
                    'ยอดขายรวม',
                    '฿ ${totalSales.toInt()}',
                    kLightGreen,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard('จำนวนสั่งซื้อ', '$orderCount', kLightYellow),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'ออเดอร์ล่าสุด',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (orders.isEmpty)
                const Center(child: Text('ยังไม่มีออเดอร์ในระบบ'))
              else
                ...orders.reversed
                    .take(5)
                    .map((order) => _buildOrderMiniCard(order)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderMiniCard(Map<String, dynamic> order) {
    final status = order['status'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'คุณ ${order['recipient_name']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '฿ ${order['total_amount']}',
                style: const TextStyle(color: kPink, fontSize: 13),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'waiting_shipment'
                  ? kPink.withOpacity(0.1)
                  : (status == 'cancelled'
                        ? Colors.red.withOpacity(0.1)
                        : (status == 'delivered'
                              ? kLightGreen.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1))),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status == 'waiting_shipment'
                  ? 'รอส่ง'
                  : (status == 'cancelled'
                        ? 'ยกเลิก'
                        : (status == 'delivered' ? 'สำเร็จ' : 'ส่งแล้ว')),
              style: TextStyle(
                color: status == 'waiting_shipment'
                    ? kPink
                    : (status == 'cancelled'
                          ? Colors.red
                          : (status == 'delivered'
                                ? kLightGreen
                                : Colors.blue)),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 1),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: kDarkBrown),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kDarkBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SellerOrdersView extends StatelessWidget {
  const SellerOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('orders')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final orders = snapshot.data!;
        if (orders.isEmpty)
          return const Center(child: Text('ยังไม่มีคำสั่งซื้อในระบบ'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final status = order['status'];
            final items = order['items'] as List;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ExpansionTile(
                title: Text(
                  'คุณ ${order['recipient_name']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'โทร: ${order['phone']} | ฿ ${order['total_amount']}',
                ),
                leading: CircleAvatar(
                  backgroundColor: status == 'waiting_shipment'
                      ? kPink
                      : (status == 'cancelled'
                            ? Colors.red
                            : (status == 'delivered'
                                  ? kLightGreen
                                  : Colors.blue)),
                  child: Icon(
                    status == 'waiting_shipment'
                        ? Icons.timer
                        : (status == 'cancelled'
                              ? Icons.cancel
                              : (status == 'delivered'
                                    ? Icons.done_all
                                    : Icons.local_shipping)),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ข้อมูลที่อยู่จัดส่ง:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${order['address']} ${order['postal_code']}'),
                        const Divider(height: 24),
                        if (status == 'cancelled' &&
                            order['cancel_reason'] != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade100),
                            ),
                            child: Text(
                              'เหตุผลการยกเลิก: ${order['cancel_reason']}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const Text(
                          'รายการสินค้า:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item['name']} (Size: ${item['size']}) x${item['quantity']}',
                                ),
                                Text('฿ ${item['price'] * item['quantity']}'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (status == 'waiting_shipment')
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _updateOrderStatus(
                                    context,
                                    order['id'],
                                    'shipped',
                                  ),
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'จัดส่งแล้ว',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPink,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _showCancelDialog(context, order['id']),
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  label: const Text(
                                    'ยกเลิก',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          )
                        else if (status == 'shipped')
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _updateOrderStatus(
                                context,
                                order['id'],
                                'delivered',
                              ),
                              icon: const Icon(
                                Icons.done_all,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'ลูกค้าได้รับของแล้ว',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kLightGreen,
                              ),
                            ),
                          )
                        else if (status == 'delivered')
                          const Center(
                            child: Chip(
                              label: Text(
                                'รายการสำเร็จแล้ว ✨',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: kLightGreen,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateOrderStatus(
    BuildContext context,
    String orderId,
    String newStatus,
  ) async {
    try {
      await Supabase.instance.client
          .from('orders')
          .update({'status': newStatus})
          .eq('id', orderId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('อัปเดตเป็น $newStatus สำเร็จ!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ผิดพลาด: $e'), backgroundColor: Colors.red),
        );
    }
  }

  void _showCancelDialog(BuildContext context, String orderId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยกเลิกออเดอร์'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'ระบุเหตุผลการยกเลิก',
            hintText: 'เช่น สินค้าหมด',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('กลับ'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) return;
              try {
                await Supabase.instance.client
                    .from('orders')
                    .update({
                      'status': 'cancelled',
                      'cancel_reason': reasonController.text.trim(),
                    })
                    .eq('id', orderId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ยกเลิกออเดอร์เรียบร้อยแล้ว'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ล้มเหลว: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'ยืนยันยกเลิก',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class SellerMembersView extends StatelessWidget {
  const SellerMembersView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Supabase.instance.client
          .from('profiles')
          .select()
          .order('created_at'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return const Center(
            child: Text('เกิดข้อผิดพลาดในการดึงข้อมูลสมาชิก'),
          );
        final members = snapshot.data as List;
        if (members.isEmpty)
          return const Center(child: Text('ยังไม่มีลูกค้าสมัครสมาชิกครับ'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: kPink.withOpacity(0.1),
                  child: Text(
                    (member['full_name'] ?? 'U')[0],
                    style: const TextStyle(color: kPink),
                  ),
                ),
                title: Text(
                  member['full_name'] ?? 'ไม่ระบุชื่อ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(member['email'] ?? 'ไม่มีอีเมล'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () => _showMemberDetails(context, member),
              ),
            );
          },
        );
      },
    );
  }

  void _showMemberDetails(BuildContext context, dynamic member) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ข้อมูลสมาชิกอย่างละเอียด',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 32),
            _buildDetailRow('ชื่อ:', member['full_name'] ?? '-'),
            _buildDetailRow('โทร:', member['phone'] ?? '-'),
            _buildDetailRow('ที่อยู่:', member['address'] ?? '-'),
            _buildDetailRow('เพศ:', member['gender'] ?? '-'),
            _buildDetailRow('อีเมล:', member['email'] ?? '-'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class SellerInventory extends StatelessWidget {
  const SellerInventory({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('products')
          .stream(primaryKey: ['id']),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final products = snapshot.data!
            .map((e) => Product.fromJson(e))
            .toList();
        if (products.isEmpty)
          return const Center(child: Text('ยังไม่มีสินค้าในคลัง'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.image),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'หมวดหมู่: ${product.category}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '฿${product.price.toInt()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kPink,
                                ),
                              ),
                              Text(
                                'คงเหลือ: ${product.stock}',
                                style: TextStyle(
                                  color: product.stock < 5
                                      ? Colors.red
                                      : kDarkBrown,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () => _showEditProductDialog(context, product),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteProduct(context, product.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(
      text: product.price.toInt().toString(),
    );
    final imageUrlController = TextEditingController(text: product.imageUrl);
    final stockController = TextEditingController(
      text: product.stock.toString(),
    );
    String selectedCategory = product.category;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'แก้ไขสินค้า',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อสินค้า',
                      ),
                    ),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'ราคา (บาท)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'หมวดหมู่'),
                      items: categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedCategory = val);
                        }
                      },
                    ),
                    TextField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL รูปภาพ',
                      ),
                    ),
                    TextField(
                      controller: stockController,
                      decoration: const InputDecoration(
                        labelText: 'จำนวนสต๊อก',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'ยกเลิก',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      await Supabase.instance.client
                          .from('products')
                          .update({
                            'name': nameController.text.trim(),
                            'price': double.parse(priceController.text.trim()),
                            'category': selectedCategory,
                            'image_url': imageUrlController.text.trim().isEmpty
                                ? product.imageUrl
                                : imageUrlController.text.trim(),
                            'stock': int.parse(stockController.text.trim()),
                          })
                          .eq('id', product.id);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('อัปเดตสินค้าเรียบร้อย ✅'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('เกิดข้อผิดพลาด: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'บันทึก',
                    style: TextStyle(
                      color: kDarkBrown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteProduct(BuildContext context, dynamic productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'ลบสินค้า',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'คุณต้องการลบสินค้านี้ออกจากคลังใช่ไหม?\nการลบจะไม่สามารถกู้คืนได้',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              try {
                await Supabase.instance.client
                    .from('products')
                    .delete()
                    .eq('id', productId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ลบสินค้าเรียบร้อยแล้ว'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('เกิดข้อผิดพลาด: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'ลบสินค้า',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
