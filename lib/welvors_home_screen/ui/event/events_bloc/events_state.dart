class EventsState {
  final int selectedCategoryIndex;
  final int selectedFilterIndex;
  final String searchQuery;

  EventsState({
    this.selectedCategoryIndex = 0,
    this.selectedFilterIndex = 0,
    this.searchQuery = '',
  });

  EventsState copyWith({
    int? selectedCategoryIndex,
    int? selectedFilterIndex,
    String? searchQuery,
  }) {
    return EventsState(
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
