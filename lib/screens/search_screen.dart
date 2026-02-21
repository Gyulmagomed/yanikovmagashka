import 'package:flutter/material.dart';
import 'package:telemost12_app/services/currency_service.dart';
import 'package:telemost12_app/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telemost12_app/theme/app_theme.dart';
import 'package:telemost12_app/widgets/glass_panel.dart';
import 'package:telemost12_app/widgets/product_image.dart';
import 'package:telemost12_app/models/product.dart';
import 'package:telemost12_app/screens/product_detail_screen.dart';
import 'package:telemost12_app/services/product_service.dart';
import 'package:telemost12_app/services/favorites_service.dart';
import 'package:telemost12_app/services/search_history_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    SearchHistoryService.instance.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Product> get _results =>
      ProductService.instance.search(_query);

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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: buildGlassPanel(context,
                        borderRadius: 14,
                        withShadow: false,
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          onChanged: (v) => setState(() => _query = v),
                          style: GoogleFonts.outfit(color: c.textPrimary, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: context.l10n('search_hint'),
                            hintStyle: GoogleFonts.outfit(color: c.textSecondary),
                            prefixIcon: Icon(Icons.search_rounded, color: c.textSecondary),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _query.isEmpty
                    ? ListenableBuilder(
                        listenable: SearchHistoryService.instance,
                        builder: (_, __) {
                          final history = SearchHistoryService.instance.queries;
                          if (history.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history_rounded, size: 56, color: c.textSecondary),
                                  const SizedBox(height: 16),
                                  Text(
                                    context.l10n('recent_searches'),
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      color: c.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  context.l10n('recent_searches'),
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: c.textSecondary,
                                  ),
                                ),
                              ),
                              ...history.map((q) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: buildGlassPanel(context,
                                  borderRadius: 16,
                                  child: ListTile(
                                    onTap: () {
                                      _controller.text = q;
                                      setState(() => _query = q);
                                    },
                                    leading: Icon(Icons.history_rounded, color: c.textSecondary, size: 22),
                                    title: Text(
                                      q,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        color: c.textPrimary,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.close_rounded, size: 20, color: c.textSecondary),
                                      onPressed: () async {
                                        await SearchHistoryService.instance.remove(q);
                                      },
                                    ),
                                  ),
                                ),
                              )),
                            ],
                          );
                        },
                      )
                    : _results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off_rounded, size: 56, color: c.textSecondary),
                                const SizedBox(height: 16),
                                Text(
                                  context.l10n('search_empty'),
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: c.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListenableBuilder(
                        listenable: ProductService.instance,
                        builder: (_, __) => ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final p = ProductService.instance.search(_query)[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: buildGlassPanel(context,
                              borderRadius: 16,
                              child: ListTile(
                                onTap: () async {
                                  await SearchHistoryService.instance.add(_query);
                                  if (!context.mounted) return;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(product: p),
                                    ),
                                  );
                                },
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
                                trailing: ListenableBuilder(
                                  listenable: FavoritesService.instance,
                                  builder: (_, __) {
                                    final isSaved = FavoritesService.instance.isFavorite(p.id);
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                            size: 22,
                                            color: isSaved ? c.accent : c.textSecondary,
                                          ),
                                          onPressed: () async {
                                            await FavoritesService.instance.toggle(p.id);
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  isSaved ? context.l10n('removed_from_favorites') : context.l10n('added_to_favorites'),
                                                ),
                                                backgroundColor: c.borderBright,
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          },
                                        ),
                                        Icon(Icons.chevron_right_rounded, color: c.textSecondary),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
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
