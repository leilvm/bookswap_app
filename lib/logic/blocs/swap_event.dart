import 'package:equatable/equatable.dart';
import '../../data/models/swap_model.dart';

abstract class SwapEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SwapLoadSent extends SwapEvent {
  final String userId;
  SwapLoadSent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class SwapLoadReceived extends SwapEvent {
  final String userId;
  SwapLoadReceived(this.userId);
  @override
  List<Object?> get props => [userId];
}

class SwapCreate extends SwapEvent {
  final SwapModel swap;
  SwapCreate(this.swap);
  @override
  List<Object?> get props => [swap];
}

class SwapUpdateStatus extends SwapEvent {
  final String swapId;
  final String bookId;
  final SwapStatus status;
  SwapUpdateStatus({
    required this.swapId,
    required this.bookId,
    required this.status,
  });
  @override
  List<Object?> get props => [swapId, bookId, status];
}

class SwapCancel extends SwapEvent {
  final String swapId;
  final String bookId;
  SwapCancel({required this.swapId, required this.bookId});
  @override
  List<Object?> get props => [swapId, bookId];
}
