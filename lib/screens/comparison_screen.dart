import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telemost12_app/theme/app_theme.dart';
import 'package:telemost12_app/widgets/glass_panel.dart';
import 'package:telemost12_app/widgets/product_image.dart';
import 'package:telemost12_app/models/product.dart';
import 'package:telemost12_app/services/comparison_service.dart';
import 'package:telemost12_app/services/currency_service.dart';
import 'package:telemost12_app/l10n/app_localizations.dart';
import 'package:telemost12_app/screens/product_detail_screen.dart';
import 'package:telemost12_app/screens/home_screen.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  @override
  void initState() {
    super.initState();
    ComparisonService.instance.load();
  }

  String _categoryName(BuildContext context, String category) {
    switch (category) {
      case Product.catClothing:
        return context.l10n('category_clothing');
      case Product.catShoes:
        return context.l10n('category_shoes');
      case Product.catAccessories:
        return context.l10n('category_accessories');
      case Product.catNew:
        return context.l10n('category_new');
      default:
        return category;
    }
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
                    Text(
                      context.l10n('compare_products'),
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
                  listenable: ComparisonService.instance,
                  builder: (_, __) {
                    final products = ComparisonService.instance.products;
                    if (products.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.compare_arrows_rounded, size: 64, color: c.textSecondary),
                            const SizedBox(height: 20),
                            Text(
                              context.l10n('no_products_to_compare'),
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: c.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.l10n('add_products_to_compare'),
                              style: GoogleFonts.outfit(fontSize: 14, color: c.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            TextButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const HomeScreen()),
                              ),
                              icon: Icon(Icons.add_rounded, color: c.accent),
                              label: Text(context.l10n('catalog'), style: GoogleFonts.outfit(color: c.accent)),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      children: products.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: buildGlassPanel(context,
                          borderRadius: 16,
                          child: InkWell(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
                            ),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: ProductImage(
                                      imagePath: p.imagePath,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.title,
                                          style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: c.textPrimary,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _categoryName(context, p.category),
                                          style: GoogleFonts.outfit(fontSize: 13, color: c.textSecondary),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          CurrencyService.instance.formatPriceString(p.price),
                                          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: c.accent),
                                        ),
                                        if (p.sizes != null && p.sizes!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            '${context.l10n('size')}: ${p.sizes!.join(', ')}',
                                            style: GoogleFonts.outfit(fontSize: 12, color: c.textSecondary),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline_rounded, color: c.textSecondary),
                                    onPressed: () => ComparisonService.instance.remove(p.id),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )).toList(),
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
