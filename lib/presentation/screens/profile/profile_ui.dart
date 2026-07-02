import 'package:flutter/material.dart';

/// Small collection of the same visual primitives used in ProfileScreen,
/// extracted so the new sub-screens (Security, Permissions, Location...)
/// share an identical look without duplicating widgets everywhere.
class ProfileUi {
  static Widget sectionLabel(String label) => Padding(
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

  static Widget row({
    required String label,
    String? subtitle,
    IconData? icon,
    VoidCallback? onTap,
    Widget? trailing,
    Color color = Colors.black,
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
                  Icon(icon, size: 18, color: color.withOpacity(.7)),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontSize: 15, color: color)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.black.withOpacity(.45),
                          ),
                        ),
                      ],
                    ],
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

  static Widget thickDivider() =>
      Container(height: 8, color: Colors.black.withOpacity(.04));

  static Widget toggle({
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

  static Widget statusPill(String text, {required bool positive}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: (positive ? Colors.green : Colors.red).withOpacity(.08),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: positive ? Colors.green.shade700 : Colors.red.shade700,
      ),
    ),
  );

  static Widget sheetHandle() => Container(
    width: 36,
    height: 4,
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(.15),
      borderRadius: BorderRadius.circular(2),
    ),
  );

  static Widget blackButton({
    required String? label,
    bool loading = false,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: loading ? null : onTap,
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

  static Widget outlineButton({
    required String label,
    required VoidCallback onTap,
  }) => GestureDetector(
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

  static Widget scaffold({required String title, required Widget body}) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w500,
            letterSpacing: -.3,
          ),
        ),
      ),
      body: SafeArea(child: body),
    );
  }

  static void snack(BuildContext context, String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
