import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/utils/date_formatter.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/core/widgets/loading_widget.dart';
import 'package:app/features/auth/services/auth_service.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/library/domain/entities/library_filter_enum.dart';
import 'package:app/features/library/domain/usecases/get_all_booking_by_user_id_use_case.dart';
import 'package:app/features/library/domain/usecases/get_all_booking_related_to_organization_use_case.dart';
import 'package:app/features/library/domain/usecases/update_booking_status_by_id_use_case.dart';
import 'package:app/features/library/presentation/bloc/library_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authDependency = DependencyInjection.get<AuthService>();
    final userId = authDependency.getCurrentUserId();

    // Handle the future for organizationId
    return FutureBuilder<String?>(
      future: authDependency
          .getCurrentUserOrganizationId(), // The future for organizationId
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for the organizationId to resolve, show a loading widget
          return const Center(child: LoadingWidget());
        }

        if (snapshot.hasError) {
          // If there's an error fetching organizationId, handle it here (optional)
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final organizationId = snapshot.data;
        // print(organizationId);

        if (userId == null) {
          return const Center(child: LoadingWidget());
        }

        return BlocProvider(
          create: (context) =>
              LibraryBloc(
                getAllBookingsByUserIdUseCase:
                    DependencyInjection.get<GetAllBookingsByUserIdUseCase>(),
                getAllBookingRelatedToOrganizationUseCase:
                    DependencyInjection.get<
                      GetAllBookingRelatedToOrganizationUseCase
                    >(),
                updateBookingStatusByIdUseCase:
                    DependencyInjection.get<UpdateBookingStatusByIdUseCase>(),
              )..add(
                LoadUserLibrary(userId: userId, organizationId: organizationId),
              ),
          child: LibraryView(userId: userId, organizationId: organizationId),
        );
      },
    );
  }
}

