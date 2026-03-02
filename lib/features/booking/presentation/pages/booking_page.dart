// import 'package:app/app/dependency_injection.dart';
// import 'package:app/core/constants/ui_constants.dart';
// import 'package:app/core/utils/date_formatter.dart';
// import 'package:app/core/widgets/common_widgets.dart';
// import 'package:app/core/widgets/custom_drop_down.dart';
// import 'package:app/core/widgets/loading_widget.dart';
// import 'package:app/features/booking/domain/entities/booking.dart';
// import 'package:app/features/booking/domain/entities/payment_enums.dart';
// import 'package:app/features/booking/domain/usecases/create_booking_use_case.dart';
// import 'package:app/features/booking/presentation/bloc/booking_bloc.dart';
// import 'package:app/features/booking/presentation/widgets/booking_posst_summary.dart';
// import 'package:app/features/post/domain/entities/post.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class BookingFormScreen extends StatelessWidget {
//   final String userId;
//   final String postId;
//   final Post? post;
//   final Booking? existingBooking; // null = create, not null = edit

//   const BookingFormScreen({
//     super.key,
//     required this.userId,
//     required this.postId,
//     this.post,
//     this.existingBooking,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) =>
//           BookingFormBloc(
//             createBookingUseCase:
//                 DependencyInjection.get<CreateBookingUseCase>(),
//           )..add(
//             BookingFormInitialized(
//               userId: userId,
//               postId: postId,
//               existingBooking: existingBooking,
//             ),
//           ),
//       child: BookingFormView(
//         userId: userId,
//         postId: postId,
//         post: post,
//         existingBooking: existingBooking,
//       ),
//     );
//   }
// }

// class BookingFormView extends StatelessWidget {
//   final String userId;
//   final String postId;
//   final Post? post;
//   final Booking? existingBooking; // null = create, not null = edit

//   const BookingFormView({
//     super.key,
//     required this.userId,
//     required this.postId,
//     this.post,
//     this.existingBooking,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           existingBooking == null ? 'Create Booking' : 'Manage Booking',
//         ),
//       ),
//       body: BlocConsumer<BookingFormBloc, BookingFormState>(
//         listener: (context, state) {
//           if (state is BookingFormSuccess) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.green,
//               ),
//             );
//           } else if (state is BookingFormError) {
//             print(state.message);
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         },
//         builder: (context, state) {
//           if (state is BookingFormLoading || state is BookingFormInitial) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (state is BookingFormSuccess) {
//             return _buildSuccessView(context, state.booking, state.wasEdit);
//           }
//           if (state is BookingFormReady) {
//             return _buildForm(context, state);
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }

//   Widget _buildForm(BuildContext context, BookingFormReady state) {
//     final isEditMode = state.isEditMode;
//     final hasErrors = state.validationErrors.isNotEmpty;

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(UiConstants.spacingSm),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Personal details for showing the user details
//           if (!isEditMode) ...[
//             SectionContainer(
//               child: Container(
//                 width: double.infinity,
//                 decoration: const BoxDecoration(),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const Align(
//                       alignment: Alignment.topLeft,
//                       child: Text(
//                         'Personal Details',
//                         style: TextStyle(fontSize: 20),
//                       ),
//                     ),
//                     // Profile Picture of the user
//                     ClipOval(
//                       child: CircleAvatar(
//                         radius: 34,
//                         child: Container(
//                           child:
//                               (state.user.imageUrl != null &&
//                                   state.user.imageUrl!.isNotEmpty)
//                               ? CachedNetworkImage(
//                                   imageUrl: state.user.imageUrl!,
//                                   width: double.infinity,
//                                   height: double.infinity,
//                                   fit: BoxFit.cover,
//                                 )
//                               : Center(
//                                   child: Text(
//                                     _getInitialCharactrOfOrganization(
//                                       state.user.fullName,
//                                     ),
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white,
//                                       fontSize: 24,
//                                     ),
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: UiConstants.spacingMd),
//                     Row(
//                       children: [
//                         const Expanded(child: Text('Full Name')),
//                         Expanded(
//                           child: Text(
//                             state.user.fullName,
//                             textAlign: TextAlign.left,
//                             style: const TextStyle(fontSize: 18),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: UiConstants.spacingSm),
//                     Row(
//                       children: [
//                         const Expanded(child: Text('Phone')),
//                         Expanded(
//                           child: Text(
//                             state.user.phone ?? 'Not Added',
//                             textAlign: TextAlign.left,
//                             style: const TextStyle(fontSize: 18),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: UiConstants.spacingSm),

//                     Row(
//                       children: [
//                         const Expanded(child: Text('email')),
//                         Expanded(
//                           child: Text(
//                             state.user.fullName,
//                             textAlign: TextAlign.left,
//                             style: const TextStyle(fontSize: 18),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: UiConstants.spacingSm),

