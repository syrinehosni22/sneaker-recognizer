import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'profile_ui.dart';

class _PermissionItem {
  final String label;
  final String description;
  final IconData icon;
  final Permission permission;

  const _PermissionItem({
    required this.label,
    required this.description,
    required this.icon,
    required this.permission,
  });
}

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with WidgetsBindingObserver {
  final List<_PermissionItem> _items = const [
    _PermissionItem(
      label: 'Caméra',
      description: 'Nécessaire pour scanner et reconnaître vos sneakers.',
      icon: Icons.camera_alt_outlined,
      permission: Permission.camera,
    ),
    _PermissionItem(
      label: 'Microphone',
      description: 'Utilisé pour les notes vocales et les appels support.',
      icon: Icons.mic_none_outlined,
      permission: Permission.microphone,
    ),
    _PermissionItem(
      label: 'Photos et fichiers',
      description: "Permet d'importer des photos depuis votre galerie.",
      icon: Icons.photo_library_outlined,
      permission: Permission.photos,
    ),
    _PermissionItem(
      label: 'Contacts',
      description: 'Permet d\'inviter des amis depuis vos contacts.',
      icon: Icons.contacts_outlined,
      permission: Permission.contacts,
    ),
    _PermissionItem(
      label: 'Bluetooth',
      description: 'Utilisé pour connecter des accessoires compatibles.',
      icon: Icons.bluetooth,
      permission: Permission.bluetooth,
    ),
  ];

  Map<Permission, PermissionStatus> _statuses = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check statuses when the user comes back from the OS settings screen.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final entries = await Future.wait(
      _items.map(
        (i) async => MapEntry(i.permission, await i.permission.status),
      ),
    );
    if (!mounted) return;
    setState(() {
      _statuses = Map.fromEntries(entries);
      _loading = false;
    });
  }

  Future<void> _handleTap(_PermissionItem item) async {
    final status = _statuses[item.permission] ?? PermissionStatus.denied;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return;
    }
    final result = await item.permission.request();
    if (!mounted) return;
    setState(() => _statuses[item.permission] = result);
    if (result.isPermanentlyDenied) {
      ProfileUi.snack(
        context,
        "Autorisation refusée. Activez-la depuis les réglages du système.",
        error: true,
      );
    }
  }

  String _statusLabel(PermissionStatus? s) {
    if (s == null) return 'Inconnu';
    if (s.isGranted || s.isLimited) return 'Autorisé';
    if (s.isPermanentlyDenied) return 'Bloqué';
    return 'Refusé';
  }

  @override
  Widget build(BuildContext context) {
    return ProfileUi.scaffold(
      title: 'Autorisations',
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : RefreshIndicator(
              color: Colors.black,
              onRefresh: _refresh,
              child: ListView(
                children: [
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Gérez les accès matériels accordés à l'application. "
                      'Un accès bloqué doit être réactivé depuis les réglages du système.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withOpacity(.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._items.map((item) {
                    final status = _statuses[item.permission];
                    final granted =
                        status?.isGranted == true || status?.isLimited == true;
                    return ProfileUi.row(
                      label: item.label,
                      subtitle: item.description,
                      icon: item.icon,
                      onTap: () => _handleTap(item),
                      trailing: ProfileUi.statusPill(
                        _statusLabel(status),
                        positive: granted,
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
