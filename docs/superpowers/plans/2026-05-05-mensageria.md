# Mensageria por Corridas/Serviços — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Substituir a lista de salas genéricas de chat por corridas/serviços reais do motorista/prestador, com chat em tempo real via Supabase Realtime.

**Architecture:** Novo `TripChatService` substitui o `ChatService` atual. Os dados são carregados via query única (trips/service_requests com join em chat_rooms e chat_messages). Realtime via `supabase_flutter` `.stream()` no ChatPage. Modelos puros (`ChatEntryData`, `ChatMessageData`, `ChatPageArgs`) concentram a lógica de transformação de dados, testada com testes unitários sem mocking de Supabase.

**Tech Stack:** Flutter, Dart, `supabase_flutter ^2.8.0`, `flutter_test` (SDK), `go_router ^17.2.1`

---

## File Map

| Ação | Arquivo |
|------|---------|
| **Criar** | `lib/core/services/trip_chat_service.dart` |
| **Criar** | `test/core/services/trip_chat_service_test.dart` |
| **Modificar** | `lib/features/chat/presentation/pages/messages_page.dart` |
| **Modificar** | `lib/features/chat/presentation/pages/chat_page.dart` |
| **Modificar** | `lib/routes/app_router.dart` |
| **Deletar** | `lib/core/services/chat_service.dart` |
| **Deletar** | `lib/features/chat/data/models/mock_message.dart` |

---

## Task 1: Criar modelos e testes de transformação de dados

**Files:**
- Create: `lib/core/services/trip_chat_service.dart` (apenas modelos + helpers estáticos)
- Create: `test/core/services/trip_chat_service_test.dart`

- [ ] **Step 1: Escrever o teste falhando**

