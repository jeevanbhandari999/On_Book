// ─────────────────────────────────────────────────────────────────
// features/search/domain/entities/search_result.dart
// ─────────────────────────────────────────────────────────────────

import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/post/domain/entities/post.dart';

/// Aggregated result returned to UI / BLoC.
/// Reuses your existing domain entities — no duplication.
class SearchResult {
  final List<Post> posts;
  final List<User> users;
  final List<Organization> organizations;

  const SearchResult({
    this.posts = const [],
    this.users = const [],
    this.organizations = const [],
  });

  bool get isEmpty =>
      posts.isEmpty && users.isEmpty && organizations.isEmpty;

  static const empty = SearchResult();
}