import 'package:equatable/equatable.dart';
import '../../data/models/book_model.dart';

abstract class BookState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BookInitial extends BookState {}

class BookLoading extends BookState {}

class BookLoaded extends BookState {
  final List<BookModel> books;

  BookLoaded(this.books);

  @override
  List<Object?> get props => [books];
}

class BookError extends BookState {
  final String message;

  BookError(this.message);

  @override
  List<Object?> get props => [message];
}

class BookSuccess extends BookState {
  final String message;

  BookSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
