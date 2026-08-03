import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../services/edit_profile_api_service.dart';
import '../models/profile_photo.dart';
import 'profile_edit_state.dart';

class ProfileEditCubit extends Cubit<ProfileEditState> {
  ProfileEditCubit() : super(ProfileEditState.initial()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    final response = await EditProfileApiService.getProfileDetails();
    if (response['error'] == null && response['data'] != null) {
      final data = response['data'];
      
      final basic = data['basicDetails'] ?? {};
      final bio = data['bio']?['bio'] ?? '';
      final lookingFor = data['lookingFor']?['title'] ?? '';
      final career = data['educationCareer'] ?? {};
      final family = data['family'] ?? {};
      final profile = data['profile'] ?? {};
      
      // Parse photos
      List<ProfilePhoto?> parsedPhotos = List.filled(6, null);
      if (data['photos'] != null && data['photos'] is List) {
        for (var p in data['photos']) {
          final int order = p['order'] ?? 1;
          if (order >= 1 && order <= 6) {
            parsedPhotos[order - 1] = ProfilePhoto(
              id: p['id'],
              url: p['url'],
            );
          }
        }
      }

      emit(state.copyWith(
        fullName: basic['fullName'] ?? '',
        email: basic['email'] ?? '',
        dob: basic['birthDate'] != null ? basic['birthDate'].toString().split('T').first : '',
        height: basic['height'] != null ? '${basic['height']} cm' : '',
        gender: basic['gender'] ?? '',
        genderIdentity: basic['genderOption'] ?? '',
        religionCaste: basic['religion']?['name'] ?? '',
        motherTongue: '', // not in API response
        zodiac: basic['zodiac'] ?? '',
        loveLanguage: basic['loveLanguage'] ?? '',
        communication: basic['communicationStyle'] ?? '',
        
        bio: bio,
        intention: lookingFor,
        
        highestEducation: career['highestEducation'] ?? '',
        degreeCourse: career['degree'] ?? '',
        college: career['collegeName'] ?? '',
        graduationYear: career['graduationYear']?.toString() ?? '',
        profession: career['profession']?['name'] ?? '',
        company: career['companyName'] ?? '',
        employmentType: career['employmentType']?['name'] ?? '',
        experience: career['experience']?['title'] ?? '',
        salaryRange: career['salaryRange']?['title'] ?? '',
        ambitionLevel: career['ambition']?['title'] ?? '',
        bigDreams: career['bigDreams'] ?? '',
        
        familyType: family['familyType']?['value'] ?? '',
        familyHome: family['familyHome']?['value'] ?? '',
        nativePlace: family['nativePlace']?['value'] ?? '',
        familyIncome: family['familyIncome']?['title'] ?? '',
        father: family['fatherOccupation']?['value'] ?? '',
        mother: family['motherOccupation']?['value'] ?? '',
        
        interestedIn: profile['interestedIn'] ?? '',
        sexualOrientation: profile['sexualOrientation'] ?? '',
        
        photos: parsedPhotos,
      ));
    }
  }

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

  void updatePhotos(List<ProfilePhoto?> newPhotos) => emit(state.copyWith(photos: newPhotos));
  
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
  void updateWorkStyle(String val) => emit(state.copyWith(workStyle: val));
  
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
  
  Future<void> updateSinglePhoto(int index, XFile? photo) async {
    final updatedPhotos = List<ProfilePhoto?>.from(state.photos);
    final existingPhoto = updatedPhotos[index];

    if (photo == null) {
      updatedPhotos[index] = null;
      emit(state.copyWith(photos: updatedPhotos));
      return;
    }

    final newPhotoState = ProfilePhoto(
      id: existingPhoto?.id,
      localFile: photo,
      isUploading: true,
    );
    updatedPhotos[index] = newPhotoState;
    emit(state.copyWith(photos: updatedPhotos));

    String? error;
    String? newPhotoId = existingPhoto?.id; // default to existing id
    if (existingPhoto?.id != null) {
      error = await EditProfileApiService.updateSpecificPhoto(existingPhoto!.id!, photo.path);
    } else {
      final response = await EditProfileApiService.addPhoto(photo.path);
      error = response['error'];
      if (error == null) {
        // try to extract new photo id from data
        final data = response['data'];
        if (data != null && data['data'] != null) {
          final photoData = data['data'];
          if (photoData is Map) {
             newPhotoId = photoData['_id'] ?? photoData['id'] ?? photoData['photoId'];
          } else if (photoData is List && photoData.isNotEmpty) {
             final lastPhoto = photoData.last;
             if (lastPhoto is Map) {
                newPhotoId = lastPhoto['_id'] ?? lastPhoto['id'] ?? lastPhoto['photoId'];
             }
          }
        }
      }
    }

    final finishedPhotos = List<ProfilePhoto?>.from(state.photos);
    if (error == null) {
       finishedPhotos[index] = finishedPhotos[index]?.copyWith(
         isUploading: false, 
         clearError: true,
         id: newPhotoId, // save the new id so future edits use PATCH
       );
    } else {
       finishedPhotos[index] = finishedPhotos[index]?.copyWith(isUploading: false, uploadError: error);
    }
    emit(state.copyWith(photos: finishedPhotos));
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
  void updateFamilyDynamic(String val) => emit(state.copyWith(familyDynamic: val));
}
