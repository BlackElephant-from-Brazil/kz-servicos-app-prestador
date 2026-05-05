# Design: Mensageria por Corridas/Serviços

**Data:** 2026-05-05  
**Status:** Aprovado

## Contexto

A tela de Mensagens deve exibir as corridas (drivers) ou solicitações de serviço (prestadores) do usuário como salas de chat. Cada corrida/serviço é uma sala. Ao clicar, abre o chat conectado ao Supabase com Realtime.

## Escopo

- Motoristas: trips com `status IN (scheduled, started, finished)`
- Prestadores de serviço: service_requests com `status IN (assigned, in_progress, finished)`
- Chat em tempo real via Supabase Realtime (`.stream()`)
- Criar sala automaticamente se não existir ao abrir o chat
- Header do chat: título da corrida/serviço + rota/endereço como subtítulo
- FAB "+" removido da lista de mensagens

## Fora do Escopo

- Upload de imagens/arquivos no chat
- Notificações push de novas mensagens

## Arquitetura

### Camada de Serviço

**`lib/core/services/trip_chat_service.dart`** — substitui `chat_service.dart`

```
TripChatService
├── getChatsForProvider(driverProfileId, providerProfileId, type) → Future<List<ChatEntryData>>
├── getOrCreateChatRoom({tripId?, serviceRequestId?, clientId, providerId}) → Future<String>
├── sendMessage(roomId, senderId, message) → Future<void>
├── subscribeToMessages(roomId) → Stream<List<ChatMessageData>>
└── markMessagesRead(roomId, userId) → Future<void>
```

### Modelos

**`ChatEntryData`** — representa trip/service_request como item da lista
- `referenceId`, `isTrip`, `roomId?`, `clientId`, `clientName`
- `title` (ex: "15/04 às 08:30"), `subtitle` (ex: "Rua A → Aeroporto")
- `lastMessage?`, `lastMessageAt?`, `unreadCount`

**`ChatMessageData`** — mensagem individual
- `id`, `senderId`, `message`, `isRead`, `sentAt`

**`ChatPageArgs`** — argumento de navegação (via `GoRouter.extra`)
- `roomId`, `title`, `subtitle`, `clientName`, `clientId`, `tripId?`, `serviceRequestId?`

### Query Principal (Motoristas)

```
trips
  .select('*, pickup_address:addresses!pickup_address_id(formatted_address),
           dropoff_address:addresses!dropoff_address_id(formatted_address),
           client:users!client_id(id, full_name),
           chat_rooms!trip_id(id, chat_messages(id, message, created_at, sender_id, is_read))')
  .eq('driver_profile_id', driverProfileId)
  .inFilter('status', ['scheduled', 'started', 'finished'])
  .order('scheduled_datetime', ascending: false)
```

### Query Principal (Prestadores de Serviço)

```
service_requests
  .select('*, service_categories(name),
           address:addresses(formatted_address),
           client:users!client_id(id, full_name),
           chat_rooms!service_request_id(id, chat_messages(id, message, created_at, sender_id, is_read))')
  .eq('provider_profile_id', providerProfileId)
  .inFilter('status', ['assigned', 'in_progress', 'finished'])
  .order('service_date', ascending: false)
```

### getOrCreateChatRoom

1. Query `chat_rooms` filtrando por `trip_id`/`service_request_id` + `provider_id`
2. Se existir: retorna `id`
3. Se não: INSERT e retorna novo `id`

### Realtime

```dart
_client
  .from('chat_messages')
  .stream(primaryKey: ['id'])
  .eq('chat_room_id', roomId)
  .order('created_at')
```

Cada evento do stream é a lista completa de mensagens da sala. O `ChatPage` mantém um `StreamSubscription` e cancela no `dispose()`.

## Camada de Apresentação

### MessagesPage

- Remove `ChatService`, usa `TripChatService.getChatsForProvider()`
- Remove FAB "+"
- Ao tap: se `entry.roomId != null` → navega diretamente; se null → chama `getOrCreateChatRoom()` (com loading) → navega
- Passa `ChatPageArgs` como `extra` na navegação

### ChatPage

- Recebe `ChatPageArgs` via `state.extra`
- Header: `args.title` (bold) + `args.subtitle` (subtitle)
- Avatar no header: inicial do `args.clientName`
- Carrega mensagens via `subscribeToMessages(roomId)` no `initState`
- Cancela subscription no `dispose()`
- `isFromMe`: `message.senderId == AuthState.userId`
- Ao abrir: chama `markMessagesRead()`
- Ao receber novas mensagens: chama `markMessagesRead()` novamente
- Send: `TripChatService.sendMessage(roomId, userId, message)`

### Router

- `/chat/:roomId` usa `state.extra as ChatPageArgs`
- Remove lógica de mock (`conversationId` numérico)

## Arquivos a Remover

- `lib/core/services/chat_service.dart`
- `lib/features/chat/data/models/mock_message.dart`

## Arquivos Novos

- `lib/core/services/trip_chat_service.dart`

## Arquivos Modificados

- `lib/features/chat/presentation/pages/messages_page.dart`
- `lib/features/chat/presentation/pages/chat_page.dart`
- `lib/routes/app_router.dart`

## RLS Relevante

- `chat_rooms`: SELECT e INSERT permitidos para `client_id` ou `provider_id`
- `chat_messages`: SELECT para participantes da sala; INSERT para `sender_id = auth.uid()` e participante
- O `provider_id` em `chat_rooms` = `users.id` do prestador (`AuthState.userId`)
