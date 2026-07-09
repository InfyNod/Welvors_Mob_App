import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingInitial()) {
    on<FetchIntentionsEvent>(_onFetchIntentions);
    on<SubmitIntentionsEvent>(_onSubmitIntentions);
    on<FetchLifestyleEvent>(_onFetchLifestyle);
    on<SubmitLifestyleEvent>(_onSubmitLifestyle);
    on<FetchInterestsEvent>(_onFetchInterests);
    on<SubmitInterestsEvent>(_onSubmitInterests);
    on<FetchPromptsCategoriesEvent>(_onFetchPromptsCategories);
    on<SubmitPromptsEvent>(_onSubmitPrompts);
    on<SubmitPhotosEvent>(_onSubmitPhotos);
    on<SubmitBasicsEvent>(_onSubmitBasics);
    on<SubmitCareerEvent>(_onSubmitCareer);
    on<SubmitBioEvent>(_onSubmitBio);
    on<SubmitPreferencesEvent>(_onSubmitPreferences);
    on<SubmitLocationEvent>(_onSubmitLocation);
  }

  Future<void> _onFetchIntentions(FetchIntentionsEvent event, Emitter<OnboardingState> emit) async {
    emit(OnboardingLoading());
    final data = await ApiService.fetchIntentions();
    emit(OnboardingSuccess(data));
  }

  Future<void> _onSubmitIntentions(SubmitIntentionsEvent event, Emitter<OnboardingState> emit) async {
    emit(OnboardingLoading());
    final error = await ApiService.submitLookingFor(event.intentionId);
    if (error != null) {
      emit(OnboardingFailure(error));
    } else {
      emit(const OnboardingSuccess());
    }
  }

  Future<void> _onFetchLifestyle(FetchLifestyleEvent event, Emitter<OnboardingState> emit) async {
    emit(OnboardingLoading());
    final data = await ApiService.fetchLifestyle();
    emit(OnboardingSuccess(data));
  }

  Future<void> _onSubmitLifestyle(SubmitLifestyleEvent event, Emitter<OnboardingState> emit) async {
    emit(OnboardingLoading());
    String? firstError;
    for (final answer in event.answers) {
      final qId = answer['questionId'] as String;
      final optionIds = answer['optionIds'] as List<String>;
      final error = await ApiService.submitAnswer(questionId: qId, optionIds: optionIds);
      if (error != null && firstError == null) {
        firstError = error;
      }
    }
    
    if (firstError != null) {
      emit(OnboardingFailure(firstError));
    } else {
      emit(const OnboardingSuccess());
    }
  }

  Future<void> _onFetchInterests(FetchInterestsEvent event, Emitter<OnboardingState> emit) async {
    emit(OnboardingLoading());
    final data = await ApiService.fetchInterests();
    emit(OnboardingSuccess(data));
  }

  Future<void> _onSubmitInterests(SubmitInterestsEvent event, Emitter<OnboardingState> emit) async {
    emit(OnboardingLoading());
    String? firstError;
    for (final answer in event.answers) {
      final qId = answer['questionId'] as String;
      final optionIds = answer['optionIds'] as List<String>;
      final error = await ApiService.submitAnswer(questionId: qId, optionIds: optionIds);
      if (error != null && firstError == null) {
        firstError = error;
      }
    }

    if (firstError != null) {
      emit(OnboardingFailure(firstError));
    } else {
      emit(const OnboardingSuccess());
    }
  }

  Future<void> _onFetchPromptsCategories(FetchPromptsCategoriesEvent event, Emitter<OnboardingState> emit) async {
    emit(OnboardingLoading());
    final data = await ApiService.fetchPromptsCategories();
    emit(OnboardingSuccess(data));
  }

  Future<void> _onSubmitPrompts(SubmitPromptsEvent event, Emitter<OnboardingState> emit) async {
    emit(OnboardingLoading());
    final error = await ApiService.submitPrompts(event.payload);
    if (error != null) {
      emit(OnboardingFailure(error));
    } else {
      emit(const OnboardingSuccess());
    }
  }

  Future<void> _onSubmitPhotos(SubmitPhotosEvent event, Emitter<OnboardingState> emit) async {
    emit(OnboardingLoading());
    final error = await ApiService.submitPhotos(event.paths);
    if (error != null) {
      emit(OnboardingFailure(error));
    } else {
      emit(const OnboardingSuccess());
    }
  }

  Future<void> _onSubmitBasics(SubmitBasicsEvent event, Emitter<OnboardingState> emit) async {
    emit(OnboardingLoading());
    final error = await ApiService.submitBasicInfo(event.payload);
    if (error != null) {
      emit(OnboardingFailure(error));
    } else {
      emit(const OnboardingSuccess());
    }
  }

  Future<void> _onSubmitCareer(SubmitCareerEvent event, Emitter<OnboardingState> emit) async {
    emit(OnboardingLoading());
    if (event.education != null) {
      final eduError = await ApiService.submitEducation(event.education!);
      if (eduError != null) {
        emit(OnboardingFailure(eduError));
        return;
      }
    }
    if (event.work != null) {
      final workError = await ApiService.submitWork(event.work!);
      if (workError != null) {
        emit(OnboardingFailure(workError));
        return;
      }
    }
    emit(const OnboardingSuccess());
  }

  Future<void> _onSubmitBio(SubmitBioEvent event, Emitter<OnboardingState> emit) async {
    emit(OnboardingLoading());
    final error = await ApiService.submitBio(event.bio);
    if (error != null) {
      emit(OnboardingFailure(error));
    } else {
      emit(const OnboardingSuccess());
    }
  }

  Future<void> _onSubmitPreferences(SubmitPreferencesEvent event, Emitter<OnboardingState> emit) async {
    emit(OnboardingLoading());
    final error = await ApiService.submitInterestedIn(event.interestedIn);
    if (error != null) {
      emit(OnboardingFailure(error));
    } else {
      emit(const OnboardingSuccess());
    }
  }

  Future<void> _onSubmitLocation(SubmitLocationEvent event, Emitter<OnboardingState> emit) async {
    emit(OnboardingLoading());
    final error1 = await ApiService.submitAddress(event.country, event.state, event.city);
    final error2 = await ApiService.submitLocation(event.lat, event.lng);
    if (error1 != null || error2 != null) {
      emit(OnboardingFailure(error1 ?? error2!));
    } else {
      emit(const OnboardingSuccess());
    }
  }
}
