import 'package:app/core/errors/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/room_model.dart';
import '../models/room_member_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  /// Rooms
  Future<RoomModel> createRoom(RoomModel room);
  Future<List<RoomModel>> getMyRooms();

  /// Members
  Future<void> addMembers({
    required String roomId,
    required List<RoomMemberModel> members,
  });

  Future<List<RoomMemberModel>> getRoomMembers(String roomId);

  Future<void> updateLastRead({
    required String roomId,
    required DateTime lastReadAt,
  });

  /// Messages
  Future<MessageModel> sendMessage(MessageModel message);

  Future<List<MessageModel>> getMessages({
    required String roomId,
    int limit = 30,
  });

  // For real time updates
  Stream<List<MessageModel>> streamMessages(String roomId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient client;

  ChatRemoteDataSourceImpl(this.client);

  // ROOM

  @override
  Future<RoomModel> createRoom(RoomModel room) async {
    try {
      final res = await client
          .from('rooms')
          .insert(room.toCreateJson())
          .select()
          .single();

      return RoomModel.fromJson(res);
    } catch (e) {
      throw ServerException('Failed to create a room: $e');
    }
  }

  @override
  Future<List<RoomModel>> getMyRooms() async {
    try {
      final userId = client.auth.currentUser!.id;

      final res = await client
          .from('room_members')
          .select('rooms(*)')
          .eq('user_id', userId);

      return (res as List).map((e) => RoomModel.fromJson(e['rooms'])).toList();
    } catch (e) {
      throw ServerException('Failed to get a room: $e');
    }
  }

  // MEMBERS

  @override
  Future<void> addMembers({
    required String roomId,
    required List<RoomMemberModel> members,
  }) async {
    try {
      final data = members
          .map((m) => m.copyWith(roomId: roomId).toCreateJson())
          .toList();

      await client.from('room_members').insert(data);
    } catch (e) {
      throw ServerException('Failed to add the members: $e');
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
      throw ServerException('Failed to get the room members : $e');
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
      throw ServerException('Failed to update the last read messages: $e');
    }
  }

  // MESSAGES

  @override
  Future<MessageModel> sendMessage(MessageModel message) async {
    try {
      final res = await client
          .from('messages')
          .insert(message.toCreateJson())
          .select()
          .single();

      return MessageModel.fromJson(res);
    } catch (e) {
      throw ServerException('Failed to send the messages: $e');
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
          .order('created_at', ascending: false)
          .limit(limit);

      return (res as List)
          .map((e) => MessageModel.fromJson(e))
          .toList()
          .reversed
          .toList(); // newest at bottom
    } catch (e) {
      throw ServerException('Failed to get the messages: $e');
    }
  }

  @override
  Stream<List<MessageModel>> streamMessages(String roomId) {
    try {
      return client
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('room_id', roomId)
          .order('created_at')
          .map((rows) => rows.map((e) => MessageModel.fromJson(e)).toList());
    } catch (e) {
      throw ServerException('Failed to stream the messages: $e');
    }
  }
}
