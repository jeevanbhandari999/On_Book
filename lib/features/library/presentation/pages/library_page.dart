// // import 'package:app/app/dependency_injection.dart';
// // import 'package:app/app/router/route_constants.dart';
// // import 'package:app/core/constants/ui_constants.dart';
// // import 'package:app/core/utils/date_formatter.dart';
// // import 'package:app/core/widgets/common_widgets.dart';
// // import 'package:app/core/widgets/loading_widget.dart';
// // import 'package:app/features/auth/services/auth_service.dart';
// // import 'package:app/features/booking/domain/entities/booking.dart';
// // import 'package:app/features/library/domain/entities/library_filter_enum.dart';
// // import 'package:app/features/library/domain/usecases/get_all_booking_by_user_id_use_case.dart';
// // import 'package:app/features/library/domain/usecases/get_all_booking_related_to_organization_use_case.dart';
// // import 'package:app/features/library/domain/usecases/update_booking_status_by_id_use_case.dart';
// // import 'package:app/features/library/presentation/bloc/library_bloc.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:go_router/go_router.dart';

// // class LibraryPage extends StatelessWidget {
// //   const LibraryPage({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     final authDependency = DependencyInjection.get<AuthService>();
// //     final userId = authDependency.getCurrentUserId();

// //     // Handle the future for organizationId
// //     return FutureBuilder<String?>(
// //       future: authDependency
// //           .getCurrentUserOrganizationId(), // The future for organizationId
// //       builder: (context, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           // While waiting for the organizationId to resolve, show a loading widget
// //           return const Center(child: LoadingWidget());
// //         }

// //         if (snapshot.hasError) {
// //           // If there's an error fetching organizationId, handle it here (optional)
// //           return Center(child: Text('Error: ${snapshot.error}'));
// //         }

// //         final organizationId = snapshot.data;
// //         // print(organizationId);

// //         if (userId == null) {
// //           return const Center(child: LoadingWidget());
// //         }

// //         return BlocProvider(
// //           create: (context) =>
// //               LibraryBloc(
// //                 getAllBookingsByUserIdUseCase:
// //                     DependencyInjection.get<GetAllBookingsByUserIdUseCase>(),
// //                 getAllBookingRelatedToOrganizationUseCase:
// //                     DependencyInjection.get<
// //                       GetAllBookingRelatedToOrganizationUseCase
// //                     >(),
// //                 updateBookingStatusByIdUseCase:
// //                     DependencyInjection.get<UpdateBookingStatusByIdUseCase>(),
// //               )..add(
// //                 LoadUserLibrary(userId: userId, organizationId: organizationId),
// //               ),
// //           child: LibraryView(userId: userId, organizationId: organizationId),
// //         );
// //       },
// //     );
// //   }
// // }

// // class LibraryView extends StatelessWidget {
// //   final String userId;
// //   final String? organizationId;
// //   const LibraryView({super.key, required this.userId, this.organizationId});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: BlocBuilder<LibraryBloc, LibraryState>(
// //         builder: (context, state) {
// //           if (state is LibraryLoading) {
// //             return const Center(child: LoadingWidget());
// //           }
// //           if (state is LibraryError) {
// //             return _buildErrorState(state, context);
// //           }
// //           if (state is LibraryLoaded) {
// //             return Column(
// //               children: [
// //                 // Filter tabs
// //                 BlocBuilder<LibraryBloc, LibraryState>(
// //                   builder: (context, state) {
// //                     if (state is! LibraryLoaded) {
// //                       return const SizedBox.shrink();
// //                     }
// //                     final activeFilter = state.activeFilter;
// //                     return Container(
// //                       width: double.infinity,
// //                       padding: const EdgeInsets.fromLTRB(
// //                         UiConstants.spacingLg,
// //                         UiConstants.spacingXxl + UiConstants.spacingSm,
// //                         UiConstants.spacingLg,
// //                         UiConstants.spacingLg,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: Theme.of(context).colorScheme.primary,
// //                         borderRadius: const BorderRadius.vertical(
// //                           bottom: Radius.circular(UiConstants.radiusXl),
// //                         ),
// //                       ),
// //                       child: SizedBox(
// //                         height: 40,
// //                         child: ListView.separated(
// //                           scrollDirection: Axis.horizontal,
// //                           itemCount: LibraryFilter.values.length,
// //                           separatorBuilder: (_, __) =>
// //                               const SizedBox(width: UiConstants.spacingXs),
// //                           itemBuilder: (context, index) {
// //                             final filter = LibraryFilter.values[index];
// //                             final isActive = filter == activeFilter;

// //                             return InkWell(
// //                               borderRadius: BorderRadius.circular(
// //                                 UiConstants.radiusMd,
// //                               ),
// //                               onTap: () {
// //                                 context.read<LibraryBloc>().add(
// //                                   ChangeLibraryFilterTabRequested(
// //                                     filter: filter,
// //                                   ),
// //                                 );
// //                               },
// //                               child: AnimatedContainer(
// //                                 duration: const Duration(milliseconds: 200),
// //                                 padding: const EdgeInsets.symmetric(
// //                                   horizontal: UiConstants.spacingMd,
// //                                 ),
// //                                 decoration: BoxDecoration(
// //                                   color: isActive
// //                                       ? Theme.of(
// //                                           context,
// //                                         ).colorScheme.primaryContainer
// //                                       : Colors.transparent,
// //                                   borderRadius: BorderRadius.circular(
// //                                     UiConstants.radiusMd,
// //                                   ),
// //                                   // border: Border.all(
// //                                   //   color: Theme.of(
// //                                   //     context,
// //                                   //   ).colorScheme.primaryContainer,
// //                                   // ),
// //                                 ),
// //                                 child: Row(
// //                                   mainAxisSize: MainAxisSize.min,
// //                                   children: [
// //                                     if (isActive) ...[
// //                                       const Icon(
// //                                         Icons.check,
// //                                         size: 16,
// //                                         color: Colors.black,
// //                                       ),
// //                                       const SizedBox(width: 6),
// //                                     ],
// //                                     Text(
// //                                       filter.displayName,
// //                                       style: TextStyle(
// //                                         fontSize: 14,
// //                                         fontWeight: isActive
// //                                             ? FontWeight.w600
// //                                             : FontWeight.w500,
// //                                         color: isActive
// //                                             ? Colors.black87
// //                                             : Colors.white,
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             );
// //                           },
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                 ),
// //                 BlocBuilder<LibraryBloc, LibraryState>(
// //                   builder: (context, state) {
// //                     if (state is! LibraryLoaded) {
// //                       return const SizedBox.shrink();
// //                     }
// //                     final filteredBookings = _getFilteredBookings(state);

// //                     return Expanded(
// //                       child: Padding(
// //                         padding: const EdgeInsets.all(UiConstants.spacingMd),
// //                         child: RefreshIndicator(
// //                           onRefresh: () async {
// //                             context.read<LibraryBloc>().add(
// //                               RefreshUserLibrary(
// //                                 userId: userId,
// //                                 organizationId: organizationId,
// //                               ),
// //                             );
// //                             // Wait for refresh to complete
// //                             await context.read<LibraryBloc>().stream.firstWhere(
// //                               (newState) => newState is! LibraryRefreshing,
// //                             );
// //                           },
// //                           child: filteredBookings.isEmpty
// //                               ? _buildEmptyState()
// //                               : ListView.separated(
// //                                   physics:
// //                                       const AlwaysScrollableScrollPhysics(),
// //                                   padding: EdgeInsets.zero,
// //                                   itemCount: filteredBookings.length,
// //                                   separatorBuilder: (_, __) => const SizedBox(
// //                                     height: UiConstants.spacingSm,
// //                                   ),
// //                                   itemBuilder: (context, index) {
// //                                     final booking = filteredBookings[index];
// //                                     return _buildBookingCard(
// //                                       context,
// //                                       booking,
// //                                       isUserBookingOwner:
// //                                           userId == booking.userId,
// //                                       isOrganizationMember:
// //                                           organizationId ==
// //                                           booking.organizationId,
// //                                       isOngoing:
// //                                           state.activeFilter ==
// //                                           LibraryFilter.ongoing,
// //                                       isPast:
// //                                           state.activeFilter ==
// //                                           LibraryFilter.past,
// //                                     );
// //                                   },
// //                                 ),
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                 ),
// //               ],
// //             );
// //           }
// //           return const LoadingWidget();
// //         },
// //       ),
// //     );
// //   }

// //   Center _buildErrorState(LibraryError state, BuildContext context) {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           const Icon(Icons.error_outline, size: 80, color: Colors.grey),
// //           const SizedBox(height: UiConstants.spacingMd),
// //           Text(
// //             state.message,
// //             style: const TextStyle(fontSize: 18, color: Colors.grey),
// //             textAlign: TextAlign.center,
// //           ),
// //           const SizedBox(height: UiConstants.spacingMd),
// //           ElevatedButton(
// //             onPressed: () => context.read<LibraryBloc>().add(
// //               LoadUserLibrary(userId: userId, organizationId: organizationId),
// //             ),
// //             child: const Text('Retry'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Center _buildEmptyState() {
// //     return const Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(Icons.library_books_outlined, size: 100, color: Colors.grey),
// //           SizedBox(height: UiConstants.spacingLg),
// //           Text(
// //             'No bookings yet',
// //             style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
// //           ),
// //           SizedBox(height: UiConstants.spacingSm),
// //           Text(
// //             'Your booking history will appear here',
// //             style: TextStyle(color: Colors.grey, fontSize: 16),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   List<Booking> _getFilteredBookings(LibraryLoaded state) {
// //     switch (state.activeFilter) {
// //       case LibraryFilter.ongoing:
// //         return state.ongoingBookings;

