import 'package:flutter_bloc/flutter_bloc.dart';
import 'admirers_event.dart';
import 'admirers_state.dart';

class AdmirersBloc extends Bloc<AdmirersEvent, AdmirersState> {
  AdmirersBloc() : super(AdmirersInitial()) {
    on<LoadAdmirersData>(_onLoadAdmirersData);
    on<ChangeAdmirersTab>(_onChangeAdmirersTab);
  }

  void _onLoadAdmirersData(LoadAdmirersData event, Emitter<AdmirersState> emit) {
    emit(AdmirersLoaded(
      coins: 1280,
      likesCount: 36,
      rosesCount: 3,
      activeTab: 'likes',
    ));
  }

  void _onChangeAdmirersTab(ChangeAdmirersTab event, Emitter<AdmirersState> emit) {
    if (state is AdmirersLoaded) {
      final currentState = state as AdmirersLoaded;
      emit(currentState.copyWith(activeTab: event.tab));
    }
  }
}
