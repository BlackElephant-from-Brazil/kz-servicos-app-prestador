import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kz_servicos_prestador/core/constants/app_colors.dart';
import 'package:kz_servicos_prestador/core/constants/map_styles.dart';
import 'package:kz_servicos_prestador/features/trip/data/models/mock_trip_history.dart';
import 'package:kz_servicos_prestador/features/trip/data/services/directions_service.dart';

class TripHistoryDetailPage extends StatefulWidget {
  final MockTripHistory trip;

  const TripHistoryDetailPage({super.key, required this.trip});

  @override
  State<TripHistoryDetailPage> createState() => _TripHistoryDetailPageState();
}

class _TripHistoryDetailPageState extends State<TripHistoryDetailPage> {
  Set<Polyline> _polylines = {};
  final DirectionsService _directionsService = DirectionsService();

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    final t = widget.trip;
    final points = await _directionsService.fetchRoute(
      origin: LatLng(t.originLat, t.originLng),
      destination: LatLng(t.destinationLat, t.destinationLng),
    );
    if (points.isNotEmpty && mounted) {
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route_glow'),
            points: points,
            color: AppColors.highlight.withValues(alpha: 0.18),
            width: 10,
          ),
          Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: AppColors.highlight,
            width: 4,
          ),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    final origin = LatLng(t.originLat, t.originLng);
    final destination = LatLng(t.destinationLat, t.destinationLng);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Detalhes da corrida',
          style: TextStyle(
            fontFamily: 'OutfitBlack',
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map preview
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      (origin.latitude + destination.latitude) / 2,
                      (origin.longitude + destination.longitude) / 2,
                    ),
                    zoom: 12,
                  ),
                  style: MapStyles.standard,
                  markers: {
                    Marker(
                      markerId: const MarkerId('pickup'),
                      position: origin,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueOrange,
                      ),
                    ),
                    Marker(
                      markerId: const MarkerId('destination'),
                      position: destination,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueOrange,
                      ),
                    ),
                  },
                  polylines: _polylines,
                  zoomControlsEnabled: false,
                  scrollGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  onMapCreated: (controller) {
                    Future.delayed(
                      const Duration(milliseconds: 300),
                      () => _fitMap(controller, origin, destination),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Price card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Valor da corrida',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${t.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: 'OutfitBlack',
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Client
            _SectionCard(
              children: [
                _DetailRow(
                  icon: Icons.person,
                  label: 'Cliente',
                  value: t.clientName,
                ),
                _DetailRow(
                  icon: Icons.people,
                  label: 'Passageiros',
                  value: '${t.passengers}',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Route
            _SectionCard(
              children: [
                _DetailRow(
                  icon: Icons.trip_origin,
                  label: 'Embarque',
                  value: t.origin,
                  iconColor: AppColors.highlight,
                ),
                _DetailRow(
                  icon: Icons.flag_rounded,
                  label: 'Destino',
                  value: t.destination,
                  iconColor: AppColors.highlight,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Trip stats
            _SectionCard(
              children: [
                _DetailRow(
                  icon: Icons.straighten,
                  label: 'Distância',
                  value: '${t.distanceKm.toStringAsFixed(1)} km',
                ),
                _DetailRow(
                  icon: Icons.timer_outlined,
                  label: 'Duração',
                  value: '${t.durationMinutes} min',
                ),
                _DetailRow(
                  icon: Icons.calendar_today,
                  label: 'Data',
                  value:
                      '${t.completedAt.day.toString().padLeft(2, '0')}/${t.completedAt.month.toString().padLeft(2, '0')}/${t.completedAt.year}',
                ),
                _DetailRow(
                  icon: Icons.access_time,
                  label: 'Horário',
                  value:
                      '${t.completedAt.hour.toString().padLeft(2, '0')}:${t.completedAt.minute.toString().padLeft(2, '0')}',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Payment
            _SectionCard(
              children: [
                _DetailRow(
                  icon: _paymentIcon(t.paymentMethod),
                  label: 'Pagamento',
                  value: t.paymentMethod,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Children
            if (t.hasChildren)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SectionCard(
                  children: [
                    _DetailRow(
                      icon: Icons.child_care,
                      label: 'Crianças',
                      value: t.childrenDescription ?? 'Sim',
                    ),
                  ],
                ),
              ),

            // Luggage
            if (t.hasLuggage)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SectionCard(
                  children: [
                    _DetailRow(
                      icon: Icons.luggage,
                      label: 'Bagagem',
                      value: t.luggageDescription ?? 'Sim',
                    ),
                  ],
                ),
              ),

            // Observations
            if (t.observations != null && t.observations!.isNotEmpty)
              _SectionCard(
                children: [
                  _DetailRow(
                    icon: Icons.notes,
                    label: 'Observações',
                    value: t.observations!,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  IconData _paymentIcon(String method) => switch (method) {
        'PIX' => Icons.pix_rounded,
        'TED' => Icons.account_balance,
        'Faturamento' => Icons.receipt_long,
        _ => Icons.credit_card,
      };

  void _fitMap(
    GoogleMapController controller,
    LatLng origin,
    LatLng destination,
  ) {
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            origin.latitude < destination.latitude
                ? origin.latitude
                : destination.latitude,
            origin.longitude < destination.longitude
                ? origin.longitude
                : destination.longitude,
          ),
          northeast: LatLng(
            origin.latitude > destination.latitude
                ? origin.latitude
                : destination.latitude,
            origin.longitude > destination.longitude
                ? origin.longitude
                : destination.longitude,
          ),
        ),
        40,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor ?? AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'QuasimodoSemiBold',
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
