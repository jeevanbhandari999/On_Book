import 'package:app/app/dependency_injection.dart';
import 'package:app/features/home/domain/repositories/home_repository.dart';
import 'package:app/features/home/domain/usecases/get_all_posts_near_by_user_use_case.dart';
import 'package:app/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  final String userId;
  final double? latitude;
  final double? longitude;
  const HomePage({
    super.key,
    required this.userId,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeBloc(
            getNearbyPostsUseCase:
                DependencyInjection.get<GetAllPostsNearByUserUseCase>(),
          )..add(
            FetchNearbyPosts(
              userId: userId,
              latitude: latitude,
              //  ?? 27.986214,
              longitude: longitude,
              //  ?? 85.446681,
            ),
          ),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Posts")),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            print(state.message);
            return Center(child: Text(state.message));
          }

          if (state is HomeLoaded) {
            if (state.posts.isEmpty) {
              return const Center(child: Text("No posts found"));
            }

            return ListView.builder(
              itemCount: state.posts.length,
              itemBuilder: (_, index) {
                final post = state.posts[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text(post.title ?? "Untitled"),
                    subtitle: Text(post.description ?? "No description"),
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}



// Scaffold(
    //   body: Center(
    //     child: TextButton(
    //       onPressed: () {
    //         context.push(RouteConstants.anotherPage);
    //       },
    //       child: const Text('Go'),
    //     ),
    //   ),
    // );
