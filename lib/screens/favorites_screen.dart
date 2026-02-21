import 'package:flutter/material.dart';
import 'package:telemost12_app/services/currency_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telemost12_app/models/product.dart';
import 'package:telemost12_app/theme/app_theme.dart';
import 'package:telemost12_app/widgets/glass_panel.dart';
import 'package:telemost12_app/widgets/product_image.dart';
import 'package:telemost12_app/services/favorites_service.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Отложенные',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: c.textPrimary,
                          ),
                        ),
                        Text(
                          'Товары, которые вы отложили',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: FavoritesService.instance,
                  builder: (context, _) {
                    final products = FavoritesService.instance.filterFeatured();
                    if (products.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bookmark_border_rounded, size: 64, color: c.textSecondary),
                            const SizedBox(height: 20),
                            Text(
                              'Отложенных товаров пока нет',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: c.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Нажимайте «Отложить» на карточках товаров',
                              style: GoogleFonts.outfit(fontSize: 14, color: c.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final p = products[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: buildGlassPanel(context,
                            borderRadius: 16,
                            child: ListTile(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(product: p),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: ProductImage(
                                imagePath: p.imagePath,
                                width: 56,
                                height: 56,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: Text(
                                p.title,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: c.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                CurrencyService.instance.formatPriceString(p.price),
                                style: GoogleFonts.outfit(fontSize: 14, color: c.textSecondary),
                              ),
                              trailing: Icon(Icons.chevron_right_rounded, color: c.textSecondary),
                            ),
                          ),
                        );
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
