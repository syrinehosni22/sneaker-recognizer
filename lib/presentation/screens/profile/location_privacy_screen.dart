import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../services/settings_repository.dart';
import '../../../services/settings_service.dart';
import 'profile_ui.dart';

class LocationPrivacyScreen extends StatefulWidget {
  const LocationPrivacyScreen({super.key});

  @override
  State<LocationPrivacyScreen> createState() => _LocationPrivacyScreenState();
}

class _LocationPrivacyScreenState extends State<LocationPrivacyScreen> {
  bool _loading = true;
  bool _sharingEnabled = false;
  LocationAccessMode _mode = LocationAccessMode.whileUsing;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Show cached values immediately, then reconcile with the backend.
    try {
      final sharing = await SettingsService.getLocationSharing();
      final mode = await SettingsService.getLocationMode();
      if (mounted) {
        setState(() {
          _sharingEnabled = sharing;
          _mode = mode;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }

    try {
      await SettingsRepository.refreshFromBackend().timeout(
        const Duration(seconds: 8),
      );
      final sharing = await SettingsService.getLocationSharing();
      final mode = await SettingsService.getLocationMode();
      if (!mounted) return;
      setState(() {
        _sharingEnabled = sharing;
        _mode = mode;
      });
    } catch (e) {
      debugPrint('Failed to sync location settings: $e');
    }
  }

  Future<void> _toggleSharing(bool v) async {
    if (v) {
      final status = await Permission.locationWhenInUse.request();
      if (!status.isGranted && !status.isLimited) {
        if (mounted) {
          ProfileUi.snack(
            context,
            'Autorisation de localisation refusée par le système.',
            error: true,
          );
        }
        return;
      }
    }
    setState(() => _sharingEnabled = v);
    final ok = await SettingsRepository.setLocationSharing(v);
    if (!ok && mounted) {
      ProfileUi.snack(
        context,
        'Synchronisation avec le serveur échouée',
        error: true,
      );
    }
    if (!v) await _setMode(LocationAccessMode.never);
  }

  Future<void> _setMode(LocationAccessMode mode) async {
    if (mode == LocationAccessMode.always) {
      final status = await Permission.locationAlways.request();
      if (!status.isGranted && mounted) {
        ProfileUi.snack(
          context,
          "L'accès permanent doit être autorisé depuis les réglages du système.",
          error: true,
        );
      }
    } else if (mode == LocationAccessMode.whileUsing) {
      await Permission.locationWhenInUse.request();
    }
    setState(() {
      _mode = mode;
      _sharingEnabled = mode != LocationAccessMode.never;
    });
    final ok = await SettingsRepository.setLocationMode(mode);
    if (!ok && mounted) {
      ProfileUi.snack(
        context,
        'Synchronisation avec le serveur échouée',
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileUi.scaffold(
      title: 'Confidentialité de la localisation',
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : ListView(
              children: [
                const SizedBox(height: 4),
                ProfileUi.row(
                  label: 'Partager ma position',
                  subtitle:
                      'Active ou désactive complètement le partage de la position.',
                  icon: Icons.location_on_outlined,
                  trailing: ProfileUi.toggle(
                    value: _sharingEnabled,
                    onChanged: _toggleSharing,
                  ),
                ),
                ProfileUi.thickDivider(),
                ProfileUi.sectionLabel('Accès à la localisation'),
                ...LocationAccessMode.values.map(
                  (mode) => GestureDetector(
                    onTap: () => _setMode(mode),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _mode == mode
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            size: 20,
                            color: _mode == mode
                                ? Colors.black
                                : Colors.black38,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mode.label,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  mode.description,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.black.withOpacity(.45),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
