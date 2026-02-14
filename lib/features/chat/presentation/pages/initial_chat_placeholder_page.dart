import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/features/chat/domain/entities/room.dart';
import 'package:app/features/chat/domain/usecases/create_room_use_case.dart';
import 'package:app/features/chat/domain/usecases/get_specific_room_related_to_the_user_or_organization_use_case.dart';
import 'package:app/features/chat/presentation/bloc/get_and_create_room_bloc.dart';
import 'package:app/features/chat/presentation/widgets/chat_detail_shimmer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class InitialChatPlaceholderPage extends StatelessWidget {
  final String? organizationId;
  final String userId;
  final String? targetUserId;

  const InitialChatPlaceholderPage({
    super.key,
    this.organizationId,
    required this.userId,
    this.targetUserId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetAndCreateRoomBloc(
            getSpecificRoomRelatedToTheUserOrOrganizationUseCase:
                DependencyInjection.get<
                  GetSpecificRoomRelatedToTheUserOrOrganizationUseCase
                >(),
            createRoomUseCase: DependencyInjection.get<CreateRoomUseCase>(),
          )..add(
            GetAndCreateRoomRequested(
              userId: userId,
              organizationId: organizationId,
              targetUserId: targetUserId,
              room: Room(
                id: '',
                type: organizationId != null
                    ? RoomType.organization
                    : RoomType.dm,
                organizationId: organizationId,
                createdAt: DateTime.now(),
              ),
            ),
          ),
      child: InitialChatPlaceholderView(
        userId: userId,
        targetUserId: targetUserId,
        organizationId: organizationId,
      ),
    );
  }
}

class InitialChatPlaceholderView extends StatelessWidget {
  final String? organizationId;
  final String userId;
  final String? targetUserId;

  const InitialChatPlaceholderView({
    super.key,
    this.organizationId,
    required this.userId,
    this.targetUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<GetAndCreateRoomBloc, GetAndCreateRoomState>(
        listener: (context, state) {
          if (state is GetAndCreateRoomSuccess) {
            context.pushReplacement(
              RouteConstants.chatPage,
              extra: {'room': state.successResponse, 'userId': userId},
            );
          }
          if (state is GetAndCreateRoomError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return const ChatDetailShimmerPage();
        },
      ),
    );
  }
}