//                     Row(
//                       children: [
//                         const Expanded(child: Text('address')),
//                         Expanded(
//                           child: Text(
//                             state.user.address ?? 'Not provided',
//                             textAlign: TextAlign.left,
//                             style: const TextStyle(fontSize: 18),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: UiConstants.spacingSm),
//             // Post details to book
//             if (post != null) BookingPostSummary(post: post!),
//             const SizedBox(height: UiConstants.spacingSm),
//             // Booking details
//             SectionContainer(
//               child: SizedBox(
//                 width: double.infinity,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Align(
//                       alignment: Alignment.topLeft,
//                       child: Text(
//                         'Booking Details',
//                         style: TextStyle(fontSize: 20),
//                       ),
//                     ),
//                     ListTile(
//                       contentPadding: EdgeInsets.zero,
//                       title: const Text('Check-in Date'),
//                       subtitle: Text(
//                         DateFormatter.formatWithDay(state.checkInDate),
//                       ),
//                       trailing: const Icon(Icons.calendar_today),
//                       onTap: () =>
//                           _selectDate(context, true, state.checkInDate),
//                     ),
//                     // Check-out Date
//                     ListTile(
//                       contentPadding: EdgeInsets.zero,
//                       title: const Text('Check-out Date'),
//                       subtitle: Text(
//                         DateFormatter.formatWithDay(state.checkOutDate),
//                       ),
//                       trailing: const Icon(Icons.calendar_today),
//                       onTap: () =>
//                           _selectDate(context, false, state.checkOutDate),
//                     ),
//                     const SizedBox(height: 8),
//                     Align(
//                       alignment: Alignment.bottomCenter,
//                       child: SectionContainer(
//                         child: Text(
//                           '${DateFormatter.range(state.checkInDate, state.checkOutDate)}'
//                           '\n${state.nights} Night${state.nights > 1 ? 's' : ''}',
//                           textAlign: TextAlign.center,
//                           style: Theme.of(context).textTheme.titleMedium,
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: UiConstants.spacingMd),
//                     CustomTextField(
//                       hint: 'Notes (Optional)',
//                       label: 'Notes (Optional)',
//                       maxLines: 4,
//                       onChanged: (value) => context.read<BookingFormBloc>().add(
//                         BookingFormNotesChanged(value),
//                       ),
//                       controller: TextEditingController(text: state.notes)
//                         ..selection = TextSelection.fromPosition(
//                           TextPosition(offset: state.notes.length),
//                         ),
//                     ),
//                     const SizedBox(height: UiConstants.spacingMd),
//                     // Payment details
//                     // CustomDropdown<PaymentMethod>(
//                     //   label: 'Payment Method',
//                     //   hint: 'Select payment method',
//                     //   value: state.paymentMethod,
//                     //   items: PaymentMethod.values
//                     //       .map(
//                     //         (m) => DropdownMenuItem(
//                     //           value: m,
//                     //           child: Text(m.displayName),
//                     //         ),
//                     //       )
//                     //       .toList(),
//                     //   onChanged: (val) {
//                     //     if (val != null) {
//                     //       context.read<BookingFormBloc>().add(
//                     //         BookingFormPaymentMethodChanged(val),
//                     //       );
//                     //     }
//                     //   },
//                     // ),
//                     CustomDropdown<PaymentMethod>(
//                       title: 'Payment Method',
//                       hint: 'Select payment method',
//                       dropdownHeaderName: 'List of Payment Methods',
//                       initialValue: state.paymentMethod,
//                       shouldDivideItems: true,
//                       items: PaymentMethod.values
//                           .map(
//                             (m) => DropdownItem<PaymentMethod>(
//                               value: m,
//                               child: Text(m.displayName),
//                             ),
//                           )
//                           .toList(),
//                       onChanged: (val) {
//                         if (val != null) {
//                           context.read<BookingFormBloc>().add(
//                             BookingFormPaymentMethodChanged(val),
//                           );
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],

//           // Only show status & payment controls in edit mode (for staff/admin)
//           if (isEditMode) ...[
//             SectionContainer(
//               child: Container(
//                 width: double.infinity,
//                 decoration: const BoxDecoration(),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const Align(
//                       alignment: Alignment.topLeft,
//                       child: Text('Booked By', style: TextStyle(fontSize: 20)),
//                     ),
//                     // Profile Picture of the user
//                     CircleAvatar(
//                       radius: 34,
//                       child: Container(
//                         child:
//                             (state.user.imageUrl != null &&
//                                 state.user.imageUrl!.isNotEmpty)
//                             ? Image.network(
//                                 state.user.imageUrl!,
//                                 fit: BoxFit.cover,
//                               )
//                             : Center(
//                                 child: Text(
//                                   _getInitialCharactrOfOrganization(
//                                     state.user.fullName,
//                                   ),
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                     fontSize: 24,
//                                   ),
//                                 ),
//                               ),
//                       ),
//                     ),
//                     const SizedBox(height: UiConstants.spacingMd),
//                     Row(
//                       children: [
//                         const Expanded(child: Text('Full Name')),
//                         Expanded(
//                           child: Text(
//                             state.user.fullName,
//                             textAlign: TextAlign.left,
//                             style: const TextStyle(fontSize: 18),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: UiConstants.spacingSm),
//                     Row(
//                       children: [
//                         const Expanded(child: Text('Phone')),
//                         Expanded(
//                           child: Text(
//                             state.user.phone ?? 'Not Added',
//                             textAlign: TextAlign.left,
//                             style: const TextStyle(fontSize: 18),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: UiConstants.spacingSm),

//                     Row(
//                       children: [
//                         const Expanded(child: Text('email')),
//                         Expanded(
//                           child: Text(
//                             state.user.fullName,
//                             textAlign: TextAlign.left,
//                             style: const TextStyle(fontSize: 18),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: UiConstants.spacingSm),

//                     Row(
//                       children: [
//                         const Expanded(child: Text('address')),
//                         Expanded(
//                           child: Text(
//                             state.user.address ?? 'Not provided',
//                             textAlign: TextAlign.left,
//                             style: const TextStyle(fontSize: 18),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: UiConstants.spacingSm),
//             if (post != null) BookingPostSummary(post: post!),
//             const SizedBox(height: UiConstants.spacingSm),
//             // Booking Status
//             DropdownButtonFormField<BookingStatus>(
//               initialValue: state.status,
//               decoration: const InputDecoration(
//                 labelText: 'Booking Status',
//                 border: OutlineInputBorder(),
//               ),
//               items: BookingStatus.values
//                   .map(
//                     (s) => DropdownMenuItem(
//                       value: s,
//                       child: Text(s.name.toUpperCase()),
//                     ),
//                   )
//                   .toList(),
//               onChanged: (value) {
//                 if (value != null) {
//                   context.read<BookingFormBloc>().add(
//                     BookingFormStatusChanged(value),
//                   );
//                 }
//               },
//             ),
//             const SizedBox(height: 16),

