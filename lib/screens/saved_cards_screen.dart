import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telemost12_app/theme/app_theme.dart';
import 'package:telemost12_app/widgets/glass_panel.dart';
import 'package:telemost12_app/services/saved_cards_service.dart';
import 'package:telemost12_app/models/saved_card.dart';
import 'package:telemost12_app/l10n/app_localizations.dart';

class SavedCardsScreen extends StatefulWidget {
  const SavedCardsScreen({super.key});

  @override
  State<SavedCardsScreen> createState() => _SavedCardsScreenState();
}

class _SavedCardsScreenState extends State<SavedCardsScreen> {
  @override
  void initState() {
    super.initState();
    SavedCardsService.instance.load();
  }

  Future<void> _showAddCardDialog() async {
    final c = AppTheme.of(context);
    final cardNumberC = TextEditingController();
    final expiryC = TextEditingController();
    final holderC = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surfaceElevated,
        title: Text(
          context.l10n('add_card'),
          style: GoogleFonts.outfit(color: c.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cardNumberC,
                decoration: InputDecoration(
                  labelText: context.l10n('card_number'),
                  hintText: '1234 5678 9012 3456',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(),
                ],
                style: GoogleFonts.outfit(color: c.textPrimary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: expiryC,
                decoration: InputDecoration(
                  labelText: context.l10n('expiry'),
                  hintText: 'MM/YY',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  _ExpiryFormatter(),
                ],
                style: GoogleFonts.outfit(color: c.textPrimary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: holderC,
                decoration: InputDecoration(
                  labelText: context.l10n('cardholder'),
                  hintText: 'IVAN IVANOV',
                ),
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.outfit(color: c.textPrimary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n('cancel'), style: GoogleFonts.outfit(color: c.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n('save'), style: GoogleFonts.outfit(color: c.accent)),
          ),
        ],
      ),
    );

    if (ok == true) {
      final digits = cardNumberC.text.replaceAll(RegExp(r'[^\d]'), '');
      final expiry = expiryC.text.replaceAll(RegExp(r'[^\d]'), '');
      if (digits.length >= 13 && expiry.length == 4) {
        final month = int.tryParse(expiry.substring(0, 2)) ?? 0;
        final year = 2000 + (int.tryParse(expiry.substring(2, 4)) ?? 0);
        if (month >= 1 && month <= 12 && year >= 2024) {
          final last4 = digits.substring(digits.length - 4);
          final brand = SavedCardsService.detectBrand(digits);
          await SavedCardsService.instance.add(SavedCard(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            last4: last4,
            brand: brand,
            expiryMonth: month,
            expiryYear: year,
            holderName: holderC.text.trim().isNotEmpty ? holderC.text.trim() : null,
          ));
        }
      }
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
                      context.l10n('saved_cards'),
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
                  listenable: SavedCardsService.instance,
                  builder: (_, __) {
                    final cards = SavedCardsService.instance.cards;
                    if (cards.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.credit_card_off_rounded, size: 64, color: c.textSecondary),
                            const SizedBox(height: 20),
                            Text(
                              context.l10n('no_saved_cards'),
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: c.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.l10n('add_card_for_payment'),
                              style: GoogleFonts.outfit(fontSize: 14, color: c.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: buildGlassPanel(context,
                            borderRadius: 16,
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    c.accent.withValues(alpha: 0.2),
                                    c.accent.withValues(alpha: 0.08),
                                  ],
                                ),
                                border: Border.all(color: c.border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: c.surface,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        card.brand == 'Visa' ? 'VISA' : card.brand == 'Mastercard' ? 'MC' : 'MIR',
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: c.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          card.maskedNumber,
                                          style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: c.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          card.expiryFormatted,
                                          style: GoogleFonts.outfit(fontSize: 13, color: c.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline_rounded, color: c.textSecondary),
                                    onPressed: () async {
                                      await SavedCardsService.instance.remove(card.id);
                                    },
                                  ),
                                ],
                              ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCardDialog,
        backgroundColor: c.accent,
        foregroundColor: c.background,
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n('add_card'), style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.length >= 2) {
      final result = '${text.substring(0, 2)}/${text.length > 2 ? text.substring(2) : ''}';
      return TextEditingValue(
        text: result,
        selection: TextSelection.collapsed(offset: result.length),
      );
    }
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
