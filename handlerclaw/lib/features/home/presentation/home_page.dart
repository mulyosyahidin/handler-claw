import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/auth/presentation/login_controller.dart';
import 'package:handlerclaw/features/home/presentation/widgets/app_drawer.dart';

import 'package:handlerclaw/shared/themes/app_text_styles.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HandlerClaw',
          style: AppTextStyles.title(),
        ),

        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      drawer: AppDrawer(
        onLogout: () => ref.read(loginControllerProvider).logout(),
      ),
      body: const Center(child: Text('Home Content Here')),
    );
  }
}
