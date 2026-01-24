import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/features/customer_review/domain/entities/rating.dart';
import 'package:app/features/customer_review/domain/usecases/get_all_customer_review_related_to_post_use_case.dart';
import 'package:app/features/customer_review/presentation/bloc/get_all_customer_review_related_to_the_post_bloc.dart';
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
    return BlocProvider(
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
      child: const CustomerReviewView(),
    );
  }
}

class CustomerReviewView extends StatelessWidget {
  const CustomerReviewView({super.key});

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
              print(state);
              if (state is GetAllCustomerReviewRelatedToThePostLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is GetAllCustomerReviewRelatedToThePostError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
              if (state is GetAllCustomerReviewRelatedToThePostSuccess) {
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
                            return Container(
                              child: Text(
                                state.ratings[index].ratingValue.toString(),
                              ),
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

  // double _calculateAverageRating(List ratings) {
  //   if (ratings.isEmpty) return 0;

  //   final total = ratings.fold<int>(
  //     0,
  //     (sum, item) => sum + item.ratingValue,
  //   );

  //   return total / ratings.length;
  // }

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
        const Text('rating length'),
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
