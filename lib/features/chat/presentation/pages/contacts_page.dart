import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/chat/domain/entities/room.dart';
import 'package:app/features/chat/domain/usecases/create_room_use_case.dart';
import 'package:app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:app/features/organizations/domain/usecases/get_organization_members_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OrganizationMembersCubit extends Cubit<List<User>?> {
  final GetOrganizationMembersUseCase getOrganizationMembersUseCase;

  OrganizationMembersCubit(this.getOrganizationMembersUseCase) : super(null);

  Future<void> loadMembers(String organizationId) async {
    // If you don't have an organization ID context, you might fetch "All Contacts"
    // Here we assume we fetch members of a specific org.
    final result = await getOrganizationMembersUseCase(
      GetOrganizationMembersParams(organizationId: organizationId),
    );
    result.fold(
      (failure) => emit([]), // Handle error state as needed
      (members) => emit(members),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. The Contacts Page
// -----------------------------------------------------------------------------
class ContactsPage extends StatelessWidget {
  final String organizationId;
  final String currentUserId;

  const ContactsPage({
    super.key,
    required this.organizationId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    // We need TWO providers:
    // 1. ChatBloc: To handle the "Create Room" action
    // 2. MembersCubit: To fetch the list of users
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ChatBloc(
            createRoomUseCase: DependencyInjection.get<CreateRoomUseCase>(),
            // Pass other UseCases as dummy or null if your Bloc allows,
            // otherwise inject them all. For brevity, assuming they are injected:
            getUserRoomsUseCase: DependencyInjection.get(),
            sendMessageUseCase: DependencyInjection.get(),
            streamMessagesUseCase: DependencyInjection.get(),
            markRoomAsReadUseCase: DependencyInjection.get(),
            streamUserRoomsUseCase: DependencyInjection.get(),
          ),
        ),
        BlocProvider(
          create: (context) => OrganizationMembersCubit(
            DependencyInjection.get<GetOrganizationMembersUseCase>(),
          )..loadMembers(organizationId),
        ),
      ],
      child: _ContactsView(currentUserId: currentUserId),
    );
  }
}

class _ContactsView extends StatelessWidget {
  final String currentUserId;
  const _ContactsView({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatLoading) {
          // Show loading dialog or overlay
        }
        if (state is RoomCreated) {
          // 🚀 SUCCESS: Room created (or fetched), navigate to ChatPage
          context.pop(); // Close contacts page
          context.push(
            RouteConstants.chatPage,
            extra: {'room': state.room, 'userId': currentUserId},
          );
        }
        if (state is ChatError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('New Message'), elevation: 0),
        body: BlocBuilder<OrganizationMembersCubit, List<User>?>(
          builder: (context, members) {
            if (members == null) {
              return const Center(child: CircularProgressIndicator());
            }

            // Filter out self
            final contacts = members
                .where((u) => u.id != currentUserId)
                .toList();

            if (contacts.isEmpty) {
              return const Center(child: Text("No contacts found"));
            }

            return ListView.separated(
              itemCount: contacts.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = contacts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (user.imageUrl != null)
                        ? NetworkImage(user.imageUrl!)
                        : null,
                    child: (user.imageUrl == null)
                        ? Text(user.fullName[0].toUpperCase())
                        : null,
                  ),
                  title: Text(user.fullName),
                  subtitle: Text(
                    user.role.name.toUpperCase(),
                  ), // Assuming Role Enum
                  onTap: () {
                    _onCreateDmTapped(context, user);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _onCreateDmTapped(BuildContext context, User targetUser) {
    // 1. Create a "Prototype" room object for the creation request
    // The Backend/UseCase will handle finding an existing DM or creating a new one
    // based on the members list.

    // NOTE: Ensure your CreateRoomUseCase handles logic to map
    // 'type' and 'members' to the rpc_create_room function.

    final roomRequest = Room(
      id: '', // Empty ID, backend generates it
      type: RoomType.dm, // DM type
      organizationId: null,
      createdAt: DateTime.now(),
    );

    context.read<ChatBloc>().add(
      CreateRoomRequested(
        room: roomRequest,
        otherUserId: targetUser.userId,
        userId: currentUserId,
      ),
    );
  }
}