// //       case LibraryFilter.upcoming:
// //         return state.upcomingBookings;

// //       case LibraryFilter.past:
// //         return state.pastBookings;

// //       case LibraryFilter.newBooking:
// //         return state.newBookings;

// //       case LibraryFilter.myBooking:
// //         return state.myBooking;

// //       case LibraryFilter.cancelled:
// //         return state.cancledBookings;

// //       case LibraryFilter.confirmed:
// //         return state.confirmedBookings;

// //       case LibraryFilter.rejected:
// //         return state.rejectedBookings;

// //       case LibraryFilter.recent:
// //         return [];
// //       case LibraryFilter.all:
// //       default:
// //         return [
// //           ...state.ongoingBookings,
// //           ...state.upcomingBookings,
// //           ...state.pastBookings,
// //         ];
// //     }
// //   }

// //   Widget _buildBookingCard(
// //     BuildContext context,
// //     Booking booking, {
// //     required bool isUserBookingOwner,
// //     required bool isOrganizationMember,
// //     bool isOngoing = false,
// //     bool isPast = false,
// //   }) {
// //     final statusColor = _getStatusColor(booking.status);

// //     return SectionContainer(
// //       padding: const EdgeInsets.all(UiConstants.spacingSm),
// //       child: InkWell(
// //         borderRadius: BorderRadius.circular(UiConstants.radiusMd),
// //         onTap: () {
// //           context.push(
// //             RouteConstants.bookingDetailsPage,
// //             extra: {'userId': userId, 'bookingId': booking.id},
// //           );
// //         },
// //         child: Padding(
// //           padding: const EdgeInsets.all(UiConstants.spacingSm),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Row(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   // Primary Image
// //                   ClipRRect(
// //                     borderRadius: BorderRadius.circular(UiConstants.radiusSm),
// //                     child: booking.primaryImageUrl.isNotEmpty
// //                         ? Image.network(
// //                             booking.primaryImageUrl,
// //                             width: 100,
// //                             height: 100,
// //                             fit: BoxFit.cover,
// //                           )
// //                         : Container(
// //                             width: 100,
// //                             height: 100,
// //                             color: Colors.grey[300],
// //                             child: const Icon(
// //                               Icons.hotel,
// //                               size: 50,
// //
// //                             ),
// //                           ),
// //                   ),
// //                   const SizedBox(width: UiConstants.spacingMd),

// //                   // Details
// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           booking.title,
// //                           style: const TextStyle(fontWeight: FontWeight.bold),
// //                           maxLines: 1,
// //                           overflow: TextOverflow.ellipsis,
// //                         ),
// //                         Text(
// //                           booking.description ?? '',
// //                           maxLines: 2,
// //                           overflow: TextOverflow.ellipsis,
// //                         ),
// //                         Text(
// //                           DateFormatter.range(
// //                             booking.checkInDate,
// //                             booking.checkOutDate,
// //                           ),
// //                           style: const TextStyle(fontSize: 15),
// //                         ),
// //                         const SizedBox(height: 4),
// //                         Text(
// //                           '${booking.nights} Night${booking.nights > 1 ? 's' : ''} • Rs.${booking.totalAmount}',
// //                           style: TextStyle(
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.w600,
// //                             color: Theme.of(context).colorScheme.primary,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),

// //                   _BookingActionMenu(
// //                     booking: booking,
// //                     isUserBookingOwner: isUserBookingOwner,
// //                     isOrganizationMember: isOrganizationMember,
// //                   ),
// //                 ],
// //               ),

// //               const SizedBox(height: UiConstants.spacingSm),

