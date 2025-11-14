import 'package:equatable/equatable.dart';
import '../../data/models/swap_model.dart';

abstract class SwapState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SwapInitial extends SwapState {}

class SwapLoading extends SwapState {}

class SwapLoaded extends SwapState {
  final List<SwapModel> swaps;
  SwapLoaded(this.swaps);
  @override
  List<Object?> get props => [swaps];
}

class SwapError extends SwapState {
  final String message;
  SwapError(this.message);
  @override
  List<Object?> get props => [message];
}

class SwapSuccess extends SwapState {
  final String message;
  SwapSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
