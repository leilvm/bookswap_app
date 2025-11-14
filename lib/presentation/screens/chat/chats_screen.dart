import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../logic/blocs/auth_bloc.dart';
import '../../../logic/blocs/auth_state.dart';
import '../../../logic/blocs/chat_bloc.dart';
import '../../../logic/blocs/chat_event.dart';
import '../../../logic/blocs/chat_state.dart';
import 'chat_detail_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ChatBloc>().add(ChatLoadUserChats(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats'), elevation: 0),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatError) {
            return Center(child: Text(state.message));
          }

          if (state is ChatLoaded) {
            if (state.chats.isEmpty) {
              return const Center(
                child: Text('No chats yet. Start a swap to chat!'),
              );
            }

            final authState = context.read<AuthBloc>().state;
            final currentUserId = authState is AuthAuthenticated
                ? authState.user.id
                : '';

            return ListView.builder(
              itemCount: state.chats.length,
              itemBuilder: (context, index) {
                final chat = state.chats[index];
                final otherUserId = chat.participants.firstWhere(
                  (id) => id != currentUserId,
                  orElse: () => '',
                );
                final otherUserName =
                    chat.participantNames[otherUserId] ?? 'Unknown';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      otherUserName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    otherUserName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    chat.lastMessage.isEmpty
                        ? 'Start a conversation'
                        : chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    DateFormat('MMM d').format(chat.updatedAt),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(chatId: chat.id),
                      ),
                    );
                  },
                );
              },
            );
          }

          return const Center(child: Text('Start chatting'));
        },
      ),
    );
  }
}
