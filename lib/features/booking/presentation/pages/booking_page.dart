import 'package:app/app/dependency_injection.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/utils/date_formatter.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/core/widgets/loading_widget.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/booking/domain/entities/payment_enums.dart';
import 'package:app/features/booking/domain/usecases/create_booking_use_case.dart';
import 'package:app/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingFormScreen extends StatelessWidget {
  final String userId;
  final String postId;
  final Booking? existingBooking; // null = create, not null = edit

  const BookingFormScreen({
    super.key,
    required this.userId,
    required this.postId,
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
        existingBooking: existingBooking,
      ),
    );
  }
}

class BookingFormView extends StatelessWidget {
  final String userId;
  final String postId;
  final Booking? existingBooking; // null = create, not null = edit

  const BookingFormView({
    super.key,
    required this.userId,
    required this.postId,
    this.existingBooking,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          existingBooking == null ? 'Create Booking' : 'Manage Booking',
        ),
      ),
      body: BlocConsumer<BookingFormBloc, BookingFormState>(
        listener: (context, state) {
          if (state is BookingFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is BookingFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BookingFormLoading || state is BookingFormInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BookingFormSuccess) {
            return _buildSuccessView(context, state.booking, state.wasEdit);
          }
          if (state is BookingFormReady) {
            return _buildForm(context, state);
          }
          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, BookingFormReady state) {
    final isEditMode = state.isEditMode;
    final hasErrors = state.validationErrors.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(UiConstants.spacingSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal details for showing the user details
          if (!isEditMode) ...[
            SectionContainer(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Personal Details',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    // Profile Picture of the user
                    CircleAvatar(
                      radius: 50,
                      child: Container(
                        child:
                            (state.user.imageUrl != null &&
                                state.user.imageUrl!.isNotEmpty)
                            ? Image.network(
                                state.user.imageUrl!,
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Text(
                                  _getInitialCharactrOfOrganization(
                                    state.user.fullName,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: UiConstants.spacingMd),
                    Row(
                      children: [
                        const Expanded(child: Text('Full Name')),
                        Expanded(
                          child: Text(
                            state.user.fullName,
                            textAlign: TextAlign.left,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: UiConstants.spacingSm),
                    Row(
                      children: [
                        Expanded(child: Text('Phone')),
                        Expanded(
                          child: Text(
                            state.user.phone ?? 'Not Added',
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: UiConstants.spacingSm),

                    Row(
                      children: [
                        Expanded(child: Text('email')),
                        Expanded(
                          child: Text(
                            state.user.fullName,
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: UiConstants.spacingSm),

                    Row(
                      children: [
                        Expanded(child: Text('address')),
                        Expanded(
                          child: Text(
                            state.user.address ?? 'Not provided',
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Booking details
            SectionContainer(
              child: Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Booking Details',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Check-in Date'),
                      subtitle: Text(
                        DateFormatter.formatWithDay(state.checkInDate),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () =>
                          _selectDate(context, true, state.checkInDate),
                    ),
                    // Check-out Date
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Check-out Date'),
                      subtitle: Text(
                        DateFormatter.formatWithDay(state.checkOutDate),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () =>
                          _selectDate(context, false, state.checkOutDate),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SectionContainer(
                        child: Text(
                          '${DateFormatter.range(state.checkInDate, state.checkOutDate)}'
                          '\n${state.nights} Night${state.nights > 1 ? 's' : ''}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),

                    const SizedBox(height: UiConstants.spacingMd),
                    CustomTextField(
                      hint: 'Notes (Optional)',
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
                    const SizedBox(height: UiConstants.spacingMd),
                    // Payment details
                    CustomDropdown<PaymentMethod>(
                      label: 'Payment Method',
                      hint: 'Select payment method',
                      value: state.paymentMethod,
                      items: PaymentMethod.values
                          .map(
                            (m) => DropdownMenuItem(
                              value: m,
                              child: Text(m.displayName),
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
            ),
          ],

          // Only show status & payment controls in edit mode (for staff/admin)
          if (isEditMode) ...[
            const Divider(),
            const Text(
              'Admin Controls',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Booking Status
            DropdownButtonFormField<BookingStatus>(
              initialValue: state.status,
              decoration: const InputDecoration(
                labelText: 'Booking Status',
                border: OutlineInputBorder(),
              ),
              items: BookingStatus.values
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<BookingFormBloc>().add(
                    BookingFormStatusChanged(value),
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Payment Status
            DropdownButtonFormField<PaymentStatus>(
              initialValue: state.paymentStatus,
              decoration: const InputDecoration(
                labelText: 'Payment Status',
                border: OutlineInputBorder(),
              ),
              items: PaymentStatus.values
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<BookingFormBloc>().add(
                    BookingFormPaymentStatusChanged(value),
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Admin Notes
            TextField(
              decoration: const InputDecoration(
                labelText: 'Admin Notes (optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              onChanged: (value) => context.read<BookingFormBloc>().add(
                BookingFormAdminNotesChanged(value),
              ),
              controller: TextEditingController(text: state.adminNotes ?? ''),
            ),
            const SizedBox(height: 24),
          ],

          // Validation Errors
          if (hasErrors)
            Padding(
              padding: const EdgeInsets.all(UiConstants.spacingMd),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(UiConstants.spacingMd),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: state.validationErrors.values
                      .map(
                        (e) => Text(
                          '• $e',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Submit Button
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UiConstants.spacingMd,
            ),
            width: double.infinity,
            child: LoadingButton(
              onPressed: state.isValid
                  ? () => context.read<BookingFormBloc>().add(
                      const BookingFormSubmitted(),
                    )
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              text: isEditMode ? 'Update Booking' : 'Book Now',
            ),
          ),
        ],
      ),
    );
  }

  String _getInitialCharactrOfOrganization(String name) {
    return name
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase())
        .join();
  }

  Widget _buildSuccessView(
    BuildContext context,
    Booking booking,
    bool wasEdit,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              Text(
                wasEdit ? 'Booking Updated!' : 'Booking Created Successfully!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 40),

              _infoRow('Title', booking.title),
              _infoRow('Price per night', '\$${booking.price}'),
              _infoRow('Nights', '${booking.nights}'),
              _infoRow('Total Amount', '\$${booking.totalAmount}', bold: true),
              const SizedBox(height: 12),
              _infoRow('Check-in', 'date'),
              _infoRow('Check-out', 'date out'),
              const SizedBox(height: 12),
              _infoRow('Status', booking.status.name.toUpperCase()),
              _infoRow('Payment', booking.paymentStatus.name.toUpperCase()),
              if (booking.notes != null && booking.notes!.isNotEmpty)
                _infoRow('Notes', booking.notes!),
              if (booking.primaryImageUrl.isNotEmpty) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    booking.primaryImageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: bold ? 18 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    bool isCheckIn,
    DateTime initial,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      if (context.mounted) {
        if (isCheckIn) {
          context.read<BookingFormBloc>().add(
            BookingFormCheckInChanged(picked),
          );
        } else {
          context.read<BookingFormBloc>().add(
            BookingFormCheckOutChanged(picked),
          );
        }
      }
    }
  }
}
