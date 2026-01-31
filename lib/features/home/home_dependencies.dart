import 'package:app/features/home/data/datasources/home_local_data_source.dart';
import 'package:app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:app/features/home/data/repositories/home_repository_impl.dart';
import 'package:app/features/home/domain/repositories/home_repository.dart';
import 'package:app/features/home/domain/usecases/get_all_posts_near_by_user_use_case.dart';
import 'package:app/features/home/domain/usecases/get_organization_detail_by_post_organization_id.dart';
import 'package:app/features/home/domain/usecases/get_organization_list_based_on_global_score_use_case.dart';
import 'package:app/features/home/domain/usecases/stream_saved_post_use_case.dart';
import 'package:app/features/home/domain/usecases/toggle_post_save_or_unsave_use_case.dart';
import 'package:app/features/home/presentation/bloc/get_organization_list_based_on_global_score_bloc.dart';
import 'package:app/features/home/presentation/bloc/home_bloc.dart';
import 'package:app/features/home/presentation/bloc/toggle_post_save_or_unsave_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeDependencies {
  static Future<void> register(GetIt getIt) async {
    // Data sources
    getIt.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(supabaseClient: Supabase.instance.client),
    );

    getIt.registerLazySingleton<HomeLocalDataSource>(
      () =>
          HomeLocalDataSourceImpl(secureStorage: const FlutterSecureStorage()),
    );

    // Repository
    getIt.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(
        remoteDataSource: getIt<HomeRemoteDataSource>(),
        localDataSource: getIt<HomeLocalDataSource>(),
      ),
    );

    // Usecases
    getIt.registerLazySingleton<GetAllPostsNearByUserUseCase>(
      () => GetAllPostsNearByUserUseCase(getIt<HomeRepository>()),
    );
    getIt.registerLazySingleton<
      GetOrganizationDetailByPostOrganizationIdUseCase
    >(
      () => GetOrganizationDetailByPostOrganizationIdUseCase(
        getIt<HomeRepository>(),
      ),
    );

    getIt.registerLazySingleton<GetOrganizationListBasedOnGlobalScoreUseCase>(
      () =>
          GetOrganizationListBasedOnGlobalScoreUseCase(getIt<HomeRepository>()),
    );

    getIt.registerLazySingleton<StreamSavedPostsUseCase>(
      () => StreamSavedPostsUseCase(getIt<HomeRepository>()),
    );

    getIt.registerLazySingleton<TogglePostSaveOrUnsaveUseCase>(
      () => TogglePostSaveOrUnsaveUseCase(getIt<HomeRepository>()),
    );

    // BLoC
    getIt.registerFactory<HomeBloc>(
      () => HomeBloc(
        getNearbyPostsUseCase: GetAllPostsNearByUserUseCase(
          getIt<HomeRepository>(),
        ),
        getOrganizationDetailByPostOrganizationIdUseCase:
            GetOrganizationDetailByPostOrganizationIdUseCase(
              getIt<HomeRepository>(),
            ),
      ),
    );

    getIt.registerFactory<GetOrganizationListBasedOnGlobalScoreBloc>(
      () => GetOrganizationListBasedOnGlobalScoreBloc(
        getOrganizationListBasedOnGlobalScoreUseCase:
            GetOrganizationListBasedOnGlobalScoreUseCase(
              getIt<HomeRepository>(),
            ),
      ),
    );

    getIt.registerFactory<TogglePostSaveOrUnsaveBloc>(
      () => TogglePostSaveOrUnsaveBloc(
        toggleUseCase: TogglePostSaveOrUnsaveUseCase(getIt<HomeRepository>()),

        streamUseCase: StreamSavedPostsUseCase(getIt<HomeRepository>()),
      ),
    );
  }
}
