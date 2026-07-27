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
  
  // Location
  void updateArea(String val) => emit(state.copyWith(area: val));
  void updateCity(String val) => emit(state.copyWith(city: val));
  void updateStateLocation(String val) => emit(state.copyWith(stateLocation: val));
  void updateShowDistance(bool val) => emit(state.copyWith(showDistance: val));
  
  // VIP Networking Intent
  void updateNetworkingIntents(List<String> intents) => emit(state.copyWith(networkingIntents: intents));
  void updateNetworkingInYourWords(String val) => emit(state.copyWith(networkingInYourWords: val));
  
  // Education & Career
  void updateCollege(String val) => emit(state.copyWith(college: val));
  void updateHighestEducation(String val) => emit(state.copyWith(highestEducation: val));
  void updateDegreeCourse(String val) => emit(state.copyWith(degreeCourse: val));
  void updateGraduationYear(String val) => emit(state.copyWith(graduationYear: val));
  void updateProfession(String val) => emit(state.copyWith(profession: val));
  void updateCompany(String val) => emit(state.copyWith(company: val));
  void updateExperience(String val) => emit(state.copyWith(experience: val));
  void updateEmploymentType(String val) => emit(state.copyWith(employmentType: val));
  void updateSalaryRange(String val) => emit(state.copyWith(salaryRange: val));
  void updateAmbitionLevel(String val) => emit(state.copyWith(ambitionLevel: val));
  void updateBigDreams(String val) => emit(state.copyWith(bigDreams: val));
  
  void togglePet(String pet) {
    final updatedPets = List<String>.from(state.pets);
    if (updatedPets.contains(pet)) {
      updatedPets.remove(pet);
    } else {
      updatedPets.add(pet);
    }
    emit(state.copyWith(pets: updatedPets));
  }
  
  void updateInterests(List<String> interests) {
    emit(state.copyWith(interests: interests));
  }
  
  void updatePrompts(List<Map<String, String>> prompts) {
    emit(state.copyWith(prompts: prompts));
  }
  
  void updateSinglePhoto(int index, XFile? photo) {
    final updatedPhotos = List<XFile?>.from(state.photos);
    updatedPhotos[index] = photo;
    emit(state.copyWith(photos: updatedPhotos));
  }
  
  // Family
  void updateFamilyType(String val) => emit(state.copyWith(familyType: val));
  void updateFather(String val) => emit(state.copyWith(father: val));
  void updateMother(String val) => emit(state.copyWith(mother: val));
  void updateSisters(String val) => emit(state.copyWith(sisters: val));
  void updateBrothers(String val) => emit(state.copyWith(brothers: val));
  void updateFamilyHome(String val) => emit(state.copyWith(familyHome: val));
  void updateNativePlace(String val) => emit(state.copyWith(nativePlace: val));
  void updateFamilyIncome(String val) => emit(state.copyWith(familyIncome: val));
}
