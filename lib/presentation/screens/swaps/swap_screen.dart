import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/blocs/swap_bloc.dart';
import '../../../logic/blocs/swap_event.dart';
import '../../../logic/blocs/swap_state.dart';
import '../../../logic/blocs/auth_bloc.dart';
import '../../../logic/blocs/auth_state.dart';
import '../../../data/models/swap_model.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({super.key});

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<SwapBloc>().add(SwapLoadSent(authState.user.id));
      context.read<SwapBloc>().add(SwapLoadReceived(authState.user.id));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildSwapTile(SwapModel swap, bool isSent) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        title: Text(swap.bookTitle),
        subtitle: Text(
          isSent ? 'To: ${swap.recipientName}' : 'From: ${swap.senderName}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              swap.status.name.toUpperCase(),
              style: TextStyle(
                color: swap.status == SwapStatus.pending
                    ? Colors.orange
                    : swap.status == SwapStatus.accepted
                        ? Colors.green
                        : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!isSent && swap.status == SwapStatus.pending)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'accept') {
                    context.read<SwapBloc>().add(SwapUpdateStatus(
                          swapId: swap.id,
                          bookId: swap.bookId,
                          status: SwapStatus.accepted,
                        ));
                  } else if (value == 'reject') {
                    context.read<SwapBloc>().add(SwapUpdateStatus(
                          swapId: swap.id,
                          bookId: swap.bookId,
                          status: SwapStatus.rejected,
                        ));
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'accept', child: Text('Accept')),
                  const PopupMenuItem(value: 'reject', child: Text('Reject')),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view swaps')),
      );
    }

    final userId = authState.user.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swap Offers'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sent'),
            Tab(text: 'Received'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BlocBuilder<SwapBloc, SwapState>(
            builder: (context, state) {
              if (state is SwapLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SwapLoaded) {
                final sentSwaps =
                    state.swaps.where((s) => s.senderId == userId).toList();
                if (sentSwaps.isEmpty) {
                  return const Center(child: Text('No swaps sent yet.'));
                }
                return ListView.builder(
                  itemCount: sentSwaps.length,
                  itemBuilder: (context, index) =>
                      _buildSwapTile(sentSwaps[index], true),
                );
              } else if (state is SwapError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox();
            },
          ),
          BlocBuilder<SwapBloc, SwapState>(
            builder: (context, state) {
              if (state is SwapLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SwapLoaded) {
                final receivedSwaps =
                    state.swaps.where((s) => s.recipientId == userId).toList();
                if (receivedSwaps.isEmpty) {
                  return const Center(child: Text('No swaps received yet.'));
                }
                return ListView.builder(
                  itemCount: receivedSwaps.length,
                  itemBuilder: (context, index) =>
                      _buildSwapTile(receivedSwaps[index], false),
                );
              } else if (state is SwapError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