// //               // Status Chips & Date
// //               Row(
// //                 children: [
// //                   Chip(
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadiusGeometry.circular(
// //                         UiConstants.radiusSm,
// //                       ),
// //                     ),
// //                     label: BlocBuilder<LibraryBloc, LibraryState>(
// //                       builder: (context, state) {
// //                         if (state is UpdatingBookingStatusFromLibraryPage) {
// //                           return const CircularProgressIndicator();
// //                         }
// //                         return Text(
// //                           booking.status.name.toUpperCase(),
// //                           style: const TextStyle(
// //                             color: Colors.white,
// //                             fontSize: 12,
// //                           ),
// //                         );
// //                       },
// //                     ),
// //                     backgroundColor: statusColor,
// //                     padding: const EdgeInsets.symmetric(horizontal: 8),
// //                   ),
// //                   if (!isOngoing) ...[
// //                     const SizedBox(width: 8),
// //                     Chip(
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadiusGeometry.circular(
// //                           UiConstants.radiusSm,
// //                         ),
// //                       ),
// //                       label: const Text(
// //                         'ONGOING',
// //                         style: TextStyle(fontSize: 12),
// //                       ),
// //                       backgroundColor: Colors.orange,
// //                     ),
// //                   ],
// //                   if (isPast && booking.status == BookingStatus.cancelled) ...[
// //                     const SizedBox(width: 8),
// //                     Chip(
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadiusGeometry.circular(
// //                           UiConstants.radiusSm,
// //                         ),
// //                       ),
// //                       label: const Text(
// //                         'CANCELLED',
// //                         style: TextStyle(fontSize: 12),
// //                       ),
// //                       backgroundColor: Colors.red,
// //                     ),
// //                   ],
// //                 ],
// //               ),
// //               Text(
// //                 'Booked ${DateFormatter.format(booking.createdAt)}',
// //                 style: const TextStyle(fontSize: 13),
// //                 overflow: TextOverflow.ellipsis,
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Color _getStatusColor(BookingStatus status) {
// //     switch (status) {
// //       case BookingStatus.pending:
// //         return Colors.orange;
// //       case BookingStatus.confirmed:
// //         return Colors.green;
// //       case BookingStatus.cancelled:
// //         return Colors.red;
// //       case BookingStatus.rejected:
// //         return Colors.red;
// //       case BookingStatus.completed:
// //         return Colors.blue;
// //     }
// //   }
// // }

// // class _BookingActionMenu extends StatelessWidget {
// //   final Booking booking;
// //   final bool isUserBookingOwner;
// //   final bool isOrganizationMember;

// //   const _BookingActionMenu({
// //     required this.booking,
// //     required this.isUserBookingOwner,
// //     required this.isOrganizationMember,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return BlocBuilder<LibraryBloc, LibraryState>(
// //       builder: (context, state) {
// //         final isUpdating = state is UpdatingBookingStatusFromLibraryPage;
// //         return PopupMenuButton<_BookingAction>(
// //           enabled: !isUpdating,
// //           icon: isUpdating
// //               ? const SizedBox(
// //                   width: 20,
// //                   height: 20,
// //                   child: CircularProgressIndicator(strokeWidth: 2),
// //                 )
// //               : const Icon(Icons.more_vert, size: 20),
// //           itemBuilder: (context) {
// //             final items = <PopupMenuEntry<_BookingAction>>[];

// //             // User related action
// //             if (isUserBookingOwner && booking.status == BookingStatus.pending) {
// //               items.add(
// //                 PopupMenuItem(
// //                   value: _BookingAction.cancel,
// //                   child: Row(
// //                     key: ValueKey(booking.status.name),
// //                     children: const [
// //                       Icon(Icons.close, size: 18, color: Colors.red),
// //                       SizedBox(width: 8),
// //                       Text('Cancel Booking'),
// //                     ],
// //                   ),
// //                 ),
// //               );
// //             }

// //             // Organization related action
// //             if (isOrganizationMember) {
// //               if (booking.status == BookingStatus.pending) {
// //                 items.add(
// //                   PopupMenuItem(
// //                     value: _BookingAction.confirm,
// //                     child: Row(
// //                       key: ValueKey(booking.status.name),
// //                       children: const [
// //                         Icon(Icons.check_circle, size: 18, color: Colors.green),
// //                         SizedBox(width: 8),
// //                         Text('Confirm Booking'),
// //                       ],
// //                     ),
// //                   ),
// //                 );
// //               }
// //               items.add(
// //                 PopupMenuItem(
// //                   value: _BookingAction.updatePayment,
// //                   child: Row(
// //                     key: ValueKey(booking.status.name),
// //                     children: const [
// //                       Icon(
// //                         Icons.currency_exchange,
// //                         size: 18,
// //                         color: Colors.blue,
// //                       ),
// //                       SizedBox(width: 8),
// //                       Text('Update Payment'),
// //                     ],
// //                   ),
// //                 ),
// //               );
// //               items.add(
// //                 PopupMenuItem(
// //                   value: _BookingAction.reject,
// //                   child: Row(
// //                     key: ValueKey(booking.status.name),
// //                     children: const [
// //                       Icon(Icons.do_not_disturb, size: 18, color: Colors.red),
// //                       SizedBox(width: 8),
// //                       Text('Reject Booking'),
// //                     ],
// //                   ),
// //                 ),
// //               );
// //             }

// //             return items;
// //           },
// //           onSelected: (action) {
// //             _handleBookingAction(context, action, booking);
// //           },
// //         );
// //       },
// //     );
// //   }

// //   void _handleBookingAction(
// //     BuildContext context,
// //     _BookingAction action,
// //     Booking booking,
// //   ) {
// //     switch (action) {
// //       case _BookingAction.confirm:
// //         context.read<LibraryBloc>().add(
// //           UpdateBookingStatusFromLibraryPage(
// //             bookingId: booking.id,
// //             status: BookingStatus.confirmed.name,
// //           ),
// //         );
// //         break;

// //       case _BookingAction.cancel:
// //         context.read<LibraryBloc>().add(
// //           UpdateBookingStatusFromLibraryPage(
// //             bookingId: booking.id,
// //             status: BookingStatus.cancelled.name,
// //           ),
// //         );
// //         break;
// //       case _BookingAction.reject:
// //         context.read<LibraryBloc>().add(
// //           UpdateBookingStatusFromLibraryPage(
// //             bookingId: booking.id,
// //             status: BookingStatus.rejected.name,
// //           ),
// //         );
// //         break;
// //       case _BookingAction.updatePayment:
// //         break;
// //     }
// //   }
// // }

// // enum _BookingAction { confirm, cancel, reject, updatePayment }

// import 'package:app/app/dependency_injection.dart';
// import 'package:app/app/router/route_constants.dart';
// import 'package:app/core/constants/ui_constants.dart';
// import 'package:app/core/utils/date_formatter.dart';
// import 'package:app/core/widgets/common_widgets.dart';
// import 'package:app/core/widgets/loading_widget.dart';
// import 'package:app/features/auth/services/auth_service.dart';
// import 'package:app/features/booking/domain/entities/booking.dart';
// import 'package:app/features/library/domain/entities/library_filter_enum.dart';
// import 'package:app/features/library/domain/usecases/get_all_booking_by_user_id_use_case.dart';
// import 'package:app/features/library/domain/usecases/get_all_booking_related_to_organization_use_case.dart';
// import 'package:app/features/library/domain/usecases/get_all_saved_posts_use_case.dart';
// import 'package:app/features/library/domain/usecases/update_booking_status_by_id_use_case.dart';
// import 'package:app/features/library/presentation/bloc/library_bloc.dart';
// import 'package:app/features/post/domain/entities/post.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';

// class LibraryPage extends StatelessWidget {
//   const LibraryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authDependency = DependencyInjection.get<AuthService>();
//     final userId = authDependency.getCurrentUserId();

//     return FutureBuilder<String?>(
//       future: authDependency.getCurrentUserOrganizationId(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: LoadingWidget());
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         final organizationId = snapshot.data;

//         if (userId == null) {
//           return const Center(child: LoadingWidget());
//         }

//         return BlocProvider(
//           create: (context) =>
//               LibraryBloc(
//                 getAllBookingsByUserIdUseCase:
//                     DependencyInjection.get<GetAllBookingsByUserIdUseCase>(),
//                 getAllBookingRelatedToOrganizationUseCase:
//                     DependencyInjection.get<
//                       GetAllBookingRelatedToOrganizationUseCase
//                     >(),
//                 updateBookingStatusByIdUseCase:
//                     DependencyInjection.get<UpdateBookingStatusByIdUseCase>(),
//                 getAllSavedPostsUseCase:
//                     DependencyInjection.get<GetAllSavedPostsUseCase>(),
//               )..add(
//                 LoadUserLibrary(userId: userId, organizationId: organizationId),
//               ),
//           child: LibraryView(userId: userId, organizationId: organizationId),
//         );
//       },
//     );
//   }
// }

// class LibraryView extends StatelessWidget {
//   final String userId;
//   final String? organizationId;

//   const LibraryView({super.key, required this.userId, this.organizationId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocBuilder<LibraryBloc, LibraryState>(
//         builder: (context, state) {
//           if (state is LibraryLoading) {
//             return const Center(child: LoadingWidget());
//           }

//           if (state is LibraryError) {
//             return _buildErrorState(state, context);
//           }

//           if (state is LibraryLoaded) {
//             return Column(
//               children: [
//                 _LibraryFilterTabs(activeFilter: state.activeFilter),
//                 Expanded(
//                   child: _LibraryContent(
//                     userId: userId,
//                     organizationId: organizationId,
//                     state: state,
//                   ),
//                 ),
//               ],
//             );
//           }

//           return const LoadingWidget();
//         },
//       ),
//     );
//   }

//   Widget _buildErrorState(LibraryError state, BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.error_outline, size: 80, color: Colors.grey),
//           const SizedBox(height: UiConstants.spacingMd),
//           Text(
//             state.message,
//             style: const TextStyle(fontSize: 18, color: Colors.grey),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: UiConstants.spacingMd),
//           ElevatedButton(
//             onPressed: () => context.read<LibraryBloc>().add(
//               LoadUserLibrary(userId: userId, organizationId: organizationId),
//             ),
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _LibraryFilterTabs extends StatelessWidget {
//   final LibraryFilter activeFilter;

//   const _LibraryFilterTabs({required this.activeFilter});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(
//         UiConstants.spacingLg,
//         UiConstants.spacingXxl + UiConstants.spacingSm,
//         UiConstants.spacingLg,
//         UiConstants.spacingLg,
//       ),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.primary,
//         borderRadius: const BorderRadius.vertical(
//           bottom: Radius.circular(UiConstants.radiusXl),
//         ),
//       ),
//       child: SizedBox(
//         height: 40,
//         child: ListView.separated(
//           scrollDirection: Axis.horizontal,
//           itemCount: LibraryFilter.values.length,
//           separatorBuilder: (_, __) =>
//               const SizedBox(width: UiConstants.spacingXs),
//           itemBuilder: (context, index) {
//             final filter = LibraryFilter.values[index];
//             final isActive = filter == activeFilter;
//             return _FilterChip(
//               filter: filter,
//               isActive: isActive,
//               onTap: () {
//                 context.read<LibraryBloc>().add(
//                   ChangeLibraryFilterTabRequested(filter: filter),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class _FilterChip extends StatelessWidget {
//   final LibraryFilter filter;
//   final bool isActive;
//   final VoidCallback onTap;

//   const _FilterChip({
//     required this.filter,
//     required this.isActive,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(UiConstants.radiusMd),
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: UiConstants.spacingMd),
//         decoration: BoxDecoration(
//           color: isActive
//               ? Theme.of(context).colorScheme.primaryContainer
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(UiConstants.radiusMd),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (isActive) ...[
//               const Icon(Icons.check, size: 16, color: Colors.black),
//               const SizedBox(width: 6),
//             ],
//             Text(
//               filter.displayName,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
//                 color: isActive ? Colors.black87 : Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _LibraryContent extends StatelessWidget {
//   final String userId;
//   final String? organizationId;
//   final LibraryLoaded state;

//   const _LibraryContent({
//     required this.userId,
//     required this.organizationId,
//     required this.state,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//       onRefresh: () async {
//         context.read<LibraryBloc>().add(
//           RefreshUserLibrary(userId: userId, organizationId: organizationId),
//         );
//         await context.read<LibraryBloc>().stream.firstWhere(
//           (newState) => newState is! LibraryRefreshing,
//         );
//       },
//       child: _buildContentByFilter(userId),
//     );
//   }

//   Widget _buildContentByFilter(String userId) {
//     // Handle saved posts filter
//     if (state.activeFilter == LibraryFilter.saved) {
//       return _SavedPostsList(
//         savedPostsData: state.savedPostsData,
//         userId: userId,
//       );
//     }

//     // Handle booking-related filters
//     return _BookingsList(
//       userId: userId,
//       organizationId: organizationId,
//       activeFilter: state.activeFilter,
//       bookingsData: state.bookingsData,
//     );
//   }
// }

// class _SavedPostsList extends StatelessWidget {
//   final SavedPostsData savedPostsData;
//   final String userId;

//   const _SavedPostsList({required this.savedPostsData, required this.userId});

//   @override
//   Widget build(BuildContext context) {
//     if (savedPostsData.isLoading) {
//       return const Center(child: LoadingWidget());
//     }

//     if (!savedPostsData.hasSavedPosts) {
//       return const _EmptyState(
//         icon: Icons.bookmark_border,
//         title: 'No saved posts',
//         subtitle: 'Posts you save will appear here',
//       );
//     }

//     return Padding(
//       padding: const EdgeInsets.all(UiConstants.spacingMd),
//       child: ListView.separated(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: EdgeInsets.zero,
//         itemCount: savedPostsData.savedPosts.length,
//         separatorBuilder: (_, __) =>
//             const SizedBox(height: UiConstants.spacingSm),
//         itemBuilder: (context, index) {
//           final post = savedPostsData.savedPosts[index];
//           return _SavedPostCard(post: post, userId: userId);
//         },
//       ),
//     );
//   }
// }

// class _SavedPostCard extends StatelessWidget {
//   final Post post;
//   final String userId;

//   const _SavedPostCard({required this.post, required this.userId});

//   @override
//   Widget build(BuildContext context) {
//     return SectionContainer(
//       padding: const EdgeInsets.all(UiConstants.spacingSm),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(UiConstants.radiusMd),
//         onTap: () {
//           // Navigate to post details
//           context.push(
//             RouteConstants.postDetailsPage,
//             extra: {'postId': post.id, 'post': post, 'userId': userId},
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(UiConstants.spacingSm),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (post.primaryImageUrl != null &&
//                       post.primaryImageUrl!.isNotEmpty)
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(UiConstants.radiusSm),
//                       child: Image.network(
//                         post.primaryImageUrl!,
//                         width: 100,
//                         height: 100,
//                         fit: BoxFit.cover,
//                       ),
//                     )
//                   else
//                     Container(
//                       width: 100,
//                       height: 100,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(
//                           UiConstants.radiusSm,
//                         ),
//                       ),
//                       child: const Icon(
//                         Icons.article,
//                         size: 50,
//
//                       ),
//                     ),
//                   const SizedBox(width: UiConstants.spacingMd),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           post.title ?? 'Untitled Post',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         if (post.description != null) ...[
//                           const SizedBox(height: 4),
//                           Text(
//                             post.description!,
//                             maxLines: 3,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(fontSize: 14),
//                           ),
//                         ],
//                         const SizedBox(height: 4),
//                         Text(
//                           'Saved ${DateFormatter.format(post.createdAt)}',
//                           style: const TextStyle(
//                             fontSize: 12,
//
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _BookingsList extends StatelessWidget {
//   final String userId;
//   final String? organizationId;
//   final LibraryFilter activeFilter;
//   final BookingsData bookingsData;

//   const _BookingsList({
//     required this.userId,
//     required this.organizationId,
//     required this.activeFilter,
//     required this.bookingsData,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final filteredBookings = _getFilteredBookings();

//     if (filteredBookings.isEmpty) {
//       return const _EmptyState(
//         icon: Icons.library_books_outlined,
//         title: 'No bookings yet',
//         subtitle: 'Your booking history will appear here',
//       );
//     }

//     return Padding(
//       padding: const EdgeInsets.all(UiConstants.spacingMd),
//       child: ListView.separated(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: EdgeInsets.zero,
//         itemCount: filteredBookings.length,
//         separatorBuilder: (_, __) =>
//             const SizedBox(height: UiConstants.spacingSm),
//         itemBuilder: (context, index) {
//           final booking = filteredBookings[index];
//           return _BookingCard(
//             userId: userId,
//             organizationId: organizationId,
//             booking: booking,
//             isUserBookingOwner: userId == booking.userId,
//             isOrganizationMember: organizationId == booking.organizationId,
//             isOngoing: activeFilter == LibraryFilter.ongoing,
//             isPast: activeFilter == LibraryFilter.past,
//             isUpdating: bookingsData.isLoading,
//           );
//         },
//       ),
//     );
//   }

//   List<Booking> _getFilteredBookings() {
//     switch (activeFilter) {
//       case LibraryFilter.ongoing:
//         return bookingsData.ongoingBookings;
//       case LibraryFilter.upcoming:
//         return bookingsData.upcomingBookings;
//       case LibraryFilter.past:
//         return bookingsData.pastBookings;
//       case LibraryFilter.newBooking:
//         return bookingsData.newBookings;
//       case LibraryFilter.myBooking:
//         return bookingsData.myBooking;
//       case LibraryFilter.cancelled:
//         return bookingsData.cancelledBookings;
//       case LibraryFilter.confirmed:
//         return bookingsData.confirmedBookings;
//       case LibraryFilter.rejected:
//         return bookingsData.rejectedBookings;
//       case LibraryFilter.saved:
//         return [];
//       case LibraryFilter.recent:
//         return [];
//       case LibraryFilter.all:
//       default:
//         return bookingsData.allBookings;
//     }
//   }
// }

// class _EmptyState extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;

//   const _EmptyState({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 100, color: Colors.grey),
//           const SizedBox(height: UiConstants.spacingLg),
//           Text(
//             title,
//             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: UiConstants.spacingSm),
//           Text(
//             subtitle,
//             style: const TextStyle(color: Colors.grey, fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _BookingCard extends StatelessWidget {
//   final String userId;
//   final String? organizationId;
//   final Booking booking;
//   final bool isUserBookingOwner;
//   final bool isOrganizationMember;
//   final bool isOngoing;
//   final bool isPast;
//   final bool isUpdating;

//   const _BookingCard({
//     required this.userId,
//     required this.organizationId,
//     required this.booking,
//     required this.isUserBookingOwner,
//     required this.isOrganizationMember,
//     required this.isOngoing,
//     required this.isPast,
//     required this.isUpdating,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final statusColor = _getStatusColor(booking.status);

//     return SectionContainer(
//       padding: const EdgeInsets.all(UiConstants.spacingSm),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(UiConstants.radiusMd),
//         onTap: () {
//           context.push(
//             RouteConstants.bookingDetailsPage,
//             extra: {'userId': userId, 'bookingId': booking.id},
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(UiConstants.spacingSm),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(UiConstants.radiusSm),
//                     child: booking.primaryImageUrl.isNotEmpty
//                         ? Image.network(
//                             booking.primaryImageUrl,
//                             width: 100,
//                             height: 100,
//                             fit: BoxFit.cover,
//                           )
//                         : Container(
//                             width: 100,
//                             height: 100,
//                             color: Colors.grey[300],
//                             child: const Icon(
//                               Icons.hotel,
//                               size: 50,
//
//                             ),
//                           ),
//                   ),
//                   const SizedBox(width: UiConstants.spacingMd),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           booking.title,
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         if (booking.description != null)
//                           Text(
//                             booking.description!,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         Text(
//                           DateFormatter.range(
//                             booking.checkInDate,
//                             booking.checkOutDate,
//                           ),
//                           style: const TextStyle(fontSize: 15),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           '${booking.nights} Night${booking.nights > 1 ? 's' : ''} • Rs.${booking.totalAmount}',
//                           style: TextStyle(
//                             // fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Theme.of(context).colorScheme.primary,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   _BookingActionMenu(
//                     booking: booking,
//                     isUserBookingOwner: isUserBookingOwner,
//                     isOrganizationMember: isOrganizationMember,
//                     isUpdating: isUpdating,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: UiConstants.spacingSm),
//               Row(
//                 children: [
//                   Chip(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(UiConstants.radiusSm),
//                     ),
//                     label: Text(
//                       booking.status.name.toUpperCase(),
//                       style: const TextStyle(color: Colors.white, fontSize: 12),
//                     ),
//                     backgroundColor: statusColor,
//                     padding: const EdgeInsets.symmetric(horizontal: 8),
//                   ),
//                   if (isOngoing) ...[
//                     const SizedBox(width: 8),
//                     Chip(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                           UiConstants.radiusSm,
//                         ),
//                       ),
//                       label: const Text(
//                         'ONGOING',
//                         style: TextStyle(fontSize: 12, color: Colors.white),
//                       ),
//                       backgroundColor: Colors.orange,
//                     ),
//                   ],
//                   if (isPast && booking.status == BookingStatus.cancelled) ...[
//                     const SizedBox(width: 8),
//                     Chip(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                           UiConstants.radiusSm,
//                         ),
//                       ),
//                       label: const Text(
//                         'CANCELLED',
//                         style: TextStyle(fontSize: 12, color: Colors.white),
//                       ),
//                       backgroundColor: Colors.red,
//                     ),
//                   ],
//                 ],
//               ),
//               Text(
//                 'Booked ${DateFormatter.format(booking.createdAt)}',
//                 style: const TextStyle(fontSize: 13),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getStatusColor(BookingStatus status) {
//     switch (status) {
//       case BookingStatus.pending:
//         return Colors.orange;
//       case BookingStatus.confirmed:
//         return Colors.green;
//       case BookingStatus.cancelled:
//         return Colors.red;
//       case BookingStatus.rejected:
//         return Colors.red;
//       case BookingStatus.completed:
//         return Colors.blue;
//     }
//   }
// }

// class _BookingActionMenu extends StatelessWidget {
//   final Booking booking;
//   final bool isUserBookingOwner;
//   final bool isOrganizationMember;
//   final bool isUpdating;

//   const _BookingActionMenu({
//     required this.booking,
//     required this.isUserBookingOwner,
//     required this.isOrganizationMember,
//     required this.isUpdating,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton<_BookingAction>(
//       enabled: !isUpdating,
//       icon: isUpdating
//           ? const SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(strokeWidth: 2),
//             )
//           : const Icon(Icons.more_vert, size: 20),
//       itemBuilder: (context) {
//         final items = <PopupMenuEntry<_BookingAction>>[];

//         if (isUserBookingOwner && booking.status == BookingStatus.pending) {
//           items.add(
//             const PopupMenuItem(
//               value: _BookingAction.cancel,
//               child: Row(
//                 children: [
//                   Icon(Icons.close, size: 18, color: Colors.red),
//                   SizedBox(width: 8),
//                   Text('Cancel Booking'),
//                 ],
//               ),
//             ),
//           );
//         }

//         if (isOrganizationMember) {
//           if (booking.status == BookingStatus.pending) {
//             items.add(
//               const PopupMenuItem(
//                 value: _BookingAction.confirm,
//                 child: Row(
//                   children: [
//                     Icon(Icons.check_circle, size: 18, color: Colors.green),
//                     SizedBox(width: 8),
//                     Text('Confirm Booking'),
//                   ],
//                 ),
//               ),
//             );
//           }
//           items.add(
//             const PopupMenuItem(
//               value: _BookingAction.updatePayment,
//               child: Row(
//                 children: [
//                   Icon(Icons.currency_exchange, size: 18, color: Colors.blue),
//                   SizedBox(width: 8),
//                   Text('Update Payment'),
//                 ],
//               ),
//             ),
//           );
//           items.add(
//             const PopupMenuItem(
//               value: _BookingAction.reject,
//               child: Row(
//                 children: [
//                   Icon(Icons.do_not_disturb, size: 18, color: Colors.red),
//                   SizedBox(width: 8),
//                   Text('Reject Booking'),
//                 ],
//               ),
//             ),
//           );
//         }

//         return items;
//       },
//       onSelected: (action) => _handleBookingAction(context, action),
//     );
//   }

//   void _handleBookingAction(BuildContext context, _BookingAction action) {
//     switch (action) {
//       case _BookingAction.confirm:
//         context.read<LibraryBloc>().add(
//           UpdateBookingStatusFromLibraryPage(
//             bookingId: booking.id,
//             status: BookingStatus.confirmed.name,
//           ),
//         );
//         break;
//       case _BookingAction.cancel:
//         context.read<LibraryBloc>().add(
//           UpdateBookingStatusFromLibraryPage(
//             bookingId: booking.id,
//             status: BookingStatus.cancelled.name,
//           ),
//         );
//         break;
//       case _BookingAction.reject:
//         context.read<LibraryBloc>().add(
//           UpdateBookingStatusFromLibraryPage(
//             bookingId: booking.id,
//             status: BookingStatus.rejected.name,
//           ),
//         );
//         break;
//       case _BookingAction.updatePayment:
//         // Handle payment update navigation
//         break;
//     }
//   }
// }

// enum _BookingAction { confirm, cancel, reject, updatePayment }

// import 'package:app/app/dependency_injection.dart';
// import 'package:app/app/router/route_constants.dart';
// import 'package:app/core/constants/ui_constants.dart';
// import 'package:app/core/utils/date_formatter.dart';
// import 'package:app/core/widgets/common_widgets.dart';
// import 'package:app/features/auth/services/auth_service.dart';
// import 'package:app/features/booking/domain/entities/booking.dart';
// import 'package:app/features/library/domain/entities/library_filter_enum.dart';
// import 'package:app/features/library/domain/usecases/get_all_booking_by_user_id_use_case.dart';
// import 'package:app/features/library/domain/usecases/get_all_booking_related_to_organization_use_case.dart';
// import 'package:app/features/library/domain/usecases/get_all_saved_posts_use_case.dart';
// import 'package:app/features/library/domain/usecases/update_booking_status_by_id_use_case.dart';
// import 'package:app/features/library/presentation/bloc/library_bloc.dart';
// import 'package:app/features/library/presentation/widgets/library_shimmer.dart';
// import 'package:app/features/post/domain/entities/post.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';

// class LibraryPage extends StatelessWidget {
//   const LibraryPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authDependency = DependencyInjection.get<AuthService>();
//     final userId = authDependency.getCurrentUserId();

//     return FutureBuilder<String?>(
//       future: authDependency.getCurrentUserOrganizationId(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const LibraryShimmer();
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         final organizationId = snapshot.data;

//         if (userId == null) {
//           return const LibraryShimmer();
//         }

//         return BlocProvider(
//           create: (context) =>
//               LibraryBloc(
//                 getAllBookingsByUserIdUseCase:
//                     DependencyInjection.get<GetAllBookingsByUserIdUseCase>(),
//                 getAllBookingRelatedToOrganizationUseCase:
//                     DependencyInjection.get<
//                       GetAllBookingRelatedToOrganizationUseCase
//                     >(),
//                 updateBookingStatusByIdUseCase:
//                     DependencyInjection.get<UpdateBookingStatusByIdUseCase>(),
//                 getAllSavedPostsUseCase:
//                     DependencyInjection.get<GetAllSavedPostsUseCase>(),
//               )..add(
//                 LoadUserLibrary(userId: userId, organizationId: organizationId),
//               ),
//           child: LibraryView(userId: userId, organizationId: organizationId),
//         );
//       },
//     );
//   }
// }

// class LibraryView extends StatelessWidget {
//   final String userId;
//   final String? organizationId;

//   const LibraryView({super.key, required this.userId, this.organizationId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocBuilder<LibraryBloc, LibraryState>(
//         builder: (context, state) {
//           if (state is LibraryLoading) {
//             return const LibraryShimmer();
//           }
//           if (state is LibraryError) {
//             return _buildErrorState(state, context);
//           }
//           if (state is LibraryLoaded) {
//             return Column(
//               children: [
//                 _LibraryFilterTabs(activeFilter: state.activeFilter),
//                 Expanded(
//                   child: _LibraryContent(
//                     userId: userId,
//                     organizationId: organizationId,
//                     state: state,
//                   ),
//                 ),
//               ],
//             );
//           }
//           return const LibraryShimmer();
//         },
//       ),
//     );
//   }

//   Widget _buildErrorState(LibraryError state, BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.error_outline, size: 80, color: Colors.grey),
//           const SizedBox(height: UiConstants.spacingMd),
//           Text(
//             state.message,
//             style: const TextStyle(fontSize: 18, color: Colors.grey),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: UiConstants.spacingMd),
//           ElevatedButton(
//             onPressed: () => context.read<LibraryBloc>().add(
//               LoadUserLibrary(userId: userId, organizationId: organizationId),
//             ),
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _LibraryFilterTabs extends StatelessWidget {
//   final LibraryFilter activeFilter;

//   const _LibraryFilterTabs({required this.activeFilter});

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Positioned.fill(
//           child:
//               Container(
//                     padding: const EdgeInsets.fromLTRB(
//                       UiConstants.spacingLg,
//                       UiConstants.spacingXxl + UiConstants.spacingSm,
//                       UiConstants.spacingLg,
//                       UiConstants.spacingLg,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).colorScheme.primary,
//                       borderRadius: const BorderRadius.vertical(
//                         bottom: Radius.circular(UiConstants.radiusXl),
//                       ),
//                     ),
//                   )
//                   .animate()
//                   .slideY(
//                     begin: -2,
//                     duration: UiConstants.animationSlow,
//                     curve: Curves.easeOutCubic,
//                   )
//                   .fadeIn(duration: UiConstants.animationSlow),
//         ),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.fromLTRB(
//             UiConstants.spacingLg,
//             UiConstants.spacingXxl + UiConstants.spacingSm,
//             UiConstants.spacingLg,
//             UiConstants.spacingLg,
//           ),

//           child: SizedBox(
//             height: 40,
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               itemCount: LibraryFilter.values.length,
//               separatorBuilder: (_, __) =>
//                   const SizedBox(width: UiConstants.spacingXs),
//               itemBuilder: (context, index) {
//                 final filter = LibraryFilter.values[index];
//                 final isActive = filter == activeFilter;

//                 return _FilterChip(
//                   filter: filter,
//                   isActive: isActive,
//                   onTap: () {
//                     context.read<LibraryBloc>().add(
//                       ChangeLibraryFilterTabRequested(filter: filter),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _FilterChip extends StatelessWidget {
//   final LibraryFilter filter;
//   final bool isActive;
//   final VoidCallback onTap;

//   const _FilterChip({
//     required this.filter,
//     required this.isActive,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(UiConstants.radiusMd),
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: UiConstants.spacingMd),
//         decoration: BoxDecoration(
//           color: isActive
//               ? Theme.of(context).colorScheme.primaryContainer
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(UiConstants.radiusMd),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (isActive) ...[
//               const Icon(Icons.check, size: 16, color: Colors.black),
//               const SizedBox(width: 6),
//             ],
//             Text(
//               filter.displayName,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
//                 color: isActive ? Colors.black87 : Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _LibraryContent extends StatelessWidget {
//   final String userId;
//   final String? organizationId;
//   final LibraryLoaded state;

//   const _LibraryContent({
//     required this.userId,
//     required this.organizationId,
//     required this.state,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//       onRefresh: () async {
//         context.read<LibraryBloc>().add(
//           RefreshUserLibrary(userId: userId, organizationId: organizationId),
//         );
//         await context.read<LibraryBloc>().stream.firstWhere(
//           (newState) => newState is! LibraryRefreshing,
//         );
//       },
//       child: _buildContentByFilter(),
//     );
//   }

//   Widget _buildContentByFilter() {
//     // Handle saved posts filter
//     if (state.activeFilter == LibraryFilter.saved) {
//       return _SavedPostsList(
//         savedPostsData: state.savedPostsData,
//         userId: userId,
//       );
//     }

//     // Handle booking-related filters
//     return _BookingsList(
//       userId: userId,
//       organizationId: organizationId,
//       activeFilter: state.activeFilter,
//       bookingsData: state.bookingsData,
//     );
//   }
// }

// class _SavedPostsList extends StatelessWidget {
//   final SavedPostsData savedPostsData;
//   final String userId;

//   const _SavedPostsList({required this.savedPostsData, required this.userId});

//   @override
//   Widget build(BuildContext context) {
//     if (!savedPostsData.hasSavedPosts) {
//       return const _EmptyState(
//         icon: Icons.bookmark_border,
//         title: 'No saved posts',
//         subtitle: 'Posts you save will appear here',
//       );
//     }

//     return Padding(
//       padding: const EdgeInsets.all(UiConstants.spacingMd),
//       child: ListView.separated(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: EdgeInsets.zero,
//         itemCount: savedPostsData.savedPosts.length,
//         separatorBuilder: (_, __) =>
//             const SizedBox(height: UiConstants.spacingSm),
//         itemBuilder: (context, index) {
//           final post = savedPostsData.savedPosts[index];
//           return _SavedPostCard(post: post, userId: userId);
//         },
//       ),
//     );
//   }
// }

// class _SavedPostCard extends StatelessWidget {
//   final Post post;
//   final String userId;

//   const _SavedPostCard({required this.post, required this.userId});

//   @override
//   Widget build(BuildContext context) {
//     return SectionContainer(
//       padding: const EdgeInsets.all(UiConstants.spacingSm),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(UiConstants.radiusMd),
//         onTap: () {
//           // Navigate to post details
//           context.push(
//             RouteConstants.postDetailsPage,
//             extra: {'postId': post.id, 'post': post, 'userId': userId},
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(UiConstants.spacingSm),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (post.primaryImageUrl.isNotEmpty)
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(UiConstants.radiusSm),
//                       child: Image.network(
//                         post.primaryImageUrl,
//                         width: 100,
//                         height: 100,
//                         fit: BoxFit.cover,
//                       ),
//                     )
//                   else
//                     Container(
//                       width: 100,
//                       height: 100,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(
//                           UiConstants.radiusSm,
//                         ),
//                       ),
//                       child: const Icon(
//                         Icons.article,
//                         size: 50,
//
//                       ),
//                     ),
//                   const SizedBox(width: UiConstants.spacingMd),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           post.title,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         if (post.description != null) ...[
//                           const SizedBox(height: 4),
//                           Text(
//                             post.description!,
//                             maxLines: 3,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(fontSize: 14),
//                           ),
//                         ],
//                         const SizedBox(height: 4),
//                         Text(
//                           'Saved ${DateFormatter.format(post.createdAt)}',
//                           style: const TextStyle(
//                             fontSize: 12,
//
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _BookingsList extends StatelessWidget {
//   final String userId;
//   final String? organizationId;
//   final LibraryFilter activeFilter;
//   final BookingsData bookingsData;

//   const _BookingsList({
//     required this.userId,
//     required this.organizationId,
//     required this.activeFilter,
//     required this.bookingsData,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final filteredBookings = _getFilteredBookings();

//     if (filteredBookings.isEmpty) {
//       return const _EmptyState(
//         icon: Icons.library_books_outlined,
//         title: 'No bookings yet',
//         subtitle: 'Your booking history will appear here',
//       );
//     }

//     return Padding(
//       padding: const EdgeInsets.all(UiConstants.spacingMd),
//       child: ListView.separated(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: EdgeInsets.zero,
//         itemCount: filteredBookings.length,
//         separatorBuilder: (_, __) =>
//             const SizedBox(height: UiConstants.spacingSm),
//         itemBuilder: (context, index) {
//           final booking = filteredBookings[index];
//           return _BookingCard(
//             userId: userId,
//             organizationId: organizationId,
//             booking: booking,
//             isUserBookingOwner: userId == booking.userId,
//             isOrganizationMember: organizationId == booking.organizationId,
//             isOngoing: activeFilter == LibraryFilter.ongoing,
//             isPast: activeFilter == LibraryFilter.past,
//             isUpdating: bookingsData.isBookingUpdating(booking.id),
//           );
//         },
//       ),
//     );
//   }

//   List<Booking> _getFilteredBookings() {
//     switch (activeFilter) {
//       case LibraryFilter.ongoing:
//         return bookingsData.ongoingBookings;
//       case LibraryFilter.upcoming:
//         return bookingsData.upcomingBookings;
//       case LibraryFilter.past:
//         return bookingsData.pastBookings;
//       case LibraryFilter.newBooking:
//         return bookingsData.newBookings;
//       case LibraryFilter.myBooking:
//         return bookingsData.myBooking;
//       case LibraryFilter.cancelled:
//         return bookingsData.cancelledBookings;
//       case LibraryFilter.confirmed:
//         return bookingsData.confirmedBookings;
//       case LibraryFilter.rejected:
//         return bookingsData.rejectedBookings;
//       case LibraryFilter.saved:
//         return [];
//       case LibraryFilter.recent:
//         return [];
//       case LibraryFilter.all:
//         return bookingsData.allBookings;
//     }
//   }
// }

// class _EmptyState extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;

//   const _EmptyState({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 100, color: Colors.grey),
//           const SizedBox(height: UiConstants.spacingLg),
//           Text(
//             title,
//             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: UiConstants.spacingSm),
//           Text(
//             subtitle,
//             style: const TextStyle(color: Colors.grey, fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _BookingCard extends StatelessWidget {
//   final String userId;
//   final String? organizationId;
//   final Booking booking;
//   final bool isUserBookingOwner;
//   final bool isOrganizationMember;
//   final bool isOngoing;
//   final bool isPast;
//   final bool isUpdating;

//   const _BookingCard({
//     required this.userId,
//     required this.organizationId,
//     required this.booking,
//     required this.isUserBookingOwner,
//     required this.isOrganizationMember,
//     required this.isOngoing,
//     required this.isPast,
//     required this.isUpdating,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final statusColor = _getStatusColor(booking.status);

//     return SectionContainer(
//       padding: const EdgeInsets.all(UiConstants.spacingSm),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(UiConstants.radiusMd),
//         onTap: () {
//           context.push(
//             RouteConstants.bookingDetailsPage,
//             extra: {'userId': userId, 'bookingId': booking.id},
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(UiConstants.spacingSm),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(UiConstants.radiusSm),
//                     child: booking.primaryImageUrl.isNotEmpty
//                         ? Image.network(
//                             booking.primaryImageUrl,
//                             width: 100,
//                             height: 100,
//                             fit: BoxFit.cover,
//                           )
//                         : Container(
//                             width: 100,
//                             height: 100,
//                             color: Colors.grey[300],
//                             child: const Icon(
//                               Icons.hotel,
//                               size: 50,
//
//                             ),
//                           ),
//                   ),
//                   const SizedBox(width: UiConstants.spacingMd),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           booking.title,
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         if (booking.description != null)
//                           Text(
//                             booking.description!,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         Text(
//                           DateFormatter.range(
//                             booking.checkInDate,
//                             booking.checkOutDate,
//                           ),
//                           style: const TextStyle(fontSize: 15),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           '${booking.nights} Night${booking.nights > 1 ? 's' : ''} • Rs.${booking.totalAmount}',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Theme.of(context).colorScheme.primary,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   _BookingActionMenu(
//                     booking: booking,
//                     isUserBookingOwner: isUserBookingOwner,
//                     isOrganizationMember: isOrganizationMember,
//                     isUpdating: isUpdating,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: UiConstants.spacingSm),
//               Row(
//                 children: [
//                   Chip(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(UiConstants.radiusSm),
//                     ),
//                     label: Text(
//                       booking.status.name.toUpperCase(),
//                       style: const TextStyle(color: Colors.white, fontSize: 12),
//                     ),
//                     backgroundColor: statusColor,
//                     padding: const EdgeInsets.symmetric(horizontal: 8),
//                   ),
//                   if (isOngoing) ...[
//                     const SizedBox(width: 8),
//                     Chip(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                           UiConstants.radiusSm,
//                         ),
//                       ),
//                       label: const Text(
//                         'ONGOING',
//                         style: TextStyle(fontSize: 12, color: Colors.white),
//                       ),
//                       backgroundColor: Colors.orange,
//                     ),
//                   ],
//                   if (isPast && booking.status == BookingStatus.cancelled) ...[
//                     const SizedBox(width: 8),
//                     Chip(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                           UiConstants.radiusSm,
//                         ),
//                       ),
//                       label: const Text(
//                         'CANCELLED',
//                         style: TextStyle(fontSize: 12, color: Colors.white),
//                       ),
//                       backgroundColor: Colors.red,
//                     ),
//                   ],
//                 ],
//               ),
//               Text(
//                 'Booked ${DateFormatter.format(booking.createdAt)}',
//                 style: const TextStyle(fontSize: 13),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getStatusColor(BookingStatus status) {
//     switch (status) {
//       case BookingStatus.pending:
//         return Colors.orange;
//       case BookingStatus.confirmed:
//         return Colors.green;
//       case BookingStatus.cancelled:
//         return Colors.red;
//       case BookingStatus.rejected:
//         return Colors.red;
//       case BookingStatus.completed:
//         return Colors.blue;
//     }
//   }
// }

// class _BookingActionMenu extends StatelessWidget {
//   final Booking booking;
//   final bool isUserBookingOwner;
//   final bool isOrganizationMember;
//   final bool isUpdating;

//   const _BookingActionMenu({
//     required this.booking,
//     required this.isUserBookingOwner,
//     required this.isOrganizationMember,
//     required this.isUpdating,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton<_BookingAction>(
//       enabled: !isUpdating,
//       icon: isUpdating
//           ? const SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(strokeWidth: 2),
//             )
//           : const Icon(Icons.more_vert, size: 20),
//       itemBuilder: (context) {
//         final items = <PopupMenuEntry<_BookingAction>>[];

//         if (isUserBookingOwner && booking.status == BookingStatus.pending) {
//           items.add(
//             const PopupMenuItem(
//               value: _BookingAction.cancel,
//               child: Row(
//                 children: [
//                   Icon(Icons.close, size: 18, color: Colors.red),
//                   SizedBox(width: 8),
//                   Text('Cancel Booking'),
//                 ],
//               ),
//             ),
//           );
//         }

//         if (isOrganizationMember) {
//           if (booking.status == BookingStatus.pending) {
//             items.add(
//               const PopupMenuItem(
//                 value: _BookingAction.confirm,
//                 child: Row(
//                   children: [
//                     Icon(Icons.check_circle, size: 18, color: Colors.green),
//                     SizedBox(width: 8),
//                     Text('Confirm Booking'),
//                   ],
//                 ),
//               ),
//             );
//           }
//           items.add(
//             const PopupMenuItem(
//               value: _BookingAction.updatePayment,
//               child: Row(
//                 children: [
//                   Icon(Icons.currency_exchange, size: 18, color: Colors.blue),
//                   SizedBox(width: 8),
//                   Text('Update Payment'),
//                 ],
//               ),
//             ),
//           );
//           items.add(
//             const PopupMenuItem(
//               value: _BookingAction.reject,
//               child: Row(
//                 children: [
//                   Icon(Icons.do_not_disturb, size: 18, color: Colors.red),
//                   SizedBox(width: 8),
//                   Text('Reject Booking'),
//                 ],
//               ),
//             ),
//           );
//         }

//         return items;
//       },
//       onSelected: (action) => _handleBookingAction(context, action),
//     );
//   }

//   void _handleBookingAction(BuildContext context, _BookingAction action) {
//     switch (action) {
//       case _BookingAction.confirm:
//         context.read<LibraryBloc>().add(
//           UpdateBookingStatusFromLibraryPage(
//             bookingId: booking.id,
//             status: BookingStatus.confirmed.name,
//           ),
//         );
//         break;
//       case _BookingAction.cancel:
//         context.read<LibraryBloc>().add(
//           UpdateBookingStatusFromLibraryPage(
//             bookingId: booking.id,
//             status: BookingStatus.cancelled.name,
//           ),
//         );
//         break;
//       case _BookingAction.reject:
//         context.read<LibraryBloc>().add(
//           UpdateBookingStatusFromLibraryPage(
//             bookingId: booking.id,
//             status: BookingStatus.rejected.name,
//           ),
//         );
//         break;
//       case _BookingAction.updatePayment:
//         // Handle payment update navigation
//         break;
//     }
//   }
// }

// enum _BookingAction { confirm, cancel, reject, updatePayment }

import 'package:app/app/dependency_injection.dart';
import 'package:app/app/router/route_constants.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/utils/date_formatter.dart';
import 'package:app/core/widgets/app_bar_popup_menu.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/auth/services/auth_service.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/library/domain/entities/library_filter_enum.dart';
import 'package:app/features/library/domain/usecases/get_all_booking_by_user_id_use_case.dart';
import 'package:app/features/library/domain/usecases/get_all_booking_related_to_organization_use_case.dart';
import 'package:app/features/library/domain/usecases/get_all_saved_posts_use_case.dart';
import 'package:app/features/library/domain/usecases/update_booking_status_by_id_use_case.dart';
import 'package:app/features/library/presentation/bloc/library_bloc.dart';
import 'package:app/features/library/presentation/widgets/library_shimmer.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authDependency = DependencyInjection.get<AuthService>();
    final userId = authDependency.getCurrentUserId();

    return FutureBuilder<String?>(
      future: authDependency.getCurrentUserOrganizationId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LibraryShimmer();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final organizationId = snapshot.data;
        if (userId == null) return const LibraryShimmer();

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
                getAllSavedPostsUseCase:
                    DependencyInjection.get<GetAllSavedPostsUseCase>(),
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
          if (state is LibraryLoading) return const LibraryShimmer();
          if (state is LibraryError) return _buildErrorState(state, context);
          if (state is LibraryLoaded) {
            return Column(
              children: [
                _LibraryFilterTabs(activeFilter: state.activeFilter),
                Expanded(
                  child: _LibraryContent(
                    userId: userId,
                    organizationId: organizationId,
                    state: state,
                  ),
                ),
              ],
            );
          }
          return const LibraryShimmer();
        },
      ),
    );
  }

  Widget _buildErrorState(LibraryError state, BuildContext context) {
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
}

// =============================================================================
// FILTER TABS
// =============================================================================

class _LibraryFilterTabs extends StatelessWidget {
  final LibraryFilter activeFilter;

  const _LibraryFilterTabs({required this.activeFilter});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child:
              Container(
                    padding: const EdgeInsets.fromLTRB(
                      UiConstants.spacingLg,
                      UiConstants.spacingXxl + UiConstants.spacingSm,
                      UiConstants.spacingLg,
                      UiConstants.spacingLg,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(UiConstants.radiusXl),
                      ),
                    ),
                  )
                  .animate()
                  .slideY(
                    begin: -2,
                    duration: UiConstants.animationSlow,
                    curve: Curves.easeOutCubic,
                  )
                  .fadeIn(duration: UiConstants.animationSlow),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            UiConstants.spacingLg,
            UiConstants.spacingXxl + UiConstants.spacingSm,
            UiConstants.spacingLg,
            UiConstants.spacingLg,
          ),
          child: SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: LibraryFilter.values.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: UiConstants.spacingXs),
              itemBuilder: (context, index) {
                final filter = LibraryFilter.values[index];
                final isActive = filter == activeFilter;
                return _FilterChip(
                  filter: filter,
                  isActive: isActive,
                  onTap: () => context.read<LibraryBloc>().add(
                    ChangeLibraryFilterTabRequested(filter: filter),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final LibraryFilter filter;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.filter,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(UiConstants.radiusMd),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: UiConstants.spacingMd),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(UiConstants.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive) ...[
              const Icon(Icons.check, size: 16, color: Colors.black),
              const SizedBox(width: 6),
            ],
            Text(
              filter.displayName,
              style: TextStyle(
                fontSize: isActive ? 16 : 14,
                color: isActive ? Colors.black87 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// CONTENT
// =============================================================================

class _LibraryContent extends StatelessWidget {
  final String userId;
  final String? organizationId;
  final LibraryLoaded state;

  const _LibraryContent({
    required this.userId,
    required this.organizationId,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<LibraryBloc>().add(
          RefreshUserLibrary(userId: userId, organizationId: organizationId),
        );
        await context.read<LibraryBloc>().stream.firstWhere(
          (s) => s is! LibraryRefreshing,
        );
      },
      child: state.activeFilter == LibraryFilter.saved
          ? _SavedPostsList(
              savedPostsData: state.savedPostsData,
              userId: userId,
            )
          : _BookingsList(
              userId: userId,
              organizationId: organizationId,
              activeFilter: state.activeFilter,
              bookingsData: state.bookingsData,
            ),
    );
  }
}

// =============================================================================
// SAVED POSTS
// =============================================================================

class _SavedPostsList extends StatelessWidget {
  final SavedPostsData savedPostsData;
  final String userId;

  const _SavedPostsList({required this.savedPostsData, required this.userId});

  @override
  Widget build(BuildContext context) {
    if (!savedPostsData.hasSavedPosts) {
      return const _EmptyState(
        icon: Icons.bookmark_border,
        title: 'No saved posts',
        subtitle: 'Posts you save will appear here',
      );
    }

    return Padding(
      padding: const EdgeInsets.all(UiConstants.spacingMd),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: savedPostsData.savedPosts.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: UiConstants.spacingSm),
        itemBuilder: (context, index) {
          final post = savedPostsData.savedPosts[index];
          return _SavedPostCard(post: post, userId: userId);
        },
      ),
    );
  }
}

class _SavedPostCard extends StatelessWidget {
  final Post post;
  final String userId;

  const _SavedPostCard({required this.post, required this.userId});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      padding: const EdgeInsets.all(UiConstants.spacingSm),
      borderRadius: BorderRadius.circular(UiConstants.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(UiConstants.radiusMd),
        onTap: () => context.push(
          RouteConstants.postDetailsPage,
          extra: {'postId': post.id, 'post': post, 'userId': userId},
        ),
        child: Padding(
          padding: const EdgeInsets.all(UiConstants.spacingSm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(UiConstants.radiusSm),
                child: post.primaryImageUrl.isNotEmpty
                    ? Image.network(
                        post.primaryImageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.article, size: 50),
                      ),
              ),
              const SizedBox(width: UiConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (post.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        post.description!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Saved ${DateFormatter.format(post.createdAt)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// BOOKINGS LIST
// =============================================================================

class _BookingsList extends StatelessWidget {
  final String userId;
  final String? organizationId;
  final LibraryFilter activeFilter;
  final BookingsData bookingsData;

  const _BookingsList({
    required this.userId,
    required this.organizationId,
    required this.activeFilter,
    required this.bookingsData,
  });

  List<Booking> get _filteredBookings {
    switch (activeFilter) {
      case LibraryFilter.ongoing:
        return bookingsData.ongoingBookings;
      case LibraryFilter.upcoming:
        return bookingsData.upcomingBookings;
      case LibraryFilter.past:
        return bookingsData.pastBookings;
      case LibraryFilter.newBooking:
        return bookingsData.newBookings;
      case LibraryFilter.myBooking:
        return bookingsData.myBooking;
      case LibraryFilter.cancelled:
        return bookingsData.cancelledBookings;
      case LibraryFilter.confirmed:
        return bookingsData.confirmedBookings;
      case LibraryFilter.rejected:
        return bookingsData.rejectedBookings;
      case LibraryFilter.all:
        return bookingsData.allBookings;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _filteredBookings;

    if (bookings.isEmpty) {
      return const _EmptyState(
        icon: Icons.library_books_outlined,
        title: 'No bookings yet',
        subtitle: 'Your booking history will appear here',
      );
    }

    return Padding(
      padding: const EdgeInsets.all(UiConstants.spacingMd),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: bookings.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: UiConstants.spacingSm),
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _BookingCard(
            userId: userId,
            organizationId: organizationId,
            booking: booking,
            isUserBookingOwner: userId == booking.userId,
            isOrganizationMember: organizationId == booking.organizationId,
            isOngoing: activeFilter == LibraryFilter.ongoing,
            isPast: activeFilter == LibraryFilter.past,
            isUpdating: bookingsData.isBookingUpdating(booking.id),
          );
        },
      ),
    );
  }
}

// =============================================================================
// BOOKING CARD
// =============================================================================

class _BookingCard extends StatelessWidget {
  final String userId;
  final String? organizationId;
  final Booking booking;
  final bool isUserBookingOwner;
  final bool isOrganizationMember;
  final bool isOngoing;
  final bool isPast;
  final bool isUpdating;

  const _BookingCard({
    required this.userId,
    required this.organizationId,
    required this.booking,
    required this.isUserBookingOwner,
    required this.isOrganizationMember,
    required this.isOngoing,
    required this.isPast,
    required this.isUpdating,
  });

  /// nights == 0 → hourly booking (stored convention from CreateBookingUseCase)
  bool get _isHourly => booking.nights == 0;

  /// Human-readable duration label:
  ///   Hourly → "2h 30m  •  14:00 → 16:30"
  ///   Nightly → "3 Nights"  /  "1 Night"
  String get _durationLabel {
    if (_isHourly) {
      final diff = booking.checkOutDate.difference(booking.checkInDate);
      // diff might be 1 day (the +1d DB trick) — derive real hours from totalAmount
      // totalAmount = (price/24) * hours  →  hours = totalAmount / (price/24)
      final realHours = booking.price > 0
          ? (booking.totalAmount / (booking.price / 24.0))
          : diff.inMinutes / 60.0;

      final h = realHours.floor();
      final m = ((realHours - h) * 60).round();

      if (m == 0) return '${h}h stay';
      return '${h}h ${m}m stay';
    }
    final n = booking.nights;
    return '$n Night${n == 1 ? '' : 's'}';
  }

  /// Time range shown only for hourly bookings: "2:00 PM → 5:30 PM"
  /// We can't recover the exact check-in time from a DATE column,
  /// so we only show this when the booking has real time data (future improvement).
  /// For now show the date range for nightly and a clock icon for hourly.
  String get _dateRangeLabel {
    if (_isHourly) {
      // The DB stored check_in_date = actual day, check_out_date = day+1 (convention)
      // So just show the check-in date for hourly
      return DateFormatter.format(booking.checkInDate);
    }
    return DateFormatter.range(booking.checkInDate, booking.checkOutDate);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);
    final chips = booking.buildStatusChips(
      isHourly: _isHourly,
      isOngoing: isOngoing,
      isPast: isPast,
    );

    return Stack(
      children: [
        SectionContainer(
          borderRadius: BorderRadius.circular(UiConstants.radiusMd),
          child: InkWell(
            borderRadius: BorderRadius.circular(UiConstants.radiusMd),
            onTap: () => context.push(
              RouteConstants.bookingDetailsPage,
              extra: {'userId': userId, 'bookingId': booking.id},
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(UiConstants.radiusSm),
                      child: booking.primaryImageUrl.isNotEmpty
                          ? Image.network(
                              booking.primaryImageUrl,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 90,
                              height: 90,
                              color: Colors.grey[300],
                              child: const Icon(Icons.hotel, size: 40),
                            ),
                    ),
                    const SizedBox(width: UiConstants.spacingMd),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Padding(
                            padding: const EdgeInsets.only(
                              right: UiConstants.spacingLg,
                            ),
                            child: Text(
                              booking.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (booking.description != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              booking.description!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                          const SizedBox(height: 6),

                          // Date range row
                          Row(
                            children: [
                              Icon(
                                _isHourly
                                    ? Icons.schedule_rounded
                                    : Icons.calendar_today_rounded,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _dateRangeLabel,
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Duration + price row
                          Row(
                            children: [
                              // Booking type badge
                              _BookingTypeBadge(isHourly: _isHourly),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$_durationLabel  •  Rs.${booking.totalAmount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: UiConstants.spacingSm),

                // ── Bottom row: status chips + booked-at ──
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: chips.map((chip) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: _StatusChip(
                                label: chip.label,
                                color: chip.color,
                              ),
                            );
                          }).toList(),
                          //  [
                          //   _StatusChip(
                          //     label: booking.status.name,
                          //     color: statusColor,
                          //   ),
                          //   if (_isHourly) ...[
                          //     const SizedBox(width: 6),
                          //     const _StatusChip(
                          //       label: 'HOURLY',
                          //       color: Color(0xFFEA580C),
                          //     ),
                          //   ],
                          //   if (isOngoing) ...[
                          //     const SizedBox(width: 6),
                          //     const _StatusChip(
                          //       label: 'ONGOING',
                          //       color: Colors.orange,
                          //     ),
                          //   ],
                          //   if (isPast &&
                          //       booking.status != BookingStatus.cancelled) ...[
                          //     const SizedBox(width: 6),
                          //     const _StatusChip(
                          //       label: 'EXPIRED',
                          //       color: Colors.red,
                          //     ),
                          //   ],
                          // ],
                        ),
                      ),
                    ),

                    const SizedBox(width: UiConstants.spacingMd),
                    Text(
                      'Booked ${DateFormatter.format(booking.createdAt)}',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: _BookingActionMenu(
            booking: booking,
            isUserBookingOwner: isUserBookingOwner,
            isOrganizationMember: isOrganizationMember,
            isUpdating: isUpdating,
          ),
        ),
      ],
    );
  }

  Color _statusColor(BookingStatus status) {
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

// =============================================================================
// SMALL REUSABLE WIDGETS
// =============================================================================

/// Orange "⚡ Hourly" or blue "🌙 Nightly" pill
class _BookingTypeBadge extends StatelessWidget {
  final bool isHourly;
  const _BookingTypeBadge({required this.isHourly});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isHourly ? const Color(0xFFFFF7ED) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHourly ? const Color(0xFFFED7AA) : const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isHourly ? Icons.bolt_rounded : Icons.nights_stay_rounded,
            size: 11,
            color: isHourly ? const Color(0xFFEA580C) : const Color(0xFF2563EB),
          ),
          const SizedBox(width: 3),
          Text(
            isHourly ? 'Hourly' : 'Nightly',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isHourly
                  ? const Color(0xFFEA580C)
                  : const Color(0xFF2563EB),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(UiConstants.radiusSm),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Colors.grey),
          const SizedBox(height: UiConstants.spacingLg),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: UiConstants.spacingSm),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _BookingActionMenu extends StatelessWidget {
  final Booking booking;
  final bool isUserBookingOwner;
  final bool isOrganizationMember;
  final bool isUpdating;

  const _BookingActionMenu({
    required this.booking,
    required this.isUserBookingOwner,
    required this.isOrganizationMember,
    required this.isUpdating,
  });

  @override
  Widget build(BuildContext context) {
    final items = <AppPopupMenuItem>[];

    /// 🔹 User can cancel if pending
    if (isUserBookingOwner && booking.status == BookingStatus.pending) {
      items.add(
        AppPopupMenuItem(
          value: 'cancel',
          label: 'Cancel Booking',
          icon: Icons.close,
          isDistructive: true,
          onTap: () => _handleAction(context, 'cancel'),
        ),
      );
    }

    /// 🔹 Organization actions
    if (isOrganizationMember) {
      if (booking.status == BookingStatus.pending) {
        items.add(
          AppPopupMenuItem(
            value: 'confirm',
            label: 'Confirm Booking',
            icon: Icons.check_circle,
            onTap: () => _handleAction(context, 'confirm'),
          ),
        );
      }

      items.add(
        AppPopupMenuItem(
          value: 'updatePayment',
          label: 'Update Payment',
          icon: Icons.currency_exchange,
          onTap: () => _handleAction(context, 'updatePayment'),
        ),
      );

      items.add(
        AppPopupMenuItem(
          value: 'reject',
          label: 'Reject Booking',
          icon: Icons.do_not_disturb,
          isDistructive: true,
          onTap: () => _handleAction(context, 'reject'),
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return AppPopupMenu(items: items, isLoading: isUpdating);
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'cancel':
        context.read<LibraryBloc>().add(
          UpdateBookingStatusFromLibraryPage(
            bookingId: booking.id,
            status: BookingStatus.cancelled.name,
          ),
        );
        break;
      case 'confirm':
        context.read<LibraryBloc>().add(
          UpdateBookingStatusFromLibraryPage(
            bookingId: booking.id,
            status: BookingStatus.confirmed.name,
          ),
        );
        break;
      case 'updatePayment':
        // TODO
        // call update payment
        break;
      case 'reject':
        context.read<LibraryBloc>().add(
          UpdateBookingStatusFromLibraryPage(
            bookingId: booking.id,
            status: BookingStatus.rejected.name,
          ),
        );
        break;
    }
  }
}

// void _handleAction(BuildContext context, _BookingAction action) {
//   switch (action) {
//     case _BookingAction.confirm:
//       context.read<LibraryBloc>().add(
//         UpdateBookingStatusFromLibraryPage(
//           bookingId: booking.id,
//           status: BookingStatus.confirmed.name,
//         ),
//       );
//     case _BookingAction.cancel:
//       context.read<LibraryBloc>().add(
//         UpdateBookingStatusFromLibraryPage(
//           bookingId: booking.id,
//           status: BookingStatus.cancelled.name,
//         ),
//       );
//     case _BookingAction.reject:
//       context.read<LibraryBloc>().add(
//         UpdateBookingStatusFromLibraryPage(
//           bookingId: booking.id,
//           status: BookingStatus.rejected.name,
//         ),
//       );
//     case _BookingAction.updatePayment:
//       break;
//   }
// }

// enum _BookingAction { confirm, cancel, reject, updatePayment }

class BookingStatusChipData {
  final String label;
  final Color color;

  const BookingStatusChipData({required this.label, required this.color});
}

extension BookingStatusUI on Booking {
  List<BookingStatusChipData> buildStatusChips({
    required bool isHourly,
    required bool isOngoing,
    required bool isPast,
  }) {
    final chips = <BookingStatusChipData>[];

    /// 1️⃣ Main booking status
    chips.add(_mapPrimaryStatus());

    /// 2️⃣ Booking type
    if (isHourly) {
      chips.add(
        const BookingStatusChipData(label: 'HOURLY', color: Color(0xFFEA580C)),
      );
    } else {
      chips.add(
        const BookingStatusChipData(label: 'NIGHTLY', color: Colors.blue),
      );
    }

    /// 3️⃣ Time-based state
    if (isOngoing) {
      chips.add(
        const BookingStatusChipData(label: 'ONGOING', color: Colors.orange),
      );
    }

    if (isPast &&
        status != BookingStatus.cancelled &&
        status != BookingStatus.completed) {
      chips.add(
        const BookingStatusChipData(label: 'EXPIRED', color: Colors.red),
      );
    }

    return chips;
  }

  BookingStatusChipData _mapPrimaryStatus() {
    switch (status) {
      case BookingStatus.pending:
        return const BookingStatusChipData(
          label: 'PENDING',
          color: Colors.amber,
        );
      case BookingStatus.confirmed:
        return const BookingStatusChipData(
          label: 'CONFIRMED',
          color: Colors.green,
        );
      case BookingStatus.cancelled:
        return const BookingStatusChipData(
          label: 'CANCELLED',
          color: Colors.red,
        );
      case BookingStatus.rejected:
        return const BookingStatusChipData(
          label: 'REJECTED',
          color: Colors.red,
        );
      case BookingStatus.completed:
        return const BookingStatusChipData(
          label: 'COMPLETED',
          color: Colors.grey,
        );
    }
  }
}
