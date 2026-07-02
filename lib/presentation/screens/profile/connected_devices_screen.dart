import 'package:flutter/material.dart';
import '../../../services/settings_repository.dart';
import 'profile_ui.dart';

class ConnectedDevicesScreen extends StatefulWidget {
  const ConnectedDevicesScreen({super.key});

  @override
  State<ConnectedDevicesScreen> createState() => _ConnectedDevicesScreenState();
}

class _ConnectedDevicesScreenState extends State<ConnectedDevicesScreen> {
  List<Device> _devices = [];
  bool _loading = true;
  String? _busyId; // device currently being revoked

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final devices = await SettingsRepository.fetchDevices().timeout(
        const Duration(seconds: 8),
      );
      if (!mounted) return;
      setState(() => _devices = devices);
    } catch (e) {
      debugPrint('Failed to load connected devices: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _revoke(Device device) async {
    setState(() => _busyId = device.id);
    final ok = await SettingsRepository.revokeDevice(device.id);
    if (!mounted) return;
    setState(() => _busyId = null);
    if (ok) {
      setState(() => _devices.removeWhere((d) => d.id == device.id));
      ProfileUi.snack(context, 'Déconnecté de "${device.name}"');
    } else {
      ProfileUi.snack(
        context,
        'Échec de la déconnexion, réessayez',
        error: true,
      );
    }
  }

  Future<void> _revokeAllOthers() async {
    setState(() => _busyId = 'all');
    final ok = await SettingsRepository.revokeAllOtherDevices();
    if (!mounted) return;
    setState(() => _busyId = null);
    if (ok) {
      setState(() => _devices = _devices.where((d) => d.current).toList());
      ProfileUi.snack(context, 'Déconnecté de tous les autres appareils');
    } else {
      ProfileUi.snack(
        context,
        'Échec de la déconnexion, réessayez',
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileUi.scaffold(
      title: 'Appareils connectés',
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : RefreshIndicator(
              color: Colors.black,
              onRefresh: _load,
              child: ListView(
                children: [
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Liste des appareils actuellement connectés à votre compte. '
                      "Déconnectez tout appareil que vous ne reconnaissez pas.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withOpacity(.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_devices.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'Aucun appareil trouvé',
                          style: TextStyle(color: Colors.black.withOpacity(.4)),
                        ),
                      ),
                    ),
                  ..._devices.map(
                    (d) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              d.current
                                  ? Icons.smartphone
                                  : Icons.devices_other,
                              size: 20,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      d.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                    if (d.current) ...[
                                      const SizedBox(width: 8),
                                      ProfileUi.statusPill(
                                        'Cet appareil',
                                        positive: true,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${d.location} · ${d.lastActive}',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.black.withOpacity(.45),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!d.current)
                            _busyId == d.id
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black45,
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () => _revoke(d),
                                    child: const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Text(
                                        'Déconnecter',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(height: 8, color: Colors.black.withOpacity(.04)),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ProfileUi.outlineButton(
                      label: _busyId == 'all'
                          ? '...'
                          : 'Déconnecter tous les autres appareils',
                      onTap: (_devices.length <= 1 || _busyId != null)
                          ? () {}
                          : _revokeAllOthers,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
