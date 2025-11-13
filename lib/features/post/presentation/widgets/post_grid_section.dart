import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'post_card.dart';

class PostGridSection extends StatelessWidget {
  final List<Map<String, dynamic>> posts;

  const PostGridSection({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StaggeredGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: List.generate(posts.length, (index) {
          final post = posts[index];
          final isWide = (index + 1) % 5 == 0;
          return StaggeredGridTile.fit(
            crossAxisCellCount: isWide ? 2 : 1,
            child: PostCard(
              key: ValueKey(post['imageUrl'] ?? post['videoUrl'] ?? index),
              title: post['title'] ?? 'Untitled',
              imageUrl: post['imageUrl'],
              videoUrl: post['videoUrl'],
              description: post['description'] ?? '',
              price: (post['price'] as num?)?.toDouble() ?? 0.0,
              onTap: () {},
            ),
          );
        }),
      ),
    );
  }
}
