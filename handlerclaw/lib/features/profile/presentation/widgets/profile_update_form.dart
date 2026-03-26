import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/providers/auth_session_provider.dart';
import 'package:handlerclaw/features/profile/data/profile_api.dart';
import 'package:handlerclaw/shared/utils/toast_utils.dart';
import 'package:handlerclaw/shared/widgets/app_submit_button.dart';
import 'package:handlerclaw/shared/widgets/app_text_field.dart';

class ProfileUpdateForm extends ConsumerStatefulWidget {
  const ProfileUpdateForm({super.key});

  @override
  ConsumerState<ProfileUpdateForm> createState() => _ProfileUpdateFormState();
}

class _ProfileUpdateFormState extends ConsumerState<ProfileUpdateForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  Map<String, String> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(authSessionProvider).value;
      if (session != null && session.userDto != null) {
        _nameController.text = session.userDto!.name;
        _emailController.text = session.userDto!.email;
      }
    });
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _fieldErrors = {};
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final api = ref.read(profileApiProvider);
      final response = await api.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
      );

      if (response.success && response.data != null) {
        // Update session
        await ref
            .read(authSessionProvider.notifier)
            .setSession(
              ref.read(authSessionProvider).value!.token!,
              response.data!.user,
            );

        if (mounted) {
          ToastUtils.showSuccess(
            context,
            title: 'Berhasil',
            description: 'Profil Anda telah diperbarui',
          );
        }
      } else {
        if (response.errors != null && response.errors is Map) {
          final errors = response.errors as Map<String, dynamic>;
          if (errors.containsKey('errors')) {
            setState(() {
              _fieldErrors = Map<String, String>.from(errors['errors']);
            });
            _formKey.currentState!.validate();
          }
        } else {
          if (mounted) {
            ToastUtils.showError(
              context,
              title: 'Gagal',
              description: response.message,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(
          context,
          title: 'Kesalahan',
          description: 'Terjadi kesalahan saat memperbarui profil',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            AppTextField(
              label: 'Nama Lengkap',
              hint: 'Masukkan nama lengkap Anda',
              controller: _nameController,
              onChanged: (_) {
                if (_fieldErrors.containsKey('name')) {
                  setState(() => _fieldErrors.remove('name'));
                }
              },
              validator: (value) {
                if (_fieldErrors.containsKey('name')) {
                  return _fieldErrors['name'];
                }
                if (value == null || value.isEmpty) {
                  return 'Nama wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Email',
              hint: 'Masukkan alamat email Anda',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) {
                if (_fieldErrors.containsKey('email')) {
                  setState(() => _fieldErrors.remove('email'));
                }
              },
              validator: (value) {
                if (_fieldErrors.containsKey('email')) {
                  return _fieldErrors['email'];
                }
                if (value == null || value.isEmpty) {
                  return 'Email wajib diisi';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            AppSubmitButton(
              text: 'Simpan',
              isLoading: _isLoading,
              loadingText: 'Menyimpan...',
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
