import 'package:app/core/constants/ui_constants.dart';
import 'package:app/features/booking/domain/entities/booking.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PaymentResultPage extends StatelessWidget {
  final Booking? booking;
  final bool success;

  const PaymentResultPage({
    super.key,
    required this.booking,
    required this.success,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = success
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);
    final lightBg = success ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2);
    final cardBg = success ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
    final iconBg = success ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ── Hero header ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 48,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    // Pulsing icon
                    Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: iconBg.withAlpha(80),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            success
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            size: 72,
                            color: iconBg,
                          ),
                        )
                        .animate()
                        .scale(
                          begin: const Offset(0, 0),
                          end: const Offset(1, 1),
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                          delay: 100.ms,
                        )
                        .then()
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(
                          begin: 1.0,
                          end: 1.06,
                          duration: 1200.ms,
                          curve: Curves.easeInOut,
                        ),

                    const SizedBox(height: 20),

                    Text(
                          success ? 'Booking Confirmed!' : 'Payment Failed',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                            letterSpacing: -0.5,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 400.ms)
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        ),

                    const SizedBox(height: 6),

                    Text(
                          success
                              ? 'Your reservation is all set.'
                              : 'No booking was created. Please try again.',
                          style: TextStyle(
                            fontSize: 14,
                            color: primaryColor.withAlpha(180),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate()
                        .fadeIn(delay: 650.ms, duration: 400.ms)
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ],
                ),
              ),

              // ── Booking details ──────────────────────────────────────────
              if (success && booking != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    UiConstants.spacingMd,
                    UiConstants.spacingMd,
                    UiConstants.spacingMd,
                    0,
                  ),
                  child: Column(
                    children: [
                      if (booking!.primaryImageUrl.isNotEmpty)
                        _ImageTitleBanner(booking: booking!)
                            .animate()
                            .fadeIn(delay: 750.ms, duration: 500.ms)
                            .slideY(
                              begin: 0.2,
                              end: 0,
                              duration: 400.ms,
                              curve: Curves.easeOutCubic,
                            ),

                      const SizedBox(height: UiConstants.spacingMd),

                      _BookingInfoCard(booking: booking!)
                          .animate()
                          .fadeIn(delay: 850.ms, duration: 500.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            duration: 400.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: UiConstants.spacingMd),

                      _PaymentSummaryCard(booking: booking!)
                          .animate()
                          .fadeIn(delay: 950.ms, duration: 500.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            duration: 400.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: UiConstants.spacingMd),

                      _BookingIdChip(bookingId: booking!.id)
                          .animate()
                          .fadeIn(delay: 1050.ms, duration: 500.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            duration: 400.ms,
                            curve: Curves.easeOutCubic,
                          ),
                    ],
                  ),
                ),
              ],

              // ── Failure hint ─────────────────────────────────────────────
              if (!success)
                Padding(
                      padding: const EdgeInsets.all(UiConstants.spacingMd),
                      child: Container(
                        padding: const EdgeInsets.all(UiConstants.spacingMd),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFFDC2626),
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'What happened?',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your payment could not be processed and no booking was created. '
                              'You can go back and try again with a different payment method.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 750.ms, duration: 500.ms)
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic,
                    ),

              // ── Action buttons ───────────────────────────────────────────
              Padding(
                    padding: const EdgeInsets.fromLTRB(
                      UiConstants.spacingMd,
                      UiConstants.spacingSm,
                      UiConstants.spacingMd,
                      UiConstants.spacingMd,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: iconBg,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () => Navigator.of(
                              context,
                            ).popUntil((r) => r.isFirst),
                            child: Text(
                              success ? 'Done' : 'Back to Home',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        if (!success) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: BorderSide(color: primaryColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'Try Again',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 1100.ms, duration: 400.ms)
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: UiConstants.spacingMd),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Payment summary ───────────────────────────────────────────────────────────

class _PaymentSummaryCard extends StatelessWidget {
  final Booking booking;
  const _PaymentSummaryCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final paymentStatusColor = booking.paymentStatus == PaymentStatus.paid
        ? const Color(0xFF16A34A)
        : const Color(0xFFF59E0B);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(UiConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Summary',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: UiConstants.spacingSm),
            _SummaryRow(
              label: 'Price / night',
              value: 'Rs. ${booking.price.toStringAsFixed(0)}',
            ),
            _SummaryRow(label: 'Nights', value: '× ${booking.nights}'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Paid',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Rs. ${booking.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UiConstants.spacingSm),
            // Payment status pill
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: paymentStatusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: paymentStatusColor.withAlpha(80)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      booking.paymentStatus == PaymentStatus.paid
                          ? Icons.check_circle_outline_rounded
                          : Icons.schedule_rounded,
                      size: 13,
                      color: paymentStatusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      booking.paymentStatus.name.toUpperCase(),
                      style: TextStyle(
                        color: paymentStatusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Booking ID copyable chip ──────────────────────────────────────────────────

class _BookingIdChip extends StatelessWidget {
  final String bookingId;
  const _BookingIdChip({required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: bookingId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Booking ID copied!'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tag_rounded, size: 15, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Text(
              bookingId.toUpperCase(),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.grey.shade600,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.copy_rounded, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// ── Tiny reusable helpers ─────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Post image with gradient title overlay ────────────────────────────────────

class _ImageTitleBanner extends StatelessWidget {
  final Booking booking;
  const _ImageTitleBanner({required this.booking});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: booking.primaryImageUrl,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(
              height: 160,
              color: Colors.grey.shade200,
              child: const Icon(Icons.image_not_supported_outlined, size: 40),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withAlpha(180)],
                ),
              ),
            ),
          ),
          // Title at bottom
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Text(
              booking.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Booking schedule + status info ───────────────────────────────────────────

class _BookingInfoCard extends StatelessWidget {
  final Booking booking;
  const _BookingInfoCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status banner at top
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  booking.status.name.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(UiConstants.spacingMd),
            child: Column(
              children: [
                _InfoTile(
                  icon: Icons.confirmation_number_outlined,
                  iconColor: const Color(0xFF6366F1),
                  label: 'Booking ID',
                  value: '#${booking.id.substring(0, 8).toUpperCase()}',
                ),
                const Divider(height: 20),
                _InfoTile(
                  icon: Icons.nights_stay_outlined,
                  iconColor: const Color(0xFF0EA5E9),
                  label: 'Duration',
                  value:
                      '${booking.nights} Night${booking.nights > 1 ? 's' : ''}',
                ),
                if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                  const Divider(height: 20),
                  _InfoTile(
                    icon: Icons.note_alt_outlined,
                    iconColor: const Color(0xFFF59E0B),
                    label: 'Notes',
                    value: booking.notes!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return const Color(0xFF16A34A);
      case BookingStatus.pending:
        return const Color(0xFFF59E0B);
      case BookingStatus.cancelled:
        return const Color(0xFFDC2626);
      default:
        return Colors.grey;
    }
  }
}
