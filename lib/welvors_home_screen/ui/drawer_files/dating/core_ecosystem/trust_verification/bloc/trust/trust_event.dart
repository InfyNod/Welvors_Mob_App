import 'package:equatable/equatable.dart';

abstract class TrustEvent extends Equatable {
  const TrustEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrustData extends TrustEvent {
  const LoadTrustData();
}

class VerifyItemRequested extends TrustEvent {
  final int sectionIndex;
  final int itemIndex;

  const VerifyItemRequested({
    required this.sectionIndex,
    required this.itemIndex,
  });

  @override
  List<Object?> get props => [sectionIndex, itemIndex];
}
