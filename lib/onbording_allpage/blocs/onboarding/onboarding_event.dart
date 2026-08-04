import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class FetchIntentionsEvent extends OnboardingEvent {}

class SubmitIntentionsEvent extends OnboardingEvent {
  final String intentionId;

  const SubmitIntentionsEvent(this.intentionId);

  @override
  List<Object?> get props => [intentionId];
}

class FetchLifestyleEvent extends OnboardingEvent {}

class SubmitLifestyleEvent extends OnboardingEvent {
  final List<Map<String, dynamic>> answers;

  const SubmitLifestyleEvent(this.answers);

  @override
  List<Object?> get props => [answers];
}

class FetchInterestsEvent extends OnboardingEvent {}

class SubmitInterestsEvent extends OnboardingEvent {
  final List<Map<String, dynamic>> answers;

  const SubmitInterestsEvent(this.answers);

  @override
  List<Object?> get props => [answers];
}

class FetchPromptsCategoriesEvent extends OnboardingEvent {}

class SubmitPromptsEvent extends OnboardingEvent {
  final List<Map<String, String>> payload;

  const SubmitPromptsEvent(this.payload);

  @override
  List<Object?> get props => [payload];
}

class SubmitPhotosEvent extends OnboardingEvent {
  final List<String> paths;

  const SubmitPhotosEvent(this.paths);

  @override
  List<Object?> get props => [paths];
}

class SubmitBasicsEvent extends OnboardingEvent {
  final Map<String, dynamic> payload;

  const SubmitBasicsEvent(this.payload);

  @override
  List<Object?> get props => [payload];
}

class SubmitCareerEvent extends OnboardingEvent {
  final Map<String, dynamic>? education;
  final Map<String, dynamic>? work;

  const SubmitCareerEvent({this.education, this.work});

  @override
  List<Object?> get props => [education, work];
}

class SubmitBioEvent extends OnboardingEvent {
  final String bio;

  const SubmitBioEvent(this.bio);

  @override
  List<Object?> get props => [bio];
}

class SubmitPreferencesEvent extends OnboardingEvent {
  final String interestedIn;
  final String sexualOrientation;

  const SubmitPreferencesEvent(this.interestedIn, this.sexualOrientation);

  @override
  List<Object?> get props => [interestedIn, sexualOrientation];
}

class SubmitLocationEvent extends OnboardingEvent {
  final String country;
  final String state;
  final String city;
  final double lat;
  final double lng;

  const SubmitLocationEvent({
    required this.country,
    required this.state,
    required this.city,
    required this.lat,
    required this.lng,
  });

  @override
  List<Object?> get props => [country, state, city, lat, lng];
}
