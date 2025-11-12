// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'post_card.dart';

// class PostGridSection extends StatelessWidget {
//   final List<Map<String, dynamic>> posts;

//   const PostGridSection({super.key, required this.posts});

//   @override
//   Widget build(BuildContext context) {
//     return MasonryGridView.count(
//       crossAxisCount: 2, // two columns like Pinterest
//       mainAxisSpacing: 8,
//       crossAxisSpacing: 8,
//       padding: const EdgeInsets.all(12),
//       itemCount: posts.length,
//       itemBuilder: (context, index) {
//         final post = posts[index];
//         return PostCard(
//           title: post['title'],
//           imageUrl: post['imageUrl'],
//           description: post['description'],
//           price: post['price'],
//           onTap: () {
//             // TODO: Navigate to detail page later
//           },
//         );
//       },
//     );
//   }
// }



// post_grid_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'post_card.dart';

class PostGridSection extends StatelessWidget {
  final List<Map<String, dynamic>> posts;

  const PostGridSection({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostCard(
          key: ValueKey(post['imageUrl'] ?? post['videoUrl'] ?? index),
          title: post['title'] ?? 'Untitled',
          imageUrl: post['imageUrl'],
          videoUrl: post['videoUrl'],
          description: post['description'] ?? '',
          price: (post['price'] as num).toDouble(),
          onTap: () {
            // Navigate to detail screen
            // Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetail(post)));
          },
        );
      },
      itemCount: posts.length,
    );
  }
}
