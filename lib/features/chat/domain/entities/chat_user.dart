import 'package:equatable/equatable.dart';

class ChatUser extends Equatable {
  final String id;
  final String userId;
  final String fullName;
  final String? imageUrl;

  const ChatUser({
    required this.id,
    required this.userId,
    required this.fullName,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, userId, fullName, imageUrl];
}
