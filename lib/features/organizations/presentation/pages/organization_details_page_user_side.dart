import 'package:app/app/dependency_injection.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/utils/date_formatter.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/organizations/domain/usecases/get_user_organization_detail_use_case.dart';
import 'package:app/features/organizations/presentation/bloc/get_user_organization_details_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrganizationDetailsPageUserSide extends StatelessWidget {
  final String organizationId;
  const OrganizationDetailsPageUserSide({
    super.key,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetUserOrganizationDetailsBloc(
            getUserOrganizationDetailUseCase:
                DependencyInjection.get<GetUserOrganizationDetailUseCase>(),
          )..add(
            GetUserOrganizationDetailsRequested(organizationId: organizationId),
          ),
      child: const OrganizationDetailsViewUserSide(),
    );
  }
}

class OrganizationDetailsViewUserSide extends StatelessWidget {
  const OrganizationDetailsViewUserSide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body:
          BlocConsumer<
            GetUserOrganizationDetailsBloc,
            GetUserOrganizationDetailsState
          >(
            listener: (context, state) {
              if (state is GetUserOrganizationDetailsError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              if (state is! GetUserOrganizationDetailsSuccess) {
                return const Center(child: CircularProgressIndicator());
              }

              final org = state.organizationDetails;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildSliverAppBar(context, org),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderSection(context, org),
                          // const SizedBox(height: 24),
                          // _buildActionButtons(context, org),
                          const SizedBox(height: 24),
                          _buildContactSection(context, org),
                          const SizedBox(height: 16),
                          _buildLocationSection(context, org),
                          const SizedBox(height: 16),
                          _buildMetadataSection(context, org),
                          const SizedBox(height: 40), // Bottom padding
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }

  // 1. The Collapsing Header with Logo
  Widget _buildSliverAppBar(BuildContext context, Organization org) {
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: false,
      pinned: true,
      // backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.8),
                      Theme.of(context).primaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(UiConstants.radiusLg),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.8),
                    Theme.of(context).primaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(UiConstants.radiusLg),
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      (org.logoUrl != null && org.logoUrl!.isNotEmpty)
                      ? NetworkImage(org.logoUrl!)
                      : null,
                  child: (org.logoUrl == null || org.logoUrl!.isEmpty)
                      ? Text(
                          org.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Name and main details
  Widget _buildHeaderSection(BuildContext context, Organization org) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          org.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        if (org.address != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  org.address!,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // Widget _buildActionButtons(BuildContext context, Organization org) {
  //   final hasPhone = org.phone != null && org.phone!.isNotEmpty;
  //   final hasLocation = org.latitude != null && org.longitude != null;

  //   if (!hasPhone && !hasLocation) return const SizedBox.shrink();

  //   return Row(
  //     children: [
  //       if (hasPhone)
  //         Expanded(
  //           child: _ActionButton(
  //             icon: Icons.phone,
  //             label: "Call",
  //             color: Colors.green,
  //             onTap: () {
  //               debugPrint("Calling ${org.phone}");
  //             },
  //           ),
  //         ),
  //       if (hasPhone && hasLocation) const SizedBox(width: 12),
  //       if (hasLocation)
  //         Expanded(
  //           child: _ActionButton(
  //             icon: Icons.map,
  //             label: "Directions",
  //             color: Colors.blue,
  //             onTap: () {
  //               // TODO: Implement url_launcher for Maps
  //               // launchUrl(Uri.parse("google.navigation:q=${org.latitude},${org.longitude}"));
  //               debugPrint("Navigating to ${org.latitude}, ${org.longitude}");
  //             },
  //           ),
  //         ),
  //     ],
  //   );
  // }

  // 4. Contact Information Card
  Widget _buildContactSection(BuildContext context, Organization org) {
    return _SectionCard(
      title: "Contact Information",
      children: [
        if (org.phone != null)
          _InfoTile(
            icon: Icons.phone_outlined,
            label: "Phone",
            value: org.phone!,
          ),
        if (org.address != null) ...[
          const SizedBox(height: UiConstants.spacingMd),
          _InfoTile(
            icon: Icons.location_city_outlined,
            label: "Address",
            value: org.address!,
          ),
        ],
        // Fallback if empty
        if (org.phone == null && org.address == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "No contact information provided.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context, Organization org) {
    if (org.latitude == null || org.longitude == null) {
      return const SizedBox.shrink();
    }

    return _SectionCard(
      title: "Coordinates",
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CoordinateBadge(
              label: "LAT",
              value: org.latitude!.toStringAsFixed(4),
            ),
            _CoordinateBadge(
              label: "LNG",
              value: org.longitude!.toStringAsFixed(4),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetadataSection(BuildContext context, Organization org) {
    final dateStr = DateFormatter.format(org.createdAt);

    return _SectionCard(
      title: "About",
      children: [
        _InfoTile(
          icon: Icons.calendar_today_outlined,
          label: "Member Since",
          value: dateStr,
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UiConstants.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UiConstants.radiusXl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withAlpha(90), Colors.white.withAlpha(40)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(22),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.black.withAlpha(80), width: 1.2),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isCopyable;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isCopyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.grey[700], size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (isCopyable)
          IconButton(
            icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
            onPressed: () {
              // Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Copied to clipboard")),
              );
            },
          ),
      ],
    );
  }
}

class _CoordinateBadge extends StatelessWidget {
  final String label;
  final String value;

  const _CoordinateBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[400],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Monospace', // Looks technical
              color: Colors.blueGrey[800],
            ),
          ),
        ],
      ),
    );
  }
}
