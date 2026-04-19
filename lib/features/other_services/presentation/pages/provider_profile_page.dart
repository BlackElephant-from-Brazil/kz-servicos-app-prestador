import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kz_servicos_prestador/core/constants/app_colors.dart';
import 'package:kz_servicos_prestador/core/widgets/service_provider_bottom_nav.dart';
import 'package:kz_servicos_prestador/features/profile/data/models/mock_provider.dart';

class ProviderProfilePage extends StatefulWidget {
  final ValueChanged<int> onNavTap;

  const ProviderProfilePage({super.key, required this.onNavTap});

  @override
  State<ProviderProfilePage> createState() =>
      _ProviderProfilePageState();
}

class _ProviderProfilePageState extends State<ProviderProfilePage> {
  final _provider = MockProvider.providerSample;
  String? _avatarPath;

  Future<void> _onEditPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() => _avatarPath = picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.fromLTRB(24, 24, 24, bottomPad + 100),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildOnlineStatus(),
                  const SizedBox(height: 16),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildCategoriesSection(),
                  const SizedBox(height: 16),
                  _buildMenuItems(),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: bottomPad + 12,
            left: 24,
            right: 24,
            child: ServiceProviderBottomNav(
              selectedIndex: 2,
              onItemSelected: widget.onNavTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor:
                  AppColors.highlight.withValues(alpha: 0.15),
              backgroundImage: _avatarPath != null
                  ? FileImage(File(_avatarPath!))
                  : null,
              child: _avatarPath == null
                  ? Text(
                      _provider.name[0],
                      style: const TextStyle(
                        fontFamily: 'OutfitBlack',
                        fontSize: 36,
                        color: AppColors.highlight,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _onEditPhoto,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.highlight,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _provider.name,
          style: const TextStyle(
            fontFamily: 'OutfitBlack',
            fontSize: 22,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _provider.email,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineStatus() {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _provider.isOnline
            ? const Color(0xFF2ECC71).withValues(alpha: 0.1)
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _provider.isOnline
                  ? const Color(0xFF2ECC71)
                  : Colors.red.shade400,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _provider.isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontFamily: 'OutfitBlack',
              fontSize: 14,
              color: _provider.isOnline
                  ? const Color(0xFF2ECC71)
                  : Colors.red.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatCard(
          icon: Icons.star,
          value: _provider.rating.toStringAsFixed(1),
          label: 'Avaliação',
          color: AppColors.highlight,
        ),
        const SizedBox(width: 12),
        _StatCard(
          icon: Icons.handyman_rounded,
          value: '${_provider.completedTrips}',
          label: 'Serviços',
          color: AppColors.secondary,
        ),
        const SizedBox(width: 12),
        _StatCard(
          icon: Icons.calendar_today,
          value: 'Desde ${_provider.memberSince}',
          label: 'Membro',
          color: const Color(0xFF2ECC71),
        ),
      ],
    );
  }

  static const _categoryColors = <String, Color>{
    'Eletricista': Color(0xFFE67E22),
    'Encanador': Color(0xFF3498DB),
    'Pintor': Color(0xFF9B59B6),
    'Faxineira': Color(0xFF1ABC9C),
    'Montador de Móveis': Color(0xFF8D6E63),
    'Técnico de Informática': Color(0xFF607D8B),
    'Jardineiro': Color(0xFF2ECC71),
    'Pedreiro': Color(0xFF795548),
    'Chaveiro': Color(0xFFF39C12),
    'Ar-condicionado': Color(0xFF00BCD4),
    'Marceneiro': Color(0xFFA1887F),
    'Vidraceiro': Color(0xFF42A5F5),
    'Serralheiro': Color(0xFF78909C),
    'Dedetizador': Color(0xFFEF5350),
  };

  Widget _buildCategoriesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categorias de serviço',
            style: TextStyle(
              fontFamily: 'OutfitBlack',
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _provider.serviceCategories.map((cat) {
              final color =
                  _categoryColors[cat] ?? AppColors.secondary;
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontFamily: 'QuasimodoSemiBold',
                    fontSize: 13,
                    color: color,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showHelpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Central de Ajuda',
                style: TextStyle(
                  fontFamily: 'OutfitBlack',
                  fontSize: 20,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _HelpRow(
                icon: Icons.phone_outlined,
                label: 'Telefone',
                value: '(11) 99999-0000',
                onTap: () =>
                    launchUrl(Uri.parse('tel:+5511999990000')),
              ),
              const Divider(height: 24),
              _HelpRow(
                icon: Icons.email_outlined,
                label: 'E-mail',
                value: 'contato@kzservicos.com.br',
                onTap: () => launchUrl(
                  Uri.parse('mailto:contato@kzservicos.com.br'),
                ),
              ),
              const Divider(height: 24),
              _HelpRow(
                icon: Icons.chat_outlined,
                label: 'WhatsApp',
                value: 'Fale conosco',
                iconColor: const Color(0xFF25D366),
                onTap: () => launchUrl(
                  Uri.parse('https://wa.me/5511999990000'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.chat_outlined,
            label: 'Mensagens',
            onTap: () => context.push('/messages'),
          ),
          _MenuItem(
            icon: Icons.history_rounded,
            label: 'Histórico de serviços',
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.security_outlined,
            label: 'Segurança',
            onTap: () => context.push('/security-settings'),
          ),
          _MenuItem(
            icon: Icons.help_outline,
            label: 'Ajuda',
            onTap: () => _showHelpSheet(context),
          ),
          _MenuItem(
            icon: Icons.logout,
            label: 'Sair',
            color: Colors.red.shade400,
            onTap: () => context.go('/login'),
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'OutfitBlack',
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final VoidCallback onTap;

  const _HelpRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon,
              color: iconColor ?? AppColors.secondary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'QuasimodoSemiBold',
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool showDivider;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading:
              Icon(icon, color: color ?? AppColors.textSecondary),
          title: Text(
            label,
            style: TextStyle(
              fontFamily: 'QuasimodoSemiBold',
              fontSize: 15,
              color: color ?? AppColors.textPrimary,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: color ?? AppColors.textSecondary,
          ),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 56,
            color: Colors.grey.shade200,
          ),
      ],
    );
  }
}
