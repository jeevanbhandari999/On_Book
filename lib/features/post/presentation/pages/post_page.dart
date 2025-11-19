import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/post/domain/usecases/get_all_posts_by_organization_id_use_case.dart';
import 'package:app/features/post/domain/usecases/get_all_posts_with_images_by_orgnization_id.dart';
import 'package:app/features/post/domain/usecases/get_all_posts_with_videos_by_organization_id.dart';
import 'package:app/features/post/presentation/bloc/posts_bloc.dart';
import 'package:app/features/post/presentation/pages/dummy_post_page.dart';
import 'package:app/features/post/presentation/pages/manager_or_staff_with_out_organization_page.dart';
import 'package:app/features/post/presentation/pages/owner_page.dart';
import 'package:app/features/post/services/post_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PostPage extends StatelessWidget {
  const PostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => OrganizationPostsBloc(
            getAllPostsByOrganizationId:
                DependencyInjection.get<GetAllPostsByOrganizationIdUseCase>(),
            getAllPostsWithImagesByOrganizationId:
                DependencyInjection.get<
                  GetAllPostsWithImagesByOrganizationIdUseCase
                >(),
            getAllPostsWithVideosByOrganizationId:
                DependencyInjection.get<
                  GetAllPostsWithVideosByOrganizationId
                >(),
            postServices: DependencyInjection.get<PostServices>(),
          )..add(const ChecKUserRoleAndOrganizationDetailStatus()),
      child: const PostView(),
    );
  }
}

class PostView extends StatelessWidget {
  const PostView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<OrganizationPostsBloc, OrganizationPostsState>(
        listener: (context, state) {
          if (state is AdminLoggedIn) {
            context.go(RouteConstants.anotherPage);
          }
        },
        builder: (context, state) {
          // print(state);
          if (state is UserRoleAndOrganizationDetailStatusChecking) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrganizationOwnerLoggedIn) {
            final user = state.user;
            final organization = state.organization;
            return OwnerPage(user: user, organization: organization);
          } else if (state is OrganizationManagerLoggedIn) {
            final user = state.user;
            final organization = state.organization;
            return OwnerPage(user: user, organization: organization);
          } else if (state is OrganizationStaffLoggedIn) {
            final user = state.user;
            final organization = state.organization;
            return OwnerPage(user: user, organization: organization);
          } else if (state
              is ManagerOrStaffLoggedInWithOutJoiningOrganization) {
            return ManagerOrStaffWithOutOrganizationPage(user: state.user);
          } else if (state is GeneralUserLoggedIn) {
            return DummyPostPage(user: state.user);
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton:
          BlocBuilder<OrganizationPostsBloc, OrganizationPostsState>(
            builder: (context, state) {
              if (state is OrganizationOwnerLoggedIn) {
                return CustomButton(
                  text: 'Create Post',
                  onPressed: () {
                    context.push(
                      RouteConstants.createPostPage,
                      extra: {
                        'userId': state.user.userId,
                        'organizationId': state.organization.id,
                      },
                    );
                  },
                  icon: const Icon(Icons.add),
                );
              }
              if (state is OrganizationManagerLoggedIn) {
                return CustomButton(
                  text: 'Create Post',
                  onPressed: () {
                    context.push(
                      RouteConstants.createPostPage,
                      extra: {
                        'userId': state.user.userId,
                        'organizationId': state.organization.id,
                      },
                    );
                  },
                  icon: const Icon(Icons.add),
                );
              }

              return const SizedBox.shrink();
            },
          ),
    );
  }
}
