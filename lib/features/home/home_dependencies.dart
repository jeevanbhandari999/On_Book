import 'package:app/features/home/data/datasources/home_local_data_source.dart';
import 'package:app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:app/features/home/data/repositories/home_repository_impl.dart';
import 'package:app/features/home/domain/repositories/home_repository.dart';
import 'package:app/features/home/domain/usecases/get_all_posts_near_by_user_use_case.dart';
import 'package:app/features/home/presentation/bloc/home_bloc.dart';
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

    // BLoC
    getIt.registerFactory<HomeBloc>(
      () => HomeBloc(
        getNearbyPostsUseCase: GetAllPostsNearByUserUseCase(
          getIt<HomeRepository>(),
        ),
      ),
    );
  }
}
