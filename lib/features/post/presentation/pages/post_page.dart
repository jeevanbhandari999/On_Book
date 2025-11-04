import 'package:app/app/dependency_injection.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/post/presentation/pages/dummy_post_page.dart';
import 'package:app/features/post/services/post_services.dart';
import 'package:flutter/material.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  bool _isLoading = true;
  UserRole? _role;
  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      final postServices = DependencyInjection.get<PostServices>();
      final role = await postServices.getCurrentUserRole();

      if (!mounted) return;

      setState(() {
        _role = role;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_role == UserRole.worker || _role == UserRole.user) {
      return const DummyPostPage();
    }

    return Scaffold(appBar: AppBar(title: Text('Post page')));
  }
}
