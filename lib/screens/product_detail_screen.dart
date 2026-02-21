import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:telemost12_app/models/product.dart';
import 'package:telemost12_app/theme/app_theme.dart';
import 'package:telemost12_app/widgets/glass_panel.dart';
import 'package:telemost12_app/widgets/product_image.dart';
import 'package:telemost12_app/services/cart_service.dart';
import 'package:telemost12_app/services/favorites_service.dart';
import 'package:telemost12_app/services/product_service.dart';
import 'package:telemost12_app/services/recently_viewed_service.dart';
import 'package:telemost12_app/services/currency_service.dart';
import 'package:telemost12_app/services/comparison_service.dart';
import 'package:telemost12_app/l10n/app_localizations.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _selectedSize;

  @override
  void initState() {
    super.initState();
    RecentlyViewedService.instance.add(widget.product.id);
    if (widget.product.sizes != null && widget.product.sizes!.isNotEmpty) {
      _selectedSize = widget.product.sizes!.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.of(context);
    final product = widget.product;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: c.backgroundGradient,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListenableBuilder(
                          listenable: ComparisonService.instance,
                          builder: (_, __) {
                            final inCompare = ComparisonService.instance.isInComparison(product.id);
                            return IconButton(
                              icon: Icon(
                                inCompare ? Icons.compare_arrows_rounded : Icons.compare_arrows_outlined,
                                color: inCompare ? c.accent : c.textPrimary,
                              ),
                              onPressed: () async {
                                await ComparisonService.instance.toggle(product.id);
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.share_rounded, color: c.textPrimary),
                          onPressed: () => Share.share(
                            '${product.title} — ${CurrencyService.instance.formatPriceString(product.price)}\nYANIKOV — ${context.l10n('brand_text')}',
                            subject: product.title,
                          ),
                        ),
                        ListenableBuilder(
                      listenable: FavoritesService.instance,
                      builder: (_, __) {
                        final isFav = FavoritesService.instance.isFavorite(product.id);
                        return IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? Colors.red : c.textPrimary,
                          ),
                          onPressed: () async {
                            await FavoritesService.instance.toggle(product.id);
                          },
                        );
                      },
                    ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildGlassPanel(context,
                        borderRadius: 24,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: c.surface,
                            ),
                            child: ProductImage(
                              imagePath: product.imagePath,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        product.title,
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        CurrencyService.instance.formatPriceString(product.price),
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: c.textPrimary,
                        ),
                      ),
                      if (product.description != null) ...[
                        const SizedBox(height: 20),
                        Text(
                          product.description!,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            color: c.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                      if (product.sizes != null && product.sizes!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          context.l10n('size'),
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: c.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: product.sizes!.map((s) {
                            final selected = _selectedSize == s;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedSize = s),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: selected ? c.accent : c.surfaceElevated,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected ? c.accent : c.border,
                                  ),
                                ),
                                child: Text(
                                  s,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: selected ? c.background : c.textPrimary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      // Похожие товары
                      if (ProductService.instance.similarTo(product).isNotEmpty) ...[
                        const SizedBox(height: 32),
                        Text(
                          'Похожие товары',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: c.textPrimary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: ProductService.instance.similarTo(product).length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, i) {
                              final p = ProductService.instance.similarTo(product)[i];
                              return _buildSimilarCard(p);
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await CartService.instance.add(widget.product);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Добавлено в корзину'),
                              backgroundColor: c.borderBright,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('В корзину'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListenableBuilder(
                      listenable: FavoritesService.instance,
                      builder: (_, __) {
                        final isSaved = FavoritesService.instance.isFavorite(product.id);
                        return SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await FavoritesService.instance.toggle(product.id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isSaved ? 'Убрано из отложенных' : 'Отложено',
                                  ),
                                  backgroundColor: c.borderBright,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: c.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              foregroundColor: c.textPrimary,
                            ),
                            icon: Icon(
                              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              size: 20,
                              color: isSaved ? c.accent : c.textSecondary,
                            ),
                            label: Text(
                              isSaved ? 'В отложенных' : 'Отложить',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: c.textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimilarCard(Product p) {
    final c = AppTheme.of(context);
    return SizedBox(
      width: 140,
      child: buildGlassPanel(context,
        borderRadius: 16,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: p),
              ),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: c.surface,
                    ),
                    child: ProductImage(
                      imagePath: p.imagePath,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyService.instance.formatPriceString(p.price),
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.accent,
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
}
