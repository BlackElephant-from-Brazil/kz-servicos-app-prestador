import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kz_servicos_prestador/core/models/trip_data.dart';

const _tripSelect =
    '*, pickup_address:addresses!pickup_address_id(formatted_address,latitude,longitude), '
    'dropoff_address:addresses!dropoff_address_id(formatted_address,latitude,longitude), '
    'client:users!client_id(full_name,phone)';

const _tripDetailSelect =
    '*, pickup_address:addresses!pickup_address_id(formatted_address,latitude,longitude), '
    'dropoff_address:addresses!dropoff_address_id(formatted_address,latitude,longitude), '
    'client:users!client_id(full_name,phone), '
    'trip_children(*), trip_luggage(*)';

const _tripHistorySelect =
    '*, pickup_address:addresses!pickup_address_id(formatted_address,latitude,longitude), '
    'dropoff_address:addresses!dropoff_address_id(formatted_address,latitude,longitude), '
    'client:users!client_id(full_name), '
    'ratings(score)';

class TripService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Convites pendentes para o motorista (trip_driver_candidates).
  Future<List<TripData>> getDriverInvitations(String driverProfileId) async {
    try {
      final res = await _client
          .from('trip_driver_candidates')
          .select('trip:trips!trip_id($_tripSelect)')
          .eq('driver_profile_id', driverProfileId)
          .eq('status', 'pending');
      return (res as List)
          .map((c) => (c as Map)['trip'] as Map<String, dynamic>?)
          .where((trip) => trip != null)
          .map((trip) => TripData.fromMap(trip!))
          .toList();
    } catch (e) {
      debugPrint('[TripService] getDriverInvitations erro: $e');
      return [];
    }
  }

  /// Aceita um convite de corrida (atualiza candidato para 'accepted').
  Future<bool> acceptCandidate(String tripId, String driverProfileId) async {
    try {
      await _client
          .from('trip_driver_candidates')
          .update({
            'status': 'accepted',
            'responded_at': DateTime.now().toIso8601String(),
          })
          .eq('trip_id', tripId)
          .eq('driver_profile_id', driverProfileId);
      return true;
    } catch (e) {
      debugPrint('[TripService] acceptCandidate erro: $e');
      return false;
    }
  }

  /// Recusa um convite de corrida (atualiza candidato para 'rejected').
  Future<bool> rejectCandidate(
    String tripId,
    String driverProfileId, {
    String? observation,
  }) async {
    try {
      await _client
          .from('trip_driver_candidates')
          .update({
            'status': 'rejected',
            'responded_at': DateTime.now().toIso8601String(),
            if (observation != null && observation.isNotEmpty)
              'observations': observation,
          })
          .eq('trip_id', tripId)
          .eq('driver_profile_id', driverProfileId);
      return true;
    } catch (e) {
      debugPrint('[TripService] rejectCandidate erro: $e');
      return false;
    }
  }

  /// Agendamentos do motorista (agendamentos tab).
  Future<List<TripData>> getDriverScheduledTrips(String providerProfileId) async {
    try {
      final res = await _client
          .from('trips')
          .select(_tripSelect)
          .eq('driver_profile_id', providerProfileId)
          .inFilter('status', [
            'awaiting_driver_confirmation',
            'awaiting_client_confirmation',
            'scheduled',
          ])
          .order('scheduled_datetime');
      return (res as List).map((m) => TripData.fromMap(m as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[TripService] getDriverScheduledTrips erro: $e');
      return [];
    }
  }

  /// Detalhes completos de uma corrida por ID.
  Future<TripData?> getTripById(String tripId) async {
    try {
      final res = await _client
          .from('trips')
          .select(_tripDetailSelect)
          .eq('id', tripId)
          .single();
      return TripData.fromMap(res);
    } catch (e) {
      debugPrint('[TripService] getTripById erro: $e');
      return null;
    }
  }

  /// Histórico de corridas finalizadas do motorista.
  Future<List<TripData>> getDriverTripHistory(String providerProfileId) async {
    try {
      final res = await _client
          .from('trips')
          .select(_tripHistorySelect)
          .eq('driver_profile_id', providerProfileId)
          .eq('status', 'finished')
          .order('finished_at', ascending: false);
      return (res as List).map((m) => TripData.fromMap(m as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[TripService] getDriverTripHistory erro: $e');
      return [];
    }
  }

  /// Aceita uma corrida disponível da home (status searching_drivers).
  Future<bool> acceptAvailableTrip(String tripId, String providerProfileId) async {
    try {
      await _client.from('trips').update({
        'driver_profile_id': providerProfileId,
        'status': 'awaiting_client_confirmation',
      }).eq('id', tripId);
      return true;
    } catch (e) {
      debugPrint('[TripService] acceptAvailableTrip erro: $e');
      return false;
    }
  }

  /// Confirma um agendamento aguardando confirmação do motorista.
  Future<bool> confirmScheduledTrip(String tripId, String? driverObservation) async {
    try {
      await _client.from('trips').update({
        'status': 'scheduled',
        if (driverObservation != null && driverObservation.isNotEmpty)
          'driver_observations': driverObservation,
      }).eq('id', tripId);
      return true;
    } catch (e) {
      debugPrint('[TripService] confirmScheduledTrip erro: $e');
      return false;
    }
  }

  /// Recusa uma corrida (disponível ou agendamento).
  Future<bool> rejectTrip(String tripId, String reason) async {
    try {
      await _client.from('trips').update({
        'driver_profile_id': null,
        'status': 'searching_drivers',
        'driver_observations': reason,
      }).eq('id', tripId);
      return true;
    } catch (e) {
      debugPrint('[TripService] rejectTrip erro: $e');
      return false;
    }
  }

  /// Ganhos do motorista: agrega corridas finalizadas por período.
  Future<EarningsData> getDriverEarnings(String providerProfileId) async {
    try {
      final res = await _client
          .from('trips')
          .select('id, estimated_price, final_price, scheduled_datetime, finished_at, payment_method')
          .eq('driver_profile_id', providerProfileId)
          .eq('status', 'finished')
          .order('finished_at', ascending: false);

      final trips = (res as List).cast<Map<String, dynamic>>();
      return EarningsData.fromTrips(trips);
    } catch (e) {
      debugPrint('[TripService] getDriverEarnings erro: $e');
      return EarningsData.empty();
    }
  }
}

// ── Earnings models ──────────────────────────────────────────────────────────

enum EarningType { trip, bonus, withdrawal }

class PeriodEarning {
  final double total;
  final int trips;
  const PeriodEarning({required this.total, required this.trips});
}

class MonthlyEarning {
  final int month;
  final int year;
  final double total;
  final int trips;
  const MonthlyEarning({
    required this.month,
    required this.year,
    required this.total,
    required this.trips,
  });
}

class EarningEntry {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final EarningType type;
  const EarningEntry({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
  });
}

class EarningsData {
  final double availableBalance;
  final double currentMonthTotal;
  final double previousMonthTotal;
  final PeriodEarning dailyEarning;
  final PeriodEarning weeklyEarning;
  final PeriodEarning monthlyEarning;
  final PeriodEarning yearlyEarning;
  final List<MonthlyEarning> monthlyHistory;
  final List<EarningEntry> recentEntries;

  const EarningsData({
    required this.availableBalance,
    required this.currentMonthTotal,
    required this.previousMonthTotal,
    required this.dailyEarning,
    required this.weeklyEarning,
    required this.monthlyEarning,
    required this.yearlyEarning,
    required this.monthlyHistory,
    required this.recentEntries,
  });

  EarningEntry get lastTransaction => recentEntries.isNotEmpty
      ? recentEntries.first
      : EarningEntry(
          id: '',
          description: '-',
          amount: 0,
          date: DateTime.now(),
          type: EarningType.trip,
        );

  factory EarningsData.empty() => const EarningsData(
        availableBalance: 0,
        currentMonthTotal: 0,
        previousMonthTotal: 0,
        dailyEarning: PeriodEarning(total: 0, trips: 0),
        weeklyEarning: PeriodEarning(total: 0, trips: 0),
        monthlyEarning: PeriodEarning(total: 0, trips: 0),
        yearlyEarning: PeriodEarning(total: 0, trips: 0),
        monthlyHistory: [],
        recentEntries: [],
      );

  factory EarningsData.fromTrips(List<Map<String, dynamic>> trips) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);
    final prevMonthStart = DateTime(now.year, now.month - 1, 1);
    final yearStart = DateTime(now.year, 1, 1);

    double daily = 0, weekly = 0, monthly = 0, prevMonthly = 0, yearly = 0;
    int dailyCount = 0, weeklyCount = 0, monthlyCount = 0, yearlyCount = 0;
    double totalBalance = 0;

    final monthMap = <String, MonthlyEarning>{};

    for (final t in trips) {
      final price = ((t['final_price'] ?? t['estimated_price']) as num?)?.toDouble() ?? 0;
      final finishedAtStr = t['finished_at'] as String?;
      if (finishedAtStr == null) continue;
      final finished = DateTime.parse(finishedAtStr);

      totalBalance += price;

      if (!finished.isBefore(yearStart)) {
        yearly += price;
        yearlyCount++;
      }
      if (!finished.isBefore(monthStart)) {
        monthly += price;
        monthlyCount++;
      }
      if (!finished.isBefore(prevMonthStart) && finished.isBefore(monthStart)) {
        prevMonthly += price;
      }
      if (!finished.isBefore(weekStart)) {
        weekly += price;
        weeklyCount++;
      }
      if (!finished.isBefore(todayStart)) {
        daily += price;
        dailyCount++;
      }

      final key = '${finished.year}-${finished.month.toString().padLeft(2, '0')}';
      final existing = monthMap[key];
      monthMap[key] = MonthlyEarning(
        month: finished.month,
        year: finished.year,
        total: (existing?.total ?? 0) + price,
        trips: (existing?.trips ?? 0) + 1,
      );
    }

    final history = monthMap.values.toList()
      ..sort((a, b) {
        final da = DateTime(a.year, a.month);
        final db = DateTime(b.year, b.month);
        return da.compareTo(db);
      });

    // Last 10 trips as entries
    final entries = trips.take(10).map((t) {
      final price =
          ((t['final_price'] ?? t['estimated_price']) as num?)?.toDouble() ?? 0;
      final finishedAtStr = t['finished_at'] as String? ?? '';
      final date = finishedAtStr.isNotEmpty
          ? DateTime.parse(finishedAtStr)
          : DateTime.now();
      return EarningEntry(
        id: t['id'] as String? ?? '',
        description: 'Corrida',
        amount: price,
        date: date,
        type: EarningType.trip,
      );
    }).toList();

    return EarningsData(
      availableBalance: totalBalance,
      currentMonthTotal: monthly,
      previousMonthTotal: prevMonthly,
      dailyEarning: PeriodEarning(total: daily, trips: dailyCount),
      weeklyEarning: PeriodEarning(total: weekly, trips: weeklyCount),
      monthlyEarning: PeriodEarning(total: monthly, trips: monthlyCount),
      yearlyEarning: PeriodEarning(total: yearly, trips: yearlyCount),
      monthlyHistory: history,
      recentEntries: entries,
    );
  }
}
