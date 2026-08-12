import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/professional_verication_repository.dart';
import 'professional_verfication_evnt.dart';
import 'professional_verfication_state.dart';

class professional_verfication_bloc
    extends Bloc<professional_verficationEvent, professional_verficationState> {
  final ProfessionalverificationRepository repository;

  professional_verfication_bloc({required this.repository})
    : super(professional_verficationInitial()) {
    on<professional_verficationEvent>(_onLoadprofessional_verfication);
  }

  Future<void> _onLoadprofessional_verfication(
    professional_verficationEvent event,
    Emitter<professional_verficationState> emit,
  ) async {
    emit(professional_verficationLoading());

    try {
      final response = await repository.fetchProfessionverification();

      emit(professional_verficationLoaded(response));
    } catch (e) {
      emit(professional_verficationError(e.toString()));
    }
  }
}
