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

class UpdateDistance extends FilterEvent {
  final double distance;

  const UpdateDistance(this.distance);

  @override
  List<Object?> get props => [distance];
}

class UpdateShowMe extends FilterEvent {
  final String showMe;
  final String showMePreference;

  const UpdateShowMe(this.showMe, this.showMePreference);

  @override
  List<Object?> get props => [showMe, showMePreference];
}

class UpdateLookingFor extends FilterEvent {
  final List<String> lookingFor;

  const UpdateLookingFor(this.lookingFor);

  @override
  List<Object?> get props => [lookingFor];
}

class UpdateHeightRange extends FilterEvent {
  final double minHeight;
  final double maxHeight;

  const UpdateHeightRange(this.minHeight, this.maxHeight);

  @override
  List<Object?> get props => [minHeight, maxHeight];
}

class UpdateEducation extends FilterEvent {
  final List<String> education;

  const UpdateEducation(this.education);

  @override
  List<Object?> get props => [education];
}
