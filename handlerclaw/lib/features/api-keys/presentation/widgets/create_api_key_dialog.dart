import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/features/api-keys/application/api_keys_controller.dart';
import 'package:handlerclaw/features/api-keys/domain/entities/api_key_entity.dart';

import 'package:handlerclaw/features/api-keys/presentation/widgets/api_key_success_dialog.dart';

class CreateApiKeyDialog extends ConsumerStatefulWidget {
  const CreateApiKeyDialog({super.key});

  @override
  ConsumerState<CreateApiKeyDialog> createState() => _CreateApiKeyDialogState();
}

class _CreateApiKeyDialogState extends ConsumerState<CreateApiKeyDialog> {
  final _nameController = TextEditingController();
  bool _isLoading = false;
  ApiKeyEntity? _createdKey;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (_nameController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final key = await ref
          .read(apiKeyListControllerProvider.notifier)
          .createKey(_nameController.text);
      if (mounted) {
        setState(() {
          _createdKey = key;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'CreateApiKeyDialog._handleCreate',
      );
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membuat API Key: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_createdKey != null) {
      return ApiKeySuccessDialog(apiKey: _createdKey!);
    }

    return AlertDialog(
      title: Text(
        'Buat API Key Baru',
        style: AppTextStyles.title(fontSize: 18),
      ),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Nama API Key',
          hintText: 'Misal: My App, Production, dsb.',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleCreate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Buat'),
        ),
      ],
    );
  }
}
