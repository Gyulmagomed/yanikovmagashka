import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telemost12_app/theme/app_theme.dart';
import 'package:telemost12_app/widgets/glass_panel.dart';
import 'package:telemost12_app/services/cart_service.dart';
import 'package:telemost12_app/services/orders_service.dart';
import 'package:telemost12_app/services/addresses_service.dart';
import 'package:telemost12_app/services/saved_cards_service.dart';
import 'package:telemost12_app/models/saved_card.dart';
import 'package:telemost12_app/services/points_service.dart';
import 'package:telemost12_app/models/address.dart';
import 'package:telemost12_app/l10n/app_localizations.dart';
import 'package:telemost12_app/services/currency_service.dart';
import 'package:telemost12_app/screens/saved_cards_screen.dart';
import 'order_success_screen.dart';
import 'addresses_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _commentController = TextEditingController();
  Address? _selectedAddress;
  SavedCard? _selectedCard;
  String? _promoCode;
  int _promoDiscount = 0;

  String _formatPrice(int value) {
    return CurrencyService.instance.format(value);
  }

  @override
  void initState() {
    super.initState();
    AddressesService.instance.load();
    SavedCardsService.instance.load();
    final addrs = AddressesService.instance.addresses;
    if (addrs.isNotEmpty) _selectedAddress = addrs.first;
    final cards = SavedCardsService.instance.cards;
    if (cards.isNotEmpty) _selectedCard = cards.first;
    _loadPromo();
  }

  Future<void> _loadPromo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _promoCode = prefs.getString('yanikov_promo');
      _promoDiscount = prefs.getInt('yanikov_promo_discount') ?? 0;
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.of(context);
    final cart = CartService.instance;
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
                      context.l10n('checkout_title'),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListenableBuilder(
                    listenable: AddressesService.instance,
                    builder: (_, __) {
                      final addresses = AddressesService.instance.addresses;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n('delivery_address'),
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (addresses.isEmpty)
                            buildGlassPanel(context,
                              borderRadius: 16,
                              child: InkWell(
                                onTap: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const AddressesScreen()),
                                  );
                                  setState(() {
                                    final a = AddressesService.instance.addresses;
                                    if (a.isNotEmpty) _selectedAddress = a.first;
                                  });
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Icon(Icons.add_location_alt_rounded, color: c.textSecondary),
                                      const SizedBox(width: 16),
                                      Text(
                                        context.l10n('add_address'),
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          color: c.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else ...[
                            ...addresses.map((a) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: buildGlassPanel(context,
                                  borderRadius: 16,
                                  child: RadioListTile<Address>(
                                    value: a,
                                    groupValue: _selectedAddress,
                                    onChanged: (v) => setState(() => _selectedAddress = v),
                                    activeColor: c.accent,
                                    title: Text(
                                      a.label,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: c.textPrimary,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${a.street}, ${a.city}',
                                      style: GoogleFonts.outfit(fontSize: 14, color: c.textSecondary),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const AddressesScreen()),
                                );
                                setState(() {
                                  final a = AddressesService.instance.addresses;
                                  if (a.isNotEmpty && !a.any((x) => x.id == _selectedAddress?.id)) {
                                    _selectedAddress = a.first;
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_rounded, size: 20, color: c.textSecondary),
                                    const SizedBox(width: 8),
                                    Text(
                                      context.l10n('add_address'),
                                      style: GoogleFonts.outfit(fontSize: 15, color: c.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          Text(
                            context.l10n('payment_method'),
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ListenableBuilder(
                            listenable: SavedCardsService.instance,
                            builder: (_, __) {
                              final cards = SavedCardsService.instance.cards;
                              if (cards.isEmpty) {
                                return Column(
                                  children: [
                                    buildGlassPanel(context,
                                      borderRadius: 16,
                                      child: Padding(
                                        padding: const EdgeInsets.all(18),
                                        child: Row(
                                          children: [
                                            Icon(Icons.credit_card_rounded, color: c.textSecondary),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                context.l10n('pay_new_card'),
                                                style: GoogleFonts.outfit(
                                                  fontSize: 16,
                                                  color: c.textPrimary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Icon(Icons.check_circle_rounded, color: c.accent, size: 22),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () async {
                                        await Navigator.of(context).push(
                                          MaterialPageRoute(builder: (_) => const SavedCardsScreen()),
                                        );
                                        setState(() {
                                          final cards = SavedCardsService.instance.cards;
                                          if (cards.isNotEmpty) _selectedCard = cards.first;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.add_rounded, size: 18, color: c.textSecondary),
                                            const SizedBox(width: 8),
                                            Text(
                                              context.l10n('add_card'),
                                              style: GoogleFonts.outfit(fontSize: 14, color: c.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return Column(
                                children: [
                                  ...cards.map((card) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: buildGlassPanel(context,
                                        borderRadius: 16,
                                        child: RadioListTile<SavedCard>(
                                          value: card,
                                          groupValue: _selectedCard,
                                          onChanged: (v) => setState(() => _selectedCard = v),
                                          activeColor: c.accent,
                                          title: Text(
                                            card.maskedNumber,
                                            style: GoogleFonts.outfit(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: c.textPrimary,
                                            ),
                                          ),
                                          subtitle: Text(
                                            '${card.brand} • ${card.expiryFormatted}',
                                            style: GoogleFonts.outfit(fontSize: 13, color: c.textSecondary),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  InkWell(
                                    onTap: () => setState(() => _selectedCard = null),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_rounded, size: 20, color: c.textSecondary),
                                          const SizedBox(width: 8),
                                          Text(
                                            context.l10n('pay_new_card'),
                                            style: GoogleFonts.outfit(
                                              fontSize: 15,
                                              color: _selectedCard == null ? c.accent : c.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const SavedCardsScreen()),
                                      );
                                      setState(() {
                                        final cards = SavedCardsService.instance.cards;
                                        if (cards.isNotEmpty && (_selectedCard == null || !cards.any((x) => x.id == _selectedCard?.id))) {
                                          _selectedCard = cards.first;
                                        }
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.credit_card_rounded, size: 18, color: c.textSecondary),
                                          const SizedBox(width: 8),
                                          Text(
                                            context.l10n('saved_cards'),
                                            style: GoogleFonts.outfit(fontSize: 14, color: c.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            context.l10n('comment'),
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          buildGlassPanel(context,
                            borderRadius: 16,
                            withShadow: false,
                            child: TextField(
                              controller: _commentController,
                              maxLines: 3,
                              style: GoogleFonts.outfit(color: c.textPrimary, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: context.l10n('comment_hint'),
                                hintStyle: GoogleFonts.outfit(color: c.textSecondary),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      );
                    },
                  ),
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
                    if (_promoCode != null && _promoDiscount > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.l10n('sum'),
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              color: c.textSecondary,
                            ),
                          ),
                          Text(
                            CurrencyService.instance.format(cart.totalRaw),
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Промокод $_promoCode (−$_promoDiscount%)',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              color: c.textSecondary,
                            ),
                          ),
                          Text(
                            '-${_formatPrice((cart.totalRaw * _promoDiscount / 100).round())}',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              color: Colors.green.shade400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
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
                          _promoDiscount > 0
                              ? _formatPrice(cart.totalRaw - (cart.totalRaw * _promoDiscount / 100).round())
                              : CurrencyService.instance.format(cart.totalRaw),
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
                        onPressed: () async {
                          if (AddressesService.instance.addresses.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.l10n('add_delivery_address_msg')),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          final itemsSummary = cart.items.map((e) => '${e.title} × ${e.quantity}').join(', ');
                          final totalNum = cart.totalRaw;
                          final discount = _promoDiscount > 0 ? (totalNum * _promoDiscount / 100).round() : 0;
                          final totalRubles = totalNum - discount;
                          final total = _formatPrice(totalRubles);
                          await OrdersService.instance.add(
                            itemsSummary: itemsSummary,
                            total: total,
                            totalRubles: totalRubles,
                            addressLabel: _selectedAddress?.label,
                          );
                          await PointsService.instance.addPointsForOrder(totalNum - discount);
                          await cart.clear();
                          if (!context.mounted) return;
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => OrderSuccessScreen(
                                orderId: OrdersService.instance.orders.first.id,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(context.l10n('confirm_order')),
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
