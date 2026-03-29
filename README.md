# Hotel Booking & Post Management System

A Flutter-based cross-platform application for managing hotel accommodations, posts, bookings, and customer reviews. The app features real-time notifications, chat functionality, map-based location services, and intelligent content-based recommendations.

## Tech Stack

### Core Framework
- **Flutter SDK**: ^3.8.1 - Cross-platform mobile, web, and desktop development
- **Dart**: Primary programming language

### State Management
- **flutter_bloc**: ^9.1.1 - BLoC (Business Logic Component) pattern for state management
- **equatable**: ^2.0.7 - Immutable data classes with value-based equality

### Navigation
- **go_router**: ^16.2.5 - Declarative routing with type-safe navigation

### Backend Services
- **supabase_flutter**: ^2.10.3 - Backend-as-a-Service for authentication, database, and real-time subscriptions
- **get_it**: ^8.2.0 - Service locator for dependency injection

### Data Persistence
- **flutter_secure_storage**: ^9.2.4 - Encrypted secure storage for sensitive data (tokens, user data)
- **shared_preferences**: ^2.5.3 - Key-value storage for small data
- **flutter_dotenv**: ^6.0.0 - Environment variable management

### Error Handling
- **dartz**: ^0.10.1 - Functional programming constructs for Either monad pattern

### Media & Storage
- **cloudinary_public**: ^0.23.1 - Cloud-based media management (images, videos)
- **image_picker**: ^1.2.0 - Image selection from device gallery/camera
- **video_thumbnail**: ^0.5.6 - Thumbnail generation for videos
- **video_player**: ^2.10.1 - Video playback functionality

### UI Components
- **flutter_animate**: ^4.5.2 - Easy animations and transitions
- **shimmer**: ^3.0.0 - Loading skeleton screens
- **flutter_staggered_grid_view**: ^0.7.0 - Responsive staggered grid layouts
- **cached_network_image**: ^3.4.1 - Efficient image caching from network
- **flutter_svg**: ^2.2.3 - SVG vector graphics rendering
- **dotted_border**: ^3.1.0 - Dotted border UI component
- **flutter_rating_bar**: ^4.0.1 - Star rating UI and logic
- **marquee**: ^2.3.0 - Scrolling text effect

### Maps & Location
- **flutter_map**: ^8.2.2 - Interactive map rendering
- **latlong2**: ^0.9.1 - Latitude/longitude handling
- **location**: ^8.0.1 - GPS location services
- **url_launcher**: ^6.3.2 - Launch external URLs (maps, browsers)

### Utilities
- **intl**: ^0.20.2 - Internationalization and date/time formatting
- **flutter_local_notifications**: ^21.0.0 - Local push notifications

### Custom SDKs
- **esewa_flutter_sdk**: Esewa payment integration (custom in-house SDK)

---

## Project Structure

```
lib/
├── app/                          # App-level configuration
│   ├── app_config.dart          # Environment and app configuration
│   ├── dependency_injection.dart # GetIt service locator setup
│   └── router/                  # GoRouter navigation configuration
│
├── core/                        # Core architecture & utilities
│   ├── constants/
│   │   ├── api_constants.dart  # API endpoints and timeouts
│   │   └── app_constants.dart  # App-wide constants
│   ├── errors/
│   │   ├── error_handler.dart  # Centralized error handling
│   │   ├── exceptions.dart     # Exception definitions
│   │   └── failures.dart       # Failure types (Domain layer errors)
│   ├── navigations/            # Navigation wrappers and utilities
│   │   ├── adaptive_navigation.dart
│   │   ├── mobile_bottom_navigation.dart
│   │   ├── navigation_wrapper.dart
│   │   └── responsive_navigation_controller.dart
│   ├── responsive/
│   │   └── screen_break_points.dart  # Responsive breakpoints
│   ├── services/
│   │   ├── cloudinary_service.dart   # Cloudinary image/video service
│   │   └── session_manager.dart      # Session state management
│   ├── theme/
│   │   └── app_text_styles.dart     # Text style definitions
│   └── utils/
│       ├── extensions/              # Flutter extensions
│       │   ├── context_extensions.dart
│       │   ├── datetime_extensions.dart
│       │   ├── responsive_extensions.dart
│       │   └── string_extensions.dart
│       └── validators/              # Form validation
│           └── form_validators.dart
│
└── features/                     # Feature modules (BLoC pattern)
    ├── auth/                     # Authentication & authorization
    │   ├── data/
    │   │   ├── datasources/     # Local/Remote data sources
    │   │   ├── models/          # Data models
    │   │   └── repositories/    # Repository implementations
    │   ├── domain/
    │   │   ├── entities/        # Domain entities
    │   │   ├── repositories/    # Repository interfaces
    │   │   └── usecases/        # Business logic use cases
    │   └── presentation/
    │       ├── bloc/            # BLoC components
    │       ├── pages/           # UI pages
    │       └── services/        # Service classes
    │
    ├── home/                     # Home feed & recommendations
    │   ├── data/datasources/
    │   ├── domain/
    │   │   ├── usecases/        # Algorithms for recommendations
    │   │   └── repositories/
    │   └── presentation/
    │       ├── bloc/            # HomeBloc, OrganizationBloc
    │       ├── pages/
    │       └── widgets/
    │
    ├── post/                     # Post creation and management
    │   ├── data/
    │   ├── domain/
    │   │   ├── entities/        # Post, PostImage, PostVideo
    │   │   ├── usecases/        # CRUD operations
    │   │   └── repositories/
    │   └── presentation/
    │
    ├── booking/                  # Booking management
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── library/                  # User's saved posts/bookmarks
    │
    ├── customer_review/          # Review system with ratings
    │   ├── domain/entities/     # Review, Rating, Reaction
    │   └── presentation/
    │
    ├── profile/                  # User profile management
    │
    ├── organizations/            # Organization management
    │
    ├── chat/                     # Real-time chat
    │
    ├── search/                   # Search functionality
    │
    ├── notifications/            # Real-time notifications
    │
    └── splash/                   # App entry point
```

