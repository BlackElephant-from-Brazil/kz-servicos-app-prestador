import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kz_servicos_prestador/core/models/service_request_data.dart';

const _serviceRequestSelect =
    '*, service_categories(name), addresses(formatted_address), '
    'client:users!client_id(full_name)';

class ServiceRequestService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Solicitações disponíveis para o prestador (das suas categorias) +
  /// solicitações que ele já aceitou.
  Future<List<ServiceRequestData>> getProviderRequests(
    String providerProfileId,
  ) async {
    try {
      final categoriesRes = await _client
          .from('provider_category_services')
          .select('service_category_id')
          .eq('provider_profile_id', providerProfileId);

      final categoryIds = (categoriesRes as List)
          .map((c) => (c as Map)['service_category_id'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toList();

      final requests = <ServiceRequestData>[];

      if (categoryIds.isNotEmpty) {
        final openRes = await _client
            .from('service_requests')
            .select(_serviceRequestSelect)
            .filter('provider_profile_id', 'is', null)
            .eq('status', 'open')
            .inFilter('service_category_id', categoryIds)
            .order('service_date');

        requests.addAll(
          (openRes as List)
              .map((m) => ServiceRequestData.fromMap(m as Map<String, dynamic>)),
        );
      }

      final acceptedRes = await _client
          .from('service_requests')
          .select(_serviceRequestSelect)
          .eq('provider_profile_id', providerProfileId)
          .order('service_date');

      requests.addAll(
        (acceptedRes as List)
            .map((m) => ServiceRequestData.fromMap(m as Map<String, dynamic>)),
      );

      return requests;
    } catch (e) {
      debugPrint('[ServiceRequestService] getProviderRequests erro: $e');
      return [];
    }
  }

  /// Aceita uma solicitação (status open → assigned).
  Future<bool> acceptRequest(
    String requestId,
    String providerProfileId,
  ) async {
    try {
      await _client.from('service_requests').update({
        'provider_profile_id': providerProfileId,
        'status': 'assigned',
      }).eq('id', requestId);
      return true;
    } catch (e) {
      debugPrint('[ServiceRequestService] acceptRequest erro: $e');
      return false;
    }
  }
}