Criar `test/core/services/trip_chat_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:kz_servicos_prestador/core/services/trip_chat_service.dart';

void main() {
  group('ChatMessageData.fromMap', () {
    test('parses all fields correctly', () {
      final map = {
        'id': 'msg-1',
        'sender_id': 'user-123',
        'message': 'Olá, tudo bem?',
        'is_read': false,
        'created_at': '2026-04-15T07:50:00.000Z',
      };
      final msg = ChatMessageData.fromMap(map);
      expect(msg.id, 'msg-1');
      expect(msg.senderId, 'user-123');
      expect(msg.message, 'Olá, tudo bem?');
      expect(msg.isRead, false);
      expect(msg.sentAt, DateTime.parse('2026-04-15T07:50:00.000Z'));
    });

    test('defaults is_read to false when null', () {
      final map = {
        'id': 'msg-2',
        'sender_id': 'user-123',
        'message': 'Oi',
        'is_read': null,
        'created_at': '2026-04-15T08:00:00.000Z',
      };
      final msg = ChatMessageData.fromMap(map);
      expect(msg.isRead, false);
    });
  });

  group('TripChatService.buildEntryFromTrip', () {
    const userId = 'driver-user-123';

    test('builds entry with room and unread count', () {
      final row = {
        'id': 'trip-1',
        'scheduled_datetime': '2026-04-15T08:30:00.000Z',
        'pickup_address': {'formatted_address': 'Rua Augusta, 1200'},
        'dropoff_address': {'formatted_address': 'Aeroporto de Guarulhos'},
        'client': {'id': 'client-1', 'full_name': 'Ana Carolina'},
        'chat_rooms': [
          {
            'id': 'room-1',
            'chat_messages': [
              {
                'id': 'msg-1',
                'sender_id': 'client-1',
                'message': 'Pode confirmar o endereço?',
                'is_read': false,
                'created_at': '2026-04-15T07:50:00.000Z',
              },
            ],
          },
        ],
      };

      final entry = TripChatService.buildEntryFromTrip(row, userId);
      expect(entry.referenceId, 'trip-1');
      expect(entry.isTrip, true);
      expect(entry.roomId, 'room-1');
      expect(entry.clientId, 'client-1');
      expect(entry.clientName, 'Ana Carolina');
      expect(entry.subtitle, 'Rua Augusta, 1200 → Aeroporto de Guarulhos');
      expect(entry.lastMessage, 'Pode confirmar o endereço?');
      expect(entry.unreadCount, 1);
    });

    test('builds entry without room', () {
      final row = {
        'id': 'trip-2',
        'scheduled_datetime': '2026-04-20T10:00:00.000Z',
        'pickup_address': {'formatted_address': 'Av. Paulista'},
        'dropoff_address': {'formatted_address': 'Shopping Eldorado'},
        'client': {'id': 'client-2', 'full_name': 'Carlos'},
        'chat_rooms': [],
      };

      final entry = TripChatService.buildEntryFromTrip(row, userId);
      expect(entry.roomId, isNull);
      expect(entry.unreadCount, 0);
      expect(entry.lastMessage, isNull);
    });

    test('does not count own messages as unread', () {
      final row = {
        'id': 'trip-3',
        'scheduled_datetime': '2026-04-15T08:30:00.000Z',
        'pickup_address': {'formatted_address': 'A'},
        'dropoff_address': {'formatted_address': 'B'},
        'client': {'id': 'c-3', 'full_name': 'Test'},
        'chat_rooms': [
          {
            'id': 'room-3',
            'chat_messages': [
              {
                'id': 'm1',
                'sender_id': userId,
                'message': 'Estou a caminho',
                'is_read': false,
                'created_at': '2026-04-15T07:50:00.000Z',
              },
            ],
          },
        ],
      };

      final entry = TripChatService.buildEntryFromTrip(row, userId);
      expect(entry.unreadCount, 0);
    });

    test('title includes formatted date', () {
      final row = {
        'id': 'trip-4',
        'scheduled_datetime': '2026-04-15T08:30:00.000Z',
        'pickup_address': {'formatted_address': 'A'},
        'dropoff_address': {'formatted_address': 'B'},
        'client': {'id': 'c-4', 'full_name': 'X'},
        'chat_rooms': [],
      };

      final entry = TripChatService.buildEntryFromTrip(row, userId);
      expect(entry.title, contains('15/04'));
      expect(entry.title, contains('08:30'));
    });
  });

  group('TripChatService.buildEntryFromServiceRequest', () {
    const userId = 'provider-user-123';

    test('builds entry from service_request row', () {
      final row = {
        'id': 'sr-1',
        'service_date': '2026-04-20T09:00:00.000Z',
        'service_categories': {'name': 'Diarista'},
        'address': {'formatted_address': 'Rua das Flores, 100'},
        'client': {'id': 'client-1', 'full_name': 'Maria Silva'},
        'chat_rooms': [],
      };

      final entry = TripChatService.buildEntryFromServiceRequest(row, userId);
      expect(entry.referenceId, 'sr-1');
      expect(entry.isTrip, false);
      expect(entry.roomId, isNull);
      expect(entry.clientName, 'Maria Silva');
      expect(entry.subtitle, 'Rua das Flores, 100');
      expect(entry.title, contains('Diarista'));
      expect(entry.title, contains('20/04'));
    });

    test('builds entry with existing room', () {
      final row = {
        'id': 'sr-2',
        'service_date': '2026-04-21T14:00:00.000Z',
        'service_categories': {'name': 'Eletricista'},
        'address': {'formatted_address': 'Av. Brasil, 500'},
        'client': {'id': 'client-2', 'full_name': 'João'},
        'chat_rooms': [
          {
            'id': 'room-sr-1',
            'chat_messages': [
              {
                'id': 'msg-sr-1',
                'sender_id': 'client-2',
                'message': 'Quando chega?',
                'is_read': false,
                'created_at': '2026-04-21T13:00:00.000Z',
              },
            ],
          },
        ],
      };

      final entry = TripChatService.buildEntryFromServiceRequest(row, userId);
      expect(entry.roomId, 'room-sr-1');
      expect(entry.lastMessage, 'Quando chega?');
      expect(entry.unreadCount, 1);
    });
  });
}
```

- [ ] **Step 2: Rodar teste para confirmar que falha**

```
flutter test test/core/services/trip_chat_service_test.dart
```

Expected: FAIL com `Error: uri 'package:kz_servicos_prestador/core/services/trip_chat_service.dart' not found`

- [ ] **Step 3: Criar `lib/core/services/trip_chat_service.dart` com modelos e helpers**

```dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class ChatEntryData {
  final String referenceId;
  final bool isTrip;
  final String? roomId;
  final String clientId;
  final String clientName;
  final String title;
  final String subtitle;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ChatEntryData({
    required this.referenceId,
    required this.isTrip,
    this.roomId,
    required this.clientId,
    required this.clientName,
    required this.title,
    required this.subtitle,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
  });
}

class ChatMessageData {
  final String id;
  final String senderId;
  final String message;
  final bool isRead;
  final DateTime sentAt;

  const ChatMessageData({
    required this.id,
    required this.senderId,
    required this.message,
    required this.isRead,
    required this.sentAt,
  });

  factory ChatMessageData.fromMap(Map<String, dynamic> map) {
    return ChatMessageData(
      id: map['id'] as String,
      senderId: map['sender_id'] as String,
      message: map['message'] as String,
      isRead: map['is_read'] as bool? ?? false,
      sentAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class ChatPageArgs {
  final String roomId;
  final String title;
  final String subtitle;
  final String clientName;
  final String clientId;
  final String? tripId;
  final String? serviceRequestId;

  const ChatPageArgs({
    required this.roomId,
    required this.title,
    required this.subtitle,
    required this.clientName,
    required this.clientId,
    this.tripId,
    this.serviceRequestId,
  });
}

// ── Service ───────────────────────────────────────────────────────────────────

class TripChatService {
  final SupabaseClient _client = Supabase.instance.client;

  static const _tripSelect =
      '*, '
      'pickup_address:addresses!pickup_address_id(formatted_address), '
      'dropoff_address:addresses!dropoff_address_id(formatted_address), '
      'client:users!client_id(id, full_name), '
      'chat_rooms!trip_id(id, chat_messages(id, message, created_at, sender_id, is_read))';

  static const _serviceRequestSelect =
      '*, '
      'service_categories(name), '
      'address:addresses(formatted_address), '
      'client:users!client_id(id, full_name), '
      'chat_rooms!service_request_id(id, chat_messages(id, message, created_at, sender_id, is_read))';

  Future<List<ChatEntryData>> getChatsForDriver(
    String driverProfileId,
    String currentUserId,
  ) async {
    try {
      final res = await _client
          .from('trips')
          .select(_tripSelect)
          .eq('driver_profile_id', driverProfileId)
          .inFilter('status', ['scheduled', 'started', 'finished'])
          .order('scheduled_datetime', ascending: false);
      return (res as List)
          .map((r) => buildEntryFromTrip(r as Map<String, dynamic>, currentUserId))
          .toList();
    } catch (e) {
      debugPrint('[TripChatService] getChatsForDriver erro: $e');
      return [];
    }
  }

  Future<List<ChatEntryData>> getChatsForServiceProvider(
    String providerProfileId,
    String currentUserId,
  ) async {
    try {
      final res = await _client
          .from('service_requests')
          .select(_serviceRequestSelect)
          .eq('provider_profile_id', providerProfileId)
          .inFilter('status', ['assigned', 'in_progress', 'finished'])
          .order('service_date', ascending: false);
      return (res as List)
          .map((r) => buildEntryFromServiceRequest(r as Map<String, dynamic>, currentUserId))
          .toList();
    } catch (e) {
      debugPrint('[TripChatService] getChatsForServiceProvider erro: $e');
      return [];
    }
  }

  Future<String> getOrCreateChatRoom({
    String? tripId,
    String? serviceRequestId,
    required String clientId,
    required String providerId,
  }) async {
    assert(tripId != null || serviceRequestId != null,
        'tripId ou serviceRequestId obrigatório');

    var query = _client
        .from('chat_rooms')
        .select('id')
        .eq('provider_id', providerId);
    if (tripId != null) {
      query = query.eq('trip_id', tripId);
    } else {
      query = query.eq('service_request_id', serviceRequestId!);
    }

    final existing = await query.maybeSingle();
    if (existing != null) return existing['id'] as String;

    final insert = <String, dynamic>{
      'client_id': clientId,
      'provider_id': providerId,
    };
    if (tripId != null) insert['trip_id'] = tripId;
    if (serviceRequestId != null) insert['service_request_id'] = serviceRequestId;

    final res = await _client
        .from('chat_rooms')
        .insert(insert)
        .select('id')
        .single();
    return res['id'] as String;
  }

  Future<void> sendMessage(
    String roomId,
    String senderId,
    String message,
  ) async {
    await _client.from('chat_messages').insert({
      'chat_room_id': roomId,
      'sender_id': senderId,
      'message': message,
      'message_type': 'text',
    });
  }

  Stream<List<ChatMessageData>> subscribeToMessages(String roomId) {
    return _client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('chat_room_id', roomId)
        .order('created_at')
        .map((rows) => rows.map(ChatMessageData.fromMap).toList());
  }

  Future<void> markMessagesRead(String roomId, String userId) async {
    try {
      await _client
          .from('chat_messages')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('chat_room_id', roomId)
          .neq('sender_id', userId)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('[TripChatService] markMessagesRead erro: $e');
    }
  }

  // ── @visibleForTesting helpers (testáveis sem mock de Supabase) ───────────

  @visibleForTesting
  static ChatEntryData buildEntryFromTrip(
    Map<String, dynamic> row,
    String currentUserId,
  ) {
    final client = (row['client'] as Map<String, dynamic>?) ?? {};
    final pickup = (row['pickup_address'] as Map<String, dynamic>?) ?? {};
    final dropoff = (row['dropoff_address'] as Map<String, dynamic>?) ?? {};
    final rooms = (row['chat_rooms'] as List?) ?? [];

    final room = rooms.isNotEmpty ? rooms.first as Map<String, dynamic> : null;
    final roomId = room?['id'] as String?;
    final msgs = ((room?['chat_messages'] as List?) ?? [])
        .cast<Map<String, dynamic>>();

    msgs.sort((a, b) => DateTime.parse(b['created_at'] as String)
        .compareTo(DateTime.parse(a['created_at'] as String)));

    final lastMsg = msgs.isNotEmpty ? msgs.first : null;
    final unread = msgs
        .where((m) => m['sender_id'] != currentUserId && m['is_read'] == false)
        .length;

    final origin = pickup['formatted_address'] as String? ?? '';
    final destination = dropoff['formatted_address'] as String? ?? '';
    final subtitle = origin.isNotEmpty && destination.isNotEmpty
        ? '$origin → $destination'
        : origin.isNotEmpty
            ? origin
            : destination;

    final scheduledStr = row['scheduled_datetime'] as String?;
    final title = scheduledStr != null
        ? _formatTripTitle(DateTime.parse(scheduledStr))
        : 'Corrida';

    return ChatEntryData(
      referenceId: row['id'] as String,
      isTrip: true,
      roomId: roomId,
      clientId: client['id'] as String? ?? '',
      clientName: client['full_name'] as String? ?? 'Cliente',
      title: title,
      subtitle: subtitle,
      lastMessage: lastMsg?['message'] as String?,
      lastMessageAt: lastMsg != null
          ? DateTime.parse(lastMsg['created_at'] as String)
          : null,
      unreadCount: unread,
    );
  }

  @visibleForTesting
  static ChatEntryData buildEntryFromServiceRequest(
    Map<String, dynamic> row,
    String currentUserId,
  ) {
    final client = (row['client'] as Map<String, dynamic>?) ?? {};
    final address = (row['address'] as Map<String, dynamic>?) ?? {};
    final category = (row['service_categories'] as Map<String, dynamic>?) ?? {};
    final rooms = (row['chat_rooms'] as List?) ?? [];

    final room = rooms.isNotEmpty ? rooms.first as Map<String, dynamic> : null;
    final roomId = room?['id'] as String?;
    final msgs = ((room?['chat_messages'] as List?) ?? [])
        .cast<Map<String, dynamic>>();

    msgs.sort((a, b) => DateTime.parse(b['created_at'] as String)
        .compareTo(DateTime.parse(a['created_at'] as String)));

    final lastMsg = msgs.isNotEmpty ? msgs.first : null;
    final unread = msgs
        .where((m) => m['sender_id'] != currentUserId && m['is_read'] == false)
        .length;

    final categoryName = category['name'] as String? ?? 'Serviço';
    final serviceDateStr = row['service_date'] as String?;
    final title = serviceDateStr != null
        ? '$categoryName · ${_formatDateShort(DateTime.parse(serviceDateStr))}'
        : categoryName;

    final subtitle = address['formatted_address'] as String? ?? '';

    return ChatEntryData(
      referenceId: row['id'] as String,
      isTrip: false,
      roomId: roomId,
      clientId: client['id'] as String? ?? '',
      clientName: client['full_name'] as String? ?? 'Cliente',
      title: title,
      subtitle: subtitle,
      lastMessage: lastMsg?['message'] as String?,
      lastMessageAt: lastMsg != null
          ? DateTime.parse(lastMsg['created_at'] as String)
          : null,
      unreadCount: unread,
    );
  }

  static String _formatTripTitle(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return 'Corrida · $day/$month às $hour:$minute';
  }

  static String _formatDateShort(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month';
  }
}
```