---

## Core Algorithms & Business Logic

### 1. Location-Based Proximity Algorithm

**Use Case**: `GetAllPostsNearByUserUseCase`

The app implements a location-aware post recommendation system that filters posts based on user proximity:

```dart
Future<Either<Failure, ({String? nextCursor, List<Post> posts})>> call(
  GetAllPostsNearByUserParams params,
) async {
  // Validate user ID
  if (params.userId.trim().isEmpty) {
    return const Left(ValidationFailure('User ID is required'));
  }

  final data = await repository.getNearByPosts(
    userId: params.userId,
    latitude: params.latitude,
    longitude: params.longitude,
    limit: params.limit,
    cursor: params.cursor,
  );
  return data;
}
```

**Parameters**:
- `userId`: Authenticated user identifier
- `latitude/longitude`: Current user location (optional, defaults to 0,0)
- `limit`: Number of results (default: 15)
- `cursor`: Pagination cursor for infinite scrolling

---

### 2. Content-Based Filtering Algorithm

**Use Case**: `GetAllPostRecommendedByContentFilterUseCase`

Implements content-based filtering for post recommendations using user preferences and location:

```dart
Future<Either<Failure, List<Post>>> call(
  GetAllPostRecommendedByContentFilterParams params,
) async {
  if (params.userId.trim().isEmpty) {
    return const Left(ValidationFailure('User ID is required'));
  }
  return await repository.getRecommendedPosts(
    userId: params.userId,
    longitude: params.longitude,
    latitude: params.latitude,
    limit: params.limit,
  );
}
```

**Features**:
- Personalized recommendations based on user behavior
- Location-aware filtering
- Configurable result limits
- Cursor-based pagination support

---

### 3. Global Score Organization Ranking

**Use Case**: `GetOrganizationListBasedOnGlobalScoreUseCase`

Organizations are ranked using a global scoring algorithm that considers:
- User ratings and reviews
- Overall engagement metrics
- Content quality scores
- Response to user preferences

```dart
Future<Either<Failure, List<Organization>>> call() async {
  return repository.getOrganizationsBasedOnUserAndOthersPreferences();
}
```

---

### 4. Caching Strategy with Expiration

**Use Case**: `HomeLocalDataSourceImpl`

Implements a multi-tier caching system with automatic expiration:

```dart
Future<bool> isCacheExpired(
  String userId, {
  Duration maxAge = const Duration(hours: 1),
}) async {
  final timestamp = await getCacheTimestamp(userId);
  if (timestamp == null) return true; // No cache exists

  final now = DateTime.now();
  final difference = now.difference(timestamp);
  return difference > maxAge; // 1-hour default expiration
}
```

**Cache Keys**:
- `home_posts_{userId}`: User-specific post cache
- `home_post_timestamp_{userId}`: Cache timestamp for expiration

**Features**:
- Automatic cache expiration (configurable TTL)
- Graceful fallback to cached data on network failures
- Selective cache invalidation per user/organization

---

### 5. Post Creation Validation Algorithm

