import 'package:app/app/dependency_injection.dart';
import 'package:app/features/organizations/domain/usecases/get_user_organization_detail_use_case.dart';
import 'package:app/features/organizations/presentation/bloc/get_user_organization_details_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrganizationDetailsPageUserSide extends StatelessWidget {
  final String organizationId;
  const OrganizationDetailsPageUserSide({
    super.key,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetUserOrganizationDetailsBloc(
            getUserOrganizationDetailUseCase:
                DependencyInjection.get<GetUserOrganizationDetailUseCase>(),
          )..add(
            GetUserOrganizationDetailsRequested(organizationId: organizationId),
          ),
      child: const OrganizationDetailsViewUserSide(),
    );
  }
}

class OrganizationDetailsViewUserSide extends StatelessWidget {
  const OrganizationDetailsViewUserSide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:
          BlocConsumer<
            GetUserOrganizationDetailsBloc,
            GetUserOrganizationDetailsState
          >(
            listener: (context, state) {
              if (state is GetUserOrganizationDetailsError) {
                print(state.message);
              }
            },
            builder: (context, state) {
              if (state is! GetUserOrganizationDetailsSuccess) {
                return const Center(child: CircularProgressIndicator());
              }
              return Center(child: Text(state.organizationDetails.name));
            },
          ),
    );
  }
}
