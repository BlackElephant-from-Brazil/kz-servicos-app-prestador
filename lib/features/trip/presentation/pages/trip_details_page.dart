import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kz_servicos_prestador/core/constants/app_colors.dart';
import 'package:kz_servicos_prestador/core/constants/map_styles.dart';
import 'package:kz_servicos_prestador/features/trip/data/models/mock_trip_request.dart';
import 'package:kz_servicos_prestador/features/trip/data/services/directions_service.dart';

class TripDetailsPage extends StatefulWidget {
  final MockTripRequest request;

  const TripDetailsPage({super.key, required this.request});

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  Set<Polyline> _polylines = {};
  final DirectionsService _directionsService = DirectionsService();

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    final r = widget.request;
    final points = await _directionsService.fetchRoute(
      origin: LatLng(r.originLat, r.originLng),
      destination: LatLng(r.destinationLat, r.destinationLng),
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
    final r = widget.request;
    final origin = LatLng(r.originLat, r.originLng);
    final destination = LatLng(r.destinationLat, r.destinationLng);

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

            // Client info
            _SectionCard(
              children: [
                _DetailRow(
                  icon: Icons.person,
                  label: 'Cliente',
                  value: r.clientName,
                ),
                _DetailRow(
                  icon: Icons.people,
                  label: 'Passageiros',
                  value: '${r.passengers}',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Schedule
            _SectionCard(
              children: [
                _DetailRow(
                  icon: Icons.calendar_today,
                  label: 'Data',
                  value:
                      '${r.scheduledDate.day.toString().padLeft(2, '0')}/${r.scheduledDate.month.toString().padLeft(2, '0')}/${r.scheduledDate.year}',
                ),
                _DetailRow(
                  icon: Icons.access_time,
                  label: 'Horário',
                  value:
                      '${r.scheduledAt.hour.toString().padLeft(2, '0')}:${r.scheduledAt.minute.toString().padLeft(2, '0')}',
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
                  value: r.origin,
                  iconColor: AppColors.highlight,
                ),
                _DetailRow(
                  icon: Icons.flag_rounded,
                  label: 'Destino',
                  value: r.destination,
                  iconColor: AppColors.highlight,
                ),
                _DetailRow(
                  icon: Icons.straighten,
                  label: 'Distância',
                  value: '${r.distanceKm.toStringAsFixed(1)} km',
                ),
                _DetailRow(
                  icon: Icons.navigation,
                  label: 'Distância até embarque',
                  value: '${r.driverDistanceKm.toStringAsFixed(1)} km',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Children
            if (r.hasChildren)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SectionCard(
                  children: [
                    _DetailRow(
                      icon: Icons.child_care,
                      label: 'Crianças',
                      value: '${r.childrenCount}',
                    ),
                    if (r.childrenDescription != null)
                      _DetailRow(
                        icon: Icons.info_outline,
                        label: 'Detalhes',
                        value: r.childrenDescription!,
                      ),
                  ],
                ),
              ),

            // Luggage
            if (r.hasLuggage)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SectionCard(
                  children: [
                    _DetailRow(
                      icon: Icons.luggage,
                      label: 'Bagagem',
                      value: r.luggageDescription ?? 'Sim',
                    ),
                  ],
                ),
              ),

            // Payment
            _SectionCard(
              children: [
                _DetailRow(
                  icon: _paymentIcon(r.paymentMethod),
                  label: 'Pagamento',
                  value: r.paymentMethod,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Observations
            if (r.observations != null && r.observations!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SectionCard(
                  children: [
                    _DetailRow(
                      icon: Icons.notes,
                      label: 'Observações',
                      value: r.observations!,
                    ),
                  ],
                ),
              ),

            // Price
            _SectionCard(
              children: [
                _DetailRow(
                  icon: Icons.attach_money,
                  label: 'Valor estimado',
                  value: 'R\$ ${r.estimatedPrice.toStringAsFixed(2)}',
                  valueStyle: const TextStyle(
                    fontFamily: 'OutfitBlack',
                    fontSize: 18,
                    color: Color(0xFF2ECC71),
                  ),
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
      child: Column(
        children: children,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final TextStyle? valueStyle;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueStyle,
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
              style: valueStyle ??
                  const TextStyle(
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
