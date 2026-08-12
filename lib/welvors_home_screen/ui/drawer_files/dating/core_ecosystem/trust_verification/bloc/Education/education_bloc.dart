import 'package:flutter_bloc/flutter_bloc.dart';
import 'education_event.dart';
import 'education_state.dart';
import '../../data/education_repository.dart';

class EducationBloc extends Bloc<EducationEvent, EducationState> {
  final EducationRepository repository;

  EducationBloc({required this.repository}) : super(EducationInitial()) {
    on<EducationEvent>(_onLoadEducation);
  }

  Future<void> _onLoadEducation(
    EducationEvent event,
    Emitter<EducationState> emit,
  ) async {
    emit(EducationLoading());

    try {
      final response = await repository.fetchEducation();

      emit(EducationLoaded(response));
    } catch (e) {
      emit(EducationError(e.toString()));
    }
  }
}
