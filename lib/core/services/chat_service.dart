import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRoomData {
  final String id;
  final String? tripId;
  final String clientName;
  final String origin;
  final String destination;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ChatRoomData({
    required this.id,
    this.tripId,
    required this.clientName,
    required this.origin,
    required this.destination,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
  });
}

class ChatService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ChatRoomData>> getChatRooms(String userId) async {
    try {
      final res = await _client
          .from('chat_rooms')
          .select(
            'id, trip_id, '
            'trip:trips!trip_id('
            '  pickup_address:addresses!pickup_address_id(formatted_address), '
            '  dropoff_address:addresses!dropoff_address_id(formatted_address), '
            '  client:users!client_id(full_name)'
            '), '
            'messages:chat_messages(id, message, created_at, sender_id, is_read)',
          )
          .eq('provider_id', userId)
          .eq('is_active', true);

      final rooms = <ChatRoomData>[];
      for (final row in res as List) {
        final map = row as Map<String, dynamic>;
        final trip = map['trip'] as Map<String, dynamic>?;
        final msgs = (map['messages'] as List?) ?? [];

        final clientName =
            (trip?['client'] as Map?)?['full_name'] as String? ?? 'Cliente';
        final origin =
            (trip?['pickup_address'] as Map?)?['formatted_address'] as String? ?? '';
        final destination =
            (trip?['dropoff_address'] as Map?)?['formatted_address'] as String? ?? '';

        msgs.sort((a, b) {
          final da = DateTime.parse((a as Map)['created_at'] as String);
          final db = DateTime.parse((b as Map)['created_at'] as String);
          return db.compareTo(da);
        });

        final lastMsg = msgs.isNotEmpty ? msgs.first as Map<String, dynamic> : null;
        final unread = msgs
            .where((m) =>
                (m as Map)['sender_id'] != userId &&
                m['is_read'] == false)
            .length;

        rooms.add(ChatRoomData(
          id: map['id'] as String,
          tripId: map['trip_id'] as String?,
          clientName: clientName,
          origin: origin,
          destination: destination,
          lastMessage: lastMsg?['message'] as String?,
          lastMessageAt: lastMsg != null
              ? DateTime.parse(lastMsg['created_at'] as String)
              : null,
          unreadCount: unread,
        ));
      }

      rooms.sort((a, b) {
        if (a.unreadCount > 0 && b.unreadCount == 0) return -1;
        if (a.unreadCount == 0 && b.unreadCount > 0) return 1;
        final da = a.lastMessageAt ?? DateTime(2000);
        final db = b.lastMessageAt ?? DateTime(2000);
        return db.compareTo(da);
      });

      return rooms;
    } catch (e) {
      debugPrint('[ChatService] getChatRooms erro: $e');
      return [];
    }
  }
}
