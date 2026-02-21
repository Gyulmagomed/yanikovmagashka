import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telemost12_app/theme/app_theme.dart';
import 'package:telemost12_app/widgets/glass_panel.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

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
                      'Помощь',
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
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildFaqItem(context,
                      'Как оформить заказ?',
                      'Добавьте товары в корзину, нажмите «Оформить заказ» и заполните адрес доставки.',
                    ),
                    const SizedBox(height: 12),
                    _buildFaqItem(context,
                      'Как отследить заказ?',
                      'Перейдите в «Мои заказы» в профиле — там отображаются все ваши заказы.',
                    ),
                    const SizedBox(height: 12),
                    _buildFaqItem(context,
                      'Бесплатная доставка?',
                      'Да, при заказе от 5 000 ₽ доставка бесплатная.',
                    ),
                    const SizedBox(height: 12),
                    _buildFaqItem(context,
                      'Как накапливать баллы?',
                      'За каждый заказ начисляются баллы. Покажите QR-код на кассе для списания.',
                    ),
                    const SizedBox(height: 12),
                    _buildFaqItem(context,
                      'Как связаться с поддержкой?',
                      'Напишите на support@yanikov.ru или откройте «Настройки» → «Связаться с нами».',
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    final c = AppTheme.of(context);
    return buildGlassPanel(context,
      borderRadius: 16,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              answer,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: c.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
