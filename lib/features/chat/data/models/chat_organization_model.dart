import '../../domain/entities/chat_organization.dart';

class ChatOrganizationModel {
  final String id;
  final String name;
  final String? logoUrl;

  ChatOrganizationModel({required this.id, required this.name, this.logoUrl});

  factory ChatOrganizationModel.fromJson(Map<String, dynamic> json) {
    return ChatOrganizationModel(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logo_url'] as String?,
    );
  }

  ChatOrganization toEntity() {
    return ChatOrganization(id: id, name: name, logoUrl: logoUrl);
  }
}
