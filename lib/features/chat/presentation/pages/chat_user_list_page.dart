// import 'package:flutter/material.dart';

// class ChatUserListPage extends StatelessWidget {
//   const ChatUserListPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(title: const Text('Username')),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: RefreshIndicator(
//           onRefresh: () async {
//             // add actual refresh logic later
//             await Future.delayed(const Duration(seconds: 1));
//           },
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Search bar
//                 TextField(
//                   // controller: _controller,
//                   textInputAction: TextInputAction.search,
//                   // onSubmitted: (_) => _startSearch(),
//                   decoration: InputDecoration(
//                     hintText: 'Search...',
//                     hintStyle: TextStyle(color: theme.hintColor),
//                     prefixIcon: const Icon(Icons.search),
//                     filled: true,
//                     fillColor: theme.colorScheme.surface.withAlpha(80),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(24),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(vertical: 0),
//                   ),
//                 ),

//                 // User list(hotel/organization)
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
Future<List<Map<String, dynamic>>> fetchOrganizations() async {
  final response = await supabase
      .from('organizations')
      .select('id, name, logo_url, address, org_global_scores(*)')
      .limit(10);

  // Convert to list if necessary
  final data = List<Map<String, dynamic>>.from(response as List);

  // Sort in Dart by total_score descending
  data.sort((a, b) {
    final scoreA = a['org_global_scores']?['total_score'] ?? 0;
    final scoreB = b['org_global_scores']?['total_score'] ?? 0;
    return scoreB.compareTo(scoreA);
  });

  return data;
}

class ChatUserListPage extends StatelessWidget {
  const ChatUserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchOrganizations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orgs = snapshot.data ?? [];

          return ListView.builder(
            itemCount: orgs.length,
            itemBuilder: (context, index) {
              final org = orgs[index];
              return ListTile(
                leading: org['logo_url'] != null
                    ? Image.network(org['logo_url'], width: 50, height: 50)
                    : const Icon(Icons.business),
                title: Text(org['name']),
                subtitle: Text(org['address'] ?? ''),
                trailing: Text(
                  'Score: ${org['org_global_scores']?['total_score'] ?? 0}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