- [ ] **Step 4: Rodar testes para confirmar que passam**

```
flutter test test/core/services/trip_chat_service_test.dart
```

Expected: All 8 tests PASS

- [ ] **Step 5: Commit**

```
git add lib/core/services/trip_chat_service.dart test/core/services/trip_chat_service_test.dart
git commit -m "feat: criar TripChatService com modelos e testes"
```

---

## Task 2: Atualizar MessagesPage

**Files:**
- Modify: `lib/features/chat/presentation/pages/messages_page.dart`

- [ ] **Step 1: Substituir conteúdo completo de `messages_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kz_servicos_prestador/core/constants/app_colors.dart';
import 'package:kz_servicos_prestador/core/services/auth_state.dart';
import 'package:kz_servicos_prestador/core/services/trip_chat_service.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with SingleTickerProviderStateMixin {
  final _chatService = TripChatService();
  List<ChatEntryData> _entries = [];
  bool _loading = true;
  bool _openingChat = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseAnimation = Tween<double>(begin: 0.03, end: 0.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
    _load();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final userId = AuthState.userId ?? '';
    final driverProfileId = AuthState.driverProfileId;
    final providerProfileId = AuthState.providerProfileId;

    List<ChatEntryData> entries;
    if (AuthState.isDriver && driverProfileId != null) {
      entries = await _chatService.getChatsForDriver(driverProfileId, userId);
    } else if (providerProfileId != null) {
      entries = await _chatService.getChatsForServiceProvider(providerProfileId, userId);
    } else {
      entries = [];
    }

    if (mounted) {
      setState(() {
        _entries = entries;
        _loading = false;
      });
    }
  }

  Future<void> _openChat(ChatEntryData entry) async {
    if (_openingChat) return;
    final userId = AuthState.userId ?? '';

    String roomId;
    if (entry.roomId != null) {
      roomId = entry.roomId!;
    } else {
      setState(() => _openingChat = true);
      try {
        roomId = await _chatService.getOrCreateChatRoom(
          tripId: entry.isTrip ? entry.referenceId : null,
          serviceRequestId: entry.isTrip ? null : entry.referenceId,
          clientId: entry.clientId,
          providerId: userId,
        );
      } catch (e) {
        if (mounted) setState(() => _openingChat = false);
        return;
      }
      if (mounted) setState(() => _openingChat = false);
    }

    if (mounted) {
      context.push(
        '/chat/$roomId',
        extra: ChatPageArgs(
          roomId: roomId,
          title: entry.title,
          subtitle: entry.subtitle,
          clientName: entry.clientName,
          clientId: entry.clientId,
          tripId: entry.isTrip ? entry.referenceId : null,
          serviceRequestId: entry.isTrip ? null : entry.referenceId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Mensagens',
          style: TextStyle(
            fontFamily: 'OutfitBlack',
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Stack(
        children: [
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_entries.isEmpty)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma mensagem',
                    style: TextStyle(
                      fontFamily: 'QuasimodoSemiBold',
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: _entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final entry = _entries[i];
                  if (entry.unreadCount > 0) {
                    return AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, _) => _ConversationTile(
                        entry: entry,
                        onTap: () => _openChat(entry),
                        pulseAlpha: _pulseAnimation.value,
                      ),
                    );
                  }
                  return _ConversationTile(
                    entry: entry,
                    onTap: () => _openChat(entry),
                  );
                },
              ),
            ),
          if (_openingChat)
            const ColoredBox(
              color: Color(0x44000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ChatEntryData entry;
  final VoidCallback onTap;
  final double? pulseAlpha;

  const _ConversationTile({
    required this.entry,
    required this.onTap,
    this.pulseAlpha,
  });

  @override
  Widget build(BuildContext context) {
    final unread = entry.unreadCount;
    final hasUnread = unread > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasUnread && pulseAlpha != null
              ? Color.lerp(
                  Colors.white,
                  AppColors.secondary.withValues(alpha: pulseAlpha!),
                  1.0,
                )
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
              child: Text(
                entry.clientName.isNotEmpty ? entry.clientName[0] : '?',
                style: const TextStyle(
                  fontFamily: 'OutfitBlack',
                  fontSize: 18,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.clientName,
                    style: const TextStyle(
                      fontFamily: 'OutfitBlack',
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (entry.subtitle.isNotEmpty)
                    Text(
                      entry.subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (entry.lastMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      entry.lastMessage!,
                      style: TextStyle(
                        fontFamily: 'QuasimodoSemiBold',
                        fontSize: 13,
                        color: hasUnread
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight:
                            hasUnread ? FontWeight.w700 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (hasUnread)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Rodar análise**

```
flutter analyze lib/features/chat/presentation/pages/messages_page.dart
```

Expected: No issues

- [ ] **Step 3: Commit**

```
git add lib/features/chat/presentation/pages/messages_page.dart
git commit -m "feat: atualizar MessagesPage para usar TripChatService"
```

---

## Task 3: Atualizar ChatPage

**Files:**
- Modify: `lib/features/chat/presentation/pages/chat_page.dart`

- [ ] **Step 1: Substituir conteúdo completo de `chat_page.dart`**

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kz_servicos_prestador/core/constants/app_colors.dart';
import 'package:kz_servicos_prestador/core/services/auth_state.dart';
import 'package:kz_servicos_prestador/core/services/trip_chat_service.dart';

class ChatPage extends StatefulWidget {
  final ChatPageArgs args;

  const ChatPage({super.key, required this.args});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _chatService = TripChatService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessageData> _messages = [];
  bool _sending = false;
  StreamSubscription<List<ChatMessageData>>? _subscription;

  static const _presets = [
    'Estou a caminho',
    'Cheguei ao local',
    'Aguardando passageiro',
    'Trânsito intenso',
    'Preciso de ajuda',
  ];

  @override
  void initState() {
    super.initState();
    _subscribeToMessages();
    _markRead();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _subscribeToMessages() {
    _subscription = _chatService
        .subscribeToMessages(widget.args.roomId)
        .listen((messages) {
      if (mounted) {
        setState(() => _messages = messages);
        _scrollToBottom();
        _markRead();
      }
    });
  }

  Future<void> _markRead() async {
    final userId = AuthState.userId;
    if (userId != null) {
      await _chatService.markMessagesRead(widget.args.roomId, userId);
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _sending) return;
    final userId = AuthState.userId ?? '';
    setState(() => _sending = true);
    _controller.clear();
    try {
      await _chatService.sendMessage(widget.args.roomId, userId, text.trim());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthState.userId ?? '';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
              child: Text(
                widget.args.clientName.isNotEmpty
                    ? widget.args.clientName[0]
                    : '?',
                style: const TextStyle(
                  fontFamily: 'OutfitBlack',
                  fontSize: 14,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.args.title,
                    style: const TextStyle(
                      fontFamily: 'OutfitBlack',
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.args.subtitle.isNotEmpty)
                    Text(
                      widget.args.subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                return _MessageBubble(
                  message: msg,
                  isFromMe: msg.senderId == currentUserId,
                );
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _presets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _sendMessage(_presets[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _presets[i],
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.secondary),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _sendMessage(_controller.text),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: _sending
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
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

class _MessageBubble extends StatelessWidget {
  final ChatMessageData message;
  final bool isFromMe;

  const _MessageBubble({required this.message, required this.isFromMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromMe) ...[
            const CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.person, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isFromMe ? AppColors.secondary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isFromMe ? 16 : 4),
                bottomRight: Radius.circular(isFromMe ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: isFromMe ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${message.sentAt.hour.toString().padLeft(2, '0')}:${message.sentAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isFromMe
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppColors.textSecondary,
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
```

