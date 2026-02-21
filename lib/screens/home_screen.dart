import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telemost12_app/theme/app_theme.dart';
import 'package:telemost12_app/widgets/glass_panel.dart';
import 'package:telemost12_app/widgets/product_image.dart';
import 'package:telemost12_app/models/product.dart';
import 'package:telemost12_app/services/cart_service.dart';
import 'package:telemost12_app/services/favorites_service.dart';
import 'package:telemost12_app/services/comparison_service.dart';
import 'package:telemost12_app/services/sessions_service.dart';
import 'package:telemost12_app/services/realtime_sync_service.dart';
import 'package:telemost12_app/services/profile_service.dart';
import 'package:telemost12_app/services/orders_service.dart';
import 'package:telemost12_app/services/addresses_service.dart';
import 'package:telemost12_app/services/saved_cards_service.dart';
import 'package:telemost12_app/services/recently_viewed_service.dart';
import 'package:telemost12_app/services/points_service.dart';
import 'package:telemost12_app/services/product_service.dart';
import 'package:telemost12_app/services/auth_service.dart';
import 'package:telemost12_app/services/promo_service.dart';
import 'package:telemost12_app/screens/product_detail_screen.dart';
import 'package:telemost12_app/screens/favorites_screen.dart';
import 'package:telemost12_app/screens/checkout_screen.dart';
import 'package:telemost12_app/screens/orders_screen.dart';
import 'package:telemost12_app/screens/addresses_screen.dart';
import 'package:telemost12_app/screens/search_screen.dart';
import 'package:telemost12_app/screens/category_screen.dart';
import 'package:telemost12_app/screens/comparison_screen.dart';
import 'package:telemost12_app/screens/devices_screen.dart';
import 'package:telemost12_app/screens/settings_screen.dart';
import 'package:telemost12_app/screens/help_screen.dart';
import 'package:telemost12_app/screens/edit_profile_screen.dart';
import 'package:telemost12_app/screens/points_qr_screen.dart';
import 'package:telemost12_app/l10n/app_localizations.dart';
import 'package:telemost12_app/services/currency_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.userName});

  final String? userName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? _savedPromo;

  List<(String, IconData)> _categories(BuildContext context) => [
    (context.l10n('category_clothing'), Icons.checkroom_outlined),
    (context.l10n('category_shoes'), Icons.shopping_bag_outlined),
    (context.l10n('category_accessories'), Icons.watch_outlined),
    (context.l10n('category_new'), Icons.star_outline_rounded),
  ];

  @override
  void initState() {
    super.initState();
    CartService.instance.load();
    FavoritesService.instance.load();
    AddressesService.instance.load();
    SavedCardsService.instance.load();
    SessionsService.instance.load().then((_) async {
      await SessionsService.instance.addCurrentSession();
      SessionsService.instance.startHeartbeat();
      if (!mounted) return;
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid != null) {
        await Future.delayed(const Duration(milliseconds: 1500));
        if (!mounted) return;
        RealtimeSyncService.instance.subscribe(uid);
      }
    });
    OrdersService.instance.load();
    RecentlyViewedService.instance.load();
    PointsService.instance.load();
    ProductService.instance.load();
    ProfileService.instance.load(widget.userName);
    CartService.instance.addListener(_onCartChanged);
    ProfileService.instance.addListener(_onCartChanged);
    FavoritesService.instance.addListener(_onCartChanged);
    OrdersService.instance.addListener(_onCartChanged);
    RecentlyViewedService.instance.addListener(_onCartChanged);
    PointsService.instance.addListener(_onCartChanged);
    ProductService.instance.addListener(_onCartChanged);
    _loadPromo();
  }

  Future<void> _loadPromo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _savedPromo = prefs.getString('yanikov_promo'));
  }

  void _onCartChanged() => setState(() {});

  String _getProductImagePath(String productId) {
    final p = ProductService.instance.byId(productId) ?? Product.byId(productId);
    return p?.imagePath ?? 'assets/products/$productId.jpg';
  }

  @override
  void dispose() {
    CartService.instance.removeListener(_onCartChanged);
    ProfileService.instance.removeListener(_onCartChanged);
    FavoritesService.instance.removeListener(_onCartChanged);
    OrdersService.instance.removeListener(_onCartChanged);
    RecentlyViewedService.instance.removeListener(_onCartChanged);
    PointsService.instance.removeListener(_onCartChanged);
    ProductService.instance.removeListener(_onCartChanged);
    super.dispose();
  }

  String _getMemberLevel() {
    final count = OrdersService.instance.orders.length;
    if (count >= 10) return 'Золото';
    if (count >= 3) return 'Серебро';
    return 'Бронза';
  }

  Color _getMemberLevelColor() {
    final level = _getMemberLevel();
    if (level == 'Золото') return const Color(0xFFFFD700);
    if (level == 'Серебро') return const Color(0xFFC0C0C0);
    return const Color(0xFFCD7F32);
  }

  Future<void> _showPromoDialog(BuildContext context) async {
    final c = AppTheme.of(context);
    final controller = TextEditingController();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: c.surfaceElevated,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: c.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Введите промокод',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: GoogleFonts.outfit(color: c.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Промокод',
                  hintStyle: GoogleFonts.outfit(color: c.textSecondary),
                  filled: true,
                  fillColor: c.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final code = controller.text.trim().toUpperCase();
                    if (code.isEmpty) return;
                    final result = await PromoService.validate(code);
                    if (!ctx.mounted) return;
                    if (!result.valid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Промокод $code не найден или недействителен.',
                            style: GoogleFonts.outfit(color: Colors.white),
                          ),
                          backgroundColor: Colors.red.shade800,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('yanikov_promo', code);
                    await prefs.setInt('yanikov_promo_discount', result.discountPercent);
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      _loadPromo();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Промокод $code применён! Скидка ${result.discountPercent}% будет учтена при заказе.',
                            style: GoogleFonts.outfit(color: Colors.white),
                          ),
                          backgroundColor: c.surfaceElevated,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Применить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: c.backgroundGradient,
        child: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _buildCatalogTab(),
              _buildCartTab(),
              _buildProfileTab(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final c = AppTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.grid_view_rounded, context.l10n('catalog')),
              _navItemWithBadge(1, Icons.shopping_cart_outlined, context.l10n('cart'), CartService.instance.totalCount),
              _navItem(2, Icons.person_outline_rounded, context.l10n('profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final c = AppTheme.of(context);
    final selected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected ? c.surfaceElevated : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: selected ? c.accent : c.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: selected ? c.textPrimary : c.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItemWithBadge(int index, IconData icon, String label, int badgeCount) {
    final c = AppTheme.of(context);
    final selected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected ? c.surfaceElevated : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 26,
                  color: selected ? c.accent : c.textSecondary,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: c.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: c.background,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: selected ? c.textPrimary : c.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onCatalogRefresh() async {
    await ProductService.instance.reload();
  }

  Widget _buildCatalogTab() {
    final c = AppTheme.of(context);
    return RefreshIndicator(
      onRefresh: _onCatalogRefresh,
      color: c.accent,
      backgroundColor: c.surfaceElevated,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'YANIKOV',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 8,
                    color: c.textPrimary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search_rounded, color: c.textPrimary),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Hero banner
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: buildGlassPanel(context,
              borderRadius: 24,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: 180,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Фоновое фото (поддержка .jpg и .png)
                      Image.asset(
                        'assets/images/hero_banner.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/hero_banner.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: c.surface,
                          ),
                        ),
                      ),
                      // Затемнение сверху для читаемости текста
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.black.withValues(alpha: 0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Текст
                      Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              context.l10n('new_collection'),
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                letterSpacing: 4,
                                color: c.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.l10n('spring_2025'),
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1,
                                color: c.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: 48,
                              height: 2,
                              color: c.accent,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Section: Категории
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  context.l10n('categories'),
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 1,
                  color: c.borderBright,
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final cats = _categories(context);
                final (name, icon) = cats[index];
                return _buildCategoryCard(name, icon);
              },
              childCount: 4,
            ),
          ),
        ),
        // Промо-баннер
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: buildGlassPanel(context,
              borderRadius: 16,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: c.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.local_offer_rounded, color: c.accent, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _savedPromo != null ? 'Промокод $_savedPromo' : 'Промокод',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _savedPromo != null
                                ? 'Скидка применена — учтётся при заказе'
                                : 'Скидка на заказ — нажмите, чтобы ввести',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Section: Популярное
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Популярное',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 1,
                  color: c.borderBright,
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
              itemCount: ProductService.instance.featured.length,
              itemBuilder: (context, index) {
                final product = ProductService.instance.featured[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _buildProductCard(product: product),
                );
              },
            ),
          ),
        ),
        // Недавно просмотренные
        if (RecentlyViewedService.instance.products.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Недавно просмотренные',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 1,
                    color: c.borderBright,
                  ),
                ],
              ),
            ),
          ),
        if (RecentlyViewedService.instance.products.isNotEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
                itemCount: RecentlyViewedService.instance.products.length,
                itemBuilder: (context, index) {
                  final product = RecentlyViewedService.instance.products[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildProductCard(product: product),
                  );
                },
              ),
            ),
          ),
      ],
      ),
    );
  }

  Widget _buildCategoryCard(String name, IconData icon) {
    final c = AppTheme.of(context);
    return buildGlassPanel(context,
      borderRadius: 20,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CategoryScreen(categoryName: name, icon: icon),
            ),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 28, color: c.textPrimary),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: c.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard({required Product product}) {
    final c = AppTheme.of(context);
    return SizedBox(
      width: 168,
      child: buildGlassPanel(context,
        borderRadius: 20,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product),
              ),
            ),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(14),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: c.surface,
                        ),
                        child: ProductImage(
                          imagePath: product.imagePath,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      if (product.category == Product.catNew)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade700,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              context.l10n('new_badge'),
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        )
                      else if (ProductService.instance.featured.any((p) => p.id == product.id))
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              context.l10n('hit_badge'),
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: ListenableBuilder(
                          listenable: FavoritesService.instance,
                          builder: (_, __) {
                            final isSaved = FavoritesService.instance.isFavorite(product.id);
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  await FavoritesService.instance.toggle(product.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isSaved ? context.l10n('removed_from_favorites') : context.l10n('added_to_favorites'),
                                      ),
                                      backgroundColor: c.borderBright,
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: c.surfaceElevated.withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: c.border),
                                  ),
                                  child: Icon(
                                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                    size: 20,
                                    color: isSaved ? c.accent : c.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: c.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyService.instance.formatPriceString(product.price),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartTab() {
    final c = AppTheme.of(context);
    final cart = CartService.instance;
    if (cart.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: c.surfaceElevated,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: c.border),
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 40,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              context.l10n('cart_empty'),
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              context.l10n('cart_add_items'),
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: c.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: buildGlassPanel(context,
                borderRadius: 16,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      ProductImage(
                        imagePath: _getProductImagePath(item.productId),
                        width: 56,
                        height: 56,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: c.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${CurrencyService.instance.formatPriceString(item.price)} × ${item.quantity}',
                              style: GoogleFonts.outfit(fontSize: 13, color: c.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyService.instance.format(CurrencyService.parseRubles(item.price) * item.quantity),
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: c.textSecondary),
                        onPressed: () => cart.removeAt(index),
                      ),
                    ],
                  ),
                ),
              ),
            );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border(top: BorderSide(color: c.border)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n('total'),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                  Text(
                    CurrencyService.instance.format(cart.totalRaw),
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(context.l10n('checkout_btn')),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    final c = AppTheme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          buildGlassPanel(context,
            borderRadius: 24,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                ),
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      ListenableBuilder(
                        listenable: ProfileService.instance,
                        builder: (_, __) {
                          final ps = ProfileService.instance;
                          return Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: c.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: c.border),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: ps.hasAvatar
                                ? Image.file(
                                    File(ps.avatarPath!),
                                    key: ValueKey(ps.avatarVersion),
                                    fit: BoxFit.cover,
                                    width: 88,
                                    height: 88,
                                  )
                                : Icon(Icons.person_rounded, size: 44, color: c.textSecondary),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        ProfileService.instance.displayName,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getMemberLevelColor().withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _getMemberLevelColor().withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              _getMemberLevel(),
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getMemberLevelColor(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n('member_yanikov'),
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: c.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.edit_rounded, size: 14, color: c.textSecondary),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildProfileStat(
                  Icons.shopping_bag_outlined,
                  '${OrdersService.instance.orders.length}',
                  context.l10n('orders_count'),
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OrdersScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProfileStat(
                  Icons.favorite_border_rounded,
                  '${FavoritesService.instance.ids.length}',
                  context.l10n('favorites_count_short'),
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProfileStat(
                  Icons.shopping_cart_outlined,
                  '${CartService.instance.totalCount}',
                  context.l10n('in_cart'),
                  () => setState(() => _currentIndex = 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          buildGlassPanel(context,
            borderRadius: 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PointsQrScreen()),
                ),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      ListenableBuilder(
                        listenable: PointsService.instance,
                        builder: (_, __) {
                          final qrData = PointsService.instance.qrData;
                          return Container(
                            width: 72,
                            height: 72,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: c.border),
                            ),
                            child: qrData.isNotEmpty
                                ? QrImageView(
                                    data: qrData,
                                    version: QrVersions.auto,
                                    backgroundColor: Colors.white,
                                    eyeStyle: const QrEyeStyle(
                                      eyeShape: QrEyeShape.square,
                                      color: Color(0xFF111111),
                                    ),
                                    dataModuleStyle: const QrDataModuleStyle(
                                      dataModuleShape: QrDataModuleShape.square,
                                      color: Color(0xFF111111),
                                    ),
                                  )
                                : const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                          );
                        },
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListenableBuilder(
                              listenable: PointsService.instance,
                              builder: (_, __) => Text(
                                '${PointsService.instance.points} ${context.l10n('points_count')}',
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: c.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n('show_qr_at_cash'),
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: c.textSecondary, size: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.border),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  c.accent.withValues(alpha: 0.12),
                  c.accent.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: c.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.local_shipping_rounded, color: c.accent, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n('free_delivery'),
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: c.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n('free_delivery_from'),
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          _profileTile(Icons.shopping_bag_outlined, context.l10n('my_orders'), () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OrdersScreen()),
            );
          }),
          ListenableBuilder(
            listenable: OrdersService.instance,
            builder: (_, __) => _profileTile(
              Icons.payments_outlined,
              context.l10n('total_spent'),
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
              ),
              subtitle: OrdersService.instance.totalSpentFormatted,
            ),
          ),
          _profileTile(Icons.bookmark_border_rounded, context.l10n('saved'), () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            );
          }),
          _profileTile(Icons.compare_arrows_rounded, context.l10n('comparison'), () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ComparisonScreen()),
            );
          }),
          _profileTile(
            Icons.local_offer_outlined,
            context.l10n('promo_code'),
            () => _showPromoDialog(context),
            subtitle: _savedPromo,
          ),
          _profileTile(Icons.location_on_outlined, context.l10n('address_delivery'), () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddressesScreen()),
            );
          }),
          _profileTile(Icons.help_outline_rounded, context.l10n('help'), () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HelpScreen()),
            );
          }),
          ListenableBuilder(
            listenable: SessionsService.instance,
            builder: (_, __) => _profileTile(
              Icons.phone_android_rounded,
              context.l10n('devices'),
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DevicesScreen()),
              ),
              subtitle: '${SessionsService.instance.sessions.length} ${context.l10n('devices_count')}',
            ),
          ),
          _profileTile(Icons.settings_outlined, context.l10n('settings'), () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          }),
          const SizedBox(height: 32),
          buildGlassPanel(context,
            borderRadius: 16,
            withShadow: false,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  RealtimeSyncService.instance.unsubscribe();
                  await SessionsService.instance.resetForLogout();
                  await AuthService.logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/auth',
                    (route) => false,
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, size: 22, color: c.textSecondary),
                      const SizedBox(width: 12),
                      Text(
                        context.l10n('logout'),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(IconData icon, String value, String label, VoidCallback onTap) {
    final c = AppTheme.of(context);
    return buildGlassPanel(context,
      borderRadius: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, size: 24, color: c.accent),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: c.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileTile(IconData icon, String title, VoidCallback onTap, {String? subtitle}) {
    final c = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: buildGlassPanel(context,
        borderRadius: 16,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: c.textPrimary, size: 22),
          ),
          title: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: c.textPrimary,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.accent,
                  ),
                )
              : null,
          trailing: Icon(Icons.chevron_right_rounded, color: c.textSecondary, size: 24),
        ),
      ),
    );
  }
}
