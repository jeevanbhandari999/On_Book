import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/utils/date_formatter.dart';
import 'package:app/features/customer_review/domain/entities/rating.dart';
import 'package:app/features/customer_review/domain/entities/review_reaction.dart';
import 'package:app/features/customer_review/domain/usecases/get_all_customer_review_related_to_post_use_case.dart';
import 'package:app/features/customer_review/domain/usecases/stream_review_reaction_use_case.dart';
import 'package:app/features/customer_review/domain/usecases/toggle_review_reaction_use_case.dart';
import 'package:app/features/customer_review/presentation/bloc/get_all_customer_review_related_to_the_post_bloc.dart';
import 'package:app/features/customer_review/presentation/bloc/review_reaction_bloc.dart';
import 'package:app/features/customer_review/presentation/widgets/rating_progress_bar_widget.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/profile/domain/usecases/get_current_user_profile_use_case.dart';
import 'package:app/features/profile/presentation/bloc/get_current_user_profile_details_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

class CustomerReviewPage extends StatelessWidget {
  final Post post;
  final String postId;
  final String? userId;
  const CustomerReviewPage({
    super.key,
    required this.post,
    required this.postId,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              GetAllCustomerReviewRelatedToThePostBloc(
                getAllCustomerReviewRelatedToPostUseCase:
                    DependencyInjection.get<
                      GetAllCustomerReviewRelatedToPostUseCase
                    >(),
              )..add(
                GetAllCustomerReviewRelatedToThePostRequested(
                  postId: postId,
                  userId: userId,
                ),
              ),
        ),
      ],
      child: CustomerReviewView(userId: userId, post: post),
    );
  }
}

class CustomerReviewView extends StatelessWidget {
  final String? userId;
  final Post post;
  const CustomerReviewView({super.key, required this.post, this.userId});