- [ ] **Step 2: Rodar análise**

```
flutter analyze lib/features/chat/presentation/pages/chat_page.dart
```

Expected: No issues

- [ ] **Step 3: Commit**

```
git add lib/features/chat/presentation/pages/chat_page.dart
git commit -m "feat: atualizar ChatPage com Realtime e header da corrida"
```

---

## Task 4: Atualizar Router

**Files:**
- Modify: `lib/routes/app_router.dart`

- [ ] **Step 1: Substituir a rota `/chat/:conversationId` por `/chat/:roomId` com `ChatPageArgs`**

Localizar no arquivo `lib/routes/app_router.dart` o bloco:

```dart
GoRoute(
  path: '/chat/:conversationId',
  builder: (context, state) {
    final id = state.pathParameters['conversationId'] ?? '0';
    return ChatPage(conversationId: id);
  },
),
```

Substituir por:

```dart
GoRoute(
  path: '/chat/:roomId',
  builder: (context, state) {
    final args = state.extra as ChatPageArgs;
    return ChatPage(args: args);
  },
),
```

Também remover a importação de `chat_page.dart` se já estiver duplicada — ela já estava na lista de imports, apenas garantir que o import de `trip_chat_service.dart` está presente (necessário para `ChatPageArgs`).

Adicionar import no topo do arquivo (se não existir):
```dart
import 'package:kz_servicos_prestador/core/services/trip_chat_service.dart';
```

