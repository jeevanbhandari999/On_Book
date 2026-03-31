import 'package:app/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:app/features/chat/data/repositories/chat_repositories_impl.dart';
import 'package:app/features/chat/domain/repositories/chat_repository.dart';
import 'package:app/features/chat/domain/usecases/create_room_use_case.dart';
import 'package:app/features/chat/domain/usecases/get_messages_use_case.dart';
import 'package:app/features/chat/domain/usecases/get_room_members_use_case.dart';
import 'package:app/features/chat/domain/usecases/get_specific_room_related_to_the_user_or_organization_use_case.dart';
import 'package:app/features/chat/domain/usecases/get_user_rooms_use_case.dart';
import 'package:app/features/chat/domain/usecases/mark_room_as_read_use_case.dart';
import 'package:app/features/chat/domain/usecases/send_message_use_case.dart';
import 'package:app/features/chat/domain/usecases/stream_messages_use_case.dart';
import 'package:app/features/chat/domain/usecases/stream_user_rooms_use_case.dart';
import 'package:app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:app/features/chat/presentation/bloc/get_and_create_room_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatDependencies {
  static Future<void> register(GetIt getIt) async {
    // Data sources
    getIt.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(Supabase.instance.client),
    );

    // Repositories
    getIt.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(remoteDataSource: getIt<ChatRemoteDataSource>()),
    );

    // Usecases
    getIt.registerLazySingleton<CreateRoomUseCase>(
      () => CreateRoomUseCase(getIt<ChatRepository>()),
    );

    getIt.registerLazySingleton<GetMessagesUseCase>(
      () => GetMessagesUseCase(getIt<ChatRepository>()),
    );

    getIt.registerLazySingleton<GetRoomMembersUseCase>(
      () => GetRoomMembersUseCase(getIt<ChatRepository>()),
    );

    getIt.registerLazySingleton<GetUserRoomsUseCase>(
      () => GetUserRoomsUseCase(getIt<ChatRepository>()),
    );

    getIt.registerLazySingleton<MarkRoomAsReadUseCase>(
      () => MarkRoomAsReadUseCase(getIt<ChatRepository>()),
    );

    getIt.registerLazySingleton<SendMessageUseCase>(
      () => SendMessageUseCase(getIt<ChatRepository>()),
    );

    getIt.registerLazySingleton<StreamMessagesUseCase>(
      () => StreamMessagesUseCase(getIt<ChatRepository>()),
    );
    getIt.registerLazySingleton<
      GetSpecificRoomRelatedToTheUserOrOrganizationUseCase
    >(
      () => GetSpecificRoomRelatedToTheUserOrOrganizationUseCase(
        getIt<ChatRepository>(),
      ),
    );
    getIt.registerLazySingleton<StreamUserRoomsUseCase>(
      () => StreamUserRoomsUseCase(getIt<ChatRepository>()),
    );

    // BLoCs
    getIt.registerFactory<ChatBloc>(
      () => ChatBloc(
        createRoomUseCase: getIt<CreateRoomUseCase>(),
        getUserRoomsUseCase: getIt<GetUserRoomsUseCase>(),
        sendMessageUseCase: getIt<SendMessageUseCase>(),
        streamMessagesUseCase: getIt<StreamMessagesUseCase>(),
        markRoomAsReadUseCase: getIt<MarkRoomAsReadUseCase>(),
        streamUserRoomsUseCase: getIt<StreamUserRoomsUseCase>(),
      ),
    );
    getIt.registerFactory<GetAndCreateRoomBloc>(
      () => GetAndCreateRoomBloc(
        createRoomUseCase: getIt<CreateRoomUseCase>(),
        getSpecificRoomRelatedToTheUserOrOrganizationUseCase:
            getIt<GetSpecificRoomRelatedToTheUserOrOrganizationUseCase>(),
      ),
    );
  }
}
