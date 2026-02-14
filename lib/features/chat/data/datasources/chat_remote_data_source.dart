import 'dart:async';
import 'package:app/features/chat/domain/entities/room.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Assuming you have these models defined elsewhere
import '../models/room_model.dart';
import '../models/room_member_model.dart';
import '../models/message_model.dart';
import 'package:app/core/errors/exceptions.dart'; // Adjust import based on your project

abstract class ChatRemoteDataSource {
  /// 1. Create the room entry (Manual Flow Step 1)
  Future<RoomModel> createRoom(
    RoomModel room,
    String userId,
    String? otherUserId,
  );

  /// 2. Add members to the room (Manual Flow Step 2)
  /// Used for creating DMs (User + Target) or Org Chats (User + All Org Members)
  Future<void> addMembers({
    required String roomId,
    required List<String> userIds,
  });

  /// Get rooms the current user belongs to
  Future<List<RoomModel>> getMyRooms();

  // Get the specific room related to the user, organization
  Future<RoomModel?> getSpecificRoom(
    String userId,
    String? targetUserId,
    String? organizationId,
  );

  /// Get members of a specific room (to show avatars, names, etc.)
  Future<List<RoomMemberModel>> getRoomMembers(String roomId);

  /// Mark messages as read
  Future<void> updateLastRead({
    required String roomId,
    required DateTime lastReadAt,
  });

  /// Send a message
  Future<MessageModel> sendMessage(MessageModel message);

  /// Get history
  Future<List<MessageModel>> getMessages({
    required String roomId,
    int limit = 30,
  });

