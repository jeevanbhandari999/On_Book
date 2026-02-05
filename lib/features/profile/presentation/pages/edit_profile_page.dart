import 'package:app/app/dependency_injection.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/profile/domain/usecases/edit_user_profile_use_case.dart';
import 'package:app/features/profile/presentation/bloc/edit_user_profile_bloc.dart';
import 'package:app/features/profile/presentation/pages/profile_image_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfilePage extends StatelessWidget {
  final User profile;
  final Organization? organization; //Made optional
  final String? email; // Made optional
  const EditProfilePage({
    super.key,
    required this.profile,
    this.organization,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return BlocProvider(
        create: (context) =>
            EditUserProfileBloc(
              editUserProfileUseCase:
                  DependencyInjection.get<EditUserProfileUseCase>(),
            )..add(
              ProfileDetailInitialized(
                userId: profile.userId,
                profile: profile,
              ),
            ),
        child: EditProfileView(
          profile: profile,
          organization: organization,
          email: email,
        ),
      );
    } catch (e) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Failed to initialize form: $e')),
      );
    }
  }
}

class EditProfileView extends StatelessWidget {
  final User profile;
  final Organization? organization;
  final String? email;
  const EditProfileView({
    super.key,
    required this.profile,
    this.organization,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    final fullNameController = TextEditingController(text: profile.fullName);
    final phoneController = TextEditingController(text: profile.phone);
    final addressController = TextEditingController(text: profile.address);

    final formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: BlocBuilder<EditUserProfileBloc, EditUserProfileState>(
        builder: (context, state) {
          if (state is ProfileDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  // // Avatar with edit
                  // Stack(
                  //   alignment: Alignment.bottomRight,
                  //   children: [
                  //     CircleAvatar(
                  //       radius: 55,
                  //       backgroundImage:
                  //           (profile.imageUrl != null &&
                  //               profile.imageUrl!.isNotEmpty)
                  //           ? NetworkImage(profile.imageUrl!)
                  //           : null,
                  //       child:
                  //           profile.imageUrl != null &&
                  //               profile.imageUrl!.isNotEmpty
                  //           ? Icon(
                  //               Icons.person,
                  //               size: 55,
                  //               color: Theme.of(context).primaryColor,
                  //             )
                  //           : null,
                  //     ),
                  //     GestureDetector(
                  //       onTap: () {
                  //         Navigator.of(context).push(
                  //           MaterialPageRoute(
                  //             builder: (_) => ProfileImagePage(user: profile),
                  //           ),
                  //         );
                  //       },
                  //       child: Container(
                  //         margin: const EdgeInsets.only(bottom: 4, right: 4),
                  //         padding: const EdgeInsets.all(6),
                  //         decoration: BoxDecoration(
                  //           color: Theme.of(context).primaryColor,
                  //           shape: BoxShape.circle,
                  //           border: Border.all(color: Colors.white, width: 2),
                  //         ),
                  //         child: const Icon(
                  //           Icons.edit,
                  //           size: 16,
                  //           color: Colors.white,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 24),

                  // Full Name
                  _buildInputCard(
                    context,
                    title: 'Full Name',
                    controller: fullNameController,
                    icon: Icons.person,
                    hintText: 'Enter your full Name',
                    validator: (value) => value == null || value.isEmpty
                        ? 'Full Name is required'
                        : null,
                  ),
                  // Address
                  _buildInputCard(
                    context,
                    title: 'Address',
                    controller: addressController,
                    icon: Icons.location_on,
                    hintText: 'Enter your address',
                  ),

                  // Phone
                  _buildInputCard(
                    context,
                    title: 'Phone',
                    controller: phoneController,
                    icon: Icons.location_on,
                    hintText: 'Enter your Phone',
                  ),

                  _buildTapableCard(
                    context,
                    icon: Icons.business,
                    title: 'Organization',
                    subtitle: organization?.name ?? 'Name',
                    onTap: () {},
                  ),

                  _buildTapableCard(
                    context,
                    icon: Icons.badge_outlined,
                    title: profile.role.name.toUpperCase(),
                    subtitle: 'You can manage this organization.',
                    onTap: () {},
                  ),

                  _buildTapableCard(
                    context,
                    icon: Icons.email,
                    title: email ?? 'Not added',
                    subtitle:
                        'Adding email will help you to restore your profile in future',
                    onTap: () {},
                  ),

                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: state is ProfileDetailUpdating
                          ? "Saving..."
                          : "Save Changes",
                      onPressed: state is ProfileDetailUpdating
                          ? null
                          : () {
                              if (formKey.currentState!.validate()) {
                                // dispatch update event
                                context.read<EditUserProfileBloc>().add(
                                  const ProfileDetailUpdateRequested(),
                                );
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputCard(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    required IconData icon,
    String? hintText,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SectionContainer(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title above the field
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          // The input field
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            onChanged: (val) {
              if (title == 'Full Name') {
                context.read<EditUserProfileBloc>().add(
                  ProfileFullNameChanged(fullName: val),
                );
              } else if (title == 'Address') {
                context.read<EditUserProfileBloc>().add(
                  ProfileAddressChanged(address: val),
                );
              }
            },
            decoration: InputDecoration(
              hintText: hintText ?? 'Enter $title',
              prefixIcon: Icon(
                icon,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTapableCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return SectionContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withAlpha(100),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 20,
        ),
        // onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
    );
  }

  // Future<void> _refresh(BuildContext context) async {
  //   print('hello working');
  //   context
  //       .read<EditUserProfileBloc>()
  //       .add(ProfileDetailInitialized(userId: profile.userId));
  // }
}