  @override
  Widget build(BuildContext context) {
    // return RefreshIndicator(
    //   onRefresh: () async {
    //     context.read<GetAllCustomerReviewRelatedToThePostBloc>().add(
    //       GetAllCustomerReviewRelatedToThePostRefreshRequested(
    //         postId: post.id,
    //         userId: userId,
    //       ),
    //     );
    //   },
    //   child: Scaffold(
    //     appBar: AppBar(
    //       backgroundColor: AppColors.primaryLight,
    //       title: const Text(
    //         'Customer Review',
    //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    //       ),
    //     ),
    //     body:
    //         BlocBuilder<
    //           GetAllCustomerReviewRelatedToThePostBloc,
    //           GetAllCustomerReviewRelatedToThePostState
    //         >(
    //           builder: (context, state) {
    //             if (state is GetAllCustomerReviewRelatedToThePostLoading) {
    //               return const Center(child: CircularProgressIndicator());
    //             }
    //             if (state is GetAllCustomerReviewRelatedToThePostError) {
    //               ScaffoldMessenger.of(
    //                 context,
    //               ).showSnackBar(SnackBar(content: Text(state.message)));
    //             }
    //             if (state is GetAllCustomerReviewRelatedToThePostSuccess) {
    //               final ratings = state.ratings;
    //               return Padding(
    //                 padding: const EdgeInsets.all(UiConstants.spacingMd),
    //                 child: Column(
    //                   children: [
    //                     _buildCustomerReviewHeader(context, state.ratings),
    //                     _ratingDetailInPercentage(context, state.ratings),
    //                     const SizedBox(height: UiConstants.spacingLg),
    //                     Expanded(
    //                       child: ListView.separated(
    //                         physics: const AlwaysScrollableScrollPhysics(),
    //                         itemBuilder: (context, index) {
    //                           final rating = ratings[index];
    //                           return CustomerReviewItem(
    //                             rating: rating,
    //                             userId: userId,
    //                           );
    //                         },
    //                         separatorBuilder: (context, index) {
    //                           return const SizedBox(
    //                             height: UiConstants.spacingMd,
    //                           );
    //                         },
    //                         itemCount: state.ratings.length,
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               );
    //             }
    //             return const SizedBox.shrink();
    //           },
    //         ),
    //   ),
    // );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<GetAllCustomerReviewRelatedToThePostBloc>().add(
            GetAllCustomerReviewRelatedToThePostRefreshRequested(
              postId: post.id,
              userId: userId,
            ),
          );
        },
        child:
            BlocBuilder<
              GetAllCustomerReviewRelatedToThePostBloc,
              GetAllCustomerReviewRelatedToThePostState
            >(
              builder: (context, state) {
                if (state is GetAllCustomerReviewRelatedToThePostLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is GetAllCustomerReviewRelatedToThePostError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }

                if (state is GetAllCustomerReviewRelatedToThePostSuccess) {
                  final ratings = state.ratings;

                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        backgroundColor: AppColors.primaryLight,
                        pinned: true,
                        expandedHeight: 325,
                        collapsedHeight: 100,
                        foregroundColor: Colors.white,
                        flexibleSpace: Stack(
                          children: [
                            Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(
                                          UiConstants.radiusXl,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .animate()
                                .slideY(
                                  begin: -2,
                                  duration: UiConstants.animationSlow,
                                  curve: Curves.easeOutCubic,
                                )
                                .fadeIn(duration: UiConstants.animationSlow),
                            FlexibleSpaceBar(
                              collapseMode: CollapseMode.parallax,
                              background: SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    UiConstants.spacingMd,
                                    60,
                                    UiConstants.spacingMd,
                                    UiConstants.spacingMd,
                                  ),
                                  child: Column(
                                    children: [
                                      _buildCustomerReviewHeader(
                                        context,
                                        ratings,
                                      ),
                                      _ratingDetailInPercentage(
                                        context,
                                        ratings,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: const Text(
                          'Customer Review',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: UiConstants.spacingMd,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final rating = ratings[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: UiConstants.spacingMd,
                              ),
                              child: CustomerReviewItem(
                                rating: rating,
                                userId: userId,
                              ),
                            );
                          }, childCount: ratings.length),
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
      ),
    );
  }

  Map<int, int> _groupRatingsByStar(List ratings) {
    final Map<int, int> result = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (final rating in ratings) {
      result[rating.ratingValue] = (result[rating.ratingValue] ?? 0) + 1;
    }

    return result;
  }

  Widget _buildCustomerReviewHeader(
    BuildContext context,
    List<Rating> ratings,
  ) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Reviews',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        const Text(
          'Ratings',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        _buildRatingStarIcon(context, post, ratings),
        Text(
          '${ratings.length} Ratings',
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: UiConstants.spacingXs),
      ],
    );
  }

  Widget _buildRatingStarIcon(
    BuildContext context,
    Post post,
    List<Rating> ratings,
  ) {
    final average = _calculateAverageRating(ratings);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${average.toStringAsFixed(1)} out of 5.0',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 8),
            RatingBarIndicator(
              rating: average.toDouble(),
              itemBuilder: (context, index) =>
                  const Icon(Icons.star, color: Colors.amber),
              itemCount: 5,
              itemSize: 20,
              direction: Axis.horizontal,
              unratedColor: Colors.grey,
            ),
          ],
        ),
        const Spacer(),
        InkWell(
          onTap: () => context.push(
            RouteConstants.writeAReviewPage,
            extra: {'post': post, 'userId': userId},
          ),
          child: const Text(
            'White a Review',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  double _calculateAverageRating(List<Rating> ratings) {
    if (ratings.isEmpty) return 0;
    final total = ratings.fold<double>(
      0,
      (sum, item) => sum + item.ratingValue,
    );

    return total / ratings.length;
  }

  Widget _ratingDetailInPercentage(BuildContext context, List ratings) {
    final totalReviews = ratings.length;
    final groupedRatings = _groupRatingsByStar(ratings);

    return Column(
      children: List.generate(5, (index) {
        final star = 5 - index; // 5 → 1
        final count = groupedRatings[star] ?? 0;
        final percent = totalReviews == 0
            ? 0
            : ((count / totalReviews) * 100).round();

        return RatingProgressBar(
          backgroundColor: Colors.grey,
          filledColor: Colors.white,
          ratingRange: star == 1 ? '1 Star' : '$star Stars',
          percent: percent.toDouble(),
          peopleNumber: count,
          textColor: Colors.white,
        );
      }),
    );
  }
}

class CustomerReviewItem extends StatelessWidget {
  final Rating rating;
  final String? userId;

  const CustomerReviewItem({
    super.key,
    required this.rating,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReviewReactionBloc(
            toggleUseCase:
                DependencyInjection.get<ToggleReviewReactionUseCase>(),
            streamUseCase:
                DependencyInjection.get<StreamReviewReactionsUseCase>(),
          )..add(ReviewReactionStarted(rating.id)),
        ),
        BlocProvider(
          create: (context) => GetCurrentUserProfileDetailsBloc(
            getCurrentUserProfileUseCase:
                DependencyInjection.get<GetCurrentUserProfileUseCase>(),
          )..add(GetCurrentUserProfileDetailsRequested(userId: rating.userId)),
        ),
      ],
      child: _ReviewTileBody(rating: rating, userId: userId),
    );
  }
}

