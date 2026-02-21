import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telemost12_app/theme/app_theme.dart';
import 'package:telemost12_app/widgets/glass_panel.dart';
import 'package:telemost12_app/services/addresses_service.dart';
import 'package:telemost12_app/models/address.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    AddressesService.instance.load();
  }

  Future<void> _showAddDialog() async {
    final c = AppTheme.of(context);
    final labelC = TextEditingController();
    final streetC = TextEditingController();
    final cityC = TextEditingController();
    final phoneC = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surfaceElevated,
        title: Text(
          'Новый адрес',
          style: GoogleFonts.outfit(color: c.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelC,
                decoration: const InputDecoration(labelText: 'Название (например: Дом)'),
                style: GoogleFonts.outfit(color: c.textPrimary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: streetC,
                decoration: const InputDecoration(labelText: 'Улица, дом'),
                style: GoogleFonts.outfit(color: c.textPrimary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityC,
                decoration: const InputDecoration(labelText: 'Город'),
                style: GoogleFonts.outfit(color: c.textPrimary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneC,
                decoration: const InputDecoration(labelText: 'Телефон'),
                keyboardType: TextInputType.phone,
                style: GoogleFonts.outfit(color: c.textPrimary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Отмена', style: GoogleFonts.outfit(color: c.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Сохранить', style: GoogleFonts.outfit(color: c.accent)),
          ),
        ],
      ),
    );
    if (ok == true &&
        labelC.text.trim().isNotEmpty &&
        streetC.text.trim().isNotEmpty &&
        cityC.text.trim().isNotEmpty &&
        phoneC.text.trim().isNotEmpty) {
      await AddressesService.instance.add(Address(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: labelC.text.trim(),
        street: streetC.text.trim(),
        city: cityC.text.trim(),
        phone: phoneC.text.trim(),
      ));
    }
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
                    Text(
                      'Адреса доставки',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: AddressesService.instance,
                  builder: (_, __) {
                    final addresses = AddressesService.instance.addresses;
                    if (addresses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_off_rounded, size: 64, color: c.textSecondary),
                            const SizedBox(height: 20),
                            Text(
                              'Нет сохранённых адресов',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: c.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Добавьте адрес для доставки',
                              style: GoogleFonts.outfit(fontSize: 14, color: c.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final a = addresses[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: buildGlassPanel(context,
                            borderRadius: 16,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: c.surface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.location_on_rounded, color: c.textPrimary),
                              ),
                              title: Text(
                                a.label,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: c.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                '${a.street}, ${a.city}\n${a.phone}',
                                style: GoogleFonts.outfit(fontSize: 14, color: c.textSecondary),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline_rounded, color: c.textSecondary),
                                onPressed: () async {
                                  await AddressesService.instance.remove(a.id);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: c.accent,
        foregroundColor: c.background,
        icon: const Icon(Icons.add_rounded),
        label: Text('Добавить адрес', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
