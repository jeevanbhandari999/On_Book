import 'dart:io';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:app/features/post/domain/usecases/create_post_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

//  EVENTS ──────────────────────────────

abstract class PostFormEvent extends Equatable {
  const PostFormEvent();

  @override
  List<Object?> get props => [];
}

class PostFormInitialized extends PostFormEvent {
  final String userId;
  final String organizationId;

  const PostFormInitialized({
    required this.userId,
    required this.organizationId,
  });

  @override
  List<Object?> get props => [userId, organizationId];
}

class PostFormTitleChanged extends PostFormEvent {
  final String title;
  const PostFormTitleChanged(this.title);
  @override
  List<Object> get props => [title];
}

class PostFormDescriptionChanged extends PostFormEvent {
  final String description;
  const PostFormDescriptionChanged(this.description);
  @override
  List<Object> get props => [description];
}

class PostFormPrimaryImageChanged extends PostFormEvent {
  final String imageUrl;
  const PostFormPrimaryImageChanged(this.imageUrl);
  @override
  List<Object> get props => [imageUrl];
}

class PostFormPrimaryImagePicked extends PostFormEvent {
  final File file;
  const PostFormPrimaryImagePicked(this.file);

  @override
  List<Object> get props => [file];
}

class PostFormAdditionalImageAdded extends PostFormEvent {
  final File image;
  const PostFormAdditionalImageAdded(this.image);
  @override
  List<Object> get props => [image];
}

class PostFormAdditionalImageRemoved extends PostFormEvent {
  final int index;
  const PostFormAdditionalImageRemoved(this.index);
  @override
  List<Object> get props => [index];
}

class PostFormYoutubeUrlChanged extends PostFormEvent {
  final String youtubeUrl;
  const PostFormYoutubeUrlChanged(this.youtubeUrl);
  @override
  List<Object> get props => [youtubeUrl];
}

class PostFormPriceChanged extends PostFormEvent {
  final double price;
  const PostFormPriceChanged(this.price);
  @override
  List<Object> get props => [price];
}

class PostFormAreaChanged extends PostFormEvent {
  final double? area;
  const PostFormAreaChanged(this.area);
  @override
  List<Object?> get props => [area];
}

class PostFormCapacityChanged extends PostFormEvent {
  final int? capacity;
  const PostFormCapacityChanged(this.capacity);
  @override
  List<Object?> get props => [capacity];
}

class PostFormRoomTypeChanged extends PostFormEvent {
  final RoomType? roomType;
  const PostFormRoomTypeChanged(this.roomType);
  @override
  List<Object?> get props => [roomType];
}

class PostFormAmenitiesChanged extends PostFormEvent {
  final List<AmenityType> amenities;
  const PostFormAmenitiesChanged(this.amenities);
  @override
  List<Object> get props => [amenities];
}

class PostFormTagsChanged extends PostFormEvent {
  final List<PostTag> tags;
  const PostFormTagsChanged(this.tags);
  @override
  List<Object> get props => [tags];
}

class PostFormCoordinatesChanged extends PostFormEvent {
  final double? latitude;
  final double? longitude;
  const PostFormCoordinatesChanged({this.latitude, this.longitude});
  @override
  List<Object?> get props => [latitude, longitude];
}

class PostFormSubmitted extends PostFormEvent {
  const PostFormSubmitted();
}

class PostFormReset extends PostFormEvent {
  const PostFormReset();
}

class PostFormVideoPicked extends PostFormEvent {
  final File videoFile;
  const PostFormVideoPicked(this.videoFile);
  @override
  List<Object> get props => [videoFile];
}

class PostFormVideoRemoved extends PostFormEvent {
  const PostFormVideoRemoved();
}

// STATES

abstract class PostFormState extends Equatable {
  const PostFormState();
  @override
  List<Object?> get props => [];
}

class PostFormInitial extends PostFormState {
  const PostFormInitial();
}

class PostFormLoading extends PostFormState {
  const PostFormLoading();
}

