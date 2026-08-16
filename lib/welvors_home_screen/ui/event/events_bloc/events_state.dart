class EventsState {
  final int selectedCategoryIndex;
  final int selectedFilterIndex;

  EventsState({
    this.selectedCategoryIndex = 0,
    this.selectedFilterIndex = 0,
  });

  EventsState copyWith({
    int? selectedCategoryIndex,
    int? selectedFilterIndex,
  }) {
    return EventsState(
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
    );
  }
}