class _ReviewTileBody extends StatelessWidget {
  final Rating rating;
  final String? userId;

  const _ReviewTileBody({required this.rating, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(UiConstants.spacingMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(50),
        // color: Colors.blue[300]!.withAlpha(70),
        borderRadius: BorderRadius.circular(UiConstants.radiusSm),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: UiConstants.spacingSm),
          if (rating.comment != null && rating.comment!.isNotEmpty)
            Text(
              rating.comment!,
              style: const TextStyle(color: Colors.black87),
            ),

          const SizedBox(height: UiConstants.spacingXs),

          Text(
            DateFormatter.format(rating.createdAt),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),

          const SizedBox(height: UiConstants.spacingMd),

          _buildReactionRow(context),
        ],
      ),
    );
  }

  Widget _buildReactionRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BlocBuilder<ReviewReactionBloc, ReviewReactionState>(
          builder: (context, reactionState) {
            final isLiked = reactionState.reactions.any(
              (r) =>
                  r.userId == userId && r.reaction == ReviewReactionType.like,
            );

            final isDisliked = reactionState.reactions.any(
              (r) =>
                  r.userId == userId &&
                  r.reaction == ReviewReactionType.dislike,
            );

            return Row(
              children: [
                Text('Helpful ?', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(width: UiConstants.spacingSm),

                InkWell(
                  onTap: () {
                    if (userId == null) return;
                    context.read<ReviewReactionBloc>().add(
                      ReviewReactionToggleRequested(
                        ratingId: rating.id,
                        userId: userId!,
                        reaction: ReviewReactionType.like,
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                        color: isLiked ? Colors.blue : null,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text('${reactionState.likes}'),
                    ],
                  ),
                ),

                const SizedBox(width: UiConstants.spacingMd),

                InkWell(
                  onTap: () {
                    if (userId == null) return;
                    context.read<ReviewReactionBloc>().add(
                      ReviewReactionToggleRequested(
                        ratingId: rating.id,
                        userId: userId!,
                        reaction: ReviewReactionType.dislike,
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        isDisliked
                            ? Icons.thumb_down
                            : Icons.thumb_down_alt_outlined,
                        color: isDisliked ? Colors.red : null,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text('${reactionState.dislikes}'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const Text(
          'Report',
          style: TextStyle(fontSize: 14, color: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<
      GetCurrentUserProfileDetailsBloc,
      GetCurrentUserProfileDetailsState
    >(
      builder: (context, state) {
        if (state is! GetCurrentUserProfileDetailsSuccess) {
          return _UserHeaderShimmer();
        }

        final user = state.user;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                if (userId != null) {
                  if (user.userId == userId) {
                    context.go(RouteConstants.profilePage);
                  } else {
                    context.push(
                      RouteConstants.viewUserProfilePage,
                      extra: {'userId': user.userId, 'currentUserId': userId!},
                    );
                  }
                }
              },
              child: CircleAvatar(
                radius: 16,
                child: ClipOval(
                  child: user.imageUrl != null && user.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: user.imageUrl!,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(color: Colors.white),
                          ),
                          errorWidget: (_, __, ___) => const Icon(Icons.person),
                        )
                      : Text(
                          user.fullName[0].toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                user.userId == userId ? 'You' : user.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            RatingBarIndicator(
              rating: rating.ratingValue.toDouble(),
              itemBuilder: (_, __) =>
                  const Icon(Icons.star, color: Colors.amber),
              itemCount: 5,
              itemSize: 16,
            ),
          ],
        );
      },
    );
  }
}

class _UserHeaderShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Row(
        children: [
          const CircleAvatar(radius: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: UiConstants.spacingXl),
          Container(
            height: 14,
            color: Colors.transparent,
            child: Row(
              children: List.generate(
                5,
                (index) => Container(
                  height: 12,
                  width: 12,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  margin: const EdgeInsets.only(right: UiConstants.spacingXs),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