- [ ] **Step 2: Rodar análise**

```
flutter analyze lib/routes/app_router.dart
```

Expected: No issues

- [ ] **Step 3: Commit**

```
git add lib/routes/app_router.dart
git commit -m "feat: atualizar rota /chat para usar ChatPageArgs"
```

---

## Task 5: Remover arquivos antigos e verificação final

**Files:**
- Delete: `lib/core/services/chat_service.dart`
- Delete: `lib/features/chat/data/models/mock_message.dart`

- [ ] **Step 1: Verificar que nenhum arquivo ainda importa os antigos**

```
grep -r "chat_service.dart\|mock_message.dart\|ChatService\|MockChatMessage\|MockConversation\|ChatRoomData" lib/
```

Expected: nenhum resultado (os únicos arquivos que usavam são os que já foram substituídos)

- [ ] **Step 2: Deletar arquivos obsoletos**

```
rm lib/core/services/chat_service.dart
rm lib/features/chat/data/models/mock_message.dart
```

- [ ] **Step 3: Rodar análise completa do projeto**

```
flutter analyze
```

Expected: No issues (ou apenas avisos de análise estática não relacionados a esta feature)

- [ ] **Step 4: Rodar todos os testes**

```
flutter test
```

Expected: All tests pass

- [ ] **Step 5: Commit final**

