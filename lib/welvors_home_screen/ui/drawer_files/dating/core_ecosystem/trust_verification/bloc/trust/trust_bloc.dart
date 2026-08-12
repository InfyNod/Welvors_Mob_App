import '../../data/trust_repository.dart';
import '../../export.dart';

class TrustBloc extends Bloc<TrustEvent, TrustState> {
  TrustBloc({required TrustRepository repository})
    : _repository = repository,
      super(const TrustInitial()) {
    on<LoadTrustData>(_onLoadTrustData);
    on<VerifyItemRequested>(_onVerifyItemRequested);
  }

  final TrustRepository _repository;

  Future<void> _onLoadTrustData(
    LoadTrustData event,
    Emitter<TrustState> emit,
  ) async {
    emit(const TrustLoading());
    try {
      final data = await _repository.fetchTrustData();
      emit(TrustLoaded(data));
    } catch (e) {
      emit(TrustError(e.toString()));
    }
  }

  void _onVerifyItemRequested(
    VerifyItemRequested event,
    Emitter<TrustState> emit,
  ) {
    final current = state;
    if (current is! TrustLoaded) return;

    final sections = List<VerificationSectionModel>.from(current.data.sections);
    if (event.sectionIndex < 0 || event.sectionIndex >= sections.length) {
      return;
    }

    final section = sections[event.sectionIndex];
    final items = List<VerificationItemModel>.from(section.items);
    if (event.itemIndex < 0 || event.itemIndex >= items.length) return;

    final item = items[event.itemIndex];
    if (item.isCompleted || item.islocked) return;

    items[event.itemIndex] = item.copyWith(
      points: '+10 pts earned',
      isCompleted: true,
      isVerfiyed: false,
      islocked: false,
      ptsColor: Mycolor.ptscolor,
      ptstextcolor: Mycolor.green,
    );

    final completedCount = items.where((e) => e.isCompleted).length;
    final progress = items.isEmpty ? 0.0 : completedCount / items.length;
    final allDone = completedCount == items.length;

    sections[event.sectionIndex] = section.copyWith(
      verified: allDone,
      buttonFirstColor: allDone ? Mycolor.pink : section.buttonFirstColor,
      buttonSecondColor: allDone ? Mycolor.pink1 : section.buttonSecondColor,
      buttonTextColor: allDone ? Colors.white : section.buttonTextColor,
      buttonText: allDone
          ? 'Verified'
          : (completedCount > 0 ? 'In Progress' : section.buttonText),
      progress: progress,
      progressLabel: allDone ? '100 %' : '$completedCount/${items.length}',
      items: items,
    );

    final score = current.data.trustScore;
    final earned = (score.score + 10).clamp(0, score.maxScore);
    final remaining = (score.maxScore - earned).clamp(0, score.maxScore);

    emit(
      TrustLoaded(
        current.data.copyWith(
          trustScore: score.copyWith(
            score: earned,
            remainingPoints: remaining,
            progress: earned / score.maxScore,
            remainingLabel: '+$remaining pts to go',
          ),
          sections: sections,
        ),
      ),
    );
  }
}
