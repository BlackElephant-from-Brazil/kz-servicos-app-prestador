import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kz_servicos_prestador/core/constants/app_colors.dart';
import 'package:kz_servicos_prestador/core/constants/map_styles.dart';
import 'package:kz_servicos_prestador/features/schedules/data/models/mock_schedule.dart';

class ScheduleDetailPage extends StatefulWidget {
  final MockSchedule schedule;

  const ScheduleDetailPage({super.key, required this.schedule});

  @override
  State<ScheduleDetailPage> createState() => _ScheduleDetailPageState();
}

class _ScheduleDetailPageState extends State<ScheduleDetailPage> {
  final _observationController = TextEditingController();
  bool _observationError = false;

  MockSchedule get _schedule => widget.schedule;

  bool get _canRespond =>
      _schedule.status == ScheduleStatus.awaitingDriverConfirmation;

  @override
  void dispose() {
    _observationController.dispose();
    super.dispose();
  }

  void _accept() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Agendamento aceito com sucesso!'),
        backgroundColor: Color(0xFF2ECC71),
      ),
    );
    context.pop();
  }

  void _reject() {
    if (_observationController.text.trim().isEmpty) {
      setState(() => _observationError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Informe o motivo da recusa na observação',
          ),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Agendamento recusado'),
        backgroundColor: Colors.red.shade400,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final origin = LatLng(_schedule.originLat, _schedule.originLng);
    final dest = LatLng(_schedule.destinationLat, _schedule.destinationLng);
    final date = _schedule.scheduledDate;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

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
          'Detalhes do agendamento',
          style: TextStyle(
            fontFamily: 'OutfitBlack',
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Map preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 180,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            (origin.latitude + dest.latitude) / 2,
                            (origin.longitude + dest.longitude) / 2,
                          ),
                          zoom: 11,
                        ),
                        style: MapStyles.standard,
                        markers: {
                          Marker(
                            markerId: const MarkerId('origin'),
                            position: origin,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueGreen,
                            ),
                          ),
                          Marker(
                            markerId: const MarkerId('dest'),
                            position: dest,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed,
                            ),
                          ),
                        },
                        zoomControlsEnabled: false,
                        scrollGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status chip
                  _StatusChip(schedule: _schedule),
                  const SizedBox(height: 16),

                  // Client info
                  _SectionCard(
                    title: 'Cliente',
                    icon: Icons.person_outline,
                    children: [
                      _InfoRow(
                        label: 'Nome',
                        value: _schedule.clientName,
                      ),
                      _InfoRow(
                        label: 'Passageiros',
                        value: '${_schedule.passengers}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Schedule
                  _SectionCard(
                    title: 'Agendamento',
                    icon: Icons.calendar_today_outlined,
                    children: [
                      _InfoRow(label: 'Data', value: dateStr),
                      _InfoRow(label: 'Horário', value: timeStr),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Route
                  _SectionCard(
                    title: 'Rota',
                    icon: Icons.route_outlined,
                    children: [
                      _InfoRow(
                        label: 'Origem',
                        value: _schedule.origin,
                      ),
                      _InfoRow(
                        label: 'Destino',
                        value: _schedule.destination,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Children
                  if (_schedule.hasChildren) ...[
                    _SectionCard(
                      title: 'Crianças',
                      icon: Icons.child_care_outlined,
                      children: [
                        _InfoRow(
                          label: 'Detalhes',
                          value: _schedule.childrenDescription ??
                              'Sim',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Luggage
                  if (_schedule.hasLuggage) ...[
                    _SectionCard(
                      title: 'Bagagem',
                      icon: Icons.luggage_outlined,
                      children: [
                        _InfoRow(
                          label: 'Detalhes',
                          value: _schedule.luggageDescription ??
                              'Sim',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Payment
                  _SectionCard(
                    title: 'Pagamento',
                    icon: Icons.payment_outlined,
                    children: [
                      _InfoRow(
                        label: 'Método',
                        value: _schedule.paymentMethod,
                      ),
                      _InfoRow(
                        label: 'Valor estimado',
                        value: 'R\$ ${_schedule.price.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Client observations
                  if (_schedule.clientObservations != null) ...[
                    _SectionCard(
                      title: 'Observações do cliente',
                      icon: Icons.note_outlined,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _schedule.clientObservations!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Driver observation field
                  if (_canRespond) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: _observationError
                            ? Border.all(color: Colors.red, width: 1.5)
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.edit_note_outlined,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Sua observação',
                                style: TextStyle(
                                  fontFamily: 'OutfitBlack',
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (_observationError)
                                const Text(
                                  ' *',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontFamily: 'OutfitBlack',
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _observationController,
                            maxLines: 3,
                            onChanged: (_) {
                              if (_observationError) {
                                setState(() => _observationError = false);
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Escreva uma observação '
                                  '(obrigatório ao recusar)',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF7F7F8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.highlight,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Action buttons
          if (_canRespond) _buildActionBar(),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24, 16, 24, MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: _reject,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade400,
                  side: BorderSide(
                    color: Colors.red.shade400,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Recusar',
                  style: TextStyle(
                    fontFamily: 'OutfitBlack',
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _accept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Aceitar',
                  style: TextStyle(
                    fontFamily: 'OutfitBlack',
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final MockSchedule schedule;

  const _StatusChip({required this.schedule});

  Color get _color => switch (schedule.status) {
        ScheduleStatus.awaitingClientApproval => Colors.orange,
        ScheduleStatus.awaitingDriverConfirmation => AppColors.secondary,
        ScheduleStatus.scheduled => const Color(0xFF2ECC71),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: _color),
          const SizedBox(width: 8),
          Text(
            schedule.statusLabel,
            style: TextStyle(
              fontFamily: 'QuasimodoSemiBold',
              fontSize: 13,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'OutfitBlack',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
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
            ),
          ),
        ],
      ),
    );
  }
}
