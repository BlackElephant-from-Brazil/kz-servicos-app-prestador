import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kz_servicos_prestador/core/constants/app_colors.dart';

void showExternalNavSheet(BuildContext context, LatLng target) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Abrir navegação em',
            style: TextStyle(
              fontFamily: 'OutfitBlack',
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.map, color: AppColors.secondary),
            title: const Text('Google Maps'),
            onTap: () {
              Navigator.pop(ctx);
              launchUrl(Uri.parse(
                'google.navigation:q=${target.latitude},${target.longitude}',
              ));
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.navigation, color: Color(0xFF33CCFF)),
            title: const Text('Waze'),
            onTap: () {
              Navigator.pop(ctx);
              launchUrl(Uri.parse(
                'https://waze.com/ul?ll=${target.latitude},${target.longitude}&navigate=yes',
              ));
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
