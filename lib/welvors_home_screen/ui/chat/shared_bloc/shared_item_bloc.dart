import 'package:flutter_bloc/flutter_bloc.dart';

import 'shared_item_model.dart';
import 'shared_item_repository.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

abstract class SharedItemEvent {
  const SharedItemEvent();
}

class LoadSharedItems extends SharedItemEvent {
  final String conversationId;

  const LoadSharedItems(this.conversationId);
}

class RefreshSharedItems extends SharedItemEvent {
  final String conversationId;

  const RefreshSharedItems(this.conversationId);
}

class SharedItemState {
  final bool loading;
  final bool refreshing;
  final SharedItemsBundle? data;
  final String? error;

  const SharedItemState({
    this.loading = false,
    this.refreshing = false,
    this.data,
    this.error,
  });

  SharedItemState copyWith({
    bool? loading,
    bool? refreshing,
    SharedItemsBundle? data,
    String? error,
    bool clearError = false,
  }) {
    return SharedItemState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      data: data ?? this.data,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class SharedItemBloc extends Bloc<SharedItemEvent, SharedItemState> {
  final SharedItemRepository repository;

  SharedItemBloc({required this.repository}) : super(const SharedItemState()) {
    on<LoadSharedItems>(_load);
    on<RefreshSharedItems>(_refresh);
  }

  Future<void> _load(
    LoadSharedItems event,
    Emitter<SharedItemState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));

    try {
      final data = await repository.getSharedItems(event.conversationId);

      AppLogger.i('SharedItemBloc', '✅ MEDIA COUNT: ${data.media.length}');

      AppLogger.i('SharedItemBloc', '✅ DOCUMENT COUNT: ${data.documents.length}');

      AppLogger.i('SharedItemBloc', '✅ LINK COUNT: ${data.links.length}');

      emit(state.copyWith(loading: false, data: data, clearError: true));
    } catch (e) {
      AppLogger.e('SharedItemBloc', '❌ SHARED ITEMS ERROR: $e');

      emit(
        state.copyWith(
          loading: false,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _refresh(
    RefreshSharedItems event,
    Emitter<SharedItemState> emit,
  ) async {
    emit(state.copyWith(refreshing: true, clearError: true));

    try {
      final data = await repository.getSharedItems(event.conversationId);

      emit(state.copyWith(refreshing: false, data: data, clearError: true));
    } catch (e) {
      emit(
        state.copyWith(
          refreshing: false,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
