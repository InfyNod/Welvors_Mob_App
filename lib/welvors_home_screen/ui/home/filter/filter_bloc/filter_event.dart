import 'package:equatable/equatable.dart';

abstract class FilterEvent extends Equatable {
  const FilterEvent();

  @override
  List<Object?> get props => [];
}

class UpdateAgeRange extends FilterEvent {
  final double startAge;
  final double endAge;

  const UpdateAgeRange(this.startAge, this.endAge);

  @override
  List<Object?> get props => [startAge, endAge];
}
