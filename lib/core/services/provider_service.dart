import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kz_servicos_prestador/core/models/provider_profile_data.dart';
import 'package:kz_servicos_prestador/core/services/trip_service.dart';

class ProviderService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ProviderProfileData?> getProviderProfile(String userId) async {
    try {
      final res = await _client
          .from('users')
          .select(
            '*, provider_profiles('
            '*, service_categories(name), '
            'provider_category_services(service_categories(name))'
            ')',
          )
          .eq('id', userId)
          .single();
      return ProviderProfileData.fromMap(res);
    } catch (e) {
      debugPrint('[ProviderService] getProviderProfile erro: $e');
      return null;
    }
  }

  /// Ganhos do prestador a partir de service_requests.
  Future<EarningsData> getProviderEarnings(String providerProfileId) async {
    try {
      final res = await _client
          .from('service_requests')
          .select(
            'id, estimated_price, final_price, service_date, '
            'is_paid, status, payment_method',
          )
          .eq('provider_profile_id', providerProfileId)
          .order('service_date', ascending: false);

      final requests = (res as List).cast<Map<String, dynamic>>();
      return EarningsData.fromServiceRequests(requests);
    } catch (e) {
      debugPrint('[ProviderService] getProviderEarnings erro: $e');
      return EarningsData.empty();
    }
  }
}
