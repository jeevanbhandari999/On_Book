import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
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
                      _buildCustomerReviewHeader(context),
                      _ratingDetailInPercentage(context),
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
                            return SizedBox(height: UiConstants.spacingMd);
                          },
                          itemCount: state.ratings.length,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
    );
  }

  Widget _buildCustomerReviewHeader(BuildContext context) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Customer Reviews', style: TextStyle(fontSize: 16)),
        Text('Ratings', style: TextStyle(fontSize: 16)),
        _buildRatingStarIcon(context),
        Text('rating length'),
      ],
    );
  }

  Widget _buildRatingStarIcon(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('4 out of 5.0'),
            const SizedBox(width: 8),
            RatingBarIndicator(
              rating: 2,
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

  Widget _ratingDetailInPercentage(BuildContext context) {
    return const Column(
      children: [
        RatingProgressBar(
          ratingRange: "5 stars",
          percent: 65,
          peopleNumber: 21,
        ),
        RatingProgressBar(ratingRange: "4 stars", percent: 14, peopleNumber: 4),
        RatingProgressBar(ratingRange: "3 stars", percent: 9, peopleNumber: 5),
        RatingProgressBar(ratingRange: "2 stars", percent: 6, peopleNumber: 1),
        RatingProgressBar(ratingRange: "1 star", percent: 7, peopleNumber: 2),
      ],
    );
  }
}
