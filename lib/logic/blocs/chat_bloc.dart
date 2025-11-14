import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;

  ChatBloc({required this.chatRepository}) : super(ChatInitial()) {
    // Load user's chats
    on<ChatLoadUserChats>((event, emit) async {
      emit(ChatLoading());
      await emit.forEach(
        chatRepository.getUserChats(event.userId),
        onData: (chats) => ChatLoaded(chats),
        onError: (error, stackTrace) => ChatError(error.toString()),
      );
    });

    // Load messages in a chat
    on<ChatLoadMessages>((event, emit) async {
      emit(ChatLoading());
      await emit.forEach(
        chatRepository.getMessages(event.chatId),
        onData: (messages) => ChatMessagesLoaded(messages),
        onError: (error, stackTrace) => ChatError(error.toString()),
      );
    });

    // Send message
    on<ChatSendMessage>((event, emit) async {
      try {
        await chatRepository.sendMessage(event.message);
        // Don't emit anything - the stream will auto-update
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    });

    // Create or get chat
    on<ChatCreateOrGet>((event, emit) async {
      emit(ChatLoading());
      try {
        final chatId = await chatRepository.getOrCreateChat(
          event.user1Id,
          event.user1Name,
          event.user2Id,
          event.user2Name,
        );
        emit(ChatCreated(chatId));
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    });
  }
}
