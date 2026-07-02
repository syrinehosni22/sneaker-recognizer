import 'package:flutter/material.dart';
import '../../../services/settings_repository.dart';
import '../../../services/settings_service.dart';
import 'profile_ui.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  static const _languages = [
    {'code': 'fr', 'label': 'Français'},
    {'code': 'en', 'label': 'English'},
    {'code': 'ar', 'label': 'العربية'},
  ];

  String _selected = 'fr';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final code = await SettingsService.getLanguage();
      if (mounted) setState(() => _selected = code);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);

    try {
      await SettingsRepository.refreshFromBackend().timeout(
        const Duration(seconds: 8),
      );
      final code = await SettingsService.getLanguage();
      if (mounted) setState(() => _selected = code);
    } catch (e) {
      debugPrint('Failed to sync language: $e');
    }
  }

  Future<void> _select(String code) async {
    final previous = _selected;
    setState(() {
      _selected = code;
      _saving = true;
    });
    final ok = await SettingsRepository.setLanguage(code);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ProfileUi.snack(context, 'Langue mise à jour');
    } else {
      setState(() => _selected = previous);
      ProfileUi.snack(
        context,
        'Échec de la mise à jour, réessayez',
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileUi.scaffold(
      title: 'Langue',
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : ListView(
              children: _languages.map((lang) {
                final selected = lang['code'] == _selected;
                return GestureDetector(
                  onTap: _saving ? null : () => _select(lang['code']!),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            lang['label']!,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check,
                            size: 18,
                            color: Colors.black,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
