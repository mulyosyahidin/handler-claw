import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/features/profile/data/profile_api.dart';
import 'package:handlerclaw/shared/utils/toast_utils.dart';
import 'package:handlerclaw/shared/widgets/app_password_field.dart';
import 'package:handlerclaw/shared/widgets/app_submit_button.dart';

class PasswordUpdateForm extends ConsumerStatefulWidget {
  const PasswordUpdateForm({super.key});

  @override
  ConsumerState<PasswordUpdateForm> createState() => _PasswordUpdateFormState();
}

class _PasswordUpdateFormState extends ConsumerState<PasswordUpdateForm> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  Map<String, String> _fieldErrors = {};

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
      final response = await api.updatePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmNewPassword: _confirmPasswordController.text,
      );

      if (response.success) {
        if (mounted) {
          ToastUtils.showSuccess(
            context,
            title: 'Berhasil',
            description: 'Password Anda telah diperbarui',
          );
          _formKey.currentState!.reset();
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
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
          description: 'Terjadi kesalahan saat memperbarui password',
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
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
            AppPasswordField(
              label: 'Password Saat Ini',
              hint: 'Masukkan password lama Anda',
              controller: _currentPasswordController,
              onChanged: (_) {
                if (_fieldErrors.containsKey('current_password')) {
                  setState(() => _fieldErrors.remove('current_password'));
                }
              },
              validator: (value) {
                if (_fieldErrors.containsKey('current_password')) {
                  return _fieldErrors['current_password'];
                }
                if (value == null || value.isEmpty) {
                  return 'Password saat ini wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            AppPasswordField(
              label: 'Password Baru',
              hint: 'Masukkan password baru',
              controller: _newPasswordController,
              onChanged: (_) {
                if (_fieldErrors.containsKey('new_password')) {
                  setState(() => _fieldErrors.remove('new_password'));
                }
              },
              validator: (value) {
                if (_fieldErrors.containsKey('new_password')) {
                  return _fieldErrors['new_password'];
                }
                if (value == null || value.isEmpty) {
                  return 'Password baru wajib diisi';
                }
                if (value.length < 8) {
                  return 'Password minimal 8 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            AppPasswordField(
              label: 'Konfirmasi Password Baru',
              hint: 'Ulangi password baru',
              controller: _confirmPasswordController,
              onChanged: (_) {
                if (_fieldErrors.containsKey('confirm_new_password')) {
                  setState(() => _fieldErrors.remove('confirm_new_password'));
                }
              },
              validator: (value) {
                if (_fieldErrors.containsKey('confirm_new_password')) {
                  return _fieldErrors['confirm_new_password'];
                }
                if (value == null || value.isEmpty) {
                  return 'Konfirmasi password wajib diisi';
                }
                if (value != _newPasswordController.text) {
                  return 'Konfirmasi password tidak cocok';
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
