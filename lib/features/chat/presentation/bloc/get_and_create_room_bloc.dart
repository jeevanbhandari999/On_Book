// import 'dart:async';

// import 'package:app/features/chat/domain/entities/room.dart';
// import 'package:app/features/chat/domain/usecases/create_room_use_case.dart';
// import 'package:app/features/chat/domain/usecases/get_specific_room_related_to_the_user_or_organization_use_case.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// // Events
// abstract class GetAndCreateRoomEvent extends Equatable {
//   const GetAndCreateRoomEvent();

//   @override
//   List<Object?> get props => [];
// }

// class GetAndCreateRoomRequested extends GetAndCreateRoomEvent {
//   final String userId;
//   final String? targetUserId;
//   final String? organizationId;

//   // For creating room
//   final Room? room;

//   const GetAndCreateRoomRequested({
//     required this.userId,
//     this.targetUserId,
//     this.organizationId,
//     this.room,
//   });

//   @override
//   List<Object?> get props => [userId, targetUserId, organizationId, room];
// }

// // States
// abstract class GetAndCreateRoomState extends Equatable {
//   const GetAndCreateRoomState();

//   @override
//   List<Object?> get props => [];
// }

// class GetAndCreateRoomInitial extends GetAndCreateRoomState {
//   const GetAndCreateRoomInitial();
// }

// class GetAndCreateRoomLoading extends GetAndCreateRoomState {
//   const GetAndCreateRoomLoading();
// }

// class GetAndCreateRoomSuccess extends GetAndCreateRoomState {
//   final Room successResponse;

//   const GetAndCreateRoomSuccess({required this.successResponse});

//   @override
//   List<Object> get props => [successResponse];
// }

// class GetAndCreateRoomError extends GetAndCreateRoomState {
//   final String message;
//   const GetAndCreateRoomError({required this.message});

//   @override
//   List<Object> get props => [message];
// }

// // BLoC
// class GetAndCreateRoomBloc
//     extends Bloc<GetAndCreateRoomEvent, GetAndCreateRoomState> {
//   final GetSpecificRoomRelatedToTheUserOrOrganizationUseCase
//   _getSpecificRoomRelatedToTheUserOrOrganizationUseCase;

//   final CreateRoomUseCase _createRoomUseCase;

//   GetAndCreateRoomBloc({
//     required GetSpecificRoomRelatedToTheUserOrOrganizationUseCase
//     getSpecificRoomRelatedToTheUserOrOrganizationUseCase,
//     required CreateRoomUseCase createRoomUseCase,
//   }) : _getSpecificRoomRelatedToTheUserOrOrganizationUseCase =
//            getSpecificRoomRelatedToTheUserOrOrganizationUseCase,
//        _createRoomUseCase = createRoomUseCase,
//        super(const GetAndCreateRoomInitial()) {
//     on<GetAndCreateRoomRequested>(_onGetAndCreateRoomRequested);
//   }

//   FutureOr<void> _onGetAndCreateRoomRequested(
//     GetAndCreateRoomRequested event,
//     Emitter<GetAndCreateRoomState> emit,
//   ) async {
//     emit(const GetAndCreateRoomLoading());
//     try {
//       final getRoomParams = GetSpecificRoomRelatedToTheUserOrOrganizationParams(
//         userId: event.userId,
//         targetUserId: event.targetUserId,
//         organizationId: event.organizationId,
//       );
//       final response =
//           await _getSpecificRoomRelatedToTheUserOrOrganizationUseCase(
//             getRoomParams,
//           );
//       print(response);
//       response.fold(
//         (failure) => emit(GetAndCreateRoomError(message: failure.message)),
//         (room) async {
//           if (room != null) {
//             emit(GetAndCreateRoomSuccess(successResponse: room));
//           } else {
//             if (event.room != null) {
//               final createdResponse = await _createRoomUseCase(
//                 event.room!,
//                 event.userId,
//                 event.targetUserId,
//               );
//               createdResponse.fold(
//                 (failure) =>
//                     emit(GetAndCreateRoomError(message: failure.message)),
//                 (successReponse) => emit(
//                   GetAndCreateRoomSuccess(successResponse: successReponse),
//                 ),
//               );
//             }
//           }
//         },
//       );
//     } catch (e) {
//       emit(GetAndCreateRoomError(message: e.toString()));
//     }
//   }
// }

