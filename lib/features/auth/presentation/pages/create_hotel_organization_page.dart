import 'package:app/features/auth/data/models/user_model.dart';
import 'package:flutter/material.dart';

class CreateHotelOrganizationPage extends StatelessWidget {
  final UserModel? user;
  const CreateHotelOrganizationPage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    print('the logged in user is : $user');
    return Scaffold(
      appBar: AppBar(title: const Text('Create Hotel'), centerTitle: true),
      body: Center(child: Text('Create hotel organization')),
    );
  }
}
