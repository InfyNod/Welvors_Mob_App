import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_edit_state.dart';

class ProfileEditCubit extends Cubit<ProfileEditState> {
  ProfileEditCubit() : super(ProfileEditState.initial());

  void updateFullName(String name) => emit(state.copyWith(fullName: name));
  void updateEmail(String email) => emit(state.copyWith(email: email));
  void updateDob(String dob) => emit(state.copyWith(dob: dob));
  void updateHeight(String height) => emit(state.copyWith(height: height));
  void updateGender(String gender) => emit(state.copyWith(gender: gender));
  void updateGenderIdentity(String identity) => emit(state.copyWith(genderIdentity: identity));
  void updateReligionCaste(String religionCaste) => emit(state.copyWith(religionCaste: religionCaste));
  void updateMotherTongue(String tongue) => emit(state.copyWith(motherTongue: tongue));
  void updateZodiac(String zodiac) => emit(state.copyWith(zodiac: zodiac));
  void updateLoveLanguage(String language) => emit(state.copyWith(loveLanguage: language));
  void updateCommunication(String comms) => emit(state.copyWith(communication: comms));
  
  void updateBio(String bio) => emit(state.copyWith(bio: bio));
  void updateIntention(String intention) => emit(state.copyWith(intention: intention));

  void updatePhotos(List<XFile?> newPhotos) => emit(state.copyWith(photos: newPhotos));
  
  void updateVideoPath(String? path) => emit(state.copyWith(videoPath: path));
  
  void updateInterestedIn(String interested) => emit(state.copyWith(interestedIn: interested));
  void updateSexualOrientation(String orientation) => emit(state.copyWith(sexualOrientation: orientation));
  
  void updateSinglePhoto(int index, XFile? photo) {
    final updatedPhotos = List<XFile?>.from(state.photos);
    updatedPhotos[index] = photo;
    emit(state.copyWith(photos: updatedPhotos));
  }
}
