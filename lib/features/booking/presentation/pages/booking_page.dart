import 'package:app/app/dependency_injection.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:app/features/booking/domain/usecases/create_booking_use_case.dart';
import 'package:app/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingFormScreen extends StatefulWidget {
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
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BookingFormBloc(
            createBookingUseCase:
                DependencyInjection.get<CreateBookingUseCase>(),
            // updateBookingUseCase: getIt<UpdateBookingUseCase>(),
          )..add(
            BookingFormInitialized(
              userId: widget.userId,
              postId: widget.postId,
              existingBooking: widget.existingBooking,
            ),
          ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.existingBooking == null
                ? 'Create Booking'
                : 'Manage Booking',
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
              return _buildSuccessView(state.booking, state.wasEdit);
            }

            if (state is BookingFormReady) {
              return _buildForm(context, state);
            }

            return const Center(child: Text('Something went wrong'));
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, BookingFormReady state) {
    final isEditMode = state.isEditMode;
    final hasErrors = state.validationErrors.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isEditMode) ...[
            // Check-in Date
            ListTile(
              title: const Text('Check-in Date'),
              subtitle: Text('${state.checkInDate}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true, state.checkInDate),
            ),
            const SizedBox(height: 12),

            // Check-out Date
            ListTile(
              title: const Text('Check-out Date'),
              subtitle: Text('${state.checkOutDate}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false, state.checkOutDate),
            ),
            const SizedBox(height: 8),
            Text(
              'Nights: ${state.nights}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
          ],

          // Notes (User)
          TextField(
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
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
              value: state.status,
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
              value: state.paymentStatus,
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
            Container(
              padding: const EdgeInsets.all(12),
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

          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isValid
                  ? () => context.read<BookingFormBloc>().add(
                      const BookingFormSubmitted(),
                    )
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                isEditMode ? 'Update Booking' : 'Create Booking',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(Booking booking, bool wasEdit) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
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
                    booking.primaryImageUrl!,
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
      if (isCheckIn) {
        context.read<BookingFormBloc>().add(BookingFormCheckInChanged(picked));
      } else {
        context.read<BookingFormBloc>().add(BookingFormCheckOutChanged(picked));
      }
    }
  }
}
