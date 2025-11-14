import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class BookRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CREATE: Add a new book
  Future<void> addBook(BookModel book, File? imageFile) async {
    try {
      String imageUrl = '';

      // Use placeholder image instead of Firebase Storage
      if (imageFile != null) {
        imageUrl =
            'https://via.placeholder.com/400x600/4CAF50/FFFFFF?text=${Uri.encodeComponent(book.title)}';
      }

      final bookWithImage = book.copyWith(imageUrl: imageUrl);
      await _firestore
          .collection('books')
          .doc(book.id)
          .set(bookWithImage.toMap());
    } catch (e) {
      throw Exception('Failed to add book: $e');
    }
  }

  // READ: Get all books
  Stream<List<BookModel>> getAllBooks() {
    return _firestore
        .collection('books')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // READ: Get books by owner
  Stream<List<BookModel>> getBooksByOwner(String ownerId) {
    return _firestore
        .collection('books')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // UPDATE: Edit a book
  Future<void> updateBook(BookModel book, File? newImageFile) async {
    try {
      String imageUrl = book.imageUrl;

      // Use placeholder if new image provided
      if (newImageFile != null) {
        imageUrl =
            'https://via.placeholder.com/400x600/2196F3/FFFFFF?text=${Uri.encodeComponent(book.title)}';
      }

      final updatedBook = book.copyWith(imageUrl: imageUrl);
      await _firestore
          .collection('books')
          .doc(book.id)
          .update(updatedBook.toMap());
    } catch (e) {
      throw Exception('Failed to update book: $e');
    }
  }

  // DELETE: Remove a book
  Future<void> deleteBook(String bookId) async {
    try {
      await _firestore.collection('books').doc(bookId).delete();
    } catch (e) {
      throw Exception('Failed to delete book: $e');
    }
  }

  // Update book status (for swaps)
  Future<void> updateBookStatus(String bookId, BookStatus status) async {
    await _firestore.collection('books').doc(bookId).update({
      'status': status.name,
    });
  }
}