class PostFormReady extends PostFormState {
  final String organizationId;
  final String userId;
  final String title;
  final String description;
  final String primaryImageUrl;
  final File? primaryImageFile;
  final List<File> additionalImages;
  final File? videoFile;
  final String youtubeUrl;
  final double price;
  final double? area;
  final int? capacity;
  final RoomType? roomType;
  final List<AmenityType> amenities;
  final List<PostTag> tags;
  final double? latitude;
  final double? longitude;
  final Map<String, String> validationErrors;
  final bool isValid;

  const PostFormReady({
    required this.organizationId,
    required this.userId,
    this.title = '',
    this.description = '',
    this.primaryImageUrl = '',
    this.primaryImageFile,
    this.additionalImages = const [],
    this.videoFile,
    this.youtubeUrl = '',
    this.price = 0,
    this.area,
    this.capacity,
    this.roomType,
    this.amenities = const [],
    this.tags = const [],
    this.latitude,
    this.longitude,
    this.validationErrors = const {},
    this.isValid = false,
  });

  @override
  List<Object?> get props => [
    organizationId,
    userId,
    title,
    description,
    primaryImageUrl,
    primaryImageFile,
    additionalImages,
    videoFile,
    youtubeUrl,
    price,
    area,
    capacity,
    roomType,
    amenities,
    tags,
    latitude,
    longitude,
    validationErrors,
    isValid,
  ];

  PostFormReady copyWith({
    String? organizationId,
    String? userId,
    String? title,
    String? description,
    String? primaryImageUrl,
    File? primaryImageFile,
    List<File>? additionalImages,
    File? videoFile,
    String? youtubeUrl,
    double? price,
    double? area,
    int? capacity,
    RoomType? roomType,
    List<AmenityType>? amenities,
    List<PostTag>? tags,
    double? latitude,
    double? longitude,
    Map<String, String>? validationErrors,
    bool? isValid,
  }) {
    return PostFormReady(
      organizationId: organizationId ?? this.organizationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
      primaryImageFile: primaryImageFile ?? this.primaryImageFile,
      additionalImages: additionalImages ?? this.additionalImages,
      videoFile: videoFile ?? this.videoFile,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      price: price ?? this.price,
      area: area ?? this.area,
      capacity: capacity ?? this.capacity,
      roomType: roomType ?? this.roomType,
      amenities: amenities ?? this.amenities,
      tags: tags ?? this.tags,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      validationErrors: validationErrors ?? this.validationErrors,
      isValid: isValid ?? this.isValid,
    );
  }
}

class PostFormSubmitting extends PostFormState {
  const PostFormSubmitting();
}

class PostFormSuccess extends PostFormState {
  final Post post;
  final String message;
  const PostFormSuccess({required this.post, required this.message});
  @override
  List<Object> get props => [post, message];
}

class PostFormError extends PostFormState {
  final String message;
  final PostFormReady? previousState;
  const PostFormError({required this.message, this.previousState});
  @override
  List<Object?> get props => [message, previousState];
}

// BLOC

class PostFormBloc extends Bloc<PostFormEvent, PostFormState> {
  final CreatePostUseCase _createPostUseCase;

  PostFormBloc({required CreatePostUseCase createPostUseCase})
    : _createPostUseCase = createPostUseCase,
      super(const PostFormInitial()) {
    on<PostFormInitialized>(_onInitialized);
    on<PostFormTitleChanged>(_onTitleChanged);
    on<PostFormDescriptionChanged>(_onDescriptionChanged);
    on<PostFormPrimaryImageChanged>(_onPrimaryImageChanged);
    on<PostFormPrimaryImagePicked>(_onPrimaryImagePicked);
    on<PostFormAdditionalImageAdded>(_onAdditionalImageAdded);
    on<PostFormAdditionalImageRemoved>(_onAdditionalImageRemoved);
    on<PostFormVideoPicked>(_onVideoPicked);
    on<PostFormVideoRemoved>(_onVideoRemoved);
    on<PostFormYoutubeUrlChanged>(_onYoutubeUrlChanged);
    on<PostFormPriceChanged>(_onPriceChanged);
    on<PostFormAreaChanged>(_onAreaChanged);
    on<PostFormCapacityChanged>(_onCapacityChanged);
    on<PostFormRoomTypeChanged>(_onRoomTypeChanged);
    on<PostFormAmenitiesChanged>(_onAmenitiesChanged);
    on<PostFormTagsChanged>(_onTagsChanged);
    on<PostFormCoordinatesChanged>(_onCoordinatesChanged);
    on<PostFormSubmitted>(_onSubmitted);
    on<PostFormReset>(_onReset);
  }

