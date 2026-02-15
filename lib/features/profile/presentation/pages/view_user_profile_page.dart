import 'package:app/app/dependency_injection.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/features/profile/domain/usecases/get_current_user_profile_use_case.dart';
import 'package:app/features/profile/presentation/bloc/get_current_user_profile_details_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewUserProfilePage extends StatelessWidget {
  final String userId;
  const ViewUserProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetCurrentUserProfileDetailsBloc(
        getCurrentUserProfileUseCase:
            DependencyInjection.get<GetCurrentUserProfileUseCase>(),
      )..add(GetCurrentUserProfileDetailsRequested(userId: userId)),
      child: const ViewUserProfileView(),
    );
  }
}

class ViewUserProfileView extends StatelessWidget {
  const ViewUserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          BlocBuilder<
            GetCurrentUserProfileDetailsBloc,
            GetCurrentUserProfileDetailsState
          >(
            builder: (context, state) {
              if (state is! GetCurrentUserProfileDetailsSuccess) {
                return const Center(child: CircularProgressIndicator());
              }

              return CustomScrollView(
                slivers: [
                  SliverAppBar(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: UiConstants.spacingMd,
                      ),
                      child: Column(children: [Text(state.user.fullName)]),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }
}