//             // Payment Status
//             DropdownButtonFormField<PaymentStatus>(
//               initialValue: state.paymentStatus,
//               decoration: const InputDecoration(
//                 labelText: 'Payment Status',
//                 border: OutlineInputBorder(),
//               ),
//               items: PaymentStatus.values
//                   .map(
//                     (s) => DropdownMenuItem(
//                       value: s,
//                       child: Text(s.name.toUpperCase()),
//                     ),
//                   )
//                   .toList(),
//               onChanged: (value) {
//                 if (value != null) {
//                   context.read<BookingFormBloc>().add(
//                     BookingFormPaymentStatusChanged(value),
//                   );
//                 }
//               },
//             ),
//             const SizedBox(height: 16),

//             // Admin Notes
//             TextField(
//               decoration: const InputDecoration(
//                 labelText: 'Admin Notes (optional)',
//                 border: OutlineInputBorder(),
//                 alignLabelWithHint: true,
//               ),
//               maxLines: 3,
//               onChanged: (value) => context.read<BookingFormBloc>().add(
//                 BookingFormAdminNotesChanged(value),
//               ),
//               controller: TextEditingController(text: state.adminNotes ?? ''),
//             ),
//             const SizedBox(height: 24),
//           ],

//           // Validation Errors
//           if (hasErrors)
//             Padding(
//               padding: const EdgeInsets.all(UiConstants.spacingMd),
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(UiConstants.spacingMd),
//                 decoration: BoxDecoration(
//                   color: Colors.red.shade50,
//                   border: Border.all(color: Colors.red),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: state.validationErrors.values
//                       .map(
//                         (e) => Text(
//                           '• $e',
//                           style: const TextStyle(color: Colors.red),
//                         ),
//                       )
//                       .toList(),
//                 ),
//               ),
//             ),

//           const SizedBox(height: 24),

