import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PresenceService with ChangeNotifier {
  static final PresenceService _instance = PresenceService._internal();
  factory PresenceService() => _instance;
  PresenceService._internal();

  final _supabase = Supabase.instance.client;

  // Active channels by roomId
  final Map<String, RealtimeChannel> _channels = {};

  // Online users per room: roomId → Set<userId>
  final Map<String, Set<String>> _onlineUsers = {};

  // Stream controllers for broadcasting changes
  final Map<String, StreamController<Set<String>>> _onlineStreamControllers =
      {};

  /// Join presence for a specific room
  Future<void> joinRoom(String roomId, String currentUserId) async {
    debugPrint('🟢 Joining room: $roomId as user: $currentUserId');

    if (_channels.containsKey(roomId)) {
      // Already joined → update our presence payload if needed
      await _channels[roomId]!.track(_buildPayload(currentUserId));
      debugPrint('♻️ Updated presence for existing channel');
      return;
    }

    final channel = _supabase.channel('room:$roomId');

    // Listen to presence events using the new dedicated methods
    channel
      ..onPresenceSync((payload) {
        debugPrint('🔄 Presence sync for room: $roomId');
        _updateOnlineUsers(roomId);
        _notifyListeners(roomId);
      })
      ..onPresenceJoin((payload) {
        debugPrint('➕ User joined room: $roomId');
        _updateOnlineUsers(roomId);
        _notifyListeners(roomId);
      })
      ..onPresenceLeave((payload) {
        debugPrint('➖ User left room: $roomId');
        _updateOnlineUsers(roomId);
        _notifyListeners(roomId);
      });

    // Subscribe and track once subscribed
    channel.subscribe((status, [error]) async {
      debugPrint('📡 Channel status for $roomId: $status');

      if (status == RealtimeSubscribeStatus.subscribed) {
        await channel.track(_buildPayload(currentUserId));
        debugPrint('✅ Successfully tracked presence for $roomId');
      } else if (status == RealtimeSubscribeStatus.closed ||
          status == RealtimeSubscribeStatus.channelError) {
        debugPrint('❌ Presence channel issue for $roomId: $status - $error');
      }
    });

    _channels[roomId] = channel;

    // Initialize
    _onlineUsers[roomId] = {};
    _onlineStreamControllers[roomId] ??=
        StreamController<Set<String>>.broadcast();
  }

  // Add this method to PresenceService
  /// Join presence for all rooms the user is a member of
  Future<void> joinAllUserRooms(
    List<String> roomIds,
    String currentUserId,
  ) async {
    debugPrint('🌐 Joining presence for ${roomIds.length} rooms');

    for (final roomId in roomIds) {
      try {
        await joinRoom(roomId, currentUserId);
      } catch (e) {
        debugPrint('❌ Failed to join room $roomId: $e');
      }
    }

    debugPrint('✅ Joined presence for all rooms');
  }

  /// Leave presence cleanly
  Future<void> leaveRoom(String roomId) async {
    debugPrint('🚪 Leaving room: $roomId');

    final channel = _channels[roomId];
    if (channel != null) {
      await channel.untrack();
      await channel.unsubscribe();
      _channels.remove(roomId);
    }

    _onlineUsers.remove(roomId);
    await _onlineStreamControllers[roomId]?.close();
    _onlineStreamControllers.remove(roomId);
  }

  /// Get current online users for a room
  Set<String> getOnlineUsers(String roomId) {
    return _onlineUsers[roomId] ?? {};
  }

  /// Stream of online users (reactive)
  Stream<Set<String>> onlineUsersStream(String roomId) {
    _onlineStreamControllers[roomId] ??=
        StreamController<Set<String>>.broadcast();
    return _onlineStreamControllers[roomId]!.stream;
  }

  /// Quick check if a user is online in this room
  bool isUserOnline(String roomId, String userId) {
    return getOnlineUsers(roomId).contains(userId);
  }

  Map<String, dynamic> _buildPayload(String userId) {
    return {
      'user_id': userId,
      'online': true,
      'last_active': DateTime.now().toUtc().toIso8601String(),
    };
  }

  void _updateOnlineUsers(String roomId) {
    final channel = _channels[roomId];
    if (channel == null) return;

    final presenceState = channel.presenceState();
    final onlineSet = <String>{};

    debugPrint(
      '📊 Presence state for $roomId: ${presenceState.length} entries',
    );

    // Iterate through presence state
    for (final entry in presenceState) {
      debugPrint(
        '  🔑 Key: ${entry.key}, Presences: ${entry.presences.length}',
      );

      for (final presence in entry.presences) {
        try {
          // Access the payload property of Presence object
          final payload = presence.payload;
          debugPrint('    📦 Payload: $payload');

          final userId = payload['user_id'] as String?;
          final online = payload['online'] as bool? ?? false;

          if (userId != null && online) {
            onlineSet.add(userId);
            debugPrint('    ✅ Added online user: $userId');
          }
        } catch (e) {
          debugPrint('    ❌ Error parsing presence payload: $e');
        }
      }
    }

    _onlineUsers[roomId] = onlineSet;
    debugPrint('👥 Total online users in $roomId: $onlineSet');
  }

  void _notifyListeners(String roomId) {
    final controller = _onlineStreamControllers[roomId];
    if (controller != null && !controller.isClosed) {
      controller.add(getOnlineUsers(roomId));
    }
    notifyListeners();
  }

  /// Debug method to check presence state
  void debugPresenceState(String roomId) {
    final channel = _channels[roomId];
    if (channel == null) {
      debugPrint('❌ No channel for room: $roomId');
      return;
    }

    final presenceState = channel.presenceState();
    debugPrint('🔍 Presence state for $roomId:');
    debugPrint('  Total entries: ${presenceState.length}');

    for (final entry in presenceState) {
      debugPrint('  Key: ${entry.key}');
      debugPrint('  Presences count: ${entry.presences.length}');

      for (final presence in entry.presences) {
        debugPrint('    Payload: ${presence.payload}');
      }
    }

    debugPrint('  Online users: ${_onlineUsers[roomId]}');
  }

  /// Clean up everything (call on app close / logout)
  Future<void> disposeAll() async {
    debugPrint('🧹 Cleaning up all presence channels');

    for (final roomId in _channels.keys.toList()) {
      await leaveRoom(roomId);
    }
    for (final controller in _onlineStreamControllers.values) {
      await controller.close();
    }
    _onlineStreamControllers.clear();
    _onlineUsers.clear();
    _channels.clear();
  }
}
