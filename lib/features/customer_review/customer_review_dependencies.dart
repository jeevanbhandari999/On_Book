import 'package:app/features/customer_review/data/datasources/customer_review_local_data_source.dart';
import 'package:app/features/customer_review/data/datasources/customer_review_remote_data_source.dart';
import 'package:app/features/customer_review/data/repositories/customer_review_repository_impl.dart';
import 'package:app/features/customer_review/domain/repositories/customer_review_repository.dart';
import 'package:app/features/customer_review/domain/usecases/create_customer_review_for_specific_post_use_case.dart';
import 'package:app/features/customer_review/domain/usecases/get_all_customer_review_related_to_post_use_case.dart';
import 'package:app/features/customer_review/domain/usecases/get_review_reaction_count_use_case.dart';
import 'package:app/features/customer_review/domain/usecases/stream_review_reaction_use_case.dart';
import 'package:app/features/customer_review/domain/usecases/toggle_review_reaction_use_case.dart';
import 'package:app/features/customer_review/presentation/bloc/create_customer_review_bloc.dart';
import 'package:app/features/customer_review/presentation/bloc/get_all_customer_review_related_to_the_post_bloc.dart';
import 'package:app/features/customer_review/presentation/bloc/review_reaction_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerReviewDependencies {
  static Future<void> register(GetIt getIt) async {
    // Data sources
    getIt.registerLazySingleton<CustomerReviewRemoteDataSource>(
      () => CustomerReviewRemoteDataSourceImpl(
        supabaseClient: Supabase.instance.client,
      ),
    );

    getIt.registerLazySingleton<CustomerReviewLocalDataSource>(
      () => CustomerReviewLocalDataSourceImpl(
        secureStorage: const FlutterSecureStorage(),
      ),
    );

    // Repository
    getIt.registerLazySingleton<CustomerReviewRepository>(
      () => CustomerReviewRepositoryImpl(
        remoteDataSource: getIt<CustomerReviewRemoteDataSource>(),
        localDataSource: getIt<CustomerReviewLocalDataSource>(),
      ),
    );

    // Usecases
    getIt.registerLazySingleton<CreateCustomerReviewForSpecificPostUseCase>(
      () => CreateCustomerReviewForSpecificPostUseCase(
        getIt<CustomerReviewRepository>(),
      ),
    );
    getIt.registerLazySingleton<GetAllCustomerReviewRelatedToPostUseCase>(
      () => GetAllCustomerReviewRelatedToPostUseCase(
        getIt<CustomerReviewRepository>(),
      ),
    );

    getIt.registerLazySingleton<ToggleReviewReactionUseCase>(
      () => ToggleReviewReactionUseCase(getIt<CustomerReviewRepository>()),
    );

    getIt.registerLazySingleton<StreamReviewReactionsUseCase>(
      () => StreamReviewReactionsUseCase(getIt<CustomerReviewRepository>()),
    );

    getIt.registerLazySingleton<GetReviewReactionCountsUseCase>(
      () => GetReviewReactionCountsUseCase(getIt<CustomerReviewRepository>()),
    );

    // BLoC
    getIt.registerFactory<GetAllCustomerReviewRelatedToThePostBloc>(
      () => GetAllCustomerReviewRelatedToThePostBloc(
        getAllCustomerReviewRelatedToPostUseCase:
            GetAllCustomerReviewRelatedToPostUseCase(
              getIt<CustomerReviewRepository>(),
            ),
      ),
    );

    getIt.registerFactory<CreateCustomerReviewBloc>(
      () => CreateCustomerReviewBloc(
        createCustomerReviewForSpecificPostUseCase:
            CreateCustomerReviewForSpecificPostUseCase(
              getIt<CustomerReviewRepository>(),
            ),
      ),
    );

    getIt.registerFactory<ReviewReactionBloc>(
      () => ReviewReactionBloc(
        toggleUseCase: ToggleReviewReactionUseCase(
          getIt<CustomerReviewRepository>(),
        ),
        streamUseCase: StreamReviewReactionsUseCase(
          getIt<CustomerReviewRepository>(),
        ),
      ),
    );
  }
}
