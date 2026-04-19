class MockChatMessage {
  final String id;
  final String text;
  final bool isFromProvider;
  final DateTime sentAt;

  const MockChatMessage({
    required this.id,
    required this.text,
    required this.isFromProvider,
    required this.sentAt,
  });
}

class MockConversation {
  final String id;
  final String tripId;
  final String clientName;
  final String origin;
  final String destination;
  final List<MockChatMessage> messages;
  final DateTime lastMessageAt;
  final int unreadCount;

  const MockConversation({
    required this.id,
    required this.tripId,
    required this.clientName,
    required this.origin,
    required this.destination,
    required this.messages,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  static final List<MockConversation> samples = [
    MockConversation(
      id: 'conv_1',
      tripId: 'req_1',
      clientName: 'Ana Carolina',
      origin: 'Rua Augusta, 1200',
      destination: 'Aeroporto de Guarulhos',
      lastMessageAt: DateTime(2026, 4, 15, 8, 10),
      unreadCount: 1,
      messages: [
        MockChatMessage(
          id: 'msg_1',
          text: 'Você foi designado para a corrida #313.',
          isFromProvider: false,
          sentAt: DateTime(2026, 4, 15, 7, 50),
        ),
        MockChatMessage(
          id: 'msg_2',
          text: 'Ok, estou a caminho do local de embarque.',
          isFromProvider: true,
          sentAt: DateTime(2026, 4, 15, 7, 55),
        ),
        MockChatMessage(
          id: 'msg_3',
          text:
              'Cliente informou que estará na portaria do prédio. '
              '2 malas grandes.',
          isFromProvider: false,
          sentAt: DateTime(2026, 4, 15, 8, 0),
        ),
        MockChatMessage(
          id: 'msg_4',
          text: 'Entendido, obrigado!',
          isFromProvider: true,
          sentAt: DateTime(2026, 4, 15, 8, 5),
        ),
        MockChatMessage(
          id: 'msg_5',
          text: 'Lembre-se: embarque previsto para 08:30.',
          isFromProvider: false,
          sentAt: DateTime(2026, 4, 15, 8, 10),
        ),
      ],
    ),
    MockConversation(
      id: 'conv_2',
      tripId: 'req_2',
      clientName: 'Carlos Mendes',
      origin: 'Av. Paulista, 1578',
      destination: 'Shopping Eldorado',
      lastMessageAt: DateTime(2026, 4, 14, 16, 0),
      unreadCount: 0,
      messages: [
        MockChatMessage(
          id: 'msg_6',
          text: 'Corrida #311 concluída. Boa avaliação!',
          isFromProvider: false,
          sentAt: DateTime(2026, 4, 14, 16, 0),
        ),
      ],
    ),
  ];
}
