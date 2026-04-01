import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PresenceService {
  static final PresenceService _instance = PresenceService._internal();
  factory PresenceService() => _instance;
  PresenceService._internal();

  final _supabase = Supabase.instance.client;

  // Active channels by roomId
  final Map<String, RealtimeChannel> _channels = {};

  /// Join presence for a specific room
  Future<void> joinRoom(String roomId, String currentUserId) async {
    if (_channels.containsKey(roomId)) {
      await _channels[roomId]!.track(_buildPayload(currentUserId));
      return;
    }

    final channel = _supabase.channel('room:$roomId');

    channel.subscribe((status, [error]) async {
      if (status == RealtimeSubscribeStatus.subscribed) {
        await channel.track(_buildPayload(currentUserId));
      } else if (status == RealtimeSubscribeStatus.closed ||
          status == RealtimeSubscribeStatus.channelError) {
        debugPrint('❌ Presence channel issue for $roomId: $status - $error');
      }
    });

    _channels[roomId] = channel;
  }

  /// Leave presence cleanly
  Future<void> leaveRoom(String roomId) async {
    final channel = _channels[roomId];
    if (channel != null) {
      await channel.untrack();
      await channel.unsubscribe();
      _channels.remove(roomId);
    }
  }

  Map<String, dynamic> _buildPayload(String userId) {
    return {
      'user_id': userId,
      'online': true,
      'last_active': DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// Clean up everything (call on app close / logout)
  Future<void> disposeAll() async {
    for (final roomId in _channels.keys.toList()) {
      await leaveRoom(roomId);
    }
    _channels.clear();
  }
}
