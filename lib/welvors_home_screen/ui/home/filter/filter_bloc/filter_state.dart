import 'package:equatable/equatable.dart';

class FilterState extends Equatable {
  final double minAge;
  final double maxAge;
  final double distance;

  const FilterState({
    this.minAge = 19.0,
    this.maxAge = 32.0,
    this.distance = 26.0,
  });

  FilterState copyWith({
    double? minAge,
    double? maxAge,
    double? distance,
  }) {
    return FilterState(
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      distance: distance ?? this.distance,
    );
  }

  @override
  List<Object?> get props => [minAge, maxAge, distance];
}
