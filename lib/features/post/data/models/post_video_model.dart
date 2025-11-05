import 'package:equatable/equatable.dart';

class PostVideoModel extends Equatable {
  final String id;
  final String organizationId;
  final String videoUrl;
  final String uploadedBy;
  final String updatedBy;
  final String createdAt;
  final String updatedAt;

  const PostVideoModel({
    required this.id,
    required this.organizationId,
    required this.videoUrl,
    required this.uploadedBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    organizationId,
    videoUrl,
    uploadedBy,
    updatedBy,
    createdAt,
    updatedAt,
  ];
}
