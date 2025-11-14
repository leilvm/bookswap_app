import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../data/models/book_model.dart';

abstract class BookEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BookLoadAll extends BookEvent {}

class BookLoadMyBooks extends BookEvent {
  final String userId;

  BookLoadMyBooks(this.userId);

  @override
  List<Object?> get props => [userId];
}

class BookAdd extends BookEvent {
  final BookModel book;
  final File? imageFile;

  BookAdd({required this.book, this.imageFile});

  @override
  List<Object?> get props => [book, imageFile];
}

class BookUpdate extends BookEvent {
  final BookModel book;
  final File? imageFile;

  BookUpdate({required this.book, this.imageFile});

  @override
  List<Object?> get props => [book, imageFile];
}

class BookDelete extends BookEvent {
  final String bookId;

  BookDelete(this.bookId);

  @override
  List<Object?> get props => [bookId];
}
