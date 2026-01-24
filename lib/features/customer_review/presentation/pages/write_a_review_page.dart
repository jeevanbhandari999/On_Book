import 'package:app/app/dependency_injection.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/utils/extensions/context_extensions.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/core/widgets/loading_widget.dart';
import 'package:app/features/customer_review/domain/entities/rating.dart';
import 'package:app/features/customer_review/domain/usecases/create_customer_review_for_specific_post_use_case.dart';
import 'package:app/features/customer_review/presentation/bloc/create_customer_review_bloc.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WriteAReviewPage extends StatelessWidget {
  final Post post;
  final String userId;

  const WriteAReviewPage({super.key, required this.post, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateCustomerReviewBloc(
        createCustomerReviewForSpecificPostUseCase:
            DependencyInjection.get<
              CreateCustomerReviewForSpecificPostUseCase
            >(),
      ),
      child: WriteAReviewView(post: post, userId: userId),
    );
  }
}

class WriteAReviewView extends StatefulWidget {
  final Post post;
  final String userId;

  const WriteAReviewView({super.key, required this.post, required this.userId});

  @override
  State<WriteAReviewView> createState() => _WriteAReviewViewState();
}

class _WriteAReviewViewState extends State<WriteAReviewView> {
  double ratingValue = 0;
  final _commentCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateCustomerReviewBloc, CreateCustomerReviewState>(
      listener: (context, state) {
        if (state is CreateCustomerReviewSuccess) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thank you for your rating!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        }
        if (state is CreateCustomerReviewError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
          print(state.message);
        }
      },
      child: Scaffold(
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
                        initialRating: 0,
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
                          setState(() {
                            ratingValue = rating;
                          });
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
                controller: _commentCtrl,
              ),

              const SizedBox(height: UiConstants.spacingLg),
              SizedBox(
                width: double.infinity,
                child:
                    BlocBuilder<
                      CreateCustomerReviewBloc,
                      CreateCustomerReviewState
                    >(
                      builder: (context, state) {
                        return LoadingButton(
                          text: 'Done',
                          isLoading: state is CreateCustomerReviewLoading,
                          onPressed: () {
                            print(
                              '${widget.post.id} and the user id is ${widget.userId}',
                            );
                            context.read<CreateCustomerReviewBloc>().add(
                              CreateReviewRequested(
                                postId: widget.post.id,
                                userId: widget.userId,
                                ratingValue: ratingValue.toInt(),
                                comment: _commentCtrl.text,
                              ),
                            );
                          },
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
