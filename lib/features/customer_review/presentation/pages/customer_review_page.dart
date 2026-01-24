import 'package:app/app/dependency_injection.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/features/customer_review/domain/usecases/get_all_customer_review_related_to_post_use_case.dart';
import 'package:app/features/customer_review/presentation/bloc/get_all_customer_review_related_to_the_post_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                return Column(
                  children: [
                    Text('Header'),
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
                );
              }
              return SizedBox.shrink();
            },
          ),
    );
  }
}
