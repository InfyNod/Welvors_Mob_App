class EventsState {
  final int selectedCategoryIndex;
  final int selectedFilterIndex;
  final String searchQuery;
  final Set<String> likedEvents;
  final Set<String> bookedEvents;

  EventsState({
    this.selectedCategoryIndex = 0,
    this.selectedFilterIndex = 0,
    this.searchQuery = '',
    this.likedEvents = const {},
    this.bookedEvents = const {},
  });

  EventsState copyWith({
    int? selectedCategoryIndex,
    int? selectedFilterIndex,
    String? searchQuery,
    Set<String>? likedEvents,
    Set<String>? bookedEvents,
  }) {
    return EventsState(
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      likedEvents: likedEvents ?? this.likedEvents,
      bookedEvents: bookedEvents ?? this.bookedEvents,
    );
  }
}
