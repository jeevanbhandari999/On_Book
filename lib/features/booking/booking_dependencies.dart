import 'package:app/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:app/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:app/features/booking/domain/repositories/booking_repository.dart';
import 'package:app/features/booking/domain/usecases/create_booking_use_case.dart';
import 'package:app/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingDependencies {
  static Future<void> register(GetIt getIt) async {
    // Data sources
    getIt.registerLazySingleton<BookingRemoteDataSource>(
      () =>
          BookingRemoteDataSourceImpl(supabaseClient: Supabase.instance.client),
    );

    // Repository
    getIt.registerLazySingleton<BookingRepository>(
      () => BookingRepositoryImpl(
        remoteDataSource: getIt<BookingRemoteDataSource>(),
      ),
    );

    // Usecases
    getIt.registerLazySingleton<CreateBookingUseCase>(
      () => CreateBookingUseCase(
        getIt<BookingRepository>(),
        getIt<PostRepository>(),
      ),
    );

    // BLoC
    getIt.registerFactory<BookingFormBloc>(
      () => BookingFormBloc(
        createBookingUseCase: CreateBookingUseCase(
          getIt<BookingRepository>(),
          getIt<PostRepository>(),
        ),
      ),
    );
  }
}
