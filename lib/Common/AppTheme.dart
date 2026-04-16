import 'package:flutter/material.dart';

// ─── Brand Colors ────────────────────────────────────────────────────────────
const kPrimary = Color(0xFF0D6EFD);
const kPrimaryDark = Color(0xFF0A58CA);
const kAccent = Color(0xFF06826f);
const kBg = Color(0xFFF4F6FA);
const kCard = Colors.white;
const kTextDark = Color(0xFF1A1A2E);
const kTextGrey = Color(0xFF8A8FA3);

// ─── Gradient ────────────────────────────────────────────────────────────────
const kGradient = LinearGradient(
  colors: [kPrimary, Color(0xFF56CCF2)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ─── Shared AppBar ───────────────────────────────────────────────────────────
PreferredSizeWidget buildAppBar(
  BuildContext context,
  String title, {
  VoidCallback? onBack,
  List<Widget>? actions,
}) {
  return AppBar(
    elevation: 0,
    flexibleSpace: Container(decoration: const BoxDecoration(gradient: kGradient)),
    title: Text(title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
      onPressed: onBack ?? () => Navigator.pop(context),
    ),
    actions: actions,
  );
}

// ─── Loader ──────────────────────────────────────────────────────────────────
Widget buildLoader() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/images/AppLogo.png", width: 80, height: 80),
        const SizedBox(height: 16),
        const CircularProgressIndicator(color: kPrimary, strokeWidth: 3),
      ],
    ),
  );
}

// ─── Empty State ─────────────────────────────────────────────────────────────
Widget buildEmptyState(String message, {IconData icon = Icons.inbox_outlined}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 64, color: kPrimary),
        ),
        const SizedBox(height: 20),
        Text(message,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: kTextGrey)),
      ],
    ),
  );
}

// ─── Section Header ──────────────────────────────────────────────────────────
Widget buildSectionHeader(String title, {String? subtitle}) {
  return Container(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
    child: Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kTextDark)),
            if (subtitle != null)
              Text(subtitle, style: const TextStyle(fontSize: 12, color: kTextGrey)),
          ],
        ),
      ],
    ),
  );
}

// ─── Gradient Button ─────────────────────────────────────────────────────────
Widget buildGradientButton(String label, VoidCallback onTap, {double? width}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: width ?? double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      alignment: Alignment.center,
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
    ),
  );
}

// ─── Info Row (label + value) ─────────────────────────────────────────────────
Widget buildInfoRow(String label, String value, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: kTextGrey, fontSize: 13)),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: valueColor ?? kTextDark)),
      ],
    ),
  );
}

// ─── Card Container ──────────────────────────────────────────────────────────
Widget buildCard({required Widget child, EdgeInsets? margin, EdgeInsets? padding, Color? color}) {
  return Container(
    margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color ?? kCard,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: child,
  );
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
Widget buildStatusBadge(String status) {
  Color bg;
  Color fg;
  switch (status.toLowerCase()) {
    case 'delivered':
      bg = const Color(0xFFE6F9F0); fg = const Color(0xFF06826f); break;
    case 'shipped':
      bg = const Color(0xFFE8F0FE); fg = kPrimary; break;
    case 'cancelled':
      bg = const Color(0xFFFFEBEB); fg = Colors.red; break;
    default:
      bg = const Color(0xFFFFF3E0); fg = const Color(0xFFE67E22);
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(status, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
  );
}
