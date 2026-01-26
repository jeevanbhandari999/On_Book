import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/utils/date_formatter.dart';
import 'package:app/features/customer_review/domain/entities/rating.dart';
import 'package:app/features/customer_review/domain/entities/review_reaction.dart';
import 'package:app/features/customer_review/domain/usecases/get_all_customer_review_related_to_post_use_case.dart';
import 'package:app/features/customer_review/domain/usecases/stream_review_reaction_use_case.dart';
import 'package:app/features/customer_review/domain/usecases/toggle_review_reaction_use_case.dart';
import 'package:app/features/customer_review/presentation/bloc/get_all_customer_review_related_to_the_post_bloc.dart';
import 'package:app/features/customer_review/presentation/bloc/review_reaction_bloc.dart';
import 'package:app/features/customer_review/presentation/widgets/rating_progress_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

class CustomerReviewPage extends StatelessWidget {
  final String postId;
  final String? userId;
  const CustomerReviewPage({super.key, required this.postId, this.userId});

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
        // BlocProvider(
        //   create: (context) => ReviewReactionBloc(
        //     toggleUseCase:
        //         DependencyInjection.get<ToggleReviewReactionUseCase>(),
        //     streamUseCase:
        //         DependencyInjection.get<StreamReviewReactionsUseCase>(),
        //   ),
        // ),
      ],
      child: CustomerReviewView(userId: userId),
    );
  }
}

class CustomerReviewView extends StatelessWidget {
  final String? userId;
  const CustomerReviewView({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Review')),
      body:
          BlocBuilder<
            GetAllCustomerReviewRelatedToThePostBloc,
            GetAllCustomerReviewRelatedToThePostState
          >(
            builder: (context, state) {
              // print(state);
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
                return Padding(
                  padding: const EdgeInsets.all(UiConstants.spacingMd),
                  child: Column(
                    children: [
                      _buildCustomerReviewHeader(context, state.ratings),
                      _ratingDetailInPercentage(context, state.ratings),
                      const SizedBox(height: UiConstants.spacingLg),
                      Expanded(
                        child: ListView.separated(
                          itemBuilder: (context, index) {
                            final rating = ratings[index];

                            // Pass the data to the isolated widget
                            return CustomerReviewItem(
                              rating: rating,
                              userId: userId,
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(
                              height: UiConstants.spacingMd,
                            );
                          },
                          itemCount: state.ratings.length,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
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
        const Text('Customer Reviews', style: TextStyle(fontSize: 16)),
        const Text('Ratings', style: TextStyle(fontSize: 16)),
        _buildRatingStarIcon(context, ratings),
        Text('${ratings.length} Ratings'),
        const SizedBox(height: UiConstants.spacingXs),
      ],
    );
  }

  Widget _buildRatingStarIcon(BuildContext context, List<Rating> ratings) {
    final average = _calculateAverageRating(ratings);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${average.toStringAsFixed(1)} out of 5.0'),
            const SizedBox(width: 8),
            RatingBarIndicator(
              rating: average.toDouble(),
              itemBuilder: (context, index) =>
                  const Icon(Icons.star, color: Colors.amber),
              itemCount: 5,
              itemSize: 20,
              direction: Axis.horizontal,
            ),
          ],
        ),
        const Spacer(),
        InkWell(
          onTap: () {
            // Later we will handle the review
            context.push(
              RouteConstants.writeAReviewPage,
              // extra: {'post': post, 'userId': userId},
            );
          },
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
          ratingRange: star == 1 ? '1 star' : '$star stars',
          percent: percent.toDouble(),
          peopleNumber: count,
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
    // PROVIDE THE BLOC HERE
    return BlocProvider(
      create: (context) => ReviewReactionBloc(
        toggleUseCase: DependencyInjection.get<ToggleReviewReactionUseCase>(),
        streamUseCase: DependencyInjection.get<StreamReviewReactionsUseCase>(),
      )..add(ReviewReactionStarted(rating.id)), // Start stream immediately
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(UiConstants.spacingMd),
        decoration: BoxDecoration(
          color: Colors.blue[300]!.withAlpha(70),
          borderRadius: BorderRadius.circular(UiConstants.radiusSm),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Your existing Header/User info code) ...
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[400],
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Username', // Replace with rating.userName if available
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                ),
                RatingBarIndicator(
                  rating: rating.ratingValue.toDouble(),
                  itemBuilder: (context, index) =>
                      const Icon(Icons.star, color: Colors.amber),
                  itemCount: 5,
                  itemSize: 16,
                  direction: Axis.horizontal,
                ),
              ],
            ),
            const SizedBox(height: UiConstants.spacingSm),
            if (rating.comment != null && rating.comment!.isNotEmpty)
              Text(
                rating.comment!,
                style: const TextStyle(color: Colors.black87),
              ),
            const SizedBox(height: UiConstants.spacingXs),
            Text(
              DateFormatter.format(rating.createdAt),
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: UiConstants.spacingMd),

            // ACTIONS ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // THIS BLOC BUILDER NOW LISTENS TO THE LOCAL BLOC
                BlocBuilder<ReviewReactionBloc, ReviewReactionState>(
                  builder: (context, reactionState) {
                    // Optional: Check if current user has reacted
                    final isLiked = reactionState.reactions.any(
                      (r) =>
                          r.userId == userId &&
                          r.reaction == ReviewReactionType.like,
                    );
                    final isDisliked = reactionState.reactions.any(
                      (r) =>
                          r.userId == userId &&
                          r.reaction == ReviewReactionType.dislike,
                    );

                    return Row(
                      children: [
                        Text(
                          'Helpful ?',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: UiConstants.spacingSm),

                        // LIKE BUTTON
                        InkWell(
                          onTap: () {
                            if (userId == null) return; // Handle guest
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
                                isLiked
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_alt_outlined,
                                color: isLiked ? Colors.blue : null,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text('${reactionState.likes}'),
                            ],
                          ),
                        ),
                        const SizedBox(width: UiConstants.spacingMd),

                        // DISLIKE BUTTON
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
                InkWell(
                  onTap: () {
                    // Report logic
                  },
                  child: const Text(
                    'Report',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
