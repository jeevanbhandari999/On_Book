// import 'package:app/core/constants/ui_constants.dart';
// import 'package:app/core/widgets/common_widgets.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// class WriteAReviewPage extends StatefulWidget {
//   const WriteAReviewPage({super.key});

//   @override
//   State<WriteAReviewPage> createState() => _WriteAReviewPageState();
// }

// class _WriteAReviewPageState extends State<WriteAReviewPage> {
//   double _rating = 0.0;
//   final TextEditingController _commentController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Write A Review')),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Align(
//                 alignment: Alignment.center,
//                 child: Text(
//                   'How was your experience?',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                 ),
//               ),

//               const SizedBox(height: UiConstants.spacingXl),

//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[300]!.withAlpha(70),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'What do you think of the product overall?',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 4),
//                     const Text('Tell us everything!'),
//                     const SizedBox(height: 12),

//                     Center(
//                       child: RatingBar.builder(
//                         initialRating: _rating,
//                         minRating: 0,
//                         direction: Axis.horizontal,
//                         allowHalfRating: false,
//                         itemCount: 5,
//                         itemSize: 42,
//                         unratedColor: Colors.grey,
//                         itemPadding: const EdgeInsets.symmetric(
//                           horizontal: 4.0,
//                         ),
//                         itemBuilder: (context, _) =>
//                             const Icon(Icons.star, color: Colors.amber),
//                         onRatingUpdate: (rating) {
//                           setState(() {
//                             _rating = rating;
//                           });
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: UiConstants.spacingLg),

//               // Comment section
//               const Text(
//                 'Write a comment',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//               const SizedBox(height: 8),
//               CustomTextField(
//                 hint: 'Tell us more about your experience...',
//                 maxLines: 4,
//                 controller: _commentController,
//               ),

//               const SizedBox(height: UiConstants.spacingLg),

//               // Submit button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _rating == 0
//                       ? null
//                       : () {
//                           debugPrint('Rating: $_rating');
//                           debugPrint('Comment: ${_commentController.text}');
//                         },
//                   child: const Text('Done'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:app/app/dependency_injection.dart';
import 'package:app/features/customer_review/domain/usecases/create_customer_review_for_specific_post_use_case.dart';
import 'package:app/features/customer_review/presentation/bloc/create_customer_review_bloc.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';

class WriteAReviewPage extends StatelessWidget {
  final Post post; // Made optional for app review if needed in future
  final String userId;

  const WriteAReviewPage({super.key, required this.post, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateReviewBloc(
        createCustomerReviewForSpecificPostUseCase:
            DependencyInjection.get<
              CreateCustomerReviewForSpecificPostUseCase
            >(),
      ),
      child: WriteAReviewView(post: post, userId: userId),
    );
  }
}

class WriteAReviewView extends StatelessWidget {
  final Post post; // Made optional for app review if needed in future
  final String userId;

  const WriteAReviewView({super.key, required this.post, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateReviewBloc, CreateReviewState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == ReviewSubmissionStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted successfully!')),
          );
          Navigator.pop(context, true); // or true = review was created
        } else if (state.status == ReviewSubmissionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Error occurred')),
          );
        } else if (state.status == ReviewSubmissionStatus.invalid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a rating')),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<CreateReviewBloc>();

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
                          initialRating: state.rating.toDouble(),
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
                            bloc.add(RatingChanged(rating.toInt()));
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
                  onChanged: (value) => bloc.add(CommentChanged(value)),
                ),

                const SizedBox(height: UiConstants.spacingLg),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        state.isSubmitEnabled &&
                            state.status != ReviewSubmissionStatus.submitting
                        ? () => bloc.add(
                            SubmitReview(userId: userId, postId: post.id),
                          )
                        : null,
                    child: state.status == ReviewSubmissionStatus.submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Done'),
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
