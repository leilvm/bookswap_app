import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_model.dart';

enum SwapStatus { pending, accepted, rejected }

class SwapModel {
  final String id;
  final String bookId;
  final String bookTitle;
  final String senderId;
  final String senderName;
  final String recipientId;
  final String recipientName;
  final SwapStatus status;
  final DateTime createdAt;

  SwapModel({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.recipientName,
    this.status = SwapStatus.pending,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'senderId': senderId,
      'senderName': senderName,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SwapModel.fromMap(Map<String, dynamic> map) {
    return SwapModel(
      id: map['id'] ?? '',
      bookId: map['bookId'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      recipientId: map['recipientId'] ?? '',
      recipientName: map['recipientName'] ?? '',
      status: SwapStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SwapStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
