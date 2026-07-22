import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_plan_event.dart';
import 'post_plan_state.dart';

class PostPlanBloc extends Bloc<PostPlanEvent, PostPlanState> {
  PostPlanBloc() : super(const PostPlanState()) {
    on<JumpToStepEvent>((event, emit) {
      emit(state.copyWith(currentStep: event.step));
    });

    on<UpdateStep1Event>((event, emit) {
      emit(state.copyWith(
        selectedActivityName: event.activityName,
        selectedActivityImage: event.activityImage,
        currentStep: 2,
      ));
    });

    on<UpdateStep2Event>((event, emit) {
      emit(state.copyWith(
        title: event.title,
        description: event.description,
        tags: event.tags,
        currentStep: 3,
      ));
    });

    on<UpdateStep3Event>((event, emit) {
      emit(state.copyWith(
        locationName: event.locationName,
        locationSubtitle: event.locationSubtitle,
        landmark: event.landmark,
        whenDate: event.whenDate,
        time: event.time,
        howLong: event.howLong,
        whoPays: event.whoPays,
        groupSize: event.groupSize,
        whoCanRequest: event.whoCanRequest,
        visibility: event.visibility,
        // Carry over group setting to final options
        finalWhoCanJoin: event.groupSize,
        currentStep: 4,
      ));
    });

    on<UpdateReviewSettingsEvent>((event, emit) {
      emit(state.copyWith(
        finalWhoCanJoin: event.finalWhoCanJoin,
        verifiedMembersOnly: event.verifiedMembersOnly,
        autoApproveRequests: event.autoApproveRequests,
      ));
    });
  }
}
