import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/profile/presentation/widgets/password_update_form.dart';
import 'package:handlerclaw/features/profile/presentation/widgets/profile_update_form.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/core/config/env.dart';
import 'package:go_router/go_router.dart';
import 'package:handlerclaw/app/app_router.dart';
import 'package:handlerclaw/core/providers/auth_session_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final authSession = ref.watch(authSessionProvider);
    final user = authSession.value?.user;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile', style: AppTextStyles.title()),
          actions: [
            if (Env.showDebugPage)
              IconButton(
                icon: const Icon(Icons.bug_report_outlined),
                onPressed: () => context.push(Routes.debug),
              ),
          ],
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
        body: TabBarView(
          children: [
            const SingleChildScrollView(child: ProfileUpdateForm()),
            if (user?.driver == 'GOOGLE')
              _buildGoogleAccountMessage(context)
            else
              const SingleChildScrollView(child: PasswordUpdateForm()),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleAccountMessage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_person_outlined,
              size: 64,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Akun Google Terhubung',
              style: AppTextStyles.title(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Anda masuk menggunakan akun Google. Silakan kelola keamanan dan kata sandi Anda langsung melalui pengaturan akun Google.',
              style: AppTextStyles.body(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
