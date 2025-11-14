import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/swap_repository.dart';
import 'swap_event.dart';
import 'swap_state.dart';

class SwapBloc extends Bloc<SwapEvent, SwapState> {
  final SwapRepository swapRepository;

  SwapBloc({required this.swapRepository}) : super(SwapInitial()) {
    // Load swaps sent by user
    on<SwapLoadSent>((event, emit) async {
      emit(SwapLoading());
      await emit.forEach(
        swapRepository.getSwapsSent(event.userId),
        onData: (swaps) => SwapLoaded(swaps),
        onError: (error, stackTrace) => SwapError(error.toString()),
      );
    });

    // Load swaps received by user
    on<SwapLoadReceived>((event, emit) async {
      emit(SwapLoading());
      await emit.forEach(
        swapRepository.getSwapsReceived(event.userId),
        onData: (swaps) => SwapLoaded(swaps),
        onError: (error, stackTrace) => SwapError(error.toString()),
      );
    });

    // Create swap
    on<SwapCreate>((event, emit) async {
      try {
        await swapRepository.createSwap(event.swap);
        emit(SwapSuccess('Swap offer sent successfully'));
      } catch (e) {
        emit(SwapError(e.toString()));
      }
    });

    // Update swap status
    on<SwapUpdateStatus>((event, emit) async {
      try {
        await swapRepository.updateSwapStatus(
          event.swapId,
          event.bookId,
          event.status,
        );
        emit(SwapSuccess('Swap status updated'));
      } catch (e) {
        emit(SwapError(e.toString()));
      }
    });

    // Cancel swap
    on<SwapCancel>((event, emit) async {
      try {
        await swapRepository.deleteSwap(event.swapId, event.bookId);
        emit(SwapSuccess('Swap cancelled'));
      } catch (e) {
        emit(SwapError(e.toString()));
      }
    });
  }
}
