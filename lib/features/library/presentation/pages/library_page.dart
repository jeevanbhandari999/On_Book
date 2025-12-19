import 'package:app/app/dependency_injection.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/utils/date_formatter.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/core/widgets/loading_widget.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/library/domain/usecases/get_all_booking_by_user_id_use_case.dart';
import 'package:app/features/library/presentation/bloc/library_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LibraryPage extends StatelessWidget {
  // final String userId;

  const LibraryPage({
    super.key,
    // required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LibraryBloc(
        getAllBookingsByUserIdUseCase:
            DependencyInjection.get<GetAllBookingsByUserIdUseCase>(),
      )..add(LoadUserLibrary('9cbe8449-9772-453a-8257-544c5c7ab415')),
      child: const LibraryView(),
    );
  }
}

class LibraryView extends StatelessWidget {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          if (state is LibraryLoading) {
            return const Center(child: LoadingWidget());
          }

          if (state is LibraryError) {
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
                    onPressed: () => context
                        .read<LibraryBloc>()
                        .add(LoadUserLibrary('9cbe8449-9772-453a-8257-544c5c7ab415')),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is LibraryLoaded) {
            if (!state.hasBookings) {
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

            return RefreshIndicator(
              onRefresh: () async {
                context.read<LibraryBloc>().add(RefreshUserLibrary(
                      '9cbe8449-9772-453a-8257-544c5c7ab415',
                    ));
              },
              child: ListView(
                padding: const EdgeInsets.all(UiConstants.spacingMd),
                children: [
                  if (state.ongoingBookings.isNotEmpty) ...[
                    _buildSectionHeader('Currently Staying'),
                    ...state.ongoingBookings.map((booking) => _buildBookingCard(context, booking, isOngoing: true)),
                    const SizedBox(height: UiConstants.spacingLg),
                  ],

                  if (state.upcomingBookings.isNotEmpty) ...[
                    _buildSectionHeader('Upcoming Bookings'),
                    ...state.upcomingBookings.map((booking) => _buildBookingCard(context, booking)),
                    const SizedBox(height: UiConstants.spacingLg),
                  ],

                  if (state.pastBookings.isNotEmpty) ...[
                    _buildSectionHeader('Past Bookings'),
                    ...state.pastBookings.map((booking) => _buildBookingCard(context, booking, isPast: true)),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UiConstants.spacingSm),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    Booking booking, {
    bool isOngoing = false,
    bool isPast = false,
  }) {
    final statusColor = _getStatusColor(booking.status);

    return SectionContainer(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: Navigate to booking detail screen
          // Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: booking)));
        },
        child: Padding(
          padding: const EdgeInsets.all(UiConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Primary Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: booking.primaryImageUrl.isNotEmpty
                        ? Image.network(
                            booking.primaryImageUrl,
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 110,
                            height: 110,
                            color: Colors.grey[300],
                            child: const Icon(Icons.hotel, size: 50, color: Colors.grey),
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormatter.range(booking.checkInDate, booking.checkOutDate),
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${booking.nights} night${booking.nights > 1 ? 's' : ''} • \$${booking.totalAmount}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: UiConstants.spacingMd),

              // Status Chips & Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          booking.status.name.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        backgroundColor: statusColor,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      if (isOngoing) ...[
                        const SizedBox(width: 8),
                        const Chip(
                          label: Text('ONGOING', style: TextStyle(fontSize: 12)),
                          backgroundColor: Colors.orange,
                        ),
                      ],
                      if (isPast && booking.status == BookingStatus.cancelled) ...[
                        const SizedBox(width: 8),
                        const Chip(
                          label: Text('CANCELLED', style: TextStyle(fontSize: 12)),
                          backgroundColor: Colors.red,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    'Booked ${DateFormatter.format(booking.createdAt)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
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
      case BookingStatus.completed:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}