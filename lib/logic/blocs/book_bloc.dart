import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/book_repository.dart';
import 'book_event.dart';
import 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final BookRepository bookRepository;

  BookBloc({required this.bookRepository}) : super(BookInitial()) {
    // Load all books
    on<BookLoadAll>((event, emit) async {
      emit(BookLoading());
      await emit.forEach(
        bookRepository.getAllBooks(),
        onData: (books) => BookLoaded(books),
        onError: (error, stackTrace) => BookError(error.toString()),
      );
    });

    // Load user's books
    on<BookLoadMyBooks>((event, emit) async {
      emit(BookLoading());
      await emit.forEach(
        bookRepository.getBooksByOwner(event.userId),
        onData: (books) => BookLoaded(books),
        onError: (error, stackTrace) => BookError(error.toString()),
      );
    });

    // Add book
    on<BookAdd>((event, emit) async {
      try {
        await bookRepository.addBook(event.book, event.imageFile);
        emit(BookSuccess('Book added successfully'));
      } catch (e) {
        emit(BookError(e.toString()));
      }
    });

    // Update book
    on<BookUpdate>((event, emit) async {
      try {
        await bookRepository.updateBook(event.book, event.imageFile);
        emit(BookSuccess('Book updated successfully'));
      } catch (e) {
        emit(BookError(e.toString()));
      }
    });

    // Delete book
    on<BookDelete>((event, emit) async {
      try {
        await bookRepository.deleteBook(event.bookId);
        emit(BookSuccess('Book deleted successfully'));
      } catch (e) {
        emit(BookError(e.toString()));
      }
    });
  }
}
