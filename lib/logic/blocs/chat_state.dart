import 'package:equatable/equatable.dart';
import '../../data/models/message_model.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatModel> chats;

  ChatLoaded(this.chats);

  @override
  List<Object?> get props => [chats];
}

class ChatMessagesLoaded extends ChatState {
  final List<MessageModel> messages;

  ChatMessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatCreated extends ChatState {
  final String chatId;

  ChatCreated(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