**Use Case**: `CreatePostUseCase`

Comprehensive validation pipeline for post creation:

```dart
Future<Either<Failure, Post>> call(CreatePostParams params) async {
  // 1. Validate required parameters (organizationId, title, createdBy)
  // 2. Check user permissions
  // 3. Validate YouTube URL format if provided
  // 4. Upload primary image to Cloudinary
  // 5. Create post entity with validated data
  // 6. Return Either<Failure, Post>
}
```

**Validation Rules**:
- Organization ID must not be empty
- Title must not be empty
- User ID must not be empty
- YouTube URLs must be valid format
- Price must be greater than 0
- Latitude/longitude must both be provided or neither
- Valid coordinate ranges (-90 to 90 for lat, -180 to 180 for lon)

---

### 6. Repository Pattern with Error Handling

**Use Case**: `AuthRepositoryImpl`, `PostRepositoryImpl`

All repositories use the Either monad pattern for functional error handling:

```dart
Future<Either<Failure, User>> login({
  required String email,
  required String password,
}) async {
  try {
    final userModel = await remoteDataSource.login(email: email, password: password);
    await localDataSource.cacheUser(userModel);
    return Right(userModel.toEntity());
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } on NetworkException catch (e) {
    return Left(NetworkFailure(e.message));
  } on AuthException catch (e) {
    return Left(AuthFailure(e.message));
  } catch (e) {
    return Left(UnknownFailure(e.toString()));
  }
}
```

**Failure Types**:
- `ServerFailure`: Backend API errors
- `NetworkFailure`: Connection errors
- `ValidationFailure`: Input validation errors
- `AuthFailure`: Authentication errors
- `PermissionFailure`: Authorization errors
- `CacheFailure`: Storage errors
- `UnknownFailure`: Unexpected errors

---

### 7. BLoC State Management Pattern

**Use Case**: `HomeBloc`, `AuthBloc`, `NotificationBloc`

All features follow the BLoC pattern with typed events and states:

```dart
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetAllPostsNearByUserUseCase getNearbyPostsUseCase;

  HomeBloc({required this.getNearbyPostsUseCase}) : super(const HomeInitial()) {
    on<FetchNearbyPosts>(_onFetchNearbyPosts);
    on<FetchNearByAndContentBasedFilteringPosts>(_onFetchNearByAndContentBasedFilteringPosts);
    on<FetchOrganizationDetails>(_onFetchOrganizationDetails);
    on<RefreshNearbyPosts>(_onRefreshNearbyPosts);
  }

  Future<void> _onFetchNearbyPosts(
    FetchNearbyPosts event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    final result = await getNearbyPostsUseCase(params);
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (data) => emit(HomeLoaded(data.posts, data.nextCursor)),
    );
  }
}
```

---

### 8. Dependency Injection with GetIt

**Use Case**: `DependencyInjection`

Centralized service locator configuration:

```dart
static Future<void> init() async {
  // Core Services
  instance.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );
  instance.registerLazySingleton<SessionManager>(() => SessionManager());

  // Feature services (loaded per feature module)
  await _registerAuthDependencies();
  await _registerPostDependencies();
  await _registerHomeDependencies();
  // ... other feature registrations
}
```

---

## Esewa Payment Integration

Custom Flutter plugin for Nepali payment gateway `esewa`:

**Key Files**:
- `lib/esewa_flutter_sdk.dart` - Flutter API wrapper
- `android/src/main/kotlin/.../EsewaFlutterSdkPlugin.kt` - Android implementation
- `lib/payment_failure.dart` - Failure handling
- `lib/esewa_payment_success_result.dart` - Success result parsing

**Features**:
- Cross-platform payment flow (Android/iOS)
- Payment status tracking (success/failure/cancellation)
- Transaction reference ID generation

---

## Environment Configuration

Create a `.env` file in the project root:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key

CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_UPLOAD_PRESET=your-upload-preset

MAP_TILER_KEY=your-maptiler-key
```

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release
```

---

## Development Guidelines

### Architecture
- **Clean Architecture** with clear separation of concerns
- **BLoC pattern** for state management
- **Repository pattern** for data access abstraction
- **Either monad** for functional error handling

### Code Organization
- Features are isolated in separate directories
- Domain-Driven Design with entities, use cases, and repositories
- Shared core utilities in `core/` folder

### State Management
- Use `Equatable` for all state objects to enable value comparison
- BLoC events trigger use case execution
- Use `Either<Failure, T>` for all async operations

---

## License

This project is proprietary and confidential.
