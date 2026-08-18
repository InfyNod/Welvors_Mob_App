import 'package:flutter_bloc/flutter_bloc.dart';
import 'events_event.dart';
import 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  EventsBloc() : super(EventsState()) {
    on<SelectCategoryEvent>((event, emit) {
      emit(state.copyWith(selectedCategoryIndex: event.index));
    });

    on<SelectFilterEvent>((event, emit) {
      emit(state.copyWith(selectedFilterIndex: event.index));
    });

    on<SearchQueryEvent>((event, emit) {
      emit(state.copyWith(searchQuery: event.query));
    });

    on<ToggleLikeEvent>((event, emit) {
      final newLikedEvents = Set<String>.from(state.likedEvents);
      if (newLikedEvents.contains(event.eventId)) {
        newLikedEvents.remove(event.eventId);
      } else {
        newLikedEvents.add(event.eventId);
      }
      emit(state.copyWith(likedEvents: newLikedEvents));
    });

    on<BookEventEvent>((event, emit) {
      final newBookedEvents = Set<String>.from(state.bookedEvents);
      newBookedEvents.add(event.eventId);
      emit(state.copyWith(bookedEvents: newBookedEvents));
    });
  }
}
