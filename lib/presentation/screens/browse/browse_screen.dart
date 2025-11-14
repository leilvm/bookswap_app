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
import '../../../logic/blocs/chat_bloc.dart';
import '../../../logic/blocs/chat_event.dart';
import '../../../logic/blocs/chat_state.dart';
import '../../../data/models/book_model.dart';
import '../../../data/models/swap_model.dart';
import '../../widgets/book_card.dart';
import '../chat/chat_detail_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookBloc>().add(BookLoadAll());
  }

  void _initiateSwap(BookModel book) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final swap = SwapModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bookId: book.id,
        bookTitle: book.title,
        senderId: authState.user.id,
        senderName: authState.user.displayName,
        recipientId: book.ownerId,
        recipientName: book.ownerName,
        createdAt: DateTime.now(),
      );

      context.read<SwapBloc>().add(SwapCreate(swap));

      // Create or get chat with book owner
      context.read<ChatBloc>().add(
        ChatCreateOrGet(
          user1Id: authState.user.id,
          user1Name: authState.user.displayName,
          user2Id: book.ownerId,
          user2Name: book.ownerName,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browse Books'), elevation: 0),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SwapBloc, SwapState>(
            listener: (context, state) {
              if (state is SwapSuccess) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
              if (state is SwapError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
          BlocListener<ChatBloc, ChatState>(
            listener: (context, state) {
              if (state is ChatCreated) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatDetailScreen(chatId: state.chatId),
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<BookBloc, BookState>(
          builder: (context, state) {
            if (state is BookLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BookError) {
              return Center(child: Text(state.message));
            }

            if (state is BookLoaded) {
              final authState = context.read<AuthBloc>().state;
              final currentUserId = authState is AuthAuthenticated
                  ? authState.user.id
                  : '';

              // Filter out current user's books
              final availableBooks = state.books
                  .where((book) => book.ownerId != currentUserId)
                  .toList();

              if (availableBooks.isEmpty) {
                return const Center(child: Text('No books available for swap'));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<BookBloc>().add(BookLoadAll());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: availableBooks.length,
                  itemBuilder: (context, index) {
                    final book = availableBooks[index];
                    return BookCard(
                      book: book,
                      onSwap: () => _initiateSwap(book),
                      showSwapButton: book.status == BookStatus.available,
                    );
                  },
                ),
              );
            }

            return const Center(child: Text('Start browsing books'));
          },
        ),
      ),
    );
  }
}
