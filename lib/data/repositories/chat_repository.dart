import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get or create a chat between two users
  Future<String> getOrCreateChat(
    String user1Id,
    String user1Name,
    String user2Id,
    String user2Name,
  ) async {
    try {
      // Create sorted participant IDs for consistent chat ID
      final participants = [user1Id, user2Id]..sort();
      final chatId = '${participants[0]}_${participants[1]}';

      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (!chatDoc.exists) {
        // Create new chat
        final chat = ChatModel(
          id: chatId,
          participants: participants,
          participantNames: {user1Id: user1Name, user2Id: user2Name},
          lastMessage: '',
          updatedAt: DateTime.now(),
        );
        await _firestore.collection('chats').doc(chatId).set(chat.toMap());
      }

      return chatId;
    } catch (e) {
      throw Exception('Failed to get/create chat: $e');
    }
  }

  // Send a message
  Future<void> sendMessage(MessageModel message) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(message.chatId)
        .collection('messages')
        .add({
      'senderId': message.senderId,
      'senderName': message.senderName,
      'text': message.text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    try {
      // Add message to subcollection
      await _firestore
          .collection('chats')
          .doc(message.chatId)
          .collection('messages')
          .doc(message.id)
          .set(message.toMap());

      // Update chat's last message
      await _firestore.collection('chats').doc(message.chatId).update({
        'lastMessage': message.text,
        'updatedAt': Timestamp.fromDate(message.timestamp),
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get messages in a chat
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Get all chats for a user
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatModel.fromMap(doc.data()))
              .toList(),
        );
  }
}