  void _onInitialized(PostFormInitialized event, Emitter<PostFormState> emit) {
    emit(
      PostFormReady(userId: event.userId, organizationId: event.organizationId),
    );
  }

  void _onTitleChanged(PostFormTitleChanged e, Emitter<PostFormState> emit) {
    final s = state;
    if (s is PostFormReady) emit(_validateForm(s.copyWith(title: e.title)));
  }

  void _onDescriptionChanged(
    PostFormDescriptionChanged e,
    Emitter<PostFormState> emit,
  ) {
    final s = state;
    if (s is PostFormReady) {
      emit(_validateForm(s.copyWith(description: e.description)));
    }
  }

  void _onPrimaryImageChanged(
    PostFormPrimaryImageChanged e,
    Emitter<PostFormState> emit,
  ) {
    final s = state;
    if (s is PostFormReady) {
      emit(_validateForm(s.copyWith(primaryImageUrl: e.imageUrl)));
    }
  }

  void _onPrimaryImagePicked(
    PostFormPrimaryImagePicked e,
    Emitter<PostFormState> emit,
  ) {
    final s = state;
    if (s is PostFormReady) {
      // print('primary imaeg: ${e.file}');
      emit(_validateForm(s.copyWith(primaryImageFile: e.file)));
    }
  }

  void _onAdditionalImageAdded(
    PostFormAdditionalImageAdded e,
    Emitter<PostFormState> emit,
  ) {
    final s = state;
    if (s is PostFormReady) {
      final imgs = List<File>.from(s.additionalImages)..add(e.image);
      emit(_validateForm(s.copyWith(additionalImages: imgs)));
    }
  }

  void _onAdditionalImageRemoved(
    PostFormAdditionalImageRemoved e,
    Emitter<PostFormState> emit,
  ) {
    final s = state;
    if (s is PostFormReady) {
      final imgs = List<File>.from(s.additionalImages);
      if (e.index >= 0 && e.index < imgs.length) imgs.removeAt(e.index);
      emit(_validateForm(s.copyWith(additionalImages: imgs)));
    }
  }

  void _onVideoPicked(PostFormVideoPicked e, Emitter<PostFormState> emit) {
    final s = state;
    if (s is PostFormReady) {
      emit(_validateForm(s.copyWith(videoFile: e.videoFile)));
    }
  }

  void _onVideoRemoved(PostFormVideoRemoved e, Emitter<PostFormState> emit) {
    final s = state;
    if (s is PostFormReady) {
      emit(_validateForm(s.copyWith(videoFile: null)));
    }
  }

  void _onYoutubeUrlChanged(
    PostFormYoutubeUrlChanged e,
    Emitter<PostFormState> emit,
  ) {
    final s = state;
    if (s is PostFormReady) {
      emit(_validateForm(s.copyWith(youtubeUrl: e.youtubeUrl)));
    }
  }

  void _onPriceChanged(PostFormPriceChanged e, Emitter<PostFormState> emit) {
    final s = state;
    if (s is PostFormReady) emit(_validateForm(s.copyWith(price: e.price)));
  }

  void _onAreaChanged(PostFormAreaChanged e, Emitter<PostFormState> emit) {
    final s = state;
    if (s is PostFormReady) emit(_validateForm(s.copyWith(area: e.area)));
  }

