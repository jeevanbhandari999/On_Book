import 'package:app/app/dependency_injection.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/customer_review/domain/usecases/create_customer_review_for_specific_post_use_case.dart';
import 'package:app/features/customer_review/presentation/bloc/create_customer_review_bloc.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class WriteAReviewPage extends StatelessWidget {
  final Post post;
  final String userId;

  const WriteAReviewPage({super.key, required this.post, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateCustomerReviewBloc(
        useCase:
            DependencyInjection.get<
              CreateCustomerReviewForSpecificPostUseCase
            >(),
      ),
      child: WriteAReviewView(post: post, userId: userId),
    );
  }
}

class WriteAReviewView extends StatelessWidget {
  final Post post;
  final String userId;

  const WriteAReviewView({super.key, required this.post, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateCustomerReviewBloc, CreateCustomerReviewState>(
      listener: (context, state) {
        if (state is CreateCustomerReviewSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted successfully!')),
          );
          Navigator.pop(context, true); // true = review was created
        } else if (state is CreateCustomerReviewError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is CreateCustomerReviewValidationError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final bloc = context.read<CreateCustomerReviewBloc>();

        // Extract current form values depending on state
        int currentRating = 0;
        String currentComment = '';

        bool isSubmitting = false;
        bool canSubmit = false;

        if (state is CreateCustomerReviewInitial) {
          currentRating = state.rating;
          currentComment = state.comment;
          canSubmit = state.canSubmit;
        } else if (state is CreateCustomerReviewLoading) {
          currentRating = state.rating;
          currentComment = state.comment;
          isSubmitting = true;
          canSubmit = false;
        } else if (state is CreateCustomerReviewValidationError) {
          currentRating = state.rating;
          currentComment = state.comment;
          canSubmit = false;
        } else if (state is CreateCustomerReviewSuccess) {
          // usually not visible long, but safe default
          currentRating = 0;
          currentComment = '';
        } else if (state is CreateCustomerReviewError) {
          currentRating = 0;
          currentComment = '';
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Write A Review')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'How was your experience?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: UiConstants.spacingXl),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[300]!.withAlpha(70),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What do you think of the product overall?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text('Tell us everything!'),
                      const SizedBox(height: 12),
                      Center(
                        child: RatingBar.builder(
                          initialRating: currentRating.toDouble(),
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemSize: 42,
                          unratedColor: Colors.grey,
                          itemPadding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                          ),
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (rating) {
                            bloc.add(
                              RatingValueChanged(rating: rating.toInt()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: UiConstants.spacingLg),

                const Text(
                  'Write a comment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),

                CustomTextField(
                  hint: 'Tell us more about your experience...',
                  maxLines: 4,

                  // If your CustomTextField supports initialValue + onChanged, use this:
                  onChanged: (value) {
                    bloc.add(CommentChanged(comment: value));
                  },
                  // If it only supports controller, uncomment and use controller instead:
                  // controller: TextEditingController(text: currentComment)..addListener(() {
                  //   bloc.add(CommentChanged(comment: controller.text));
                  // }),
                ),

                const SizedBox(height: UiConstants.spacingLg),

                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Done',
                    isLoading: isSubmitting,
                    onPressed: () {
                      bloc.add(
                        CreateReviewRequested(postId: post.id, userId: userId),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
