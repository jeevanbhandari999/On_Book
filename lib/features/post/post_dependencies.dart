import 'package:app/features/auth/services/auth_service.dart';
import 'package:app/features/post/data/datasources/post_local_data_source.dart';
import 'package:app/features/post/data/datasources/post_remote_data_source.dart';
import 'package:app/features/post/data/repositories/post_repository_impl.dart';
import 'package:app/features/post/domain/repositories/post_repository.dart';
import 'package:app/features/post/domain/usecases/create_post_use_case.dart';
import 'package:app/features/post/domain/usecases/delete_post_use_case.dart';
import 'package:app/features/post/domain/usecases/get_all_posts_by_organization_id_use_case.dart';
import 'package:app/features/post/domain/usecases/get_all_posts_with_images_by_orgnization_id.dart';
import 'package:app/features/post/domain/usecases/get_all_posts_with_videos_by_organization_id.dart';
import 'package:app/features/post/domain/usecases/get_post_by_id_use_case.dart';
import 'package:app/features/post/presentation/bloc/post_details_bloc.dart';
import 'package:app/features/post/presentation/bloc/post_form_bloc.dart';
import 'package:app/features/post/presentation/bloc/posts_bloc.dart';
import 'package:app/features/post/services/post_services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostDependencies {
  static Future<void> register(GetIt getIt) async {
    // Data sources
    getIt.registerLazySingleton<PostRemoteDataSource>(
      () => PostRemoteDataSourceImpl(supabaseClient: Supabase.instance.client),
    );

    getIt.registerLazySingleton<PostLocalDataSource>(
      () =>
          PostLocalDataSourceImpl(secureStorage: const FlutterSecureStorage()),
    );

    // Repository
    getIt.registerLazySingleton<PostRepository>(
      () => PostRepositoryImpl(
        remoteDataSource: getIt<PostRemoteDataSource>(),
        localDataSource: getIt<PostLocalDataSource>(),
      ),
    );

    // Services
    getIt.registerLazySingleton<PostServices>(
      () => PostServices(authService: getIt<AuthService>()),
    );

    // Usecases
    getIt.registerLazySingleton<CreatePostUseCase>(
      () => CreatePostUseCase(getIt<PostRepository>()),
    );
    getIt.registerLazySingleton<GetAllPostsByOrganizationIdUseCase>(
      () => GetAllPostsByOrganizationIdUseCase(getIt<PostRepository>()),
    );

    getIt.registerLazySingleton<GetAllPostsWithImagesByOrganizationIdUseCase>(
      () =>
          GetAllPostsWithImagesByOrganizationIdUseCase(getIt<PostRepository>()),
    );

    getIt.registerLazySingleton<GetAllPostsWithVideosByOrganizationId>(
      () => GetAllPostsWithVideosByOrganizationId(getIt<PostRepository>()),
    );

    getIt.registerLazySingleton<GetPostByIdUseCase>(
      () => GetPostByIdUseCase(getIt<PostRepository>()),
    );

    getIt.registerLazySingleton<DeletePostUseCase>(
      () => DeletePostUseCase(getIt<PostRepository>()),
    );

    // BLoC
    getIt.registerFactory<PostFormBloc>(
      () => PostFormBloc(
        createPostUseCase: CreatePostUseCase(getIt<PostRepository>()),
      ),
    );

    getIt.registerFactory<OrganizationPostsBloc>(
      () => OrganizationPostsBloc(
        getAllPostsByOrganizationId: GetAllPostsByOrganizationIdUseCase(
          getIt<PostRepository>(),
        ),
        getAllPostsWithImagesByOrganizationId:
            GetAllPostsWithImagesByOrganizationIdUseCase(
              getIt<PostRepository>(),
            ),
        getAllPostsWithVideosByOrganizationId:
            GetAllPostsWithVideosByOrganizationId(getIt<PostRepository>()),
        postServices: PostServices(authService: getIt<AuthService>()),
      ),
    );

    getIt.registerFactory<PostDetailsBloc>(
      () => PostDetailsBloc(
        getPostByIdUseCase: GetPostByIdUseCase(getIt<PostRepository>()),
        deletePostUseCase: DeletePostUseCase(getIt<PostRepository>()),
      ),
    );
  }
}
