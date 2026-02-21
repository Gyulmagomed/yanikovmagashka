import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telemost12_app/supabase_config.dart';
import 'package:telemost12_app/services/orders_service.dart';
import 'package:telemost12_app/services/favorites_service.dart';
import 'package:telemost12_app/services/cart_service.dart';
import 'package:telemost12_app/services/addresses_service.dart';
import 'package:telemost12_app/services/saved_cards_service.dart';

/// Подписки на Realtime для синхронизации данных между устройствами.
/// RLS ограничивает данные по user_id, поэтому фильтр не нужен.
class RealtimeSyncService {
  RealtimeSyncService._();
  static final RealtimeSyncService _instance = RealtimeSyncService._();
  static RealtimeSyncService get instance => _instance;

  RealtimeChannel? _channel;

  void subscribe(String userId) {
    if (!SupabaseConfig.isConfigured || userId.isEmpty) return;
    unsubscribe();

    _channel = Supabase.instance.client
        .channel('user_data_sync_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_orders',
          callback: (_) => OrdersService.instance.load(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_favorites',
          callback: (_) => FavoritesService.instance.load(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_cart',
          callback: (_) => CartService.instance.load(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_addresses',
          callback: (_) => AddressesService.instance.load(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_saved_cards',
          callback: (_) => SavedCardsService.instance.load(),
        )
        .subscribe((status, [err]) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            debugPrint('RealtimeSyncService: подписка активна');
          } else if (err != null) {
            debugPrint('RealtimeSyncService: ошибка $err');
          }
        });
  }

  void unsubscribe() {
    if (_channel != null) {
      Supabase.instance.client.removeChannel(_channel!);
      _channel = null;
      debugPrint('RealtimeSyncService: подписка отменена');
    }
  }
}
