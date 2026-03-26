import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/profile/presentation/widgets/password_update_form.dart';
import 'package:handlerclaw/features/profile/presentation/widgets/profile_update_form.dart';
import 'package:handlerclaw/shared/themes/app_text_styles.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile', style: AppTextStyles.title()),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Profile'),
              Tab(text: 'Password'),
            ],
            labelStyle: AppTextStyles.body(fontWeight: FontWeight.w600),
            unselectedLabelStyle: AppTextStyles.body(),
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.5),
            indicatorColor: colorScheme.primary,
          ),
        ),
        body: const TabBarView(
          children: [
            SingleChildScrollView(child: ProfileUpdateForm()),
            SingleChildScrollView(child: PasswordUpdateForm()),
          ],
        ),
      ),
    );
  }
}
