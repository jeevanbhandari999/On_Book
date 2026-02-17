import 'package:app/features/home/domain/repositories/home_repository.dart';
import 'package:app/features/home/domain/usecases/get_all_posts_near_by_user_use_case.dart';
import 'package:app/features/home/domain/usecases/get_organization_detail_by_post_organization_id.dart';
import 'package:app/features/home/domain/usecases/get_organization_list_based_on_global_score_use_case.dart';
import 'package:app/features/home/domain/usecases/stream_saved_post_use_case.dart';
import 'package:app/features/home/domain/usecases/toggle_post_save_or_unsave_use_case.dart';
import 'package:app/features/home/presentation/bloc/get_organization_list_based_on_global_score_bloc.dart';
import 'package:app/features/home/presentation/bloc/home_bloc.dart';
import 'package:app/features/home/presentation/bloc/toggle_post_save_or_unsave_bloc.dart';
import 'package:app/features/search/data/datasources/search_remote_data_source.dart';
import 'package:app/features/search/data/repositories/search_repository_impl.dart';
import 'package:app/features/search/domain/repositories/search_repository.dart';
import 'package:app/features/search/domain/usecases/search_use_cases.dart';
import 'package:app/features/search/presentation/bloc/search_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchDependencies {
  static Future<void> register(GetIt getIt) async {
    // Data sources
    getIt.registerLazySingleton<SearchRemoteDataSource>(
      () => SearchRemoteDataSourceImpl(supabase: Supabase.instance.client),
    );

    // Repository
    getIt.registerLazySingleton<SearchRepository>(
      () => SearchRepositoryImpl(
        remoteDataSource: getIt<SearchRemoteDataSource>(),
      ),
    );

    // Usecases
    getIt.registerLazySingleton<GetDiscoveryFeedUseCase>(
      () => GetDiscoveryFeedUseCase(getIt<SearchRepository>()),
    );

    getIt.registerLazySingleton<SearchAllUseCase>(
      () => SearchAllUseCase(getIt<SearchRepository>()),
    );

    getIt.registerLazySingleton<SearchUsersUseCase>(
      () => SearchUsersUseCase(getIt<SearchRepository>()),
    );

    getIt.registerLazySingleton<SearchPostsUseCase>(
      () => SearchPostsUseCase(getIt<SearchRepository>()),
    );

    getIt.registerLazySingleton<SearchOrganizationsUseCase>(
      () => SearchOrganizationsUseCase(getIt<SearchRepository>()),
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

    getIt.registerFactory(
      () => SearchBloc(
        getDiscoveryFeedUseCase: getIt<GetDiscoveryFeedUseCase>(),
        searchAllUseCase: getIt<SearchAllUseCase>(),
      ),
    );
  }
}
