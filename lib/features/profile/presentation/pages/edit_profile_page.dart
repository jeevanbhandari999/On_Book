// import 'package:app/app/dependency_injection.dart';
// import 'package:app/core/constants/ui_constants.dart';
// import 'package:app/core/widgets/common_widgets.dart';
// import 'package:app/features/auth/domain/entities/organization.dart';
// import 'package:app/features/auth/domain/entities/user.dart';
// import 'package:app/features/profile/domain/usecases/edit_user_profile_use_case.dart';
// import 'package:app/features/profile/domain/usecases/get_current_user_profile_use_case.dart';
// import 'package:app/features/profile/presentation/bloc/edit_user_profile_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class EditProfilePage extends StatelessWidget {
//   final User profile;
//   final Organization? organization; //Made optional
//   final String? email; // Made optional
//   const EditProfilePage({
//     super.key,
//     required this.profile,
//     this.organization,
//     this.email,
//   });

//   @override
//   Widget build(BuildContext context) {
//     try {
//       return BlocProvider(
//         create: (context) =>
//             EditUserProfileBloc(
//               editUserProfileUseCase:
//                   DependencyInjection.get<EditUserProfileUseCase>(),
//               getCurrentUserProfileUseCase:
//                   DependencyInjection.get<GetCurrentUserProfileUseCase>(),
//             )..add(
//               ProfileDetailInitialized(
//                 userId: profile.userId,
//                 profile: profile,
//               ),
//             ),
//         child: EditProfileView(
//           profile: profile,
//           organization: organization,
//           email: email,
//         ),
//       );
//     } catch (e) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Error')),
//         body: Center(child: Text('Failed to initialize form: $e')),
//       );
//     }
//   }
// }

// class EditProfileView extends StatelessWidget {
//   final User profile;
//   final Organization? organization;
//   final String? email;
//   const EditProfileView({
//     super.key,
//     required this.profile,
//     this.organization,
//     this.email,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final fullNameController = TextEditingController(text: profile.fullName);
//     final phoneController = TextEditingController(text: profile.phone);
//     final addressController = TextEditingController(text: profile.address);

//     final formKey = GlobalKey<FormState>();

//     return Scaffold(
//       // appBar: AppBar(title: const Text('Edit Profile')),
//       body: BlocBuilder<EditUserProfileBloc, EditUserProfileState>(
//         builder: (context, state) {
//           if (state is ProfileDetailLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           return RefreshIndicator(
//             onRefresh: () => _onRefresh(context),
//             child: CustomScrollView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               slivers: [
//                 SliverAppBar(
//                   pinned: true,
//                   stretch: true,
//                   leading: const BackButton(color: Colors.white),
//                   collapsedHeight: kToolbarHeight + UiConstants.spacingSm,

//                   elevation: 0,
//                   title: Text(
//                     profile.fullName,
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                   flexibleSpace: FlexibleSpaceBar(
//                     background: Container(
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).colorScheme.primary,
//                         borderRadius: const BorderRadius.vertical(
//                           bottom: Radius.circular(UiConstants.radiusXl),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//                 SliverPadding(
//                   padding: const EdgeInsets.all(16),
//                   sliver: SliverToBoxAdapter(
//                     child: Form(
//                       key: formKey,
//                       child: Column(
//                         children: [
//                           _buildInputCard(
//                             context,
//                             title: 'Full Name',
//                             controller: fullNameController,
//                             icon: Icons.person,
//                             hintText: 'Enter your full Name',
//                             validator: (value) => value == null || value.isEmpty
//                                 ? 'Full Name is required'
//                                 : null,
//                           ),
//                           const SizedBox(height: UiConstants.spacingSm),

//                           _buildInputCard(
//                             context,
//                             title: 'Address',
//                             controller: addressController,
//                             icon: Icons.location_on,
//                             hintText: 'Enter your address',
//                           ),
//                           const SizedBox(height: UiConstants.spacingSm),

//                           _buildInputCard(
//                             context,
//                             title: 'Phone',
//                             controller: phoneController,
//                             icon: Icons.phone,
//                             hintText: 'Enter your Phone',
//                           ),
//                           const SizedBox(height: UiConstants.spacingMd),

//                           _buildTapableCard(
//                             context,
//                             icon: Icons.business,
//                             title: 'Organization',
//                             subtitle: organization?.name ?? 'Name',
//                             onTap: () {},
//                           ),
//                           const SizedBox(height: UiConstants.spacingSm),

//                           _buildTapableCard(
//                             context,
//                             icon: Icons.badge_outlined,
//                             title: profile.role.name.toUpperCase(),
//                             subtitle: 'You can manage this organization.',
//                             onTap: () {},
//                           ),
//                           const SizedBox(height: UiConstants.spacingSm),

