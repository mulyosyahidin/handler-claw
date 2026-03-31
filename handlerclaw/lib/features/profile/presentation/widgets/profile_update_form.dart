import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/providers/auth_session_provider.dart';
import 'package:handlerclaw/features/profile/application/profile_controller.dart';
import 'package:handlerclaw/core/utils/toast_utils.dart';
import 'package:handlerclaw/shared/widgets/app_submit_button.dart';
import 'package:handlerclaw/shared/widgets/app_text_field.dart';
import 'package:image_picker/image_picker.dart';

class ProfileUpdateForm extends ConsumerStatefulWidget {
  const ProfileUpdateForm({super.key});

  @override
  ConsumerState<ProfileUpdateForm> createState() => _ProfileUpdateFormState();
}

class _ProfileUpdateFormState extends ConsumerState<ProfileUpdateForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  Map<String, String> _fieldErrors = {};

  Future<void> _handleImagePick(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1000,
      maxHeight: 1000,
    );

    if (image == null) return;

    try {
      final response = await ref
          .read(profileControllerProvider.notifier)
          .updateAvatar(File(image.path));

      if (response.success) {
        if (mounted) {
          ToastUtils.showSuccess(
            context,
            title: 'Berhasil',
            description: 'Foto profil telah diperbarui',
          );
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
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'ProfileUpdateForm._handleImagePick',
      );
      if (mounted) {
        ToastUtils.showError(
          context,
          title: 'Kesalahan',
          description: 'Gagal memperbarui foto profil',
        );
      }
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _handleImagePick(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _handleImagePick(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(authSessionProvider).value;
      if (session?.user != null) {
        _nameController.text = session!.user!.name;
        _emailController.text = session.user!.email;
      }
    });
  }

  Future<void> _handleSubmit() async {
    setState(() => _fieldErrors = {});

    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await ref
          .read(profileControllerProvider.notifier)
          .updateProfile(
            name: _nameController.text,
            email: _emailController.text,
          );

      if (response.success) {
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
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'ProfileUpdateForm._handleSubmit',
      );
      if (mounted) {
        ToastUtils.showError(
          context,
          title: 'Kesalahan',
          description: 'Terjadi kesalahan saat memperbarui profil',
        );
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
    final isLoading = ref.watch(profileControllerProvider).isLoading;
    final session = ref.watch(authSessionProvider).value;
    final user = session?.user;
    final name = user?.name ?? '';
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join()
        : '?';
    final primary = Theme.of(context).colorScheme.primary;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primary.withValues(alpha: 0.08),
                        border: Border.all(
                          color: primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child:
                            user?.avatarUrl != null &&
                                user!.avatarUrl!.isNotEmpty
                            ? Image.network(
                                user.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      initials.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: primary,
                                      ),
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                              )
                            : Center(
                                child: Text(
                                  initials.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: primary,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImageSourceActionSheet,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 14,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

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
              isLoading: isLoading,
              loadingText: 'Menyimpan...',
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
