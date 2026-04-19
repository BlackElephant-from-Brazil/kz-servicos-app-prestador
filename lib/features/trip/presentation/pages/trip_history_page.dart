import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kz_servicos_prestador/core/constants/app_colors.dart';
import 'package:kz_servicos_prestador/features/trip/data/models/mock_trip_history.dart';

class TripHistoryPage extends StatefulWidget {
  const TripHistoryPage({super.key});

  @override
  State<TripHistoryPage> createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends State<TripHistoryPage> {
  final _allTrips = MockTripHistory.samples;
  String _activeFilter = 'Todas';
  DateTimeRange? _customRange;

  List<MockTripHistory> get _filteredTrips {
    final now = DateTime.now();
    return switch (_activeFilter) {
      'Este mês' => _allTrips
          .where((t) =>
              t.completedAt.month == now.month &&
              t.completedAt.year == now.year)
          .toList(),
      'Período' => _customRange != null
          ? _allTrips
              .where((t) =>
                  t.completedAt.isAfter(_customRange!.start
                      .subtract(const Duration(days: 1))) &&
                  t.completedAt.isBefore(
                      _customRange!.end.add(const Duration(days: 1))))
              .toList()
          : _allTrips,
      _ => _allTrips,
    };
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (range != null) {
      setState(() {
        _customRange = range;
        _activeFilter = 'Período';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final filtered = _filteredTrips;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Histórico de corridas',
                      style: TextStyle(
                        fontFamily: 'OutfitBlack',
                        fontSize: 24,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
                const SizedBox(height: 16),

                // Filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Todas',
                        isActive: _activeFilter == 'Todas',
                        onTap: () =>
                            setState(() => _activeFilter = 'Todas'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Este mês',
                        isActive: _activeFilter == 'Este mês',
                        onTap: () =>
                            setState(() => _activeFilter = 'Este mês'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Período',
                        isActive: _activeFilter == 'Período',
                        onTap: _pickDateRange,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Trip list
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhuma corrida encontrada',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            24,
                            0,
                            24,
                            bottomPadding + 16,
                          ),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => GestureDetector(
                              onTap: () => context.push(
                                '/trip-history-detail',
                                extra: filtered[i],
                              ),
                              child: _TripHistoryCard(trip: filtered[i]),
                            ),
                        ),
                ),
              ],
            ),
          ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.highlight : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? null
              : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'QuasimodoSemiBold',
            fontSize: 13,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _TripHistoryCard extends StatelessWidget {
  final MockTripHistory trip;

  const _TripHistoryCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Expanded(
                child: Text(
                  trip.clientName,
                  style: const TextStyle(
                    fontFamily: 'OutfitBlack',
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+R\$ ${trip.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: 'OutfitBlack',
                    fontSize: 14,
                    color: Color(0xFF2ECC71),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _RouteLine(
            origin: trip.origin,
            destination: trip.destination,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                '${trip.completedAt.day.toString().padLeft(2, '0')}/${trip.completedAt.month.toString().padLeft(2, '0')}/${trip.completedAt.year}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time,
                  size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                '${(trip.distanceKm / 30 * 60).round()} min',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 14, color: AppColors.highlight),
                  const SizedBox(width: 4),
                  Text(
                    trip.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteLine extends StatelessWidget {
  final String origin;
  final String destination;

  const _RouteLine({required this.origin, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2ECC71),
                  width: 2,
                ),
              ),
            ),
            Container(
              width: 2,
              height: 16,
              color: Colors.grey.shade300,
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red.shade400,
                  width: 2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                origin,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                destination,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