//           // Submit Button
//           Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: UiConstants.spacingMd,
//             ),
//             width: double.infinity,
//             child: LoadingButton(
//               isLoading: state.isSubmitting,
//               onPressed: state.isValid && !(state.isSubmitting)
//                   ? () => context.read<BookingFormBloc>().add(
//                       const BookingFormSubmitted(),
//                     )
//                   : null,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//               ),
//               text: isEditMode ? 'Update Booking' : 'Book Now',
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getInitialCharactrOfOrganization(String name) {
//     return name
//         .trim()
//         .split(' ')
//         .where((word) => word.isNotEmpty)
//         .map((word) => word[0].toUpperCase())
//         .join();
//   }

//   Widget _buildSuccessView(
//     BuildContext context,
//     Booking booking,
//     bool wasEdit,
//   ) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Card(
//         elevation: 6,
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Icon(Icons.check_circle, color: Colors.green, size: 60),
//               const SizedBox(height: 16),
//               Text(
//                 wasEdit ? 'Booking Updated!' : 'Booking Created Successfully!',
//                 style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                   color: Colors.green,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const Divider(height: 40),

//               _infoRow('Title', booking.title),
//               _infoRow('Price per night', '\$${booking.price}'),
//               _infoRow('Nights', '${booking.nights}'),
//               _infoRow('Total Amount', '\$${booking.totalAmount}', bold: true),
//               const SizedBox(height: 12),
//               _infoRow('Check-in', 'date'),
//               _infoRow('Check-out', 'date out'),
//               const SizedBox(height: 12),
//               _infoRow('Status', booking.status.name.toUpperCase()),
//               _infoRow('Payment', booking.paymentStatus.name.toUpperCase()),
//               if (booking.notes != null && booking.notes!.isNotEmpty)
//                 _infoRow('Notes', booking.notes!),
//               if (booking.primaryImageUrl.isNotEmpty) ...[
//                 const SizedBox(height: 20),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image.network(
//                     booking.primaryImageUrl,
//                     height: 200,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ],
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: const Text('Done'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _infoRow(String label, String value, {bool bold = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               '$label:',
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(
//                 fontWeight: bold ? FontWeight.bold : FontWeight.normal,
//                 fontSize: bold ? 18 : 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _selectDate(
//     BuildContext context,
//     bool isCheckIn,
//     DateTime initial,
//   ) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );
//     if (picked != null) {
//       if (context.mounted) {
//         if (isCheckIn) {
//           context.read<BookingFormBloc>().add(
//             BookingFormCheckInChanged(picked),
//           );
//         } else {
//           context.read<BookingFormBloc>().add(
//             BookingFormCheckOutChanged(picked),
//           );
//         }
//       }
//     }
//   }
// }

// import 'package:app/app/dependency_injection.dart';
// import 'package:app/core/constants/ui_constants.dart';
// import 'package:app/core/theme/app_colors.dart';
// import 'package:app/core/utils/date_formatter.dart';
// import 'package:app/core/widgets/common_widgets.dart';
// import 'package:app/core/widgets/custom_drop_down.dart';
// import 'package:app/core/widgets/loading_widget.dart';
// import 'package:app/features/auth/domain/entities/user.dart';
// import 'package:app/features/booking/domain/entities/booking.dart';
// import 'package:app/features/booking/domain/entities/payment_enums.dart';
// import 'package:app/features/booking/domain/usecases/create_booking_use_case.dart';
// import 'package:app/features/booking/presentation/bloc/booking_bloc.dart';
// import 'package:app/features/booking/presentation/widgets/booking_posst_summary.dart';
// import 'package:app/features/post/domain/entities/post.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class BookingFormScreen extends StatelessWidget {
//   final String userId;
//   final String postId;
//   final Post? post;
//   final Booking? existingBooking; // null = create, not null = edit

//   const BookingFormScreen({
//     super.key,
//     required this.userId,
//     required this.postId,
//     this.post,
//     this.existingBooking,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) =>
//           BookingFormBloc(
//             createBookingUseCase:
//                 DependencyInjection.get<CreateBookingUseCase>(),
//           )..add(
//             BookingFormInitialized(
//               userId: userId,
//               postId: postId,
//               existingBooking: existingBooking,
//             ),
//           ),
//       child: BookingFormView(
//         userId: userId,
//         postId: postId,
//         post: post,
//         existingBooking: existingBooking,
//       ),
//     );
//   }
// }

// class BookingFormView extends StatelessWidget {
//   final String userId;
//   final String postId;
//   final Post? post;
//   final Booking? existingBooking; // null = create, not null = edit

//   const BookingFormView({
//     super.key,
//     required this.userId,
//     required this.postId,
//     this.post,
//     this.existingBooking,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<BookingFormBloc, BookingFormState>(
//       listener: (context, state) {
//         if (state is BookingFormSuccess) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 state.message,
//                 style: const TextStyle(fontWeight: FontWeight.w600),
//               ),
//               backgroundColor: Colors.green.shade600,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           );
//         } else if (state is BookingFormError) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 state.message,
//                 style: const TextStyle(fontWeight: FontWeight.w600),
//               ),
//               backgroundColor: Colors.red.shade600,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           );
//         }
//       },
//       builder: (context, state) {
//         if (state is BookingFormLoading || state is BookingFormInitial) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//         if (state is BookingFormSuccess) {
//           return _buildSuccessView(context, state.booking, state.wasEdit);
//         }
//         if (state is BookingFormReady) {
//           return _buildForm(context, state);
//         }
//         return const Scaffold(body: SizedBox.shrink());
//       },
//     );
//   }

//   Widget _buildForm(BuildContext context, BookingFormReady state) {
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             pinned: true,
//             elevation: 0,
//             stretch: true,
//             backgroundColor: AppColors.primaryLight,
//             title: Text(
//               state.isEditMode ? 'Manage Booking' : 'Create Booking',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           SliverPadding(
//             padding: const EdgeInsets.only(
//               bottom: UiConstants.spacingMd,
//               top: UiConstants.spacingSm,
//             ),
//             sliver: SliverList(
//               delegate: SliverChildListDelegate([
//                 _buildUserDetailsCard(context, state.user, state.isEditMode),
//                 if (post != null)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: UiConstants.spacingMd,
//                       vertical: UiConstants.spacingSm,
//                     ),
//                     child: Hero(
//                       tag: 'post_${post!.id}',
//                       child: BookingPostSummary(post: post!),
//                     ),
//                   ),
//                 if (!state.isEditMode) ...[
//                   _buildDatesCard(context, state),
//                   _buildNotesAndPaymentCard(context, state),
//                 ],
//                 if (state.isEditMode) ...[
//                   _buildAdminControlsCard(context, state),
//                 ],
//                 if (state.validationErrors.isNotEmpty)
//                   _buildErrorsCard(context, state.validationErrors),
//               ]),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: _buildBottomSubmitBar(context, state),
//     );
//   }

//   // ===========================================================================
//   // UI SECTIONS
//   // ===========================================================================

//   Widget _buildUserDetailsCard(
//     BuildContext context,
//     User user,
//     bool isEditMode,
//   ) {
//     return Card(
//       elevation: 3,
//       shadowColor: Colors.black12,
//       margin: const EdgeInsets.symmetric(
//         horizontal: UiConstants.spacingMd,
//         vertical: UiConstants.spacingSm,
//       ),
//       color: Theme.of(context).colorScheme.primary,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Padding(
//         padding: const EdgeInsets.all(UiConstants.spacingMd),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               isEditMode ? 'Booked By' : 'Personal Details',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 color: Theme.of(context).colorScheme.onPrimary,
//               ),
//             ),
//             const SizedBox(height: UiConstants.spacingSm),
//             Row(
//               children: [
//                 _buildAvatar(user),
//                 const SizedBox(width: UiConstants.spacingMd),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         user.fullName,
//                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           color: Theme.of(context).colorScheme.onPrimary,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         user.email,
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: UiConstants.spacingSm),

//             _buildInfoRow(
//               context,
//               Icons.phone_outlined,
//               user.phone ?? 'Not Added',
//             ),
//             const SizedBox(height: 12),
//             _buildInfoRow(
//               context,
//               Icons.location_on_outlined,
//               user.address ?? 'Not provided',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDatesCard(BuildContext context, BookingFormReady state) {
//     return Card(
//       elevation: 3,
//       shadowColor: Colors.black12,
//       margin: const EdgeInsets.symmetric(
//         horizontal: UiConstants.spacingMd,
//         vertical: UiConstants.spacingSm,
//       ),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Padding(
//         padding: const EdgeInsets.all(UiConstants.spacingMd),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Booking Schedule',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.w700,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//             ),
//             const SizedBox(height: UiConstants.spacingMd),
//             Container(
//               decoration: BoxDecoration(
//                 color: Theme.of(
//                   context,
//                 ).colorScheme.surfaceVariant.withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(
//                   color: Theme.of(
//                     context,
//                   ).colorScheme.outlineVariant.withAlpha(15),
//                 ),
//               ),
//               padding: const EdgeInsets.all(8),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: _buildDateTile(
//                       context,
//                       'Check-in',
//                       state.checkInDate,
//                       true,
//                     ),
//                   ),
//                   _buildNightsBadge(context, state.nights),
//                   Expanded(
//                     child: _buildDateTile(
//                       context,
//                       'Check-out',
//                       state.checkOutDate,
//                       false,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: UiConstants.spacingMd),
//             Center(
//               child: Text(
//                 DateFormatter.range(state.checkInDate, state.checkOutDate),
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: Theme.of(context).colorScheme.onSurfaceVariant,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNotesAndPaymentCard(
//     BuildContext context,
//     BookingFormReady state,
//   ) {
//     return Card(
//       elevation: 3,
//       shadowColor: Colors.black12,
//       margin: const EdgeInsets.symmetric(
//         horizontal: UiConstants.spacingMd,
//         vertical: UiConstants.spacingSm,
//       ),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Padding(
//         padding: const EdgeInsets.all(UiConstants.spacingMd),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Additional Details',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.w700,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//             ),
//             const SizedBox(height: UiConstants.spacingMd),
//             CustomTextField(
//               hint: 'e.g., Late arrival, special requests...',
//               label: 'Notes (Optional)',
//               maxLines: 4,
//               onChanged: (value) => context.read<BookingFormBloc>().add(
//                 BookingFormNotesChanged(value),
//               ),
//               controller: TextEditingController(text: state.notes)
//                 ..selection = TextSelection.fromPosition(
//                   TextPosition(offset: state.notes.length),
//                 ),
//             ),
//             const SizedBox(height: 24),
//             CustomDropdown<PaymentMethod>(
//               title: 'Payment Method',
//               hint: 'Select payment method',
//               dropdownHeaderName: 'List of Payment Methods',
//               initialValue: state.paymentMethod,
//               shouldDivideItems: true,
//               items: PaymentMethod.values
//                   .map(
//                     (m) => DropdownItem<PaymentMethod>(
//                       value: m,
//                       child: Text(
//                         m.displayName,
//                         style: const TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                     ),
//                   )
//                   .toList(),
//               onChanged: (val) {
//                 if (val != null) {
//                   context.read<BookingFormBloc>().add(
//                     BookingFormPaymentMethodChanged(val),
//                   );
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAdminControlsCard(BuildContext context, BookingFormReady state) {
//     return Card(
//       elevation: 3,
//       shadowColor: Colors.black12,
//       margin: const EdgeInsets.symmetric(
//         horizontal: UiConstants.spacingMd,
//         vertical: UiConstants.spacingSm,
//       ),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Padding(
//         padding: const EdgeInsets.all(UiConstants.spacingMd),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.admin_panel_settings,
//                   color: Theme.of(context).colorScheme.error,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Admin Controls',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.w700,
//                     color: Theme.of(context).colorScheme.error,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             DropdownButtonFormField<BookingStatus>(
//               initialValue: state.status,
//               decoration: InputDecoration(
//                 labelText: 'Booking Status',
//                 filled: true,
//                 fillColor: Theme.of(context).colorScheme.surface,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               items: BookingStatus.values
//                   .map(
//                     (s) => DropdownMenuItem(
//                       value: s,
//                       child: Text(
//                         s.name.toUpperCase(),
//                         style: const TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   )
//                   .toList(),
//               onChanged: (value) {
//                 if (value != null) {
//                   context.read<BookingFormBloc>().add(
//                     BookingFormStatusChanged(value),
//                   );
//                 }
//               },
//             ),
//             const SizedBox(height: 20),
//             DropdownButtonFormField<PaymentStatus>(
//               initialValue: state.paymentStatus,
//               decoration: InputDecoration(
//                 labelText: 'Payment Status',
//                 filled: true,
//                 fillColor: Theme.of(context).colorScheme.surface,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               items: PaymentStatus.values
//                   .map(
//                     (s) => DropdownMenuItem(
//                       value: s,
//                       child: Text(
//                         s.name.toUpperCase(),
//                         style: const TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   )
//                   .toList(),
//               onChanged: (value) {
//                 if (value != null) {
//                   context.read<BookingFormBloc>().add(
//                     BookingFormPaymentStatusChanged(value),
//                   );
//                 }
//               },
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               decoration: InputDecoration(
//                 labelText: 'Admin Notes (optional)',
//                 alignLabelWithHint: true,
//                 filled: true,
//                 fillColor: Theme.of(context).colorScheme.surface,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               maxLines: 3,
//               onChanged: (value) => context.read<BookingFormBloc>().add(
//                 BookingFormAdminNotesChanged(value),
//               ),
//               controller: TextEditingController(text: state.adminNotes ?? ''),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorsCard(BuildContext context, Map<String, String> errors) {
//     return Container(
//       margin: const EdgeInsets.symmetric(
//         horizontal: UiConstants.spacingMd,
//         vertical: UiConstants.spacingSm,
//       ),
//       padding: const EdgeInsets.all(UiConstants.spacingMd),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.errorContainer,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: Theme.of(context).colorScheme.error.withAlpha(15),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.error_outline,
//                 color: Theme.of(context).colorScheme.onErrorContainer,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 'Please fix the following errors:',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Theme.of(context).colorScheme.onErrorContainer,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           ...errors.values.map(
//             (e) => Padding(
//               padding: const EdgeInsets.only(top: 4),
//               child: Text(
//                 '• $e',
//                 style: TextStyle(
//                   color: Theme.of(context).colorScheme.onErrorContainer,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomSubmitBar(BuildContext context, BookingFormReady state) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(
//         UiConstants.spacingMd,
//         UiConstants.spacingMd,
//         UiConstants.spacingMd,
//         UiConstants.spacingMd,
//       ),

//       child: LoadingButton(
//         isLoading: state.isSubmitting,
//         onPressed: state.isValid && !state.isSubmitting
//             ? () => context.read<BookingFormBloc>().add(
//                 const BookingFormSubmitted(),
//               )
//             : null,
//         style: ElevatedButton.styleFrom(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(UiConstants.radiusXl),
//           ),
//           elevation: 0,
//         ),
//         text: state.isEditMode ? 'Update Booking' : 'Book Now',
//       ),
//     );
//   }

//   Widget _buildSuccessView(
//     BuildContext context,
//     Booking booking,
//     bool wasEdit,
//   ) {
//     return Scaffold(
//       backgroundColor: Colors.green.shade50,
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Card(
//               elevation: 8,
//               shadowColor: Colors.green.shade200,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(28),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(32),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.green.shade100,
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.check_circle,
//                         color: Colors.green.shade600,
//                         size: 80,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     Text(
//                       wasEdit ? 'Booking Updated!' : 'Booking Confirmed!',
//                       textAlign: TextAlign.center,
//                       style: Theme.of(context).textTheme.headlineMedium
//                           ?.copyWith(
//                             color: Colors.green.shade800,
//                             fontWeight: FontWeight.w800,
//                           ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Your transaction was successful.',
//                       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                         color: Colors.green.shade700,
//                       ),
//                     ),
//                     const Padding(
//                       padding: EdgeInsets.symmetric(vertical: 24),
//                       child: Divider(thickness: 1.5),
//                     ),
//                     _buildSuccessInfoRow('Title', booking.title),
//                     _buildSuccessInfoRow('Price/night', '\$${booking.price}'),
//                     _buildSuccessInfoRow('Nights', '${booking.nights}'),
//                     const Padding(
//                       padding: EdgeInsets.symmetric(vertical: 12),
//                       child: Divider(thickness: 1.5),
//                     ),
//                     _buildSuccessInfoRow(
//                       'Total Amount',
//                       '\$${booking.totalAmount}',
//                       isTotal: true,
//                     ),
//                     const SizedBox(height: 16),
//                     _buildSuccessInfoRow(
//                       'Status',
//                       booking.status.name.toUpperCase(),
//                     ),
//                     _buildSuccessInfoRow(
//                       'Payment',
//                       booking.paymentStatus.name.toUpperCase(),
//                     ),
//                     if (booking.notes != null && booking.notes!.isNotEmpty) ...[
//                       const SizedBox(height: 12),
//                       _buildSuccessInfoRow('Notes', booking.notes!),
//                     ],
//                     if (booking.primaryImageUrl.isNotEmpty) ...[
//                       const SizedBox(height: 24),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(16),
//                         child: CachedNetworkImage(
//                           imageUrl: booking.primaryImageUrl,
//                           height: 180,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ],
//                     const SizedBox(height: 32),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green.shade600,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 18),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           elevation: 0,
//                         ),
//                         onPressed: () => Navigator.of(context).pop(),
//                         child: const Text(
//                           'Done',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ===========================================================================
//   // HELPERS
//   // ===========================================================================

//   Widget _buildAvatar(dynamic user) {
//     final hasImage = user.imageUrl != null && user.imageUrl!.isNotEmpty;
//     return Container(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha(25),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: CircleAvatar(
//         radius: 28,
//         backgroundColor: Colors.blueGrey.shade100,
//         child: ClipOval(
//           child: hasImage
//               ? CachedNetworkImage(
//                   imageUrl: user.imageUrl!,
//                   width: double.infinity,
//                   height: double.infinity,
//                   fit: BoxFit.cover,
//                 )
//               : Center(
//                   child: Text(
//                     _getInitialCharacterOfOrganization(user.fullName),
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blueGrey.shade700,
//                       fontSize: 28,
//                     ),
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDateTile(
//     BuildContext context,
//     String title,
//     DateTime date,
//     bool isCheckIn,
//   ) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () => _selectDate(context, isCheckIn, date),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//           child: Column(
//             children: [
//               Text(
//                 title,
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: Theme.of(context).colorScheme.secondary,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 DateFormatter.formatWithDay(date),
//                 textAlign: TextAlign.center,
//                 style: Theme.of(
//                   context,
//                 ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(height: 8),
//               Icon(
//                 Icons.calendar_month_rounded,
//                 color: Theme.of(context).colorScheme.primary,
//                 size: 20,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNightsBadge(BuildContext context, int nights) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.primaryContainer,
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Column(
//         children: [
//           Icon(
//             Icons.nights_stay_rounded,
//             color: Theme.of(context).colorScheme.onPrimaryContainer,
//             size: 20,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             '$nights Night${nights > 1 ? 's' : ''}',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).colorScheme.onPrimaryContainer,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(BuildContext context, IconData icon, String value) {
//     return Row(
//       children: [
//         Icon(icon, color: Colors.white, size: 20),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(
//             value,
//             style: Theme.of(
//               context,
//             ).textTheme.bodyMedium?.copyWith(color: Colors.white, fontSize: 15),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSuccessInfoRow(
//     String label,
//     String value, {
//     bool isTotal = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               color: Colors.grey.shade600,
//               fontSize: isTotal ? 18 : 16,
//             ),
//           ),
//           Flexible(
//             child: Text(
//               value,
//               textAlign: TextAlign.right,
//               style: TextStyle(
//                 fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
//                 color: isTotal ? Colors.green.shade800 : Colors.black87,
//                 fontSize: isTotal ? 22 : 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _selectDate(
//     BuildContext context,
//     bool isCheckIn,
//     DateTime initial,
//   ) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: Theme.of(context).colorScheme.copyWith(
//               primary: Theme.of(context).colorScheme.primary,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) {
//       if (context.mounted) {
//         if (isCheckIn) {
//           context.read<BookingFormBloc>().add(
//             BookingFormCheckInChanged(picked),
//           );
//         } else {
//           context.read<BookingFormBloc>().add(
//             BookingFormCheckOutChanged(picked),
//           );
//         }
//       }
//     }
//   }

//   String _getInitialCharacterOfOrganization(String name) {
//     return name
//         .trim()
//         .split(' ')
//         .where((word) => word.isNotEmpty)
//         .map((word) => word[0].toUpperCase())
//         .join();
//   }
// }

import 'package:app/app/dependency_injection.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/utils/date_formatter.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/core/widgets/custom_drop_down.dart';
import 'package:app/core/widgets/loading_widget.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/booking/domain/entities/payment_enums.dart';
import 'package:app/features/booking/domain/usecases/create_booking_use_case.dart';
import 'package:app/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:app/features/booking/presentation/widgets/booking_posst_summary.dart';
import 'package:app/features/post/domain/entities/post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingFormScreen extends StatelessWidget {
  final String userId;
  final String postId;
  final Post? post;
  final Booking? existingBooking;

  const BookingFormScreen({
    super.key,
    required this.userId,
    required this.postId,
    this.post,
    this.existingBooking,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BookingFormBloc(
            createBookingUseCase:
                DependencyInjection.get<CreateBookingUseCase>(),
          )..add(
            BookingFormInitialized(
              userId: userId,
              postId: postId,
              existingBooking: existingBooking,
            ),
          ),
      child: BookingFormView(
        userId: userId,
        postId: postId,
        post: post,
        existingBooking: existingBooking,
      ),
    );
  }
}

class BookingFormView extends StatelessWidget {
  final String userId;
  final String postId;
  final Post? post;
  final Booking? existingBooking;

  const BookingFormView({
    super.key,
    required this.userId,
    required this.postId,
    this.post,
    this.existingBooking,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingFormBloc, BookingFormState>(
      listener: (context, state) {
        if (state is BookingFormSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else if (state is BookingFormError) {
          print(state.message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is BookingFormLoading || state is BookingFormInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is BookingFormSuccess) {
          return _buildSuccessView(context, state.booking, state.wasEdit);
        }
        if (state is BookingFormReady) {
          return _buildForm(context, state);
        }
        return const Scaffold(body: SizedBox.shrink());
      },
    );
  }

  Widget _buildForm(BuildContext context, BookingFormReady state) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            stretch: true,
            backgroundColor: AppColors.primaryLight,
            title: Text(
              state.isEditMode ? 'Manage Booking' : 'Create Booking',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              bottom: UiConstants.spacingMd,
              top: UiConstants.spacingSm,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildUserDetailsCard(context, state.user, state.isEditMode),
                if (post != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UiConstants.spacingMd,
                      vertical: UiConstants.spacingSm,
                    ),
                    child: Hero(
                      tag: 'post_${post!.id}',
                      child: BookingPostSummary(post: post!),
                    ),
                  ),
                if (!state.isEditMode) ...[
                  _buildDatesCard(context, state),
                  _buildNotesAndPaymentCard(context, state),
                ],
                if (state.isEditMode) ...[
                  _buildAdminControlsCard(context, state),
                ],
                if (state.validationErrors.isNotEmpty)
                  _buildErrorsCard(context, state.validationErrors),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomSubmitBar(context, state),
    );
  }

  // ===========================================================================
  // UI SECTIONS
  // ===========================================================================

  Widget _buildUserDetailsCard(
    BuildContext context,
    User user,
    bool isEditMode,
  ) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.symmetric(
        horizontal: UiConstants.spacingMd,
        vertical: UiConstants.spacingSm,
      ),
      color: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(UiConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditMode ? 'Booked By' : 'Personal Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: UiConstants.spacingSm),
            Row(
              children: [
                _buildAvatar(user),
                const SizedBox(width: UiConstants.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: UiConstants.spacingSm),
            _buildInfoRow(
              context,
              Icons.phone_outlined,
              user.phone ?? 'Not Added',
            ),
            const SizedBox(height: UiConstants.spacingMd),
            _buildInfoRow(
              context,
              Icons.location_on_outlined,
              user.address ?? 'Not provided',
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DATES CARD — Date + Time combined picker, auto-detects hourly vs nightly
  // ---------------------------------------------------------------------------

  Widget _buildDatesCard(BuildContext context, BookingFormReady state) {
    final checkIn = state.checkInDate;
    final checkOut = state.checkOutDate;
    final duration = checkOut.difference(checkIn);
    final isHourly = duration.inHours < 24;
    final durationLabel = isHourly
        ? '${duration.inHours}h ${duration.inMinutes % 60}m'
        : '${duration.inDays} Night${duration.inDays > 1 ? 's' : ''}';

    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.symmetric(
        horizontal: UiConstants.spacingMd,
        vertical: UiConstants.spacingSm,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(UiConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + type pill
            Row(
              children: [
                Text(
                  'Booking Schedule',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                _BookingTypePill(isHourly: isHourly),
              ],
            ),
            const SizedBox(height: UiConstants.spacingMd),

            // Check-in tile
            _DateTimeTile(
              label: 'CHECK-IN',
              icon: Icons.login_rounded,
              accentColor: const Color(0xFF10B981),
              dateTime: checkIn,
              onTap: () =>
                  _selectDateTime(context, isCheckIn: true, current: checkIn),
            ),

            // Duration connector
            _DurationConnector(label: durationLabel, isHourly: isHourly),

            // Check-out tile
            _DateTimeTile(
              label: 'CHECK-OUT',
              icon: Icons.logout_rounded,
              accentColor: const Color(0xFFEF4444),
              dateTime: checkOut,
              onTap: () =>
                  _selectDateTime(context, isCheckIn: false, current: checkOut),
            ),

            const SizedBox(height: UiConstants.spacingMd),

            // Summary banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isHourly
                        ? Icons.schedule_rounded
                        : Icons.nights_stay_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$durationLabel · ${DateFormatter.range(checkIn, checkOut)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesAndPaymentCard(
    BuildContext context,
    BookingFormReady state,
  ) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.symmetric(
        horizontal: UiConstants.spacingMd,
        vertical: UiConstants.spacingSm,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(UiConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: UiConstants.spacingMd),
            CustomTextField(
              hint: 'e.g., Late arrival, special requests...',
              label: 'Notes (Optional)',
              maxLines: 4,
              onChanged: (value) => context.read<BookingFormBloc>().add(
                BookingFormNotesChanged(value),
              ),
              controller: TextEditingController(text: state.notes)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: state.notes.length),
                ),
            ),
            const SizedBox(height: 24),
            CustomDropdown<PaymentMethod>(
              title: 'Payment Method',
              hint: 'Select payment method',
              dropdownHeaderName: 'List of Payment Methods',
              initialValue: state.paymentMethod,
              shouldDivideItems: true,
              items: PaymentMethod.values
                  .map(
                    (m) => DropdownItem<PaymentMethod>(
                      value: m,
                      child: Text(
                        m.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  context.read<BookingFormBloc>().add(
                    BookingFormPaymentMethodChanged(val),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminControlsCard(BuildContext context, BookingFormReady state) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.symmetric(
        horizontal: UiConstants.spacingMd,
        vertical: UiConstants.spacingSm,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(UiConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Admin Controls',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<BookingStatus>(
              initialValue: state.status,
              decoration: InputDecoration(
                labelText: 'Booking Status',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: BookingStatus.values
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        s.name.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null)
                  context.read<BookingFormBloc>().add(
                    BookingFormStatusChanged(value),
                  );
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<PaymentStatus>(
              initialValue: state.paymentStatus,
              decoration: InputDecoration(
                labelText: 'Payment Status',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: PaymentStatus.values
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        s.name.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null)
                  context.read<BookingFormBloc>().add(
                    BookingFormPaymentStatusChanged(value),
                  );
              },
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Admin Notes (optional)',
                alignLabelWithHint: true,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              onChanged: (value) => context.read<BookingFormBloc>().add(
                BookingFormAdminNotesChanged(value),
              ),
              controller: TextEditingController(text: state.adminNotes ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorsCard(BuildContext context, Map<String, String> errors) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: UiConstants.spacingMd,
        vertical: UiConstants.spacingSm,
      ),
      padding: const EdgeInsets.all(UiConstants.spacingMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withAlpha(15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'Please fix the following errors:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...errors.values.map(
            (e) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '• $e',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSubmitBar(BuildContext context, BookingFormReady state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        UiConstants.spacingMd,
        UiConstants.spacingMd,
        UiConstants.spacingMd,
        UiConstants.spacingMd,
      ),
      child: LoadingButton(
        isLoading: state.isSubmitting,
        onPressed: state.isValid && !state.isSubmitting
            ? () => context.read<BookingFormBloc>().add(
                const BookingFormSubmitted(),
              )
            : null,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiConstants.radiusXl),
          ),
          elevation: 0,
        ),
        text: state.isEditMode ? 'Update Booking' : 'Book Now',
      ),
    );
  }

  Widget _buildSuccessView(
    BuildContext context,
    Booking booking,
    bool wasEdit,
  ) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shadowColor: Colors.green.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 80,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      wasEdit ? 'Booking Updated!' : 'Booking Confirmed!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your transaction was successful.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.green.shade700,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(thickness: 1.5),
                    ),
                    _buildSuccessInfoRow('Title', booking.title),
                    _buildSuccessInfoRow('Price/night', '\$${booking.price}'),
                    _buildSuccessInfoRow('Nights', '${booking.nights}'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(thickness: 1.5),
                    ),
                    _buildSuccessInfoRow(
                      'Total Amount',
                      '\$${booking.totalAmount}',
                      isTotal: true,
                    ),
                    const SizedBox(height: 16),
                    _buildSuccessInfoRow(
                      'Status',
                      booking.status.name.toUpperCase(),
                    ),
                    _buildSuccessInfoRow(
                      'Payment',
                      booking.paymentStatus.name.toUpperCase(),
                    ),
                    if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildSuccessInfoRow('Notes', booking.notes!),
                    ],
                    if (booking.primaryImageUrl.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: booking.primaryImageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  Widget _buildAvatar(dynamic user) {
    final hasImage = user.imageUrl != null && user.imageUrl!.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.blueGrey.shade100,
        child: ClipOval(
          child: hasImage
              ? CachedNetworkImage(
                  imageUrl: user.imageUrl!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                )
              : Center(
                  child: Text(
                    _getInitials(user.fullName),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade700,
                      fontSize: 22,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessInfoRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              fontSize: isTotal ? 18 : 16,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
                color: isTotal ? Colors.green.shade800 : Colors.black87,
                fontSize: isTotal ? 22 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Step 1: date picker → Step 2: time picker → combine into one DateTime.
  Future<void> _selectDateTime(
    BuildContext context, {
    required bool isCheckIn,
    required DateTime current,
  }) async {
    // — Date picker —
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: Theme.of(context).colorScheme.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (pickedDate == null || !context.mounted) return;

    // — Time picker —
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      helpText: isCheckIn ? 'SELECT CHECK-IN TIME' : 'SELECT CHECK-OUT TIME',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: Theme.of(context).colorScheme.primary,
          ),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: Theme.of(context).colorScheme.surface,
            hourMinuteShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            dayPeriodShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (pickedTime == null || !context.mounted) return;

    // — Combine —
    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (isCheckIn) {
      context.read<BookingFormBloc>().add(BookingFormCheckInChanged(combined));
    } else {
      context.read<BookingFormBloc>().add(BookingFormCheckOutChanged(combined));
    }
  }

  String _getInitials(String name) {
    return name
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase())
        .join();
  }
}

// =============================================================================
// REUSABLE WIDGETS
// =============================================================================

/// Tappable tile showing date + time for one end of the booking.
class _DateTimeTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final DateTime dateTime;
  final VoidCallback onTap;

  const _DateTimeTile({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.dateTime,
    required this.onTap,
  });

  String get _timeLabel {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String get _dateLabel {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[dateTime.weekday - 1]}, ${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.22)),
        ),
        child: Row(
          children: [
            // Left accent bar
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),
            // Icon
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: accentColor),
            ),
            const SizedBox(width: 14),
            // Date label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _dateLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            // Time chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_rounded, size: 13, color: accentColor),
                  const SizedBox(width: 5),
                  Text(
                    _timeLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.edit_rounded, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

/// Dotted vertical connector between check-in and check-out tiles.
class _DurationConnector extends StatelessWidget {
  final String label;
  final bool isHourly;

  const _DurationConnector({required this.label, required this.isHourly});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 22),
      child: Row(
        children: [
          // Dotted line
          Column(
            children: List.generate(
              4,
              (_) => Container(
                width: 2,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Duration badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isHourly
                      ? Icons.hourglass_bottom_rounded
                      : Icons.nights_stay_rounded,
                  size: 13,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill in the header showing "Hourly ⚡" or "Nightly 🌙" — animated on switch.
class _BookingTypePill extends StatelessWidget {
  final bool isHourly;

  const _BookingTypePill({required this.isHourly});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: Container(
        key: ValueKey(isHourly),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              size: 13,
              color: isHourly
                  ? const Color(0xFFEA580C)
                  : const Color(0xFF2563EB),
            ),
            const SizedBox(width: 4),
            Text(
              isHourly ? 'Hourly' : 'Nightly',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isHourly
                    ? const Color(0xFFEA580C)
                    : const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
