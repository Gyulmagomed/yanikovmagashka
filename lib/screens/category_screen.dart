import 'package:flutter/material.dart';
import 'package:telemost12_app/l10n/app_localizations.dart';
import 'package:telemost12_app/services/currency_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telemost12_app/theme/app_theme.dart';
import 'package:telemost12_app/widgets/glass_panel.dart';
import 'package:telemost12_app/widgets/product_image.dart';
import 'package:telemost12_app/models/product.dart';
import 'package:telemost12_app/screens/product_detail_screen.dart';
import 'package:telemost12_app/services/product_service.dart';
import 'package:telemost12_app/services/favorites_service.dart';
import 'package:telemost12_app/services/comparison_service.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key, required this.categoryName, required this.icon});

  final String categoryName;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.of(context);
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
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: c.textPrimary),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      categoryName,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: ProductService.instance,
                  builder: (_, __) {
                    final products = ProductService.instance.byCategory(categoryName);
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return _ProductCard(product: products[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.of(context);
    return buildGlassPanel(context,
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
                          ),
                          child: Text(
                            context.l10n('new_badge'),
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
                          ),
                          child: Text(
                            context.l10n('hit_badge'),
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListenableBuilder(
                            listenable: ComparisonService.instance,
                            builder: (_, __) {
                              final inCompare = ComparisonService.instance.isInComparison(product.id);
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    await ComparisonService.instance.toggle(product.id);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          inCompare ? context.l10n('remove_from_comparison') : context.l10n('add_to_comparison'),
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
                                    margin: const EdgeInsets.only(right: 4),
                                    decoration: BoxDecoration(
                                      color: c.surfaceElevated.withValues(alpha: 0.9),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: c.border),
                                    ),
                                    child: Icon(
                                      inCompare ? Icons.compare_arrows_rounded : Icons.compare_arrows_outlined,
                                      size: 18,
                                      color: inCompare ? c.accent : c.textSecondary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          ListenableBuilder(
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
                        ],
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
    );
  }
}
