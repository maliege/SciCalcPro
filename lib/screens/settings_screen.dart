import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import 'guide_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Google Play package id — used to open the store listing for reviews.
  static const _packageName = 'com.maliege.scicalcpro';

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final controller = ThemeController.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ayarlar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _SectionTitle('Görünüm', color: colors.label),
          _ThemeCard(controller: controller),
          const SizedBox(height: 24),
          _SectionTitle('Yardım', color: colors.label),
          _ActionCard(
            icon: Icons.menu_book_outlined,
            iconColor: const Color(0xFF4FC3F7),
            title: 'Kullanım Rehberi',
            subtitle: 'Modüllerin nasıl kullanılacağını öğren',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GuideScreen()),
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Geri Bildirim', color: colors.label),
          _ActionCard(
            icon: Icons.star_rate_rounded,
            iconColor: const Color(0xFFFFB300),
            title: 'Uygulamayı Değerlendir',
            subtitle: 'Google Play\'de puan ver ve destek ol',
            onTap: () => _rateApp(context),
          ),
        ],
      ),
    );
  }

  Future<void> _rateApp(BuildContext context) async {
    // Prefer the Play Store app via market:// scheme, fall back to the web URL.
    final marketUri = Uri.parse('market://details?id=$_packageName');
    final webUri = Uri.parse(
        'https://play.google.com/store/apps/details?id=$_packageName');
    try {
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mağaza şu anda açılamadı.')),
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionTitle(this.text, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final ThemeController controller;
  const _ThemeCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _option(context, ThemeMode.system, Icons.brightness_auto,
              'Sistem', 'Cihaz ayarını izle'),
          Divider(color: colors.border, height: 1),
          _option(context, ThemeMode.light, Icons.light_mode_outlined,
              'Açık', 'Aydınlık tema'),
          Divider(color: colors.border, height: 1),
          _option(context, ThemeMode.dark, Icons.dark_mode_outlined,
              'Koyu', 'Karanlık tema'),
        ],
      ),
    );
  }

  Widget _option(BuildContext context, ThemeMode mode, IconData icon,
      String title, String subtitle) {
    final colors = context.appColors;
    final selected = controller.mode == mode;
    const accent = Color(0xFF4FC3F7);
    return InkWell(
      onTap: () => controller.setMode(mode),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: selected ? accent : colors.label),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: colors.primaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: TextStyle(color: colors.label, fontSize: 12)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, size: 20, color: accent),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 26, color: iconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: colors.primaryText,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    Text(subtitle,
                        style: TextStyle(color: colors.label, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.label),
            ],
          ),
        ),
      ),
    );
  }
}
