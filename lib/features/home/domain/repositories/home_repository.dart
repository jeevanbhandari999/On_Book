import 'package:app/core/errors/failures.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/home/domain/entities/saved_post.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:dartz/dartz.dart';

abstract class HomeRepository {
  // Get all posts near user
  Future<Either<Failure, ({List<Post> posts, String? nextCursor})>>
  getNearByPosts({
    required String userId,
    double? latitude,
    double? longitude,
    int limit = 15,
    String? cursor,
  });

  // Get the recommendation (content based or AI whatever)
  // TODO
  Future<Either<Failure, List<Post>>> getRecommendedPosts({
    required String userId,
    int limit = 15,
  });

  // Get cached home page posts for offline supports
  Future<Either<Failure, List<Post>>> getCachedPosts(String userId);

  // Cache posts locally
  Future<Either<Failure, void>> cachePosts(String userId, List<Post> posts);

  // Clear cached posts for a specific user
  Future<Either<Failure, void>> clearCachedPosts(String userId);

  // Subscribe to real time posts updates
  Stream<Either<Failure, List<Post>>> subscribeToPosts(String userId);

  // For refresh , if needed
  Future<Either<Failure, List<Post>>> refreshHomePage(String userId);

  // For future need
  // Like the post or may be rate to make recommendation in future
  Future<Either<Failure, void>> likePost(String postId);

  // Unlike posts
  Future<Either<Failure, void>> unlikePost(String postId);

  // // Save the post for add to the library
  // Future<Either<Failure, void>> bookmarkPost(String postId);

  // Unsave posts from the library
  Future<Either<Failure, void>> removeBookmark(String postId);

  // Get the organization detail by post id
  Future<Either<Failure, Organization>>
  getOrganizationDetailByPostOrganizationId(String organizationId);

  // Get the most rated organizations according to the user ratings and the others
  Future<Either<Failure, List<Organization>>>
  getOrganizationsBasedOnUserAndOthersPreferences({String? userId});

  // Save the post by users
  Future<Either<Failure, void>> togglePostSaveOrUnsave(
    String userId,
    String postId,
    String organizationId,
  );


  Stream<Either<Failure, List<SavedPost>>> streamReactions(String userId);

}
