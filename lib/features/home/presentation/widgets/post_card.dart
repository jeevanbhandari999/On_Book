import 'dart:ui';

import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/customer_review/domain/usecases/get_all_customer_review_related_to_post_use_case.dart';
import 'package:app/features/home/domain/usecases/stream_saved_post_use_case.dart';
import 'package:app/features/home/domain/usecases/toggle_post_save_or_unsave_use_case.dart';
import 'package:app/features/home/presentation/bloc/post_rating_summary_bloc.dart';
import 'package:app/features/home/presentation/bloc/toggle_post_save_or_unsave_bloc.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final Organization organization;
  final String userId;

  const PostCard({
    super.key,
    required this.post,
    required this.organization,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TogglePostSaveOrUnsaveBloc(
            toggleUseCase:
                DependencyInjection.get<TogglePostSaveOrUnsaveUseCase>(),
            streamUseCase: DependencyInjection.get<StreamSavedPostsUseCase>(),
          )..add(PostSaveStarted(userId)),
        ),

        BlocProvider(
          create: (context) => PostRatingSummaryBloc(
            getReviewsUseCase:
                DependencyInjection.get<
                  GetAllCustomerReviewRelatedToPostUseCase
                >(),
          )..add(PostRatingSummaryRequested(postId: post.id)),
        ),
      ],
      child: PostView(post: post, organization: organization, userId: userId),
    );
  }
}

class PostView extends StatelessWidget {
  final Post post;
  final Organization organization;
  final String userId;

  const PostView({
    super.key,
    required this.post,
    required this.organization,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final double baseHeight = 200;
    final double heightVariation = (post.title.length % 5) * 40.0;
    final double cardHeight = baseHeight + heightVariation;
    final double maxHeight = MediaQuery.of(context).size.height * 0.55;

    final theme = Theme.of(context);
    final isAvailable = post.status == PostStatus.available;

    return BlocListener<
      TogglePostSaveOrUnsaveBloc,
      TogglePostSaveOrUnsaveState
    >(
      listenWhen: (prev, curr) =>
          prev.message != curr.message && curr.message != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.message!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: theme.colorScheme.primary,
            ),
          );

        context.read<TogglePostSaveOrUnsaveBloc>().add(
          const PostSaveMessageConsumed(),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            context.push(
              RouteConstants.postDetailsPage,
              extra: {'postId': post.id, 'post': post, 'userId': userId},
            );
          },
          borderRadius: BorderRadius.circular(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: cardHeight < maxHeight ? cardHeight : maxHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: post.primaryImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),

                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? Colors.green.withAlpha(225)
                                : Colors.black54,
                            borderRadius: BorderRadius.circular(
                              UiConstants.radiusRound,
                            ),
                          ),
                          child: Text(
                            isAvailable ? 'Available' : 'Booked',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: 8,
                        right: 8,
                        child:
                            BlocBuilder<
                              TogglePostSaveOrUnsaveBloc,
                              TogglePostSaveOrUnsaveState
                            >(
                              buildWhen: (prev, curr) =>
                                  prev.isSaved(post.id) !=
                                  curr.isSaved(post.id),
                              builder: (context, state) {
                                final isSaved = state.isSaved(post.id);

                                return InkWell(
                                  onTap: () {
                                    context
                                        .read<TogglePostSaveOrUnsaveBloc>()
                                        .add(
                                          PostSaveToggleRequested(
                                            postId: post.id,
                                            userId: userId,
                                            organizationId: organization.id,
                                          ),
                                        );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(
                                        UiConstants.radiusRound,
                                      ),
                                    ),
                                    child: AnimatedSwitcher(
                                      duration:
                                          UiConstants.animationDelayFaster,
                                      transitionBuilder: (child, animation) {
                                        return ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        );
                                      },
                                      child: Icon(
                                        isSaved
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_outlined,
                                        size: UiConstants.iconSm,
                                        key: ValueKey(isSaved),
                                        color: isSaved
                                            ? Colors.red
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                      ),

                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              color: Colors.white.withAlpha(100),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              post.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                            ),

                                            BlocBuilder<
                                              PostRatingSummaryBloc,
                                              PostRatingSummaryState
                                            >(
                                              builder: (context, state) {
                                                if (state
                                                    is PostRatingSummaryLoading) {
                                                  return const SizedBox(
                                                    height: 14,
                                                    width: 60,
                                                    child:
                                                        LinearProgressIndicator(),
                                                  );
                                                }

                                                if (state
                                                    is PostRatingSummaryLoaded) {
                                                  // Show nothing if no reviews yet — keeps card clean
                                                  if (state.reviewCount == 0) {
                                                    return const Text(
                                                      'No reviews yet',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.black54,
                                                      ),
                                                    );
                                                  }

                                                  return Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.star_rounded,
                                                        size: 14,
                                                        color: Colors.amber,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${state.average}',
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '(${state.reviewCount})',
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }
                                                // Error or initial — show nothing, don't break layout
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          context.push(
                                            RouteConstants
                                                .organizationDetailsPageUserSide,
                                            extra: {
                                              'organizationId':
                                                  post.organizationId,
                                              'userId': userId,
                                            },
                                          );
                                        },
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor:
                                              theme.colorScheme.primary,
                                          child:
                                              (organization.logoUrl != null &&
                                                  organization
                                                      .logoUrl!
                                                      .isNotEmpty)
                                              ? ClipOval(
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        organization.logoUrl!,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  ),
                                                )
                                              : Center(
                                                  child: Text(
                                                    _getInitialCharactrOfOrganization(
                                                      organization.name,
                                                    ),
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Rs. ${post.price!.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: isAvailable
                                            ? () {
                                                context.push(
                                                  RouteConstants
                                                      .bookingFormPage,
                                                  extra: {
                                                    'userId': userId,
                                                    'postId': post.id,
                                                    'post': post,
                                                  },
                                                );
                                              }
                                            : null,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isAvailable
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(
                                                    context,
                                                  ).disabledColor,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            isAvailable ? 'Book' : 'Booked',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _getInitialCharactrOfOrganization(String name) {
  return name
      .trim()
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase())
      .join();
}
