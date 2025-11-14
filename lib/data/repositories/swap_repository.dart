import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/swap_model.dart';
import '../models/book_model.dart';

class SwapRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createSwap(SwapModel swap) async {
    await _firestore.collection('swaps').doc(swap.id).set(swap.toMap());
    await _firestore.collection('books').doc(swap.bookId).update({
      'status': BookStatus.pending.name,
    });
  }

  Stream<List<SwapModel>> getSwapsSent(String userId) {
    return _firestore
        .collection('swaps')
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SwapModel.fromMap(doc.data())).toList());
  }

  Stream<List<SwapModel>> getSwapsReceived(String userId) {
    return _firestore
        .collection('swaps')
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SwapModel.fromMap(doc.data())).toList());
  }

  Future<void> updateSwapStatus(
      String swapId, String bookId, SwapStatus status) async {
    await _firestore.collection('swaps').doc(swapId).update({
      'status': status.name,
    });

    BookStatus bookStatus;
    if (status == SwapStatus.accepted) {
      bookStatus = BookStatus.swapped;
    } else if (status == SwapStatus.rejected) {
      bookStatus = BookStatus.available;
    } else {
      bookStatus = BookStatus.pending;
    }

    await _firestore.collection('books').doc(bookId).update({
      'status': bookStatus.name,
    });
  }

  Future<void> deleteSwap(String swapId, String bookId) async {
    await _firestore.collection('swaps').doc(swapId).delete();
    await _firestore.collection('books').doc(bookId).update({
      'status': BookStatus.available.name,
    });
  }
}
