import 'package:app/features/organizations/data/datasources/organization_local_data_source.dart';
import 'package:app/features/organizations/data/datasources/organization_remote_data_source.dart';
import 'package:app/features/organizations/data/repositories/organization_repository_impl.dart';
import 'package:app/features/organizations/domain/repositories/organization_repository.dart';
import 'package:app/features/organizations/domain/usecases/get_organization_members_use_case.dart';
import 'package:app/features/organizations/domain/usecases/get_user_organization_detail_use_case.dart';
import 'package:app/features/organizations/presentation/bloc/get_user_organization_details_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrganizationDependencies {
  static Future<void> register(GetIt getIt) async {
    // Register data sources
    getIt.registerLazySingleton<OrganizationLocalDataSource>(
      () => const OrganizationLocalDataSourceImpl(
        secureStorage: FlutterSecureStorage(),
      ),
    );

    getIt.registerLazySingleton<OrganizationRemoteDataSource>(
      () => OrganizationRemoteDataSourceImpl(
        supabaseClient: Supabase.instance.client,
      ),
    );

    // Repositoties
    getIt.registerLazySingleton<OrganizationRepository>(
      () => OrganizationRepositoryImpl(
        localDataSource: getIt<OrganizationLocalDataSource>(),
        remoteDataSource: getIt<OrganizationRemoteDataSource>(),
      ),
    );

    // Usecases
    getIt.registerLazySingleton<GetUserOrganizationDetailUseCase>(
      () => GetUserOrganizationDetailUseCase(getIt<OrganizationRepository>()),
    );
    getIt.registerLazySingleton<GetOrganizationMembersUseCase>(
      () => GetOrganizationMembersUseCase(getIt<OrganizationRepository>()),
    );

    // BLoCs
    getIt.registerLazySingleton<GetUserOrganizationDetailsBloc>(
      () => GetUserOrganizationDetailsBloc(
        getUserOrganizationDetailUseCase:
            getIt<GetUserOrganizationDetailUseCase>(),
        getOrganizationMembersUseCase: getIt<GetOrganizationMembersUseCase>(),
      ),
    );
  }
}