import 'dart:async';

import 'package:app/features/chat/domain/entities/room.dart';
import 'package:app/features/chat/domain/usecases/create_room_use_case.dart';
import 'package:app/features/chat/domain/usecases/get_specific_room_related_to_the_user_or_organization_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class GetAndCreateRoomEvent extends Equatable {
  const GetAndCreateRoomEvent();

  @override
  List<Object?> get props => [];
}

class GetAndCreateRoomRequested extends GetAndCreateRoomEvent {
  final String userId;
  final String? targetUserId;
  final String? organizationId;

  // For creating room
  final Room? room;

  const GetAndCreateRoomRequested({
    required this.userId,
    this.targetUserId,
    this.organizationId,
    this.room,
  });

  @override
  List<Object?> get props => [userId, targetUserId, organizationId, room];
}

// States
abstract class GetAndCreateRoomState extends Equatable {
  const GetAndCreateRoomState();

  @override
  List<Object?> get props => [];
}

class GetAndCreateRoomInitial extends GetAndCreateRoomState {
  const GetAndCreateRoomInitial();
}

class GetAndCreateRoomLoading extends GetAndCreateRoomState {
  const GetAndCreateRoomLoading();
}

class GetAndCreateRoomSuccess extends GetAndCreateRoomState {
  final Room successResponse;

  const GetAndCreateRoomSuccess({required this.successResponse});

  @override
  List<Object> get props => [successResponse];
}

class GetAndCreateRoomError extends GetAndCreateRoomState {
  final String message;
  const GetAndCreateRoomError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class GetAndCreateRoomBloc
    extends Bloc<GetAndCreateRoomEvent, GetAndCreateRoomState> {
  final GetSpecificRoomRelatedToTheUserOrOrganizationUseCase
  _getSpecificRoomRelatedToTheUserOrOrganizationUseCase;

  final CreateRoomUseCase _createRoomUseCase;

  GetAndCreateRoomBloc({
    required GetSpecificRoomRelatedToTheUserOrOrganizationUseCase
    getSpecificRoomRelatedToTheUserOrOrganizationUseCase,
    required CreateRoomUseCase createRoomUseCase,
  }) : _getSpecificRoomRelatedToTheUserOrOrganizationUseCase =
           getSpecificRoomRelatedToTheUserOrOrganizationUseCase,
       _createRoomUseCase = createRoomUseCase,
       super(const GetAndCreateRoomInitial()) {
    on<GetAndCreateRoomRequested>(_onGetAndCreateRoomRequested);
  }

  Future<void> _onGetAndCreateRoomRequested(
    GetAndCreateRoomRequested event,
    Emitter<GetAndCreateRoomState> emit,
  ) async {
    emit(const GetAndCreateRoomLoading());

    try {
      final getRoomParams = GetSpecificRoomRelatedToTheUserOrOrganizationParams(
        userId: event.userId,
        targetUserId: event.targetUserId,
        organizationId: event.organizationId,
      );

      final response =
          await _getSpecificRoomRelatedToTheUserOrOrganizationUseCase(
            getRoomParams,
          );

      // Handle the response properly without nested async callbacks
      await response.fold(
        (failure) async {
          if (!emit.isDone) {
            emit(GetAndCreateRoomError(message: failure.message));
          }
        },
        (room) async {
          if (room != null) {
            if (!emit.isDone) {
              emit(GetAndCreateRoomSuccess(successResponse: room));
            }
          } else {
            // Room doesn't exist, create a new one
            if (event.room != null) {
              final createdResponse = await _createRoomUseCase(
                event.room!,
                event.userId,
                event.targetUserId,
              );

              createdResponse.fold(
                (failure) {
                  if (!emit.isDone) {
                    emit(GetAndCreateRoomError(message: failure.message));
                  }
                },
                (successResponse) {
                  if (!emit.isDone) {
                    emit(
                      GetAndCreateRoomSuccess(successResponse: successResponse),
                    );
                  }
                },
              );
            } else {
              if (!emit.isDone) {
                emit(
                  const GetAndCreateRoomError(
                    message:
                        'No room found and no room data provided to create',
                  ),
                );
              }
            }
          }
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(GetAndCreateRoomError(message: e.toString()));
      }
    }
  }
}
