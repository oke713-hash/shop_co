import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/product.dart';
import 'product_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'tracking_screen.dart';

// ─── Sakuraya Design Tokens ────────────────────────────────────────────────
const _cream = Color(0xFFF7F3EE);
const _blush = Color(0xFFE8D5C4);
const _charcoal = Color(0xFF1A1A1A);
const _mist = Color(0xFF9B9590);
const _gold = Color(0xFFC9A96E);

// ─── Main Shell ────────────────────────────────────────────────────────────
class BuyerMainScreen extends StatefulWidget {
  const BuyerMainScreen({super.key});

  @override
  State<BuyerMainScreen> createState() => _BuyerMainScreenState();
}

class _BuyerMainScreenState extends State<BuyerMainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchCart();
    });
  }

  final List<Widget> _pages = [
    const HomeView(),
    const CategoriesView(),
    const CartScreen(),
    const TrackingScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: _SakurayaBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ─── Bottom Navigation ─────────────────────────────────────────────────────
class _SakurayaBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SakurayaBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'หน้าแรก',
      ),
      _NavItem(
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view_rounded,
        label: 'หมวดหมู่',
      ),
      _NavItem(
        icon: Icons.shopping_bag_outlined,
        activeIcon: Icons.shopping_bag_rounded,
        label: 'ตะกร้า',
      ),
      _NavItem(
        icon: Icons.local_shipping_outlined,
        activeIcon: Icons.local_shipping_rounded,
        label: 'ติดตาม',
      ),
      _NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'ไอดี',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isActive = currentIndex == i;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? _charcoal.withValues(alpha: 0.07)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cart badge
                  if (i == 2)
                    Consumer<CartProvider>(
                      builder: (ctx, cart, _) => Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            isActive ? item.activeIcon : item.icon,
                            color: isActive ? _charcoal : _mist,
                            size: 22,
                          ),
                          if (cart.itemCount > 0)
                            Positioned(
                              top: -4,
                              right: -6,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: _gold,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${cart.itemCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  else
                    Icon(
                      isActive ? item.activeIcon : item.icon,
                      color: isActive ? _charcoal : _mist,
                      size: 22,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive ? _charcoal : _mist,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  _NavItem({required this.icon, required this.activeIcon, required this.label});
}

// ─── Home View ─────────────────────────────────────────────────────────────
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _marqueeController;
  String _selectedCategory = 'ทั้งหมด';

  final List<String> _pills = [
    'ทั้งหมด',
    'เสื้อ',
    'กระโปรง',
    'กางเกง',
    'เครื่องประดับ',
    'ชุดเซ็ต',
  ];

  @override
  void initState() {
    super.initState();
    _marqueeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _marqueeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return CustomScrollView(
      slivers: [
        // ── App Bar ──
        SliverToBoxAdapter(child: _buildAppBar(topPad)),

        // ── Hero Banner ──
        SliverToBoxAdapter(child: _buildHero()),

        // ── Marquee Strip ──
        SliverToBoxAdapter(child: _buildMarquee()),

        // ── Category Pills ──
        SliverToBoxAdapter(child: _buildCategoryPills()),

        // ── Section Header ──
        SliverToBoxAdapter(child: _buildSectionHeader()),

        // ── Products Grid ──
        _buildProductsGrid(),

        // ── Featured Strip ──
        SliverToBoxAdapter(child: _buildFeaturedStrip()),

        // ── Bottom spacer ──
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildAppBar(double topPad) {
    return Container(
      color: _cream,
      padding: EdgeInsets.only(
        top: topPad + 12,
        left: 24,
        right: 24,
        bottom: 14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          const Text(
            'SAKURAYA',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 22,
              fontWeight: FontWeight.w300,
              letterSpacing: 5,
              color: _charcoal,
            ),
          ),
          // Icons
          Row(
            children: [
              _AppBarIcon(icon: Icons.search_rounded, onTap: () {}),
              const SizedBox(width: 4),
              _AppBarIcon(icon: Icons.favorite_border_rounded, onTap: () {}),
              const SizedBox(width: 4),
              Consumer<CartProvider>(
                builder: (ctx, cart, _) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _AppBarIcon(
                      icon: Icons.shopping_bag_outlined,
                      onTap: () {},
                    ),
                    if (cart.itemCount > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: _gold,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${cart.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0EBE4), Color(0xFFE8D8CC), Color(0xFFF5EDE8)],
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Watermark text
          Positioned(
            top: 20,
            left: -20,
            child: Text(
              'Weekend Hub',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 60,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
                color: Colors.black.withValues(alpha: 0.05),
                height: 1,
              ),
            ),
          ),

          // Right side fashion image
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 140,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=400&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              foregroundDecoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFEDE8E2), Colors.transparent],
                ),
              ),
            ),
          ),

          // Content — use Positioned to avoid Column overflow
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 140,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 12, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: _gold.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '✦  Spring 2026',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.5,
                        color: _gold,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Title
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 36,
                        fontWeight: FontWeight.w300,
                        color: _charcoal,
                        height: 1.15,
                      ),
                      children: [
                        TextSpan(text: 'Soft\n'),
                        TextSpan(
                          text: 'Feminine\n',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: _mist,
                          ),
                        ),
                        TextSpan(text: 'Stories'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'New Collection — Weekend Hub',
                    style: TextStyle(
                      fontSize: 10,
                      color: _mist,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Button
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _charcoal,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Shop New In',
                            style: TextStyle(
                              color: _cream,
                              fontSize: 10,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward, color: _cream, size: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarquee() {
    final List<String> items = [
      'New Arrivals',
      '  ✦  ',
      'Free Shipping over ฿2000',
      '  ✦  ',
      'Weekend Hub Collection',
      '  ✦  ',
      'Feminine Essentials',
      '  ✦  ',
    ];
    // Repeat 3x to ensure seamless loop across all screen sizes
    final repeated = [...items, ...items, ...items];
    const itemWidth = 160.0;
    final totalSetWidth = items.length * itemWidth; // one full set in px

    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(vertical: 16),
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(color: _charcoal),
      child: AnimatedBuilder(
        animation: _marqueeController,
        builder: (_, child) {
          final dx = -(_marqueeController.value * totalSetWidth);
          return OverflowBox(
            // Allow the Row to be as wide as it needs — no overflow error
            maxWidth: double.infinity,
            alignment: Alignment.centerLeft,
            child: Transform.translate(offset: Offset(dx, 0), child: child),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: repeated.map((text) {
            final isDot = text.contains('✦');
            return SizedBox(
              width: itemWidth,
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: isDot ? 0 : 2.5,
                    color: isDot ? _gold : Colors.white.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryPills() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _pills.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isActive = _pills[i] == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = _pills[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? _charcoal : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: isActive ? _charcoal : _mist.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                _pills[i],
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.5,
                  color: isActive ? _cream : _mist,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          const Text(
            '01 / ',
            style: TextStyle(
              fontFamily: 'serif',
              fontStyle: FontStyle.italic,
              fontSize: 13,
              color: _mist,
            ),
          ),
          const Expanded(
            child: Text(
              'New Arrivals',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 26,
                fontWeight: FontWeight.w400,
                color: _charcoal,
                letterSpacing: -0.3,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Row(
              children: [
                Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: _mist,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 12, color: _mist),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid() {
    // Build the Supabase stream query
    var query = Supabase.instance.client
        .from('products')
        .stream(primaryKey: ['id'])
        .order('id', ascending: false)
        .limit(8);

    return SliverToBoxAdapter(
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: query,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(48),
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: _mist,
                  ),
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'ยังไม่มีสินค้าในร้านค่ะ',
                  style: TextStyle(color: _mist, fontSize: 13),
                ),
              ),
            );
          }

          List<Product> products = snapshot.data!
              .map((e) => Product.fromJson(e))
              .toList();

          // Filter by category if selected
          if (_selectedCategory != 'ทั้งหมด') {
            products = products
                .where((p) => p.category == _selectedCategory)
                .toList();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                crossAxisSpacing: 14,
                mainAxisSpacing: 22,
              ),
              itemBuilder: (context, index) {
                return _SakurayaProductCard(
                  product: products[index],
                  isNew: index == 0 || index == 3,
                  isBest: index == 2,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedStrip() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 40, 16, 0),
      decoration: BoxDecoration(
        color: _charcoal,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.62),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✦  WEEKEND HUB EDIT',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 3,
                    color: _gold,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Dressed for\nsoft moments',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 36,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Our Weekend Hub collection celebrates\nthe in-between — effortless pieces for\ndays that ask nothing but to feel beautiful.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.55),
                    height: 1.9,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    _FeaturedButton(
                      label: 'Shop the Edit',
                      filled: true,
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    _FeaturedButton(
                      label: 'Lookbook',
                      filled: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Product Card ──────────────────────────────────────────────────────────
class _SakurayaProductCard extends StatefulWidget {
  final Product product;
  final bool isNew;
  final bool isBest;

  const _SakurayaProductCard({
    required this.product,
    this.isNew = false,
    this.isBest = false,
  });

  @override
  State<_SakurayaProductCard> createState() => _SakurayaProductCardState();
}

class _SakurayaProductCardState extends State<_SakurayaProductCard>
    with SingleTickerProviderStateMixin {
  bool _wishlisted = false;
  late AnimationController _heartController;
  late Animation<double> _heartAnim;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartAnim = Tween<double>(begin: 1, end: 1.35).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _toggleWishlist() {
    setState(() => _wishlisted = !_wishlisted);
    _heartController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, animation, __) =>
                ProductDetailScreen(product: widget.product),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image container
          Expanded(
            child: Stack(
              children: [
                // Image
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _blush.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Image.network(
                    widget.product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: _blush.withValues(alpha: 0.3),
                      child: const Icon(
                        Icons.image_outlined,
                        color: _mist,
                        size: 36,
                      ),
                    ),
                  ),
                ),

                // Badge
                if (widget.isNew || widget.isBest)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isNew ? _gold : _charcoal,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.isNew ? 'NEW' : 'BEST',
                        style: TextStyle(
                          fontSize: 8,
                          letterSpacing: 1.5,
                          color: widget.isNew ? _charcoal : _cream,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Wishlist button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _toggleWishlist,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: AnimatedBuilder(
                        animation: _heartAnim,
                        builder: (_, child) => Transform.scale(
                          scale: _heartAnim.value,
                          child: child,
                        ),
                        child: Icon(
                          _wishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                          color: _wishlisted ? const Color(0xFFE87878) : _mist,
                        ),
                      ),
                    ),
                  ),
                ),

                // Quick add overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
                    child: GestureDetector(
                      onTap: () {
                        // Quick add to cart
                        final cart = Provider.of<CartProvider>(
                          context,
                          listen: false,
                        );
                        cart.addItem(widget.product, 'M', 1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'เพิ่ม ${widget.product.name} ในตะกร้าแล้ว',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: _charcoal,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(16),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Quick Add  +',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            color: _charcoal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product info
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: _charcoal,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _StarRating(rating: 4.5),
                    const SizedBox(width: 5),
                    const Text(
                      '4.5',
                      style: TextStyle(
                        fontSize: 10,
                        color: _mist,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '฿${widget.product.price.toInt()}',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: _charcoal,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final double rating;
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star_rounded, color: _gold, size: 13);
        } else if (i < rating) {
          return const Icon(Icons.star_half_rounded, color: _gold, size: 13);
        }
        return const Icon(Icons.star_outline_rounded, color: _gold, size: 13);
      }),
    );
  }
}

// ─── Featured Strip Buttons ────────────────────────────────────────────────
class _FeaturedButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _FeaturedButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        decoration: BoxDecoration(
          color: filled ? _cream : Colors.transparent,
          border: Border.all(
            color: filled ? _cream : Colors.white.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                color: filled
                    ? _charcoal
                    : Colors.white.withValues(alpha: 0.65),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (filled) ...[
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward, color: _charcoal, size: 13),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── App Bar Icon ──────────────────────────────────────────────────────────
class _AppBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        child: Icon(icon, color: _charcoal, size: 22),
      ),
    );
  }
}

// ─── Categories View ───────────────────────────────────────────────────────
class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: _cream,
            padding: EdgeInsets.only(
              top: topPad + 16,
              left: 24,
              right: 24,
              bottom: 20,
            ),
            child: const Text(
              'COLLECTIONS',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 22,
                fontWeight: FontWeight.w300,
                letterSpacing: 5,
                color: _charcoal,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final cat = categories[index];
              final imgs = _categoryImages[index % _categoryImages.length];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryProductsScreen(category: cat),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(imgs),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.38),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          cat,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }, childCount: categories.length),
          ),
        ),
      ],
    );
  }

  static const _categoryImages = [
    'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&q=80',
    'https://images.unsplash.com/photo-1529139574466-a303027614b2?w=600&q=80',
    'https://images.unsplash.com/photo-1485968579580-b6d095142e6e?w=600&q=80',
    'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=600&q=80',
    'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=600&q=80',
    'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=600&q=80',
    'https://images.unsplash.com/photo-1617019114583-affb34d1b3cd?w=600&q=80',
  ];
}

// ─── Category Products Screen ───────────────────────────────────────────────
class CategoryProductsScreen extends StatelessWidget {
  final String category;
  const CategoryProductsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _charcoal,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          category.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 18,
            fontWeight: FontWeight.w300,
            letterSpacing: 4,
            color: _charcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('products')
            .stream(primaryKey: ['id'])
            .eq('category', category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: _mist,
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'ไม่มีสินค้าในหมวดหมู่นี้',
                style: TextStyle(color: _mist),
              ),
            );
          }

          final catProducts = snapshot.data!
              .map((e) => Product.fromJson(e))
              .toList();

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: catProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 14,
              mainAxisSpacing: 22,
            ),
            itemBuilder: (context, index) =>
                _SakurayaProductCard(product: catProducts[index]),
          );
        },
      ),
    );
  }
}

// ─── Legacy ProductCard alias (used nowhere new but kept for compatibility) ──
class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return _SakurayaProductCard(product: product);
  }
}
