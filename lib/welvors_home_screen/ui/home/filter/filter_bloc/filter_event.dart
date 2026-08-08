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

class UpdateLanguages extends FilterEvent {
  final List<String> languages;

  const UpdateLanguages(this.languages);

  @override
  List<Object?> get props => [languages];
}

class UpdateLifestyle extends FilterEvent {
  final List<String> lifestyle;

  const UpdateLifestyle(this.lifestyle);

  @override
  List<Object?> get props => [lifestyle];
}

class UpdateReligion extends FilterEvent {
  final List<String> religion;

  const UpdateReligion(this.religion);

  @override
  List<Object?> get props => [religion];
}

class UpdateProfession extends FilterEvent {
  final List<String> profession;

  const UpdateProfession(this.profession);

  @override
  List<Object?> get props => [profession];
}

class UpdateZodiac extends FilterEvent {
  final String zodiac;

  const UpdateZodiac(this.zodiac);

  @override
  List<Object?> get props => [zodiac];
}
