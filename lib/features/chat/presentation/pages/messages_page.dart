import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kz_servicos_prestador/core/constants/app_colors.dart';
import 'package:kz_servicos_prestador/core/services/auth_state.dart';
import 'package:kz_servicos_prestador/core/services/chat_service.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with SingleTickerProviderStateMixin {
  final _chatService = ChatService();
  List<ChatRoomData> _rooms = [];
  bool _loading = true;

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
    final userId = AuthState.userId ?? '';
    final rooms = await _chatService.getChatRooms(userId);
    if (mounted) {
      setState(() {
        _rooms = rooms;
        _loading = false;
      });
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
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _rooms.isEmpty
                  ? const Center(
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
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                        itemCount: _rooms.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final room = _rooms[i];
                          final hasUnread = room.unreadCount > 0;
                          if (hasUnread) {
                            return AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return _ConversationTile(
                                  room: room,
                                  onTap: () =>
                                      context.push('/chat/${room.id}'),
                                  pulseAlpha: _pulseAnimation.value,
                                );
                              },
                            );
                          }
                          return _ConversationTile(
                            room: room,
                            onTap: () => context.push('/chat/${room.id}'),
                          );
                        },
                      ),
                    ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'newChat',
              backgroundColor: AppColors.secondary,
              onPressed: () => context.push('/chat/new'),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ChatRoomData room;
  final VoidCallback onTap;
  final double? pulseAlpha;

  const _ConversationTile({
    required this.room,
    required this.onTap,
    this.pulseAlpha,
  });

  @override
  Widget build(BuildContext context) {
    final unread = room.unreadCount;
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
                room.clientName.isNotEmpty ? room.clientName[0] : '?',
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
                    room.clientName,
                    style: const TextStyle(
                      fontFamily: 'OutfitBlack',
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (room.origin.isNotEmpty || room.destination.isNotEmpty)
                    Text(
                      '${room.origin} → ${room.destination}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (room.lastMessage != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      room.lastMessage!,
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
