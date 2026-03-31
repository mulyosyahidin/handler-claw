import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlerclaw/core/theme/app_text_styles.dart';
import 'package:handlerclaw/core/utils/toast_utils.dart';
import 'package:handlerclaw/features/finances/application/account_type_controller.dart';
import 'package:handlerclaw/features/finances/domain/entities/account_type_entity.dart';

class EditAccountTypePage extends ConsumerStatefulWidget {
  final AccountTypeEntity type;

  const EditAccountTypePage({super.key, required this.type});

  @override
  ConsumerState<EditAccountTypePage> createState() =>
      _EditAccountTypePageState();
}

class _EditAccountTypePageState extends ConsumerState<EditAccountTypePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _selectedCategory;
  bool _isLoading = false;

  final List<String> _categories = ['LIQUID', 'DEBT', 'INVESTMENT'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.type.name);
    _selectedCategory = widget.type.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(accountTypeControllerProvider.notifier)
          .updateAccountType(
            id: widget.type.id,
            name: _nameController.text.trim(),
            category: _selectedCategory,
          );

      if (mounted) {
        ToastUtils.showSuccess(
          context,
          title: 'Berhasil',
          description: 'Tipe akun berhasil diperbarui',
        );
        // Do NOT pop, stay here as requested by user
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(
          context,
          title: 'Gagal',
          description: e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Tipe Akun', style: AppTextStyles.title()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Update Detail Tipe Akun',
                style: AppTextStyles.title(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Perbarui informasi untuk tipe akun "${widget.type.name}".',
                style: AppTextStyles.body(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Tipe Akun',
                  prefixIcon: const Icon(Icons.label_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),

              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih kategori';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 48),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