class LibraryView extends StatelessWidget {
  final String userId;
  final String? organizationId;
  const LibraryView({super.key, required this.userId, this.organizationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          if (state is LibraryLoading) {
            return const Center(child: LoadingWidget());
          }
          if (state is LibraryError) {
            return _buildErrorState(state, context);
          }
          if (state is LibraryLoaded) {
            return Padding(
              padding: const EdgeInsets.all(UiConstants.spacingMd),
              child: Column(
                children: [
                  // Filter tabs
                  BlocBuilder<LibraryBloc, LibraryState>(
                    builder: (context, state) {
                      if (state is! LibraryLoaded) {
                        return const SizedBox.shrink();
                      }
                      final activeFilter = state.activeFilter;
                      return SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: LibraryFilter.values.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: UiConstants.spacingSm),
                          itemBuilder: (context, index) {
                            final filter = LibraryFilter.values[index];
                            final isActive = filter == activeFilter;

                            return CustomButton(
                              icon: isActive ? const Icon(Icons.check) : null,
                              text: filter.displayName,
                              isOutlined: !isActive,
                              onPressed: () {
                                context.read<LibraryBloc>().add(
                                  ChangeLibraryFilterTabRequested(
                                    filter: filter,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: UiConstants.spacingMd),
                  BlocBuilder<LibraryBloc, LibraryState>(
                    builder: (context, state) {
                      if (state is! LibraryLoaded) {
                        return const SizedBox.shrink();
                      }
                      final filteredBookings = _getFilteredBookings(state);

                      return Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            context.read<LibraryBloc>().add(
                              RefreshUserLibrary(
                                userId: userId,
                                organizationId: organizationId,
                              ),
                            );
                            // Wait for refresh to complete
                            await context.read<LibraryBloc>().stream.firstWhere(
                              (newState) => newState is! LibraryRefreshing,
                            );
                          },
                          child: filteredBookings.isEmpty
                              ? _buildEmptyState()
                              : ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: filteredBookings.length,
                                  separatorBuilder: (_, __) => const SizedBox(
                                    height: UiConstants.spacingSm,
                                  ),
                                  itemBuilder: (context, index) {
                                    final booking = filteredBookings[index];
                                    return _buildBookingCard(
                                      context,
                                      booking,
                                      isUserBookingOwner:
                                          userId == booking.userId,
                                      isOrganizationMember:
                                          organizationId ==
                                          booking.organizationId,
                                      isOngoing:
                                          state.activeFilter ==
                                          LibraryFilter.ongoing,
                                      isPast:
                                          state.activeFilter ==
                                          LibraryFilter.past,
                                    );
                                  },
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
          return const LoadingWidget();
        },
      ),
    );
  }

  Center _buildErrorState(LibraryError state, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.grey),
          const SizedBox(height: UiConstants.spacingMd),
          Text(
            state.message,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UiConstants.spacingMd),
          ElevatedButton(
            onPressed: () => context.read<LibraryBloc>().add(
              LoadUserLibrary(userId: userId, organizationId: organizationId),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Center _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined, size: 100, color: Colors.grey),
          SizedBox(height: UiConstants.spacingLg),
          Text(
            'No bookings yet',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: UiConstants.spacingSm),
          Text(
            'Your booking history will appear here',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  List<Booking> _getFilteredBookings(LibraryLoaded state) {
    switch (state.activeFilter) {
      case LibraryFilter.ongoing:
        return state.ongoingBookings;
      case LibraryFilter.upcoming:
        return state.upcomingBookings;
      case LibraryFilter.past:
        return state.pastBookings;
      case LibraryFilter.newBooking:
        return state.newBookings;
      case LibraryFilter.myBooking:
        return state.myBooking;
      case LibraryFilter.recent:
        return [];
      case LibraryFilter.all:
      default:
        return [
          ...state.ongoingBookings,
          ...state.upcomingBookings,
          ...state.pastBookings,
        ];
    }
  }

  Widget _buildBookingCard(
    BuildContext context,
    Booking booking, {
    required bool isUserBookingOwner,
    required bool isOrganizationMember,
    bool isOngoing = false,
    bool isPast = false,
  }) {
    final statusColor = _getStatusColor(booking.status);

    return SectionContainer(
      padding: const EdgeInsets.all(UiConstants.spacingSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(UiConstants.radiusMd),
        onTap: () {
          context.push(
            RouteConstants.bookingDetailsPage,
            extra: {'userId': userId, 'bookingId': booking.id},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(UiConstants.spacingSm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Primary Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(UiConstants.radiusSm),
                    child: booking.primaryImageUrl.isNotEmpty
                        ? Image.network(
                            booking.primaryImageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.hotel,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  const SizedBox(width: UiConstants.spacingMd),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          booking.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          DateFormatter.range(
                            booking.checkInDate,
                            booking.checkOutDate,
                          ),
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${booking.nights} Night${booking.nights > 1 ? 's' : ''} • Rs.${booking.totalAmount}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _BookingActionMenu(
                    booking: booking,
                    isUserBookingOwner: isUserBookingOwner,
                    isOrganizationMember: isOrganizationMember,
                  ),
                ],
              ),

              const SizedBox(height: UiConstants.spacingSm),

              // Status Chips & Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Chip(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(
                            UiConstants.radiusSm,
                          ),
                        ),
                        label: BlocBuilder<LibraryBloc, LibraryState>(
                          builder: (context, state) {
                            if (state is UpdatingBookingStatusFromLibraryPage) {
                              return const CircularProgressIndicator();
                            }
                            return Text(
                              booking.status.name.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                        backgroundColor: statusColor,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      if (!isOngoing) ...[
                        const SizedBox(width: 8),
                        Chip(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(
                              UiConstants.radiusSm,
                            ),
                          ),
                          label: Text(
                            'ONGOING',
                            style: TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      ],
                      if (isPast &&
                          booking.status == BookingStatus.cancelled) ...[
                        const SizedBox(width: 8),
                        Chip(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(
                              UiConstants.radiusSm,
                            ),
                          ),
                          label: Text(
                            'CANCELLED',
                            style: TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    'Booked ${DateFormatter.format(booking.createdAt)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.rejected:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.blue;
    }
  }
}

class _BookingActionMenu extends StatelessWidget {
  final Booking booking;
  final bool isUserBookingOwner;
  final bool isOrganizationMember;

  const _BookingActionMenu({
    required this.booking,
    required this.isUserBookingOwner,
    required this.isOrganizationMember,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        final isUpdating = state is UpdatingBookingStatusFromLibraryPage;
        return PopupMenuButton<_BookingAction>(
          enabled: !isUpdating,
          icon: isUpdating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.more_vert, size: 20),
          itemBuilder: (context) {
            final items = <PopupMenuEntry<_BookingAction>>[];

            // User related action
            if (isUserBookingOwner && booking.status == BookingStatus.pending) {
              items.add(
                PopupMenuItem(
                  value: _BookingAction.cancel,
                  child: Row(
                    key: ValueKey(booking.status.name),
                    children: [
                      Icon(Icons.close, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Cancel Booking'),
                    ],
                  ),
                ),
              );
            }

            // Organization related action
            if (isOrganizationMember) {
              if (booking.status == BookingStatus.pending) {
                items.add(
                  PopupMenuItem(
                    value: _BookingAction.confirm,
                    child: Row(
                      key: ValueKey(booking.status.name),
                      children: [
                        Icon(Icons.check_circle, size: 18, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Confirm Booking'),
                      ],
                    ),
                  ),
                );
              }
              items.add(
                PopupMenuItem(
                  value: _BookingAction.updatePayment,
                  child: Row(
                    key: ValueKey(booking.status.name),
                    children: [
                      Icon(
                        Icons.currency_exchange,
                        size: 18,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 8),
                      Text('Update Payment'),
                    ],
                  ),
                ),
              );
              items.add(
                PopupMenuItem(
                  value: _BookingAction.reject,
                  child: Row(
                    key: ValueKey(booking.status.name),
                    children: [
                      Icon(Icons.do_not_disturb, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Reject Booking'),
                    ],
                  ),
                ),
              );
            }

            return items;
          },
          onSelected: (action) {
            _handleBookingAction(context, action, booking);
          },
        );
      },
    );
  }

  void _handleBookingAction(
    BuildContext context,
    _BookingAction action,
    Booking booking,
  ) {
    switch (action) {
      case _BookingAction.confirm:
        context.read<LibraryBloc>().add(
          UpdateBookingStatusFromLibraryPage(
            bookingId: booking.id,
            status: BookingStatus.confirmed.name,
          ),
        );
        break;

      case _BookingAction.cancel:
        context.read<LibraryBloc>().add(
          UpdateBookingStatusFromLibraryPage(
            bookingId: booking.id,
            status: BookingStatus.cancelled.name,
          ),
        );
        break;
      case _BookingAction.reject:
        context.read<LibraryBloc>().add(
          UpdateBookingStatusFromLibraryPage(
            bookingId: booking.id,
            status: BookingStatus.rejected.name,
          ),
        );
        break;
      case _BookingAction.updatePayment:
        break;
    }
  }
}

enum _BookingAction { confirm, cancel, reject, updatePayment }
