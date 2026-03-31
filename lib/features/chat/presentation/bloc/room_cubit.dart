// room_cubit.dart
import 'dart:async';
import 'package:app/features/chat/domain/entities/room.dart';
import 'package:app/features/chat/domain/usecases/stream_user_rooms_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class RoomState extends Equatable {
  const RoomState();
  @override
  List<Object?> get props => [];
}

class RoomInitial extends RoomState {}
class RoomLoading extends RoomState {}
class RoomStreamUpdated extends RoomState {
  final List<Room> rooms;
  const RoomStreamUpdated(this.rooms);
  @override
  List<Object?> get props => [rooms];
}
class RoomError extends RoomState {
  final String message;
  const RoomError(this.message);
  @override
  List<Object?> get props => [message];
}

class RoomCubit extends Cubit<RoomState> {
  final StreamUserRoomsUseCase streamUserRoomsUseCase;
  StreamSubscription? _sub;

  RoomCubit({required this.streamUserRoomsUseCase}) : super(RoomInitial()) {
    _startStreaming();
  }

  void _startStreaming() {
    emit(RoomLoading());
    _sub = streamUserRoomsUseCase().listen(
      (either) {
        either.fold(
          (failure) => emit(RoomError(failure.message)),
          (rooms) => emit(RoomStreamUpdated(rooms)),
        );
      },
      onError: (e) => emit(RoomError(e.toString())),
    );
  }

  void refresh() {
    _sub?.cancel();
    _startStreaming();
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}