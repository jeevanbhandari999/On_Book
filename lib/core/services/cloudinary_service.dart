import 'package:app/app/app_config.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  CloudinaryService._internal();

  static final CloudinaryService _instance = CloudinaryService._internal();
  static CloudinaryService get instance => _instance;

  final cloudinary = CloudinaryPublic(
    AppConfig.cloudinaryCloudName,
    AppConfig.cloudinaryUploadPreset,
    cache: false,
  );
}
