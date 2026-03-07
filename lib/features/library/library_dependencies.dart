import 'package:app/features/home/domain/usecases/get_organization_detail_by_post_organization_id.dart';
import 'package:app/features/library/data/datasources/library_local_data_source.dart';
import 'package:app/features/library/data/datasources/library_remote_data_source.dart';
import 'package:app/features/library/data/repositories/library_repository_impl.dart';
import 'package:app/features/library/domain/repositories/library_repository.dart';
import 'package:app/features/library/domain/usecases/get_all_booking_by_user_id_use_case.dart';
import 'package:app/features/library/domain/usecases/get_all_booking_related_to_organization_use_case.dart';
import 'package:app/features/library/domain/usecases/get_all_saved_posts_use_case.dart';
import 'package:app/features/library/domain/usecases/update_booking_status_by_id_use_case.dart';
import 'package:app/features/library/presentation/bloc/get_all_saved_posts_bloc.dart';
import 'package:app/features/library/presentation/bloc/library_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LibraryDependencies {
  static Future<void> register(GetIt getIt) async {
    // Data sources
    getIt.registerLazySingleton<LibraryLocalDataSource>(
      () => LibraryLocalDataSourceImpl(
        secureStorage: const FlutterSecureStorage(),
      ),
    );
    getIt.registerLazySingleton<LibraryRemoteDataSource>(
      () =>
          LibraryRemoteDataSourceImpl(supabaseClient: Supabase.instance.client),
    );

    // Repository
    getIt.registerLazySingleton<LibraryRepository>(
      () => LibraryRepositoryImpl(
        remoteDataSource: getIt<LibraryRemoteDataSource>(),
        localDataSource: getIt<LibraryLocalDataSource>(),
      ),
    );

    // Usecases
    getIt.registerLazySingleton<GetAllBookingsByUserIdUseCase>(
      () => GetAllBookingsByUserIdUseCase(getIt<LibraryRepository>()),
    );

    getIt.registerLazySingleton<GetAllBookingRelatedToOrganizationUseCase>(
      () =>
          GetAllBookingRelatedToOrganizationUseCase(getIt<LibraryRepository>()),
    );

    getIt.registerLazySingleton<UpdateBookingStatusByIdUseCase>(
      () => UpdateBookingStatusByIdUseCase(getIt<LibraryRepository>()),
    );

    getIt.registerLazySingleton<GetAllSavedPostsUseCase>(
      () => GetAllSavedPostsUseCase(getIt<LibraryRepository>()),
    );

    // BLoC
    getIt.registerFactory<LibraryBloc>(
      () => LibraryBloc(
        getAllBookingsByUserIdUseCase: getIt<GetAllBookingsByUserIdUseCase>(),
        getAllBookingRelatedToOrganizationUseCase:
            getIt<GetAllBookingRelatedToOrganizationUseCase>(),
        updateBookingStatusByIdUseCase: getIt<UpdateBookingStatusByIdUseCase>(),
        getAllSavedPostsUseCase: getIt<GetAllSavedPostsUseCase>(),
        getOrganizationDetailUseCase:
            getIt<GetOrganizationDetailByPostOrganizationIdUseCase>(),
      ),
    );

    getIt.registerFactory<GetAllSavedPostsBloc>(
      () => GetAllSavedPostsBloc(
        getAllSavedPostsUseCase: getIt<GetAllSavedPostsUseCase>(),
      ),
    );
  }
}
