import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import 'buyer/home_screen.dart';
import 'seller/seller_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // New Signup Fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _selectedGender = 'ไม่ระบุ';

  bool _isLoading = false;
  bool _isSignUp = false; // Toggle between Login and Sign Up mode
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('กรุณากรอกอีเมลและรหัสผ่านให้ครบถ้วนค่ะ 🌸', isError: true);
      return;
    }

    if (_isSignUp) {
      if (_nameController.text.trim().isEmpty ||
          _phoneController.text.trim().isEmpty ||
          _birthDateController.text.trim().isEmpty ||
          _addressController.text.trim().isEmpty) {
        _showSnackBar(
          'กรุณากรอกข้อมูลส่วนตัวให้ครบถ้วนก่อนสมัครนะคะ 🌸',
          isError: true,
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final selectedRole = _tabController.index == 0 ? 'buyer' : 'seller';

      if (selectedRole == 'seller') {
        // --- ผู้ขาย (Seller / Admin) ---
        // ใช้ระบบ Real Login สำหรับ Admin เพื่อให้ RLS ทำงานถูกต้อง
        try {
          // ในระบบนี้เราใช้ email เป็น teat.112233@sakuraya.com เป็นหลัก
          final loginEmail = email.contains('@')
              ? email
              : '$email@sakuraya.com';

          await Supabase.instance.client.auth.signInWithPassword(
            email: loginEmail,
            password: password,
          );

          _showSnackBar('เข้าสู่ระบบผู้ดูแลร้านค้าสำเร็จ! 🏪');
          _navigateToDashboard();
        } catch (e) {
          _showSnackBar(
            'ไม่สามารถเข้าสู่ระบบผู้ขาย: ${e.toString()}',
            isError: true,
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (_isSignUp) {
        // --- สมัครสมาชิก (Sign Up - Buyer Only) ---
        final AuthResponse res = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {
            'role': selectedRole,
            'full_name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'gender': _selectedGender,
            'birth_date': _birthDateController.text.trim(),
            'address': _addressController.text.trim(),
          },
        );

        if (res.user != null) {
          _showSnackBar('สมัครสมาชิกผู้ซื้อสำเร็จ! ยินดีต้อนรับค่ะ 🎉');
          _navigateToDashboard();
        }
      } else {
        // --- เข้าสู่ระบบ (Log In - Buyer) ---
        final AuthResponse res = await Supabase.instance.client.auth
            .signInWithPassword(email: email, password: password);

        if (res.session != null) {
          final userRole = res.user?.userMetadata?['role'];

          if (userRole != null && userRole != selectedRole) {
            _showSnackBar('บัญชีนี้ไม่ใช่ผู้ซื้อค่ะ!', isError: true);
            await Supabase.instance.client.auth.signOut();
            return;
          }

          _navigateToDashboard();
        }
      }
    } on AuthException catch (e) {
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToDashboard() {
    if (!mounted) return;

    if (_tabController.index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BuyerMainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SellerDashboard()),
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade300 : kLightGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // โลโก้แบรนด์
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: kPink.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite, size: 60, color: kPink),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'SAKURAYA',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: kDarkBrown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Fashion • Funleash your inner kawaii',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: kBackground,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              onTap: (index) {
                                setState(() {
                                  // Force login mode when switching to seller, hide signup toggle
                                  if (index == 1) {
                                    _isSignUp = false;
                                  }
                                  _emailController.clear();
                                  _passwordController.clear();
                                });
                              },
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: kPink,
                              ),
                              labelColor: Colors.white,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              unselectedLabelColor: kDarkBrown.withValues(
                                alpha: 0.6,
                              ),
                              tabs: const [
                                Tab(text: '👤 ผู้ซื้อ'),
                                Tab(text: '🏪 ผู้ขาย'),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _isSignUp ? 'สร้างบัญชีใหม่' : 'เข้าสู่ระบบ',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: kDarkBrown,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Email Field (Changed from Username)
                              TextField(
                                controller: _emailController,
                                keyboardType: _tabController.index == 0
                                    ? TextInputType.emailAddress
                                    : TextInputType.text,
                                decoration: InputDecoration(
                                  labelText: _tabController.index == 0
                                      ? 'อีเมล (Email)'
                                      : 'ชื่อผู้ใช้ (Username)',
                                  prefixIcon: Icon(
                                    _tabController.index == 0
                                        ? Icons.email_outlined
                                        : Icons.storefront_outlined,
                                    color: kPink,
                                  ),
                                  filled: true,
                                  fillColor: kBackground,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Password field
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'รหัสผ่าน (Password)',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: kPink,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: kBackground,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),

                              if (_isSignUp) ...[
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 16),
                                const Text(
                                  'ข้อมูลส่วนตัว',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: kDarkBrown,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'ชื่อ-นามสกุล',
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                      color: kPink,
                                    ),
                                    filled: true,
                                    fillColor: kBackground,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: 'เบอร์โทรศัพท์',
                                    prefixIcon: const Icon(
                                      Icons.phone_outlined,
                                      color: kPink,
                                    ),
                                    filled: true,
                                    fillColor: kBackground,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // แบบฟอร์มแปลกๆ เล็กๆ เพื่อประหยัดพื้นที่
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: kBackground,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: _selectedGender,
                                            isExpanded: true,
                                            icon: const Icon(
                                              Icons.arrow_drop_down,
                                              color: kPink,
                                            ),
                                            items:
                                                [
                                                  'ไม่ระบุ',
                                                  'ชาย',
                                                  'หญิง',
                                                  'อื่นๆ',
                                                ].map((String value) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                            onChanged: (newValue) {
                                              setState(() {
                                                _selectedGender = newValue!;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextField(
                                        controller: _birthDateController,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          labelText: 'วันเกิด',
                                          prefixIcon: const Icon(
                                            Icons.calendar_today,
                                            color: kPink,
                                            size: 20,
                                          ),
                                          filled: true,
                                          fillColor: kBackground,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        onTap: () async {
                                          DateTime? pickedDate =
                                              await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now()
                                                    .subtract(
                                                      const Duration(
                                                        days: 365 * 18,
                                                      ),
                                                    ), // Default 18 years ago
                                                firstDate: DateTime(1900),
                                                lastDate: DateTime.now(),
                                              );
                                          if (pickedDate != null) {
                                            setState(() {
                                              _birthDateController.text =
                                                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _addressController,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    labelText: 'ที่อยู่ปัจจุบัน',
                                    prefixIcon: const Icon(
                                      Icons.home_outlined,
                                      color: kPink,
                                    ),
                                    filled: true,
                                    fillColor: kBackground,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ],

                              if (!_isSignUp)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed:
                                        () {}, // TODO: Forgot password flow
                                    child: const Text(
                                      'ลืมรหัสผ่าน?',
                                      style: TextStyle(
                                        color: kDarkBrown,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(height: 24),

                              // Auth Button
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleAuth,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kDarkBrown,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          _isSignUp
                                              ? 'สมัครสมาชิก ✨'
                                              : 'เข้าสู่ระบบเลย! ✨',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const SizedBox(height: 24),

                  // Toggle Mode Button (Only for Buyer)
                  if (_tabController.index == 0)
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _isSignUp
                              ? 'มีบัญชีอยู่แล้วใช่ไหม?'
                              : 'ยังไม่มีบัญชีใช่ไหม?',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                              // Clear fields when toggling
                              _emailController.clear();
                              _passwordController.clear();
                              _nameController.clear();
                              _phoneController.clear();
                              _birthDateController.clear();
                              _addressController.clear();
                              _selectedGender = 'ไม่ระบุ';
                            });
                          },
                          child: Text(
                            _isSignUp
                                ? 'เข้าสู่ระบบที่นี่'
                                : 'สมัครสมาชิกที่นี่',
                            style: const TextStyle(
                              color: kPink,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
