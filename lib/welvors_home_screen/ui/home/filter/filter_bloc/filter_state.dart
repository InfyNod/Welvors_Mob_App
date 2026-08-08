import 'package:equatable/equatable.dart';

class FilterState extends Equatable {
  final double minAge;
  final double maxAge;

  const FilterState({
    this.minAge = 19.0,
    this.maxAge = 32.0,
  });

  FilterState copyWith({
    double? minAge,
    double? maxAge,
  }) {
    return FilterState(
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
    );
  }

  @override
  List<Object?> get props => [minAge, maxAge];
}