  /// Real-time stream
  Stream<List<MessageModel>> streamMessages(String roomId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient client;

  ChatRemoteDataSourceImpl(this.client);

  // ROOMS
  // @override
  // Future<RoomModel> createRoom(
  //   RoomModel room,
  //   String userId,
  //   String? otherUserId,
  // ) async {
  //   try {
  //     // First check if the room is already exist between these users
  //     final isRoomAvailable = await isRoomAlreadyCreated(
  //       room.type,
  //       userId,
  //       otherUserId,
  //       room.organizationId,
  //     );
  //     if (!isRoomAvailable) {
  //       // First create the room
  //       final res = await client
  //           .from('rooms')
  //           .insert({
  //             'type': room.type.name,
  //             'organization_id': room.organizationId,
  //           })
  //           .select()
  //           .single();

  //       // For organizations
  //       if (room.organizationId != null && room.type == RoomType.organization) {
  //         // fetch the users related to that organiztion id,
  //         final response = await client
  //             .from('users')
  //             .select('user_id')
  //             .eq('organization_id', room.organizationId!);
  //         final users = response as List;

  //         final userIds = users
  //             .map((user) => user['user_id'] as String)
  //             .toList();
  //         await addMembers(roomId: res['id'], userIds: userIds);
  //       } else {
  //         if (otherUserId != null) {
  //           // For direct message
  //           await addMembers(roomId: res['id'], userIds: [userId, otherUserId]);
  //         }
  //       }
  //     }
  //     return RoomModel.fromJson(res);

  //   } catch (e) {
  //     throw ServerException('Failed to create room: ${e.toString()}');
  //   }
  // }

  @override
  Future<RoomModel> createRoom(
    RoomModel room,
    String userId,
    String? otherUserId,
  ) async {
    try {
      Map<String, dynamic> roomData = {
        'type': room.type.name,
        'organization_id': room.organizationId,
      };

      // Handle DM room
      if (room.type == RoomType.dm && otherUserId != null) {
        final sortedIds = [userId, otherUserId]..sort();
        final dmKey = '${sortedIds[0]}_${sortedIds[1]}';

        roomData['dm_key'] = dmKey;
      }

      // Upsert instead of insert
      final res = await client
          .from('rooms')
          .upsert(roomData, onConflict: 'dm_key')
          .select()
          .single();

      final roomId = res['id'];

      // Add members only if not already added
      if (room.type == RoomType.organization && room.organizationId != null) {
        final response = await client
            .from('users')
            .select('user_id')
            .eq('organization_id', room.organizationId!);

        final userIds = (response as List)
            .map((user) => user['user_id'] as String)
            .toList();

        await addMembers(roomId: roomId, userIds: userIds);
      } else if (room.type == RoomType.dm && otherUserId != null) {
        await addMembers(roomId: roomId, userIds: [userId, otherUserId]);
      }

      return RoomModel.fromJson(res);
    } catch (e) {
      throw ServerException('Failed to create room: ${e.toString()}');
    }
  }

  @override
  Future<List<RoomModel>> getMyRooms() async {
    try {
      final userId = client.auth.currentUser!.id;

      final res = await client
          .from('room_members')
          .select('rooms(*)')
          .eq('user_id', userId)
          .order('joined_at', ascending: false);

      final List<dynamic> data = res as List<dynamic>;

      return data.map((e) => RoomModel.fromJson(e['rooms'])).toList();
    } catch (e) {
      throw ServerException('Failed to fetch rooms: ${e.toString()}');
    }
  }

  // MEMBERS
  @override
  Future<void> addMembers({
    required String roomId,
    required List<String> userIds,
  }) async {
    try {
      if (userIds.isEmpty) return;

      // Prepare batch insert data
      final List<Map<String, dynamic>> data = userIds.map((uid) {
        return {
          'room_id': roomId,
          'user_id': uid,
          'joined_at': DateTime.now().toIso8601String(),
        };
      }).toList();

      await client.from('room_members').insert(data);
    } catch (e) {
      throw ServerException('Failed to add members: ${e.toString()}');
    }
  }

  @override
  Future<List<RoomMemberModel>> getRoomMembers(String roomId) async {
    try {
      final res = await client
          .from('room_members')
          .select()
          .eq('room_id', roomId);

      return (res as List).map((e) => RoomMemberModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException('Failed to fetch members: ${e.toString()}');
    }
  }

  @override
  Future<void> updateLastRead({
    required String roomId,
    required DateTime lastReadAt,
  }) async {
    try {
      final userId = client.auth.currentUser!.id;

      await client
          .from('room_members')
          .update({'last_read_at': lastReadAt.toIso8601String()})
          .eq('room_id', roomId)
          .eq('user_id', userId);
    } catch (e) {
      // Fail silently or log error, usually not critical to block UI
      print('Failed to update last read: $e');
    }
  }

  // MESSAGES
  @override
  Future<MessageModel> sendMessage(MessageModel message) async {
    try {
      final msgData = message.toCreateJson();
      msgData['sender_id'] = client.auth.currentUser!.id;

      final res = await client
          .from('messages')
          .insert(msgData)
          .select()
          .single();

      return MessageModel.fromJson(res);
    } catch (e) {
      throw ServerException('Failed to send message: ${e.toString()}');
    }
  }

  @override
  Future<List<MessageModel>> getMessages({
    required String roomId,
    int limit = 30,
  }) async {
    try {
      final res = await client
          .from('messages')
          .select()
          .eq('room_id', roomId)
          .order('created_at', ascending: false) // Get newest first
          .limit(limit);

      // Return reversed list so it displays correctly in a standard ListView (Old -> New)
      // Or keep as is if using reverse: true in ListView
      return (res as List).map((e) => MessageModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException('Failed to fetch messages: ${e.toString()}');
    }
  }

  @override
  Stream<List<MessageModel>> streamMessages(String roomId) {
    return client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .map((rows) => rows.map((e) => MessageModel.fromJson(e)).toList());
  }

  // Helper method to check if the room is already created
  Future<bool> isRoomAlreadyCreated(
    RoomType type,
    String userId,
    String? targetedUserId,
    String? organizationId,
  ) async {
    try {
      if (type == RoomType.organization && organizationId != null) {
        final response = await client
            .from('rooms')
            .select()
            .eq('organization_id', organizationId)
            .maybeSingle();

        return response != null;
      }

      if (type == RoomType.dm && targetedUserId != null) {
        final response = await client
            .from('room_members')
            .select('room_id')
            .inFilter('user_id', [userId, targetedUserId]);

        if ((response as List).isEmpty) {
          return false;
        }

        final roomCounts = <String, int>{};

        for (final row in response) {
          final roomId = row['room_id'] as String;
          roomCounts[roomId] = (roomCounts[roomId] ?? 0) + 1;
        }

        final sharedRoomId = roomCounts.entries
            .firstWhere(
              (entry) => entry.value == 2,
              orElse: () => const MapEntry('', 0),
            )
            .key;

        if (sharedRoomId.isEmpty) return false;

        final roomResponse = await client
            .from('rooms')
            .select('type')
            .eq('id', sharedRoomId)
            .maybeSingle();

        return roomResponse != null && roomResponse['type'] == 'dm';
      }

      return false;
    } catch (e) {
      throw ServerException(
        'Failed to check the room is available or not: ${e.toString()}',
      );
    }
  }

  @override
  Future<RoomModel?> getSpecificRoom(
    String userId,
    String? targetUserId,
    String? organizationId,
  ) async {
    try {
      if (organizationId != null) {
        final response = await client
            .from('rooms')
            .select()
            .eq('organization_id', organizationId)
            .eq('type', 'organization')
            .maybeSingle();
        if (response != null) {
          return RoomModel.fromJson(response);
        }
        return null;
      }
      if (targetUserId != null) {
        final memberRooms = await client
            .from('room_members')
            .select('room_id')
            .eq('user_id', userId);

        if (memberRooms.isEmpty) return null;

        final roomIds = memberRooms.map((e) => e['room_id']).toList();

        final room = await client
            .from('rooms')
            .select()
            .inFilter('id', roomIds)
            .eq('type', 'dm')
            .maybeSingle();

        if (room != null) {
          return RoomModel.fromJson(room);
        }

        return null;
      } else {
        return null;
      }
    } catch (e) {
      throw ServerException(
        'Failed to get the specific room related to the user or organizations: ${e.toString()}',
      );
    }
  }
}
