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

    getIt.registerFactory(
      () => SearchBloc(
        getDiscoveryFeedUseCase: getIt<GetDiscoveryFeedUseCase>(),
        searchAllUseCase: getIt<SearchAllUseCase>(),
      ),
    );
  }
}
