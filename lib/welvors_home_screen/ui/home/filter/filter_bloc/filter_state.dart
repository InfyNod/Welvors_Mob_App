import 'package:equatable/equatable.dart';

class FilterState extends Equatable {
  final double minAge;
  final double maxAge;
  final double distance;
  final String showMe;
  final String showMePreference;

  const FilterState({
    this.minAge = 19.0,
    this.maxAge = 32.0,
    this.distance = 26.0,
    this.showMe = 'Women',
    this.showMePreference = '',
  });

  FilterState copyWith({
    double? minAge,
    double? maxAge,
    double? distance,
    String? showMe,
    String? showMePreference,
  }) {
    return FilterState(
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      distance: distance ?? this.distance,
      showMe: showMe ?? this.showMe,
      showMePreference: showMePreference ?? this.showMePreference,
    );
  }

  @override
  List<Object?> get props => [minAge, maxAge, distance, showMe, showMePreference];
}
