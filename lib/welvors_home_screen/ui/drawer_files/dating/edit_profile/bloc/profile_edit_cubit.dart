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
  
  void updateDrinking(String val) => emit(state.copyWith(drinking: val));
  void updateSmoking(String val) => emit(state.copyWith(smoking: val));
  void updateWorkout(String val) => emit(state.copyWith(workout: val));
  void updateDiet(String val) => emit(state.copyWith(diet: val));
  void updateTravel(String val) => emit(state.copyWith(travel: val));
  void updateSleep(String val) => emit(state.copyWith(sleep: val));
  
  void togglePet(String pet) {
    final updatedPets = List<String>.from(state.pets);
    if (updatedPets.contains(pet)) {
      updatedPets.remove(pet);
    } else {
      updatedPets.add(pet);
    }
    emit(state.copyWith(pets: updatedPets));
  }
  
  void updateSinglePhoto(int index, XFile? photo) {
    final updatedPhotos = List<XFile?>.from(state.photos);
    updatedPhotos[index] = photo;
    emit(state.copyWith(photos: updatedPhotos));
  }
}