```
git add -A
git commit -m "chore: remover ChatService e mocks obsoletos da mensageria"
```

---

## Self-Review

### Spec coverage

| Requisito | Task |
|-----------|------|
| Lista exibe trips (motorista) com status scheduled/started/finished | Task 2 — `getChatsForDriver` + `MessagesPage` |
| Lista exibe service_requests (prestador) com status assigned/in_progress/finished | Task 2 — `getChatsForServiceProvider` + `MessagesPage` |
| Cada corrida/serviço é uma sala | Task 1 — `ChatEntryData.referenceId` mapeia para trip/SR |
| Criar sala ao abrir se não existir | Task 2 — `_openChat` chama `getOrCreateChatRoom` |
| Manter aparência visual atual dos cards | Task 2 — `_ConversationTile` preserva layout exato |
| Chat com API Supabase (enviar/receber) | Task 1 — `sendMessage` + `subscribeToMessages` |
| Header: info da corrida + rota como subtítulo | Task 3 — `ChatPage` usa `args.title` e `args.subtitle` |
| Realtime (mensagens aparecem sem recarregar) | Task 3 — `subscribeToMessages` via `.stream()` |
| Marcar mensagens como lidas ao abrir | Task 3 — `markMessagesRead` em `initState` |
| FAB "+" removido | Task 2 — não está no novo `MessagesPage` |

### Placeholder scan

Nenhum TBD ou TODO. Todos os blocos de código são completos.

### Type consistency

- `ChatPageArgs` definido em Task 1, usado em Task 2 (`_openChat`), Task 3 (`ChatPage`), e Task 4 (router) — consistente
- `ChatEntryData` definido em Task 1, usado em Task 2 — consistente
- `ChatMessageData` definido em Task 1, usado em Task 3 — consistente
- `TripChatService` instanciado em Task 2 e Task 3 com `TripChatService()` — consistente
- `buildEntryFromTrip` / `buildEntryFromServiceRequest` são `static` em Task 1 e chamados como `TripChatService.buildEntryFromTrip(...)` nos testes — consistente
