import 'package:equatable/equatable.dart';

class FilterState extends Equatable {
  final double minAge;
  final double maxAge;
  final double distance;
  final String showMe;
  final String showMePreference;
  final List<String> lookingFor;
  final double? minHeight;
  final double? maxHeight;
  final List<String> education;

  const FilterState({
    this.minAge = 19.0,
    this.maxAge = 32.0,
    this.distance = 26.0,
    this.showMe = 'Women',
    this.showMePreference = '',
    this.lookingFor = const [],
    this.minHeight,
    this.maxHeight,
    this.education = const [],
  });

  FilterState copyWith({
    double? minAge,
    double? maxAge,
    double? distance,
    String? showMe,
    String? showMePreference,
    List<String>? lookingFor,
    double? minHeight,
    double? maxHeight,
    List<String>? education,
  }) {
    return FilterState(
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      distance: distance ?? this.distance,
      showMe: showMe ?? this.showMe,
      showMePreference: showMePreference ?? this.showMePreference,
      lookingFor: lookingFor ?? this.lookingFor,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      education: education ?? this.education,
    );
  }

  @override
  List<Object?> get props => [minAge, maxAge, distance, showMe, showMePreference, lookingFor, minHeight, maxHeight, education];
}
