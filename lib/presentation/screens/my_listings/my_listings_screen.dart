import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/blocs/auth_bloc.dart';
import '../../../logic/blocs/auth_state.dart';
import '../../../logic/blocs/book_bloc.dart';
import '../../../logic/blocs/book_event.dart';
import '../../../logic/blocs/book_state.dart';
import '../../../logic/blocs/swap_bloc.dart';
import '../../../logic/blocs/swap_event.dart';
import '../../../logic/blocs/swap_state.dart';
import '../../../data/models/swap_model.dart';
import '../../widgets/book_card.dart';
import 'add_book_screen.dart';
import 'edit_book_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<BookBloc>().add(BookLoadMyBooks(authState.user.id));
      context.read<SwapBloc>().add(SwapLoadReceived(authState.user.id));
    }
  }

  void _deleteBook(String bookId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<BookBloc>().add(BookDelete(bookId));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _updateSwapStatus(String swapId, String bookId, SwapStatus status) {
    context.read<SwapBloc>().add(
          SwapUpdateStatus(swapId: swapId, bookId: bookId, status: status),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedTab == 0
                              ? Colors.blue
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Text(
                      'My Books',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedTab == 1
                              ? Colors.blue
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Swap Offers',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<BookBloc, BookState>(
            listener: (context, state) {
              if (state is BookSuccess) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
                _loadData();
              }
              if (state is BookError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
          BlocListener<SwapBloc, SwapState>(
            listener: (context, state) {
              if (state is SwapSuccess) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
                _loadData();
              }
            },
          ),
        ],
        child: _selectedTab == 0 ? _buildMyBooks() : _buildSwapOffers(),
      ),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddBookScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildMyBooks() {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        if (state is BookLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is BookLoaded) {
          if (state.books.isEmpty) {
            return const Center(
              child: Text('No books listed yet. Add your first book!'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.books.length,
            itemBuilder: (context, index) {
              final book = state.books[index];
              return BookCard(
                book: book,
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditBookScreen(book: book),
                    ),
                  );
                },
                onDelete: () => _deleteBook(book.id),
                showActions: true,
              );
            },
          );
        }

        return const Center(child: Text('Add your books to get started'));
      },
    );
  }

  Widget _buildSwapOffers() {
    return BlocBuilder<SwapBloc, SwapState>(
      builder: (context, state) {
        if (state is SwapLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SwapLoaded) {
          if (state.swaps.isEmpty) {
            return const Center(child: Text('No swap offers yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.swaps.length,
            itemBuilder: (context, index) {
              final swap = state.swaps[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        swap.bookTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('From: ${swap.senderName}'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: swap.status == SwapStatus.pending
                                  ? Colors.orange
                                  : swap.status == SwapStatus.accepted
                                      ? Colors.green
                                      : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              swap.status.name.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (swap.status == SwapStatus.pending) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _updateSwapStatus(
                                swap.id,
                                swap.bookId,
                                SwapStatus.rejected,
                              ),
                              child: const Text('Reject'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _updateSwapStatus(
                                swap.id,
                                swap.bookId,
                                SwapStatus.accepted,
                              ),
                              child: const Text('Accept'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        }

        return const Center(child: Text('No swap offers'));
      },
    );
  }
}
