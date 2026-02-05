import 'package:app/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:app/features/profile/domain/repositories/profile_repository.dart';
import 'package:app/features/profile/domain/usecases/delete_profile_picture_use_case.dart';
import 'package:app/features/profile/domain/usecases/edit_user_profile_use_case.dart';
import 'package:app/features/profile/domain/usecases/get_current_user_profile_use_case.dart';
import 'package:app/features/profile/domain/usecases/update_profile_picture_use_case.dart';
import 'package:app/features/profile/presentation/bloc/edit_user_profile_bloc.dart';
import 'package:app/features/profile/presentation/bloc/get_current_user_profile_details_bloc.dart';
import 'package:app/features/profile/presentation/bloc/update_profile_picture_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDependencies {
  static Future<void> register(GetIt getIt) async {
    // Data sources
    getIt.registerLazySingleton<ProfileLocalDataSource>(
      () => ProfileLocalDataSourceImpl(
        secureStorage: const FlutterSecureStorage(),
      ),
    );

    getIt.registerLazySingleton<ProfileRemoteDataSource>(
      () =>
          ProfileRemoteDataSourceImpl(supabaseClient: Supabase.instance.client),
    );

    // Repositories
    getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        localDataSource: getIt<ProfileLocalDataSource>(),
        remoteDataSource: getIt<ProfileRemoteDataSource>(),
      ),
    );

    // Usecases
    getIt.registerLazySingleton<GetCurrentUserProfileUseCase>(
      () => GetCurrentUserProfileUseCase(getIt<ProfileRepository>()),
    );

    getIt.registerLazySingleton<UpdateProfilePictureUseCase>(
      () => UpdateProfilePictureUseCase(getIt<ProfileRepository>()),
    );

    getIt.registerLazySingleton<DeleteProfilePictureUseCase>(
      () => DeleteProfilePictureUseCase(getIt<ProfileRepository>()),
    );

    getIt.registerLazySingleton<EditUserProfileUseCase>(
      () => EditUserProfileUseCase(getIt<ProfileRepository>()),
    );

    // BLoCs
    getIt.registerFactory<GetCurrentUserProfileDetailsBloc>(
      () => GetCurrentUserProfileDetailsBloc(
        getCurrentUserProfileUseCase: getIt<GetCurrentUserProfileUseCase>(),
      ),
    );

    getIt.registerFactory<UpdateProfilePictureBloc>(
      () => UpdateProfilePictureBloc(
        updateProfilePictureUseCase: getIt<UpdateProfilePictureUseCase>(),
        deleteProfilePictureUseCase: getIt<DeleteProfilePictureUseCase>(),
        repository: getIt<ProfileRepository>(),
      ),
    );

    getIt.registerFactory<EditUserProfileBloc>(
      () => EditUserProfileBloc(
        editUserProfileUseCase: getIt<EditUserProfileUseCase>(),
      ),
    );
  }
}
