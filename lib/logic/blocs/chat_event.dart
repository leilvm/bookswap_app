import 'package:equatable/equatable.dart';
import '../../data/models/message_model.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatLoadUserChats extends ChatEvent {
  final String userId;

  ChatLoadUserChats(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ChatLoadMessages extends ChatEvent {
  final String chatId;

  ChatLoadMessages(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class ChatSendMessage extends ChatEvent {
  final MessageModel message;

  ChatSendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatCreateOrGet extends ChatEvent {
  final String user1Id;
  final String user1Name;
  final String user2Id;
  final String user2Name;

  ChatCreateOrGet({
    required this.user1Id,
    required this.user1Name,
    required this.user2Id,
    required this.user2Name,
  });

  @override
  List<Object?> get props => [user1Id, user1Name, user2Id, user2Name];
}
