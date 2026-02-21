import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:telemost12_app/theme/app_theme.dart';
import 'package:telemost12_app/widgets/glass_panel.dart';
import 'package:telemost12_app/services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nicknameController = TextEditingController();
  final _profileService = ProfileService.instance;
  final _imagePicker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nicknameController.text = _profileService.nickname ?? '';
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final c = AppTheme.of(context);
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: c.surfaceElevated,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Выберите фото',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.photo_library_rounded, color: c.textPrimary),
                  title: Text(
                    'Галерея',
                    style: GoogleFonts.outfit(color: c.textPrimary),
                  ),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt_rounded, color: c.textPrimary),
                  title: Text(
                    'Камера',
                    style: GoogleFonts.outfit(color: c.textPrimary),
                  ),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
              ],
            ),
          ),
        ),
      );
      if (source == null || !mounted) return;
      setState(() => _isLoading = true);
      final xFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (xFile != null) {
        await _profileService.setAvatarFromPath(xFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось загрузить фото: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removeAvatar() async {
    await _profileService.removeAvatar();
  }

  Future<void> _save() async {
    await _profileService.setNickname(_nicknameController.text);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: c.backgroundGradient,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Редактировать профиль',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : _save,
                      child: Text(
                        'Сохранить',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: c.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: GestureDetector(
                        onTap: _isLoading ? null : _pickImage,
                        child: ListenableBuilder(
                          listenable: _profileService,
                          builder: (_, __) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: c.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: c.border, width: 2),
                                  ),
                                  child: _isLoading
                                      ? Center(
                                          child: SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: c.accent,
                                            ),
                                          ),
                                        )
                                      : _profileService.hasAvatar
                                          ? ClipOval(
                                              child: Image.file(
                                                File(_profileService.avatarPath!),
                                                key: ValueKey(_profileService.avatarVersion),
                                                fit: BoxFit.cover,
                                                width: 120,
                                                height: 120,
                                              ),
                                            )
                                          : Icon(
                                              Icons.person_rounded,
                                              size: 56,
                                              color: c.textSecondary,
                                            ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: c.accent,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.camera_alt_rounded,
                                      color: c.background,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    ListenableBuilder(
                      listenable: _profileService,
                      builder: (_, __) {
                        if (!_profileService.hasAvatar) return const SizedBox.shrink();
                        return Column(
                          children: [
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton(
                                onPressed: _isLoading ? null : _removeAvatar,
                                child: Text(
                                  'Удалить фото',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    color: c.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    buildGlassPanel(context,
                      borderRadius: 16,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: TextField(
                          controller: _nicknameController,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: c.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Никнейм',
                            labelStyle: GoogleFonts.outfit(color: c.textSecondary),
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
