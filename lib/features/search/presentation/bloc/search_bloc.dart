// ─────────────────────────────────────────────────────────────────
// features/search/presentation/bloc/search_event.dart
// ─────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:app/features/search/domain/entities/search_filter_enum.dart';
import 'package:app/features/search/domain/entities/search_result.dart';
import 'package:equatable/equatable.dart';
import 'package:app/features/search/domain/usecases/search_use_cases.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

/// Page opened → load content-based discovery feed
class LoadDiscoveryFeed extends SearchEvent {
  final String currentUserId;
  const LoadDiscoveryFeed({required this.currentUserId});
  @override
  List<Object?> get props => [currentUserId];
}

/// User is typing in the search bar (debounced internally)
class SearchQueryChanged extends SearchEvent {
  final String query;
  final String currentUserId;
  const SearchQueryChanged({required this.query, required this.currentUserId});
  @override
  List<Object?> get props => [query, currentUserId];
}

/// User tapped a filter chip
class SearchFilterChanged extends SearchEvent {
  final SearchFilter filter;
  const SearchFilterChanged({required this.filter});
  @override
  List<Object?> get props => [filter];
}

/// User cleared the search bar
class SearchCleared extends SearchEvent {
  final String currentUserId;
  const SearchCleared({required this.currentUserId});
  @override
  List<Object?> get props => [currentUserId];
}

/// Internal — fired after debounce expires
class _ExecuteSearch extends SearchEvent {
  final String query;
  final String currentUserId;
  const _ExecuteSearch({required this.query, required this.currentUserId});
  @override
  List<Object?> get props => [query, currentUserId];
}

// ─────────────────────────────────────────────────────────────────
// features/search/presentation/bloc/search_state.dart
// ─────────────────────────────────────────────────────────────────

abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

/// Before first load
class SearchInitial extends SearchState {}

/// Waiting for data (shows shimmer)
class SearchLoading extends SearchState {}

/// Discovery feed loaded (no query, content-based)
class SearchDiscoveryLoaded extends SearchState {
  final SearchResult result;
  final SearchFilter activeFilter;

  const SearchDiscoveryLoaded({
    required this.result,
    this.activeFilter = SearchFilter.all,
  });

  SearchDiscoveryLoaded copyWith({
    SearchResult? result,
    SearchFilter? activeFilter,
  }) => SearchDiscoveryLoaded(
    result: result ?? this.result,
    activeFilter: activeFilter ?? this.activeFilter,
  );

  @override
  List<Object?> get props => [result, activeFilter];
}

/// Search results loaded (query was typed)
class SearchResultsLoaded extends SearchState {
  final SearchResult result;
  final String query;
  final SearchFilter activeFilter;

  const SearchResultsLoaded({
    required this.result,
    required this.query,
    this.activeFilter = SearchFilter.all,
  });

  SearchResultsLoaded copyWith({
    SearchResult? result,
    String? query,
    SearchFilter? activeFilter,
  }) => SearchResultsLoaded(
    result: result ?? this.result,
    query: query ?? this.query,
    activeFilter: activeFilter ?? this.activeFilter,
  );

  @override
  List<Object?> get props => [result, query, activeFilter];
}

/// Something went wrong
class SearchError extends SearchState {
  final String message;
  const SearchError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────────────────────────
// features/search/presentation/bloc/search_bloc.dart
// ─────────────────────────────────────────────────────────────────

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final GetDiscoveryFeedUseCase getDiscoveryFeedUseCase;
  final SearchAllUseCase searchAllUseCase;

  Timer? _debounce;
  static const _debounceDuration = Duration(milliseconds: 450);

  SearchBloc({
    required this.getDiscoveryFeedUseCase,
    required this.searchAllUseCase,
  }) : super(SearchInitial()) {
    on<LoadDiscoveryFeed>(_onLoadDiscoveryFeed);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<_ExecuteSearch>(_onExecuteSearch);
    on<SearchFilterChanged>(_onSearchFilterChanged);
    on<SearchCleared>(_onSearchCleared);
  }

  // ── handlers ─────────────────────────────────────────────────────

  Future<void> _onLoadDiscoveryFeed(
    LoadDiscoveryFeed event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    final result = await getDiscoveryFeedUseCase(
      DiscoveryParams(currentUserId: event.currentUserId),
    );
    result.fold(
      (failure) => emit(SearchError(message: failure.message)),
      (data) => emit(SearchDiscoveryLoaded(result: data)),
    );
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) {
    _debounce?.cancel();
    final query = event.query.trim();

    if (query.isEmpty) {
      add(SearchCleared(currentUserId: event.currentUserId));
      return;
    }

    // Keep existing results visible while debouncing
    if (state is! SearchResultsLoaded) emit(SearchLoading());

    _debounce = Timer(
      _debounceDuration,
      () =>
          add(_ExecuteSearch(query: query, currentUserId: event.currentUserId)),
    );
  }

  Future<void> _onExecuteSearch(
    _ExecuteSearch event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    final result = await searchAllUseCase(
      SearchParams(query: event.query, currentUserId: event.currentUserId),
    );
    result.fold(
      (failure) => emit(SearchError(message: failure.message)),
      (data) => emit(SearchResultsLoaded(result: data, query: event.query)),
    );
  }

  void _onSearchFilterChanged(
    SearchFilterChanged event,
    Emitter<SearchState> emit,
  ) {
    final current = state;
    if (current is SearchDiscoveryLoaded) {
      emit(current.copyWith(activeFilter: event.filter));
    } else if (current is SearchResultsLoaded) {
      emit(current.copyWith(activeFilter: event.filter));
    }
    // SearchLoading / SearchError — ignore, filter will apply after load
  }

  Future<void> _onSearchCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) async {
    _debounce?.cancel();
    // Go back to discovery feed
    add(LoadDiscoveryFeed(currentUserId: event.currentUserId));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
