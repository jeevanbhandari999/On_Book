// import 'package:app/app/dependency_injection.dart';
// import 'package:app/core/constants/ui_constants.dart';
// import 'package:app/core/theme/app_colors.dart';
// import 'package:app/features/chat/domain/entities/room.dart';
// import 'package:app/features/chat/presentation/bloc/chat_bloc.dart';
// import 'package:app/features/chat/presentation/pages/chat_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class ChatRoomsPage extends StatelessWidget {
//   const ChatRoomsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => DependencyInjection.get<ChatBloc>()..add(const GetUserRoomsRequested()),
//       child: const ChatRoomsView(),
//     );
//   }
// }

// class ChatRoomsView extends StatelessWidget {
//   const ChatRoomsView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chats'),
//         backgroundColor: AppColors.primary,
//       ),
//       body: BlocConsumer<ChatBloc, ChatState>(
//         listener: (context, state) {
//           if (state is ChatError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.message)),
//             );
//           }
//         },
//         builder: (context, state) {
//           if (state is ChatLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (state is UserRoomsLoaded) {
//             final rooms = state.rooms;
//             if (rooms.isEmpty) {
//               return const Center(child: Text('No chats yet.'));
//             }

//             return ListView.separated(
//               padding: const EdgeInsets.all(UiConstants.spacingMd),
//               itemCount: rooms.length,
//               separatorBuilder: (_, __) => const SizedBox(height: UiConstants.spacingSm),
//               itemBuilder: (_, index) {
//                 final room = rooms[index];
//                 return _RoomTile(room: room);
//               },
//             );
//           }

//           return const Center(child: Text('Something went wrong.'));
//         },
//       ),
//     );
//   }
// }

// class _RoomTile extends StatelessWidget {
//   final Room room;
//   const _RoomTile({required this.room});

//   @override
//   Widget build(BuildContext context) {
//     // final title = room.type == 'dm'
//     //     ? room.join(', ')
//     //     : room.organizationName ?? 'Organization Chat';

//     return ListTile(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(UiConstants.radiusLg),
//         side: BorderSide(color: Colors.grey.shade300),
//       ),
//       tileColor: Colors.white,
//       contentPadding: const EdgeInsets.symmetric(
//         horizontal: UiConstants.spacingMd,
//         vertical: UiConstants.spacingSm,
//       ),
//       title: Text('title', style: const TextStyle(fontWeight: FontWeight.w600)),
//       subtitle: room. != null
//           ? Text(
//               room.lastMessage!,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             )
//           : null,
//       trailing: room.lastMessageTime != null
//           ? Text(
//               room.lastMessageTimeFormatted,
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             )
//           : null,
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => ChatPage(room: room)),
//         );
//       },
//     );
//   }
// }