//                           _buildTapableCard(
//                             context,
//                             icon: Icons.email,
//                             title: email ?? 'Not added',
//                             subtitle:
//                                 'Adding email will help you to restore your profile in future',
//                             onTap: () {},
//                           ),

//                           const SizedBox(height: 32),

//                           SizedBox(
//                             width: double.infinity,
//                             child: CustomButton(
//                               text: "Save Changes",
//                               isLoading: state is ProfileDetailUpdating,
//                               onPressed: () {
//                                 if (formKey.currentState!.validate()) {
//                                   context.read<EditUserProfileBloc>().add(
//                                     const ProfileDetailUpdateRequested(),
//                                   );
//                                 }
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildInputCard(
//     BuildContext context, {
//     required String title,
//     required TextEditingController controller,
//     required IconData icon,
//     String? hintText,
//     String? Function(String?)? validator,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return SectionContainer(
//       borderRadius: BorderRadius.circular(UiConstants.radiusMd),
//       padding: const EdgeInsets.all(8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: Theme.of(context).textTheme.labelMedium?.copyWith(
//               fontWeight: FontWeight.w600,
//               color: Theme.of(context).colorScheme.onSurfaceVariant,
//             ),
//           ),
//           const SizedBox(height: 8),
//           TextFormField(
//             controller: controller,
//             validator: validator,
//             keyboardType: keyboardType,
//             onChanged: (val) {
//               if (title == 'Full Name') {
//                 context.read<EditUserProfileBloc>().add(
//                   ProfileFullNameChanged(fullName: val),
//                 );
//               } else if (title == 'Address') {
//                 context.read<EditUserProfileBloc>().add(
//                   ProfileAddressChanged(address: val),
//                 );
//               } else if (title == 'Phone') {
//                 context.read<EditUserProfileBloc>().add(
//                   ProfilePhoneChanged(phone: val),
//                 );
//               }
//             },
//             decoration: InputDecoration(
//               hintText: hintText ?? 'Enter $title',
//               prefixIcon: Icon(
//                 icon,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//               filled: true,
//               fillColor: Theme.of(
//                 context,
//               ).colorScheme.onSurfaceVariant.withAlpha(25),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTapableCard(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return SectionContainer(
//       borderRadius: BorderRadius.circular(UiConstants.radiusMd),
//       onTap: onTap,
//       padding: const EdgeInsets.all(8),
//       child: ListTile(
//         contentPadding: EdgeInsets.zero,
//         leading: Container(
//           padding: const EdgeInsets.all(8),
//           child: Icon(
//             icon,
//             color: Theme.of(context).colorScheme.primary,
//             size: 20,
//           ),
//         ),
//         title: Text(
//           title,
//           style: Theme.of(
//             context,
//           ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
//         ),
//         subtitle: Text(
//           subtitle,
//           style: Theme.of(context).textTheme.labelMedium?.copyWith(),
//         ),
//         trailing: Icon(
//           Icons.chevron_right,
//           color: Theme.of(context).colorScheme.onSurfaceVariant,
//           size: 20,
//         ),
//         // onTap: onTap,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   Future<void> _onRefresh(BuildContext context) async {
//     context.read<EditUserProfileBloc>().add(
//       ProfileDetailRefreshRequested(userId: profile.userId),
//     );
//   }
// }

import 'dart:async';

import 'package:app/app/dependency_injection.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/widgets/common_widgets.dart';
import 'package:app/features/auth/domain/entities/organization.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/profile/domain/usecases/edit_user_profile_use_case.dart';
import 'package:app/features/profile/domain/usecases/get_current_user_profile_use_case.dart';
import 'package:app/features/profile/presentation/bloc/edit_user_profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfilePage extends StatelessWidget {
  final User profile;
  final Organization? organization;
  final String? email;

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
              getCurrentUserProfileUseCase:
                  DependencyInjection.get<GetCurrentUserProfileUseCase>(),
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

class EditProfileView extends StatefulWidget {
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
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _addressController = TextEditingController(text: widget.profile.address);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<EditUserProfileBloc, EditUserProfileState>(
        listener: (context, state) {
          if (state is ProfileDetailUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is UpdateProfileDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ProfileDetailReady) {
            if (_fullNameController.text != state.fullName) {
              _fullNameController.text = state.fullName;
            }
            if (state.phone != null && _phoneController.text != state.phone) {
              _phoneController.text = state.phone!;
            }
            if (state.address != null &&
                _addressController.text != state.address) {
              _addressController.text = state.address!;
            }
          }
        },

        buildWhen: (previous, current) {
          return current is ProfileDetailLoading ||
              current is UpdateProfileDetailInitial;
        },
        builder: (context, state) {
          if (state is ProfileDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<EditUserProfileBloc>().add(
                ProfileDetailRefreshRequested(userId: widget.profile.userId),
              );

              return Future.value();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  stretch: true,
                  leading: const BackButton(color: Colors.white),
                  collapsedHeight: kToolbarHeight + UiConstants.spacingSm,
                  elevation: 0,
                  title: Text(
                    // Prefer controller text, fallback to widget profile
                    _fullNameController.text.isNotEmpty
                        ? _fullNameController.text
                        : widget.profile.fullName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(UiConstants.radiusXl),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildInputCard(
                            context,
                            title: 'Full Name',
                            controller: _fullNameController,
                            icon: Icons.person,
                            hintText: 'Enter your full Name',
                            validator: (value) => value == null || value.isEmpty
                                ? 'Full Name is required'
                                : null,
                          ),
                          const SizedBox(height: UiConstants.spacingSm),
                          _buildInputCard(
                            context,
                            title: 'Address',
                            controller: _addressController,
                            icon: Icons.location_on,
                            hintText: 'Enter your address',
                          ),
                          const SizedBox(height: UiConstants.spacingSm),
                          _buildInputCard(
                            context,
                            title: 'Phone',
                            controller: _phoneController,
                            icon: Icons.phone,
                            hintText: 'Enter your Phone',
                          ),
                          const SizedBox(height: UiConstants.spacingMd),

                          // _buildTapableCard(
                          //   context,
                          //   icon: Icons.business,
                          //   title: 'Organization',
                          //   subtitle: widget.organization?.name ?? 'Name',
                          //   onTap: () {},
                          // ),
                          // const SizedBox(height: UiConstants.spacingSm),
                          // _buildTapableCard(
                          //   context,
                          //   icon: Icons.badge_outlined,
                          //   title: widget.profile.role.name.toUpperCase(),
                          //   subtitle: 'You can manage this organization.',
                          //   onTap: () {},
                          // ),
                          // const SizedBox(height: UiConstants.spacingSm),
                          // _buildTapableCard(
                          //   context,
                          //   icon: Icons.email,
                          //   title: widget.email ?? 'Not added',
                          //   subtitle:
                          //       'Adding email will help you to restore your profile in future',
                          //   onTap: () {},
                          // ),
                          // const SizedBox(height: 32),
                          BlocBuilder<
                            EditUserProfileBloc,
                            EditUserProfileState
                          >(
                            builder: (context, btnState) {
                              return SizedBox(
                                width: double.infinity,
                                child: CustomButton(
                                  text: "Save Changes",
                                  isLoading: btnState is ProfileDetailUpdating,
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<EditUserProfileBloc>().add(
                                        const ProfileDetailUpdateRequested(),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
      // borderRadius: BorderRadius.circular(UiConstants.radiusMd),
      padding: const EdgeInsets.only(
        right: UiConstants.spacingMd,
        left: UiConstants.spacingMd,
        bottom: UiConstants.spacingMd,
        top: UiConstants.spacingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   title,
          //   style: Theme.of(context).textTheme.labelMedium?.copyWith(
          //     fontWeight: FontWeight.w600,
          //     color: Theme.of(context).colorScheme.onSurfaceVariant,
          //   ),
          // ),
          CustomTextField(
            label: title,
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            onChanged: (val) {
              if (title == 'Full Name') {
                context.read<EditUserProfileBloc>().add(
                  ProfileFullNameChanged(fullName: val),
                );
                // Force rebuild to update AppBar title
                setState(() {});
              } else if (title == 'Address') {
                context.read<EditUserProfileBloc>().add(
                  ProfileAddressChanged(address: val),
                );
              } else if (title == 'Phone') {
                context.read<EditUserProfileBloc>().add(
                  ProfilePhoneChanged(phone: val),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Widget _buildTapableCard(
  //   BuildContext context, {
  //   required IconData icon,
  //   required String title,
  //   required String subtitle,
  //   required VoidCallback onTap,
  // }) {
  //   return SectionContainer(
  //     borderRadius: BorderRadius.circular(UiConstants.radiusMd),
  //     onTap: onTap,
  //     padding: const EdgeInsets.all(8),
  //     child: ListTile(
  //       contentPadding: EdgeInsets.zero,
  //       leading: Container(
  //         padding: const EdgeInsets.all(8),
  //         color: Theme.of(context).colorScheme.primary.withAlpha(100),
  //         child: Icon(
  //           icon,
  //           color: Theme.of(context).colorScheme.primary,
  //           size: 20,
  //         ),
  //       ),
  //       title: Text(
  //         title,
  //         style: Theme.of(
  //           context,
  //         ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
  //       ),
  //       subtitle: Text(
  //         subtitle,
  //         style: Theme.of(context).textTheme.labelMedium?.copyWith(),
  //       ),
  //       trailing: Icon(
  //         Icons.chevron_right,
  //         color: Theme.of(context).colorScheme.onSurfaceVariant,
  //         size: 20,
  //       ),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     ),
  //   );
  // }
}
