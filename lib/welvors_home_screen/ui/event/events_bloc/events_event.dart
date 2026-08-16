abstract class EventsEvent {}

class SelectCategoryEvent extends EventsEvent {
  final int index;
  SelectCategoryEvent(this.index);
}

class SelectFilterEvent extends EventsEvent {
  final int index;
  SelectFilterEvent(this.index);
}

class SearchQueryEvent extends EventsEvent {
  final String query;
  SearchQueryEvent(this.query);
}
