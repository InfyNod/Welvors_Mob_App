import 'package:flutter_bloc/flutter_bloc.dart';
import 'filter_event.dart';
import 'filter_state.dart';

class FilterBloc extends Bloc<FilterEvent, FilterState> {
  FilterBloc() : super(const FilterState()) {
    on<UpdateAgeRange>((event, emit) {
      emit(state.copyWith(
        minAge: event.startAge,
        maxAge: event.endAge,
      ));
    });

    on<UpdateDistance>((event, emit) {
      emit(state.copyWith(
        distance: event.distance,
      ));
    });

    on<UpdateShowMe>((event, emit) {
      emit(state.copyWith(
        showMe: event.showMe,
        showMePreference: event.showMePreference,
      ));
    });
  }
}