  void _onCapacityChanged(
    PostFormCapacityChanged e,
    Emitter<PostFormState> emit,
  ) {
    final s = state;
    if (s is PostFormReady) {
      emit(_validateForm(s.copyWith(capacity: e.capacity)));
    }
  }

  void _onRoomTypeChanged(
    PostFormRoomTypeChanged e,
    Emitter<PostFormState> emit,
  ) {
    final s = state;
    if (s is PostFormReady) {
      emit(_validateForm(s.copyWith(roomType: e.roomType)));
    }
  }

  void _onAmenitiesChanged(
    PostFormAmenitiesChanged e,
    Emitter<PostFormState> emit,
  ) {
    final s = state;
    if (s is PostFormReady) {
      emit(_validateForm(s.copyWith(amenities: e.amenities)));
    }
  }

  void _onTagsChanged(PostFormTagsChanged e, Emitter<PostFormState> emit) {
    final s = state;
    if (s is PostFormReady) emit(_validateForm(s.copyWith(tags: e.tags)));
  }

  void _onCoordinatesChanged(
    PostFormCoordinatesChanged e,
    Emitter<PostFormState> emit,
  ) {
    final s = state;
    if (s is PostFormReady) {
      emit(
        _validateForm(s.copyWith(latitude: e.latitude, longitude: e.longitude)),
      );
    }
  }

  Future<void> _onSubmitted(
    PostFormSubmitted e,
    Emitter<PostFormState> emit,
  ) async {
    final s = state;
    if (s is! PostFormReady || !s.isValid) return;

    emit(const PostFormSubmitting());

    final params = CreatePostParams(
      organizationId: s.organizationId,
      title: s.title,
      description: s.description,
      primaryImageUrl: s.primaryImageUrl,
      primaryImageFile: s.primaryImageFile,
      additionalImages: s.additionalImages,
      youtubeUrl: s.youtubeUrl.isEmpty ? null : s.youtubeUrl,
      longitude: s.longitude,
      latitude: s.latitude,
      price: s.price,
      area: s.area,
      capacity: s.capacity,
      roomType: s.roomType,
      amenities: s.amenities,
      tags: s.tags,
      createdBy: s.userId,
      updatedBy: s.userId,
    );

    final result = await _createPostUseCase(params);

    result.fold(
      (failure) => emit(
        PostFormError(
          message: 'Failed to create post: ${failure.message}',
          previousState: s,
        ),
      ),

      (post) => emit(
        PostFormSuccess(post: post, message: 'Post created successfully!'),
      ),
    );
  }

  void _onReset(PostFormReset e, Emitter<PostFormState> emit) {
    emit(const PostFormInitial());
  }
  // VALIDATION

  PostFormReady _validateForm(PostFormReady s) {
    final errors = <String, String>{};

    if (s.title.trim().isEmpty) {
      errors['title'] = 'Title is required';
    }

    if (s.description.trim().isEmpty) {
      errors['description'] = 'Description is required';
    }

    if (s.price <= 0) {
      errors['price'] = 'Price must be greater than 0';
    }

    if (s.area != null && s.area! < 0) {
      errors['area'] = 'Area must be non-negative';
    }

    if (s.capacity != null && s.capacity! <= 0) {
      errors['capacity'] = 'Capacity must be greater than 0';
    }

    if (s.youtubeUrl.isNotEmpty && !_isValidYoutubeUrl(s.youtubeUrl)) {
      errors['youtubeUrl'] = 'Invalid YouTube URL format';
    }

    if (s.organizationId.trim().isEmpty) {
      errors['organizationId'] = 'Organization ID required';
    }

    return s.copyWith(validationErrors: errors, isValid: errors.isEmpty);
  }

  bool _isValidYoutubeUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return (uri.host.contains('youtube.com') ||
              uri.host.contains('youtu.be')) &&
          (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  // Helpers for UI
  PostFormReady? get currentForm =>
      state is PostFormReady ? state as PostFormReady : null;
  bool get isFormValid => currentForm?.isValid ?? false;
}
