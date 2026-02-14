import 'package:equatable/equatable.dart';

class ChatOrganization extends Equatable {
  final String id;
  final String name;
  final String? logoUrl;

  const ChatOrganization({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  @override
  List<Object?> get props => [id, name, logoUrl];
}
