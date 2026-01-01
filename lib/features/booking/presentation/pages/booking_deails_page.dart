import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/utils/date_formatter.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/booking/domain/usecases/get_booking_by_id_use_case.dart';
import 'package:app/features/booking/presentation/bloc/booking_details_bloc.dart';
import 'package:app/features/post/domain/entities/post_enums.dart';
import 'package:app/features/post/presentation/widgets/detail_info_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BookingDetailsPage extends StatelessWidget {
  final String bookingId;
  final String userId;

  const BookingDetailsPage({
    super.key,
    required this.bookingId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingDetailsBloc(
        getBookingByIdUseCase: DependencyInjection.get<GetBookingByIdUseCase>(),
      )..add(LoadBookingDetails(bookingId: bookingId, userId: userId)),
      child: const BookingDetailsView(),
    );
  }
}

class BookingDetailsView extends StatelessWidget {
  const BookingDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        actions: [
          BlocBuilder<BookingDetailsBloc, BookingDetailsState>(
            builder: (context, state) {
              if (state is BookingDetailsLoaded) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      context.push(
                        RouteConstants.bookingFormPage,
                        extra: {
                          'userId': state.booking.userId,
                          'postId': state.booking.postId,
                          'editBooking': state.booking,
                        },
                      );
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: UiConstants.iconMd),
                          SizedBox(width: UiConstants.spacingSm),
                          Text('Edit Booking'),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<BookingDetailsBloc, BookingDetailsState>(
        builder: (context, state) {
          if (state is BookingDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BookingDetailsError) {
            return _buildErrorState(context, message: state.message);
          }

          if (state is BookingDetailsLoaded) {
            if (state.isViewingImage) {
              return _buildImageViewer(context, state);
            }
            return _buildBookingContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

Widget _buildErrorState(
  BuildContext context, {
  required String message,
  String? description,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Semantics(
      label: message,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Semantics(
              image: true,
              label: 'Error icon',
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const Text(
              'Error',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (description != null)
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: UiConstants.spacingSm),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UiConstants.spacingLg),
            Semantics(
              label: 'Try again',
              hint: message,
              button: true,
              child: CustomButton(
                text: 'Try Again',
                onPressed: () => _onRefresh(context),
                icon: const Icon(Icons.refresh),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _onRefresh(BuildContext context) {}

Widget _buildBookingContent(BuildContext context, BookingDetailsLoaded state) {
  final booking = state.booking;
  final List<AmenityType>? selectedAmenities = booking.amenities!
      .map((a) => amenityTypeFromString(a))
      .where((e) => e != null)
      .cast<AmenityType>()
      .toList();

  return RefreshIndicator(
    onRefresh: () async {
      context.read<BookingDetailsBloc>().add(
        LoadBookingDetails(bookingId: booking.id, userId: booking.userId),
      );
    },
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageCarousel(context, state),

          _buildTitleAndPriceSection(
            context,
            title: booking.title,
            price: booking.price,
          ),

          _buildStatus(context, booking, state.canManage),

          _buildDateSection(booking),

          _buildPriceSection(booking),

          _buildAmeniticsSection(
            context,
            amenityType: enumListFromStrings(
              booking.amenities,
              AmenityType.values,
            ),
          ),
          const SizedBox(height: UiConstants.spacingSm),

          _buildTagsSection(
            context,
            postTag: enumListFromStrings(booking.tags, PostTag.values),
          ),
          const SizedBox(height: UiConstants.spacingSm),
          _buildOthersDetails(
            context,
            roomType: enumFromString(RoomType.values, booking.roomType),
            area: booking.area,
            capacity: booking.capacity,
          ),
          const SizedBox(height: UiConstants.spacingSm),
          if (booking.notes?.isNotEmpty == true)
            _buildNotesSection(context, booking.notes!),

          const SizedBox(height: UiConstants.spacingLg),

          if (state.canManage) _ManageActions(booking: booking),

          const SizedBox(height: UiConstants.spacingXxl),
        ],
      ),
    ),
  );
}

Widget _buildAmeniticsSection(
  BuildContext context, {
  required List<AmenityType>? amenityType,
}) {
  if (amenityType == null) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.all(UiConstants.spacingSm),
    child: Column(
      children: [
        CustomMultiSelect<AmenityType>(
          label: 'Amenities',
          items: AmenityType.values,
          selected: amenityType,
          itemLabel: (a) => _amenityLabel(a),
          readOnly: true,
          onChanged: null,
        ),
      ],
    ),
  );
}

Widget _buildTagsSection(
  BuildContext context, {
  required List<PostTag>? postTag,
}) {
  if (postTag == null) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.all(UiConstants.spacingSm),
    child: Column(
      children: [
        CustomMultiSelect<PostTag>(
          label: 'Tags',
          items: PostTag.values,
          selected: postTag,
          itemLabel: (p) => _tagLabel(p),
          readOnly: true,
          onChanged: null,
        ),
      ],
    ),
  );
}

Widget _buildOthersDetails(
  BuildContext context, {
  required RoomType? roomType,
  required double? area,
  required int? capacity,
}) {
  if (roomType == null && area == null && capacity == null) {
    return const SizedBox.shrink();
  }
  return Padding(
    padding: const EdgeInsets.all(UiConstants.spacingSm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Others details!!!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: UiConstants.spacingSm),
        if (roomType != null)
          DetailInfoTile(
            icon: Icons.bed,
            title: "Room Type",
            value: roomType.displayName,
          ),
        const SizedBox(height: UiConstants.spacingSm),
        if (area != null)
          DetailInfoTile(
            icon: Icons.square_foot,
            title: "Area",
            value: "$area sqft",
          ),
        const SizedBox(height: UiConstants.spacingSm),
        if (capacity != null)
          DetailInfoTile(
            icon: Icons.people,
            title: "Capacity",
            value: "$capacity guests",
          ),
      ],
    ),
  );
}

String _amenityLabel(AmenityType a) => a.name.replaceAll('_', ' ').capitalize();
String _tagLabel(PostTag p) => p.name.replaceAll('_', ' ').capitalize();

extension StringExt on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}

AmenityType? amenityTypeFromString(String value) {
  try {
    return AmenityType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
    );
  } catch (e) {
    return null; // if string doesn't match any enum
  }
}

_buildNotesSection(BuildContext context, String s) {}

Widget _buildImageCarousel(BuildContext context, BookingDetailsLoaded state) {
  final images = state.allImages;
  return SizedBox(
    height: 400,
    child: Stack(
      children: [
        PageView.builder(
          itemCount: images.length,
          onPageChanged: (i) => context.read<BookingDetailsBloc>().add(
            BookingImageViewRequested(i),
          ),
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => context.read<BookingDetailsBloc>().add(
              BookingFullImageViewRequested(i),
            ),
            child: Image.network(
              images[i],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.black45, Colors.black54],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final currentIndex = state.viewingImageIndex ?? 0;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentIndex == i ? 10 : 4,
                  height: currentIndex == i ? 10 : 4,
                  decoration: BoxDecoration(
                    color: currentIndex == i
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onPrimary,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildTitleAndPriceSection(
  BuildContext context, {
  required String title,
  required double price,
}) {
  return Padding(
    padding: const EdgeInsets.all(UiConstants.spacingSm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Rs.', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '$price',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// Widget _buildStatus(BuildContext context, Booking booking) {
//   return Padding(
//     padding: const EdgeInsets.all(UiConstants.spacingSm),
//     child: Row(
//       children: [
//         Expanded(
//           child: _StatusChip(label: booking.status.name, color: Colors.blue),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: _StatusChip(
//             label: booking.paymentStatus.name,
//             color: Colors.green,
//           ),
//         ),
//       ],
//     ),
//   );
// }

Widget _buildStatus(BuildContext context, Booking booking, bool canManage) {
  final isUser = !canManage; // based on your rule

  return Padding(
    padding: const EdgeInsets.all(UiConstants.spacingSm),
    child: Row(
      children: [
        Expanded(
          child: StatusActionChip<BookingStatus>(
            label: booking.status.name,
            color: getBookingStatusColor(booking.status),
            actions: bookingStatusActions(
              booking: booking,
              canManage: canManage,
              isUser: isUser,
            ),
            onSelected: (status) {
              // dispatch bloc event
              // context.read<BookingDetailsBloc>().add(
              //       BookingStatusUpdateRequested(status),
              //     );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatusActionChip<PaymentStatus>(
            label: booking.paymentStatus.name,
            color: getPaymentStatusColor(booking.paymentStatus),
            actions: paymentStatusActions(canManage: canManage),
            onSelected: (status) {
              // context.read<BookingDetailsBloc>().add(
              //       PaymentStatusUpdateRequested(status),
              //     );
            },
          ),
        ),
      ],
    ),
  );
}

Color getBookingStatusColor(BookingStatus status) {
  switch (status) {
    case BookingStatus.pending:
      return Colors.amber;

    case BookingStatus.confirmed:
      return Colors.teal;

    case BookingStatus.cancelled:
      return Colors.redAccent;

    case BookingStatus.completed:
      return Colors.indigo;
  }
}

Color getPaymentStatusColor(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.pending:
      return Colors.orange;

    case PaymentStatus.paid:
      return Colors.green;

    case PaymentStatus.refunded:
      return Colors.blueGrey;

    case PaymentStatus.failed:
      return Colors.red;
  }
}

class StatusActionChip<T> extends StatelessWidget {
  final String label;
  final Color color;
  final List<StatusAction<T>> actions;
  final ValueChanged<T>? onSelected;

  const StatusActionChip({
    super.key,
    required this.label,
    required this.color,
    required this.actions,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isClickable = actions.isNotEmpty && onSelected != null;

    return SizedBox(
      width: double.infinity,
      child: PopupMenuButton<T>(
        enabled: isClickable,
        onSelected: onSelected,
        itemBuilder: (context) {
          return actions
              .map(
                (a) => PopupMenuItem<T>(
                  value: a.value,
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Icon(a.icon, size: 18, color: a.color),
                        const SizedBox(width: 8),
                        Text(a.label),
                      ],
                    ),
                  ),
                ),
              )
              .toList();
        },
        child: SectionContainer(
          borderRadius: BorderRadius.circular(UiConstants.radiusSm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
              if (isClickable) ...[
                const SizedBox(width: 6),
                Icon(Icons.arrow_drop_down, size: 18, color: color),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class StatusAction<T> {
  final T value;
  final String label;
  final IconData icon;
  final Color color;

  const StatusAction({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}

List<StatusAction<BookingStatus>> bookingStatusActions({
  required Booking booking,
  required bool canManage,
  required bool isUser,
}) {
  // USER: can only cancel
  if (isUser && booking.status == BookingStatus.pending) {
    return [
      const StatusAction(
        value: BookingStatus.cancelled,
        label: 'Cancel Booking',
        icon: Icons.cancel,
        color: Colors.red,
      ),
    ];
  }

  // OWNER / ADMIN
  if (canManage) {
    return [
      if (booking.status == BookingStatus.pending)
        const StatusAction(
          value: BookingStatus.confirmed,
          label: 'Confirm',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
      if (booking.status != BookingStatus.cancelled)
        const StatusAction(
          value: BookingStatus.cancelled,
          label: 'Cancel',
          icon: Icons.cancel,
          color: Colors.red,
        ),
      if (booking.status == BookingStatus.confirmed)
        const StatusAction(
          value: BookingStatus.completed,
          label: 'Mark Completed',
          icon: Icons.done_all,
          color: Colors.blue,
        ),
    ];
  }

  return [];
}

List<StatusAction<PaymentStatus>> paymentStatusActions({
  required bool canManage,
}) {
  if (!canManage) return [];

  return const [
    StatusAction(
      value: PaymentStatus.paid,
      label: 'Mark Paid',
      icon: Icons.payment,
      color: Colors.green,
    ),
    StatusAction(
      value: PaymentStatus.refunded,
      label: 'Refund',
      icon: Icons.undo,
      color: Colors.blueGrey,
    ),
    StatusAction(
      value: PaymentStatus.failed,
      label: 'Failed',
      icon: Icons.error,
      color: Colors.red,
    ),
  ];
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Widget _buildDateSection(Booking booking) {
  return Padding(
    padding: const EdgeInsets.all(UiConstants.spacingSm),
    child: Column(
      children: [
        _InfoRow(
          label: 'Check-in',
          value: DateFormatter.formatWithDay(booking.checkInDate),
        ),
        _InfoRow(
          label: 'Check-out',
          value: DateFormatter.formatWithDay(booking.checkOutDate),
        ),
        _InfoRow(label: 'Nights', value: booking.nights.toString()),
      ],
    ),
  );
}

Widget _buildPriceSection(Booking booking) {
  return Padding(
    padding: const EdgeInsets.all(UiConstants.spacingSm),
    child: Column(
      children: [
        _InfoRow(label: 'Price / Night', value: 'Rs. ${booking.price}'),
        _InfoRow(label: 'Total Amount', value: 'Rs. ${booking.totalAmount}'),
      ],
    ),
  );
}

Widget _buildImageViewer(BuildContext context, BookingDetailsLoaded state) {
  final images = state.allImages;
  final index = state.viewingImageIndex ?? 0;

  return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => context.read<BookingDetailsBloc>().add(
          const BookingImageViewClosed(),
        ),
      ),
      title: Text('${index + 1} / ${images.length}'),
    ),
    body: PageView.builder(
      itemCount: images.length,
      controller: PageController(initialPage: index),
      onPageChanged: (i) =>
          context.read<BookingDetailsBloc>().add(BookingImageViewRequested(i)),
      itemBuilder: (_, i) => InteractiveViewer(
        child: Center(
          child: CachedNetworkImage(
            imageUrl: images[index],
            fit: BoxFit.contain,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                const Center(child: Icon(Icons.error)),
          ),
        ),
      ),
    ),
  );
}

class _BookingDetailsContent extends StatelessWidget {
  final Booking booking;
  final bool canManage;

  const _BookingDetailsContent({
    required this.booking,
    required this.canManage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(booking.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),

          // 🔹 Status
          _InfoRow(label: 'Status', value: booking.status.name.toUpperCase()),
          _InfoRow(
            label: 'Payment',
            value: booking.paymentStatus.name.toUpperCase(),
          ),

          const Divider(height: 32),

          // 🔹 Images
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              booking.primaryImageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Dates
          _InfoRow(
            label: 'Check-in',
            value: DateFormatter.formatWithDay(booking.checkInDate),
          ),
          _InfoRow(
            label: 'Check-out',
            value: DateFormatter.formatWithDay(booking.checkOutDate),
          ),
          _InfoRow(label: 'Nights', value: booking.nights.toString()),

          const Divider(height: 32),

          // 🔹 Pricing
          _InfoRow(
            label: 'Price / Night',
            value: booking.price.toStringAsFixed(2),
          ),
          _InfoRow(
            label: 'Total',
            value: booking.totalAmount.toStringAsFixed(2),
          ),

          if (booking.notes != null && booking.notes!.isNotEmpty) ...[
            const Divider(height: 32),
            Text('Notes', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(booking.notes!),
          ],

          const SizedBox(height: 32),

          // 🔹 Actions
          if (canManage) _ManageActions(booking: booking),
        ],
      ),
    );
  }
}

class _ManageActions extends StatelessWidget {
  final Booking booking;

  const _ManageActions({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Cancel booking
          },
          child: const Text('Cancel Booking'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            // Update booking
          },
          child: const Text('Update Booking'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
