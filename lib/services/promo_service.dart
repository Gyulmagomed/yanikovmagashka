import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telemost12_app/supabase_config.dart';

/// Результат проверки промокода
class PromoResult {
  const PromoResult({required this.valid, this.discountPercent = 0});

  final bool valid;
  final int discountPercent;
}

/// Сервис проверки промокодов из Supabase
class PromoService {
  PromoService._();
  static final PromoService instance = PromoService._();

  /// Проверяет промокод в Supabase. Возвращает PromoResult с valid=true и discountPercent
  /// если промокод активен, иначе valid=false.
  static Future<PromoResult> validate(String code) async {
    if (!SupabaseConfig.isConfigured) {
      return const PromoResult(valid: false);
    }
    final clean = code.trim().toUpperCase();
    if (clean.isEmpty) return const PromoResult(valid: false);
    try {
      final response = await Supabase.instance.client
          .from('promo_codes')
          .select('discount_percent')
          .eq('code', clean)
          .eq('is_active', true)
          .maybeSingle();

      if (response != null) {
        final map = response as Map<String, dynamic>;
        final discount = (map['discount_percent'] as num?)?.toInt() ?? 0;
        if (discount >= 1 && discount <= 100) {
          return PromoResult(valid: true, discountPercent: discount);
        }
      }
    } catch (_) {}
    return const PromoResult(valid: false);
  }
}
