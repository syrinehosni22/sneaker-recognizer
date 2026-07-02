import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_recognizer_plateform/services/auth_service.dart';

import 'connected_devices_screen.dart';
import 'download_and_password_sheets.dart';
import 'language_screen.dart';
import 'legal_text_screen.dart';
import 'location_privacy_screen.dart';
import 'payment_methods_screen.dart';
import 'permissions_screen.dart';
import 'profile_ui.dart';
import 'two_factor_sheet.dart';
import '../../../services/settings_repository.dart';
import '../../../services/settings_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  bool _settingsLoading = true;
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  bool _twoFactorEnabled = false;
  bool _unusualLoginAlerts = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // 1. Show cached values instantly so the UI never blocks on network.
    try {
      await _readCacheIntoState().timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Failed to read cached settings: $e');
    } finally {
      if (mounted) setState(() => _settingsLoading = false);
    }

    // 2. Reconcile with the backend in the background; update UI if it
    // returns something different (e.g. settings changed on another device).
    try {
      await SettingsRepository.refreshFromBackend().timeout(
        const Duration(seconds: 8),
      );
      await _readCacheIntoState();
    } catch (e) {
      debugPrint('Failed to sync settings from backend: $e');
    }
  }

  Future<void> _readCacheIntoState() async {
    final notifications = await SettingsService.getNotifications();
    final darkMode = await SettingsService.getDarkMode();
    final twoFactor = await SettingsService.getTwoFactor();
    final unusualAlerts = await SettingsService.getUnusualLoginAlerts();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = notifications;
      _darkMode = darkMode;
      _twoFactorEnabled = twoFactor;
      _unusualLoginAlerts = unusualAlerts;
    });
  }

  // ── Photo picker ───────────────────────────────────────────────────────────
  void _showPhotoOptions(AuthService auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            const SizedBox(height: 20),
            const Text(
              'Profile photo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                letterSpacing: -.3,
              ),
            ),
            const SizedBox(height: 20),
            _sheetRow(
              icon: Icons.photo_library_outlined,
              label: 'Choose from library',
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(auth, ImageSource.gallery);
              },
            ),
            _sheetRow(
              icon: Icons.camera_alt_outlined,
              label: 'Take a photo',
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(auth, ImageSource.camera);
              },
            ),
            if (auth.profileImage != null)
              _sheetRow(
                icon: Icons.delete_outline,
                label: 'Remove photo',
                color: Colors.red,
                onTap: () async {
                  Navigator.pop(context);
                  await auth.updateProfileImage('');
                  setState(() {});
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(AuthService auth, ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    await auth.updateProfileImage(picked.path);
    setState(() {});
  }

  // ── Edit profile sheet ─────────────────────────────────────────────────────
  void _showEditProfile(AuthService auth) {
    final nameCtrl = TextEditingController(text: auth.currentUser?.name ?? '');
    final emailCtrl = TextEditingController(
      text: auth.currentUser?.email ?? '',
    );
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.of(ctx).viewInsets.bottom +
                MediaQuery.of(ctx).padding.bottom +
                24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _sheetHandle()),
              const SizedBox(height: 20),
              const Text(
                'Edit profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  letterSpacing: -.3,
                ),
              ),
              const SizedBox(height: 20),
              _inputField(controller: nameCtrl, label: 'Name'),
              const SizedBox(height: 12),
              _inputField(
                controller: emailCtrl,
                label: 'Email',
                keyboard: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              _blackButton(
                label: loading ? null : 'Save changes',
                loading: loading,
                onTap: () async {
                  setSheet(() => loading = true);
                  try {
                    await auth.updateProfile(
                      name: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    _snack('Profile updated');
                  } catch (e) {
                    setSheet(() => loading = false);
                    _snack('Update failed: $e', error: true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Change password sheet ──────────────────────────────────────────────────
  void _showChangePassword(AuthService auth) {
    final emailCtrl = TextEditingController(
      text: auth.currentUser?.email ?? '',
    );
    bool loading = false;
    bool sent = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.of(ctx).viewInsets.bottom +
                MediaQuery.of(ctx).padding.bottom +
                24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _sheetHandle()),
              const SizedBox(height: 20),
              const Text(
                'Reset password',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  letterSpacing: -.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                sent
                    ? 'A reset link has been sent to your email.'
                    : 'We\'ll send a reset link to your email.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(.45),
                ),
              ),
              const SizedBox(height: 20),
              if (!sent)
                _inputField(
                  controller: emailCtrl,
                  label: 'Email',
                  keyboard: TextInputType.emailAddress,
                ),
              const SizedBox(height: 24),
              sent
                  ? _blackButton(label: 'Done', onTap: () => Navigator.pop(ctx))
                  : _blackButton(
                      label: loading ? null : 'Send reset link',
                      loading: loading,
                      onTap: () async {
                        setSheet(() => loading = true);
                        try {
                          await auth.resetPassword(emailCtrl.text.trim());
                          setSheet(() {
                            loading = false;
                            sent = true;
                          });
                        } catch (e) {
                          setSheet(() => loading = false);
                          _snack('Failed: $e', error: true);
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sécurité du compte : 2FA (backend-backed) ───────────────────────────────
  Future<void> _toggleTwoFactor(bool value) async {
    if (value) {
      final confirmed = await show2FASetupSheet(
        context,
        startSetup: () async {
          final setup = await SettingsRepository.start2FASetup();
          return {
            'qrCodeUrl': setup.qrCodeUrl,
            'manualSecret': setup.manualSecret,
          };
        },
        verifyCode: (code) => SettingsRepository.confirm2FASetup(code),
      );
      if (confirmed != true) return;
      if (!mounted) return;
      setState(() => _twoFactorEnabled = true);
      _snack('Double authentification activée');
    } else {
      final confirmed = await confirmDisable2FASheet(context);
      if (confirmed != true) return;
      final ok = await SettingsRepository.disable2FA();
      if (!mounted) return;
      if (ok) {
        setState(() => _twoFactorEnabled = false);
        _snack('Double authentification désactivée');
      } else {
        _snack('Échec de la désactivation, réessayez', error: true);
      }
    }
  }

  Future<void> _toggleUnusualAlerts(bool value) async {
    setState(() => _unusualLoginAlerts = value);
    final ok = await SettingsRepository.setUnusualLoginAlerts(value);
    if (!ok && mounted) {
      _snack('Synchronisation avec le serveur échouée', error: true);
    }
  }

  // ── Confirm logout ─────────────────────────────────────────────────────────
  void _confirmLogout(AuthService auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            const SizedBox(height: 24),
            const Text(
              'Log out?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                letterSpacing: -.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You will need to sign in again.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(.4),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _outlineButton(
                    label: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _blackButton(
                    label: 'Log out',
                    onTap: () async {
                      Navigator.pop(context);
                      await auth.logout();
                      if (mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Confirm delete (backend-backed) ─────────────────────────────────────────
  void _confirmDelete(AuthService auth) {
    bool loading = false;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHandle(),
              const SizedBox(height: 24),
              const Text(
                'Delete account?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  letterSpacing: -.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This action is permanent and cannot be undone.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(.4),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _outlineButton(
                      label: 'Cancel',
                      onTap: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _redButton(
                      label: loading ? '...' : 'Delete',
                      onTap: loading
                          ? () {}
                          : () async {
                              setSheet(() => loading = true);
                              final deleted =
                                  await SettingsRepository.deleteAccount();
                              if (!ctx.mounted) return;
                              if (!deleted) {
                                setSheet(() => loading = false);
                                _snack(
                                  'Échec de la suppression, réessayez',
                                  error: true,
                                );
                                return;
                              }
                              try {
                                await auth.logout();
                              } catch (_) {}
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (mounted) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                );
                                _snack('Compte supprimé');
                              }
                            },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Snackbar ───────────────────────────────────────────────────────────────
  void _snack(String msg, {bool error = false}) {
    ProfileUi.snack(context, msg, error: error);
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'Not logged in',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _settingsLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.black),
              )
            : RefreshIndicator(
                color: Colors.black,
                onRefresh: _loadSettings,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ───────────────────────────────────────────
                      _buildHeader(auth, user),
                      _thickDivider(),

                      // ── Account ─────────────────────────────────────────
                      _sectionLabel('Account'),
                      _row(
                        label: 'Edit profile',
                        icon: Icons.person_outline,
                        onTap: () => _showEditProfile(auth),
                      ),
                      _row(
                        label: 'Change password',
                        icon: Icons.lock_outline,
                        onTap: () => _showChangePassword(auth),
                      ),
                      _row(
                        label: 'Payment methods',
                        icon: Icons.credit_card_outlined,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaymentMethodsScreen(),
                          ),
                        ),
                      ),
                      _thickDivider(),

                      // ── Sécurité du compte ──────────────────────────────
                      _sectionLabel('Sécurité du compte'),
                      _row(
                        label: 'Mot de passe fort',
                        icon: Icons.password_outlined,
                        onTap: () => showPasswordTipsSheet(
                          context,
                          onChangePassword: () => _showChangePassword(auth),
                        ),
                      ),
                      _row(
                        label: 'Authentification à deux facteurs (2FA)',
                        icon: Icons.verified_user_outlined,
                        trailing: _switch(
                          value: _twoFactorEnabled,
                          onChanged: _toggleTwoFactor,
                        ),
                      ),
                      _row(
                        label: 'Appareils connectés',
                        icon: Icons.devices_outlined,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ConnectedDevicesScreen(),
                          ),
                        ),
                      ),
                      _row(
                        label: 'Alertes de connexion inhabituelle',
                        icon: Icons.notifications_active_outlined,
                        trailing: _switch(
                          value: _unusualLoginAlerts,
                          onChanged: _toggleUnusualAlerts,
                        ),
                      ),
                      _thickDivider(),

                      // ── Autorisations ────────────────────────────────────
                      _sectionLabel('Autorisations'),
                      _row(
                        label: 'Caméra, micro, photos, contacts, Bluetooth',
                        icon: Icons.admin_panel_settings_outlined,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PermissionsScreen(),
                          ),
                        ),
                      ),
                      _thickDivider(),

                      // ── Confidentialité ───────────────────────────────────
                      _sectionLabel('Confidentialité'),
                      _row(
                        label: 'Localisation',
                        icon: Icons.location_on_outlined,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LocationPrivacyScreen(),
                          ),
                        ),
                      ),
                      _thickDivider(),

                      // ── Preferences ───────────────────────────────────────
                      _sectionLabel('Preferences'),
                      _row(
                        label: 'Notifications',
                        icon: Icons.notifications_none_outlined,
                        trailing: _switch(
                          value: _notificationsEnabled,
                          onChanged: (v) async {
                            setState(() => _notificationsEnabled = v);
                            final ok =
                                await SettingsRepository.setNotifications(v);
                            if (!ok && mounted) {
                              _snack(
                                'Synchronisation avec le serveur échouée',
                                error: true,
                              );
                            }
                          },
                        ),
                      ),
                      _row(
                        label: 'Dark mode',
                        icon: Icons.dark_mode_outlined,
                        trailing: _switch(
                          value: _darkMode,
                          onChanged: (v) async {
                            setState(() => _darkMode = v);
                            final ok = await SettingsRepository.setDarkMode(v);
                            if (!ok && mounted) {
                              _snack(
                                'Synchronisation avec le serveur échouée',
                                error: true,
                              );
                            }
                          },
                        ),
                      ),
                      _row(
                        label: 'Language',
                        icon: Icons.language_outlined,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LanguageScreen(),
                          ),
                        ),
                      ),
                      _thickDivider(),

                      // ── Legal ───────────────────────────────────────────
                      _sectionLabel('Legal'),
                      _row(
                        label: 'Privacy policy',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LegalTextScreen(
                              title: 'Privacy policy',
                              content: LegalTextScreen.privacyPolicy,
                            ),
                          ),
                        ),
                      ),
                      _row(
                        label: 'Terms of use',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LegalTextScreen(
                              title: 'Terms of use',
                              content: LegalTextScreen.termsOfUse,
                            ),
                          ),
                        ),
                      ),
                      _row(
                        label: 'Licences',
                        onTap: () => showLicensePage(
                          context: context,
                          applicationName: 'Sneaker Recognizer',
                        ),
                      ),
                      _row(
                        label: 'Download my data',
                        onTap: () => showDownloadDataSheet(
                          context,
                          localFallback: {
                            'name': user.name,
                            'email': user.email,
                            'settings': {
                              'notifications': _notificationsEnabled,
                              'darkMode': _darkMode,
                              'twoFactorEnabled': _twoFactorEnabled,
                              'unusualLoginAlerts': _unusualLoginAlerts,
                            },
                          },
                        ),
                      ),
                      _thickDivider(),

                      // ── Logout / Delete ─────────────────────────────────
                      const SizedBox(height: 4),
                      _centeredRow(
                        label: 'Log out',
                        onTap: () => _confirmLogout(auth),
                      ),
                      _centeredRow(
                        label: 'Delete or suspend account',
                        onTap: () => _confirmDelete(auth),
                        color: Colors.red,
                      ),

                      // ── Version ──────────────────────────────────────────
                      const SizedBox(height: 32),
                      Center(
                        child: Text(
                          '1.0.0 (1)',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withOpacity(.3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(AuthService auth, dynamic user) {
    final hasImage = auth.profileImage != null && auth.profileImage!.isNotEmpty;

    return GestureDetector(
      onTap: () => _showEditProfile(auth),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Row(
          children: [
            // Avatar with tap to change
            GestureDetector(
              onTap: () => _showPhotoOptions(auth),
              child: Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: hasImage
                        ? Image.file(
                            File(auth.profileImage!),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey.shade100,
                            child: const Icon(
                              Icons.person_outline,
                              size: 30,
                              color: Colors.black54,
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Name + email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      letterSpacing: -.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(.45),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.black.withOpacity(.35),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reusable widgets ───────────────────────────────────────────────────────

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
    child: Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Colors.black.withOpacity(.4),
        letterSpacing: .6,
      ),
    ),
  );

  Widget _row({
    required String label,
    IconData? icon,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: Colors.black.withOpacity(.6)),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  ),
                ),
                trailing ??
                    (onTap != null
                        ? Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Colors.black.withOpacity(.35),
                          )
                        : const SizedBox()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Container(height: 0.5, color: Colors.black.withOpacity(.1)),
          ),
        ],
      ),
    );
  }

  Widget _centeredRow({
    required String label,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Center(
            child: Text(label, style: TextStyle(fontSize: 15, color: color)),
          ),
        ),
        Container(height: 0.5, color: Colors.black.withOpacity(.1)),
      ],
    ),
  );

  Widget _thickDivider() =>
      Container(height: 8, color: Colors.black.withOpacity(.04));

  Widget _switch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => Transform.scale(
    scale: 0.85,
    child: Switch(
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: Colors.black,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: Colors.black.withOpacity(.2),
    ),
  );

  Widget _sheetHandle() => Container(
    width: 36,
    height: 4,
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(.15),
      borderRadius: BorderRadius.circular(2),
    ),
  );

  Widget _sheetRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 14),
              Text(label, style: TextStyle(fontSize: 15, color: color)),
            ],
          ),
        ),
        Container(height: 0.5, color: Colors.black.withOpacity(.1)),
      ],
    ),
  );

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
  }) => TextField(
    controller: controller,
    keyboardType: keyboard,
    obscureText: obscure,
    style: const TextStyle(fontSize: 15, color: Colors.black),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 14, color: Colors.black.withOpacity(.45)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withOpacity(.3), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  Widget _blackButton({
    required String? label,
    bool loading = false,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
      ),
    ),
  );

  Widget _outlineButton({required String label, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
      );

  Widget _redButton({required String label, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
}
