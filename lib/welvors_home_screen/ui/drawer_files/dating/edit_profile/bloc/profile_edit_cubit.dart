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

      String lookingFor = data['lookingFor']?['title'] ?? '';
      if (lookingFor.startsWith('"') &&
          lookingFor.endsWith('"') &&
          lookingFor.length >= 2) {
        lookingFor = lookingFor.substring(1, lookingFor.length - 1);
      }

      final career = data['educationCareer'] ?? {};
      final family = data['family'] ?? {};
      final profile = data['profile'] ?? {};

      // Parse photos
      List<ProfilePhoto?> parsedPhotos = List.filled(6, null);
      if (data['photos'] != null && data['photos'] is List) {
        var backendPhotos = List.from(data['photos']);
        // Sort by order just in case they are different, but keep original sequence if same
        backendPhotos.sort((a, b) {
          int orderA = a['order'] ?? 1;
          int orderB = b['order'] ?? 1;
          return orderA.compareTo(orderB);
        });

        int currentIndex = 0;
        for (var p in backendPhotos) {
          if (currentIndex < 6) {
            parsedPhotos[currentIndex] = ProfilePhoto(
              id: p['id'],
              url: p['url'],
            );
            currentIndex++;
          }
        }
      }

      String formattedHeight = '';
      if (basic['height'] != null) {
        int cm = basic['height'] is int
            ? basic['height']
            : int.tryParse(basic['height'].toString()) ?? 0;
        if (cm > 0) {
          int inches = (cm / 2.54).round();
          int feet = inches ~/ 12;
          int remainingInches = inches % 12;
          formattedHeight = '$feet\'$remainingInches" · $cm cm';
        }
      }

      String mapGenderFromBackend(String? g) {
        if (g == null) return '';
        if (g.toUpperCase() == 'MEN') return 'Man';
        if (g.toUpperCase() == 'WOMEN') return 'Woman';
        return g.substring(0, 1).toUpperCase() +
            g.substring(1).toLowerCase().replaceAll('_', ' ');
      }

      String formatEnumFromBackend(String? val) {
        if (val == null || val.isEmpty) return '';
        if (val == 'AROMATIC') return 'Aromantic';
        final parts = val.split('_');
        return parts
            .map((p) {
              if (p.isEmpty) return '';
              return p[0].toUpperCase() + p.substring(1).toLowerCase();
            })
            .join(' ');
      }

      String parseHighestEdu(String? val) {
        if (val == null || val.isEmpty) return '';
        switch (val) {
          case 'UNDER_GRADUATE':
            return 'Undergraduate';
          case 'POST_GRADUATE':
            return 'Post Graduate';
          case 'HIGH_SCHOOL':
            return 'High School';
          case 'BACHELOR':
            return 'Undergraduate';
          case 'MASTER':
            return 'Master';
          case 'PHD':
            return 'PhD';
          case 'DIPLOMA':
            return 'Diploma';
          default:
            return formatEnumFromBackend(val);
        }
      }

      String formattedDob = '';
      if (basic['birthDate'] != null) {
        final dobStr = basic['birthDate'].toString().split('T').first;
        final parts = dobStr.split('-');
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            // YYYY-MM-DD
            formattedDob = '${parts[2]} / ${parts[1]} / ${parts[0]}';
          } else {
            // DD-MM-YYYY
            formattedDob = '${parts[0]} / ${parts[1]} / ${parts[2]}';
          }
        }
      }

      List<int>? parsedLanguageIds;
      String parsedMotherTongue = '';
      if (basic['languages'] != null && basic['languages'] is List) {
        final langs = basic['languages'] as List;
        parsedLanguageIds = langs.map((l) => l['id'] as int).toList();
        parsedMotherTongue = langs.map((l) => l['name'].toString()).join(', ');
      } else if (basic['languageIds'] != null && basic['languageIds'] is List) {
        final langIds = basic['languageIds'] as List;
        parsedLanguageIds = langIds.map((e) => e as int).toList();
      }

      List<Map<String, dynamic>> parsedLifestyle = [];
      if (data['lifestyle'] != null && data['lifestyle'] is List) {
        for (var item in data['lifestyle']) {
          parsedLifestyle.add({
            'id': item['id'],
            'question': item['question'],
            'option': item['option'],
          });
        }
      }

      List<String> parsedInterests = [];
      if (data['interests'] != null && data['interests'] is List) {
        for (var item in data['interests']) {
          final question = item['question']?.toString() ?? '';
          final option = item['option']?.toString() ?? '';
          if (option.isNotEmpty) {
            String emoji = '✨';
            final lowerQ = question.toLowerCase();
            if (lowerQ.contains('creativ'))
              emoji = '🎨';
            else if (lowerQ.contains('favorite'))
              emoji = '🎬';
            else if (lowerQ.contains('food') || lowerQ.contains('drink'))
              emoji = '🍔';
            else if (lowerQ.contains('travel') || lowerQ.contains('outdoor'))
              emoji = '✈️';
            else if (lowerQ.contains('gam'))
              emoji = '🎮';
            else if (lowerQ.contains('well'))
              emoji = '🧘';

            parsedInterests.add('$emoji $option');
          }
        }
      }

      List<Map<String, String>> parsedPrompts = [];
      if (data['prompts'] != null && data['prompts'] is List) {
        for (var item in data['prompts']) {
          String question = item['question']?.toString() ?? item['prompt']?.toString() ?? '';
          String answer = item['answer']?.toString() ?? '';
          String promptId = item['promptId']?.toString() ?? item['id']?.toString() ?? item['questionId']?.toString() ?? '';
          String categoryId = item['categoryId']?.toString() ?? '';
          
          if (item['prompt'] is Map) {
            final p = item['prompt'];
            question = p['question']?.toString() ?? question;
            promptId = p['id']?.toString() ?? promptId;
            categoryId = p['categoryId']?.toString() ?? categoryId;
          }
          if (item['category'] is Map) {
            categoryId = item['category']['id']?.toString() ?? categoryId;
          }

          parsedPrompts.add({
            'question': question,
            'answer': answer,
            'promptId': promptId,
            'categoryId': categoryId,
          });
        }
      }

      emit(
        state.copyWith(
          fullName: basic['fullName'] ?? '',
          email: basic['email'] ?? '',
          dob: formattedDob,
          height: formattedHeight,
          gender: mapGenderFromBackend(basic['gender']),
          genderIdentity: formatEnumFromBackend(basic['genderOption'] ?? ''),
          religionCaste:
              (basic['community'] != null &&
                  basic['community']['name'] != null &&
                  basic['community']['name'].toString().isNotEmpty)
              ? '${basic['religion']?['name'] ?? ''} · ${basic['community']?['name'] ?? ''}'
              : basic['religion']?['name'] ?? '',
          religionId: basic['religion']?['id'] as int?,
          communityId: basic['community']?['id'] as int?,
          languageIds: parsedLanguageIds,
          motherTongue: parsedMotherTongue,
          interests: parsedInterests,
          prompts: parsedPrompts,
          zodiac: formatEnumFromBackend(basic['zodiac']),
          loveLanguage: formatEnumFromBackend(basic['loveLanguage']),
          communication: formatEnumFromBackend(basic['communicationStyle']),

          bio: bio,
          intention: lookingFor,

          highestEducation: parseHighestEdu(
            career['highestEducation'] ?? career['highestEdu'],
          ),
          degreeCourse: career['degree'] ?? '',
          college: career['collegeName'] ?? '',
          graduationYear: career['graduationYear']?.toString() ?? '',
          profession: career['profession']?['name'] ?? '',
          professionId: career['profession']?['id'] as int?,
          company: career['companyName'] ?? '',
          employmentType: career['employmentType']?['name'] ?? '',
          employmentTypeId: career['employmentType']?['id'] as int?,
          experience: career['experience']?['title'] ?? '',
          experienceId: career['experience']?['id'] as int?,
          salaryRange: career['salaryRange']?['title'] ?? '',
          salaryRangeId: career['salaryRange']?['id'] as int?,
          ambitionLevel: career['ambition']?['title'] ?? '',
          ambitionId: career['ambition']?['id'] as int?,
          bigDreams: career['bigDreams'] ?? '',

          familyType: family['familyType']?['value'] ?? '',
          familyHome: family['familyHome']?['value'] ?? '',
          nativePlace: family['nativePlace']?['value'] ?? '',
          familyIncome: family['familyIncome']?['title'] ?? '',
          father: family['fatherOccupation']?['value'] ?? '',
          mother: family['motherOccupation']?['value'] ?? '',

          interestedIn: formatEnumFromBackend(profile['interestedIn']),
          sexualOrientation: formatEnumFromBackend(
            profile['sexualOrientation'],
          ),

          lifestyle: parsedLifestyle,
          photos: parsedPhotos,
          profileScore: data['profileScore'] ?? 0,
        ),
      );
    }
  }

  void updateFullName(String name) {
    emit(state.copyWith(fullName: name));
    saveBasicDetails();
  }

  void updateEmail(String email) {
    emit(state.copyWith(email: email));
    saveBasicDetails();
  }

  void updateDob(String dob) {
    emit(state.copyWith(dob: dob));
    saveBasicDetails();
  }

  void updateHeight(String height) {
    emit(state.copyWith(height: height));
    saveBasicDetails();
  }

  void updateGender(String gender) {
    emit(state.copyWith(gender: gender));
    saveBasicDetails();
  }

  void updateGenderIdentity(String identity) {
    emit(state.copyWith(genderIdentity: identity));
    saveBasicDetails();
  }

  void updateLifestyleAnswer(String questionTitle, List<String> optionLabels) {
    List<Map<String, dynamic>> newLifestyle = List.from(state.lifestyle);
    newLifestyle.removeWhere((item) => item['question'] == questionTitle);
    for (var label in optionLabels) {
      newLifestyle.add({'id': '', 'question': questionTitle, 'option': label});
    }
    emit(state.copyWith(lifestyle: newLifestyle));
  }

  void updateReligionCaste(
    String religionCaste,
    int? religionId,
    int? communityId,
  ) async {
    emit(
      state.copyWith(
        religionCaste: religionCaste,
        religionId: religionId,
        communityId: communityId,
      ),
    );
    if (religionId != null) {
      await EditProfileApiService.updateReligion(religionId, communityId);
    }
  }

  void updateMotherTongue(String tongue, List<int> languageIds) {
    emit(state.copyWith(motherTongue: tongue, languageIds: languageIds));
    saveBasicDetails();
  }

  void updateZodiac(String zodiac) {
    emit(state.copyWith(zodiac: zodiac));
    saveBasicDetails();
  }

  void updateLoveLanguage(String language) {
    emit(state.copyWith(loveLanguage: language));
    saveBasicDetails();
  }

  void updateCommunication(String comms) {
    emit(state.copyWith(communication: comms));
    saveBasicDetails();
  }

  void updateBio(String bio) => emit(state.copyWith(bio: bio));
  void updateIntention(String intention) =>
      emit(state.copyWith(intention: intention));

  void updatePhotos(List<ProfilePhoto?> newPhotos) =>
      emit(state.copyWith(photos: newPhotos));

  void updateVideoPath(String? path) => emit(state.copyWith(videoPath: path));

  void updateInterestedIn(String interested) {
    emit(state.copyWith(interestedIn: interested));
    _saveWhoYouAreSeeing();
  }

  void updateSexualOrientation(String orientation) {
    emit(state.copyWith(sexualOrientation: orientation));
    _saveWhoYouAreSeeing();
  }

  Future<void> _saveWhoYouAreSeeing() async {
    String mappedInterestedIn = 'EVERYONE';
    switch (state.interestedIn) {
      case 'Men':
        mappedInterestedIn = 'MEN';
        break;
      case 'Women':
        mappedInterestedIn = 'WOMEN';
        break;
      case 'Non binary':
        mappedInterestedIn = 'NON_BINARY';
        break;
      case 'Prefer not to say':
        mappedInterestedIn = 'PREFER_NOT_TO_SAY';
        break;
      case 'Everyone':
        mappedInterestedIn = 'EVERYONE';
        break;
    }

    String mappedOrientation = 'NOT_LISTED';
    switch (state.sexualOrientation) {
      case 'Straight':
        mappedOrientation = 'STRAIGHT';
        break;
      case 'Gay':
        mappedOrientation = 'GAY';
        break;
      case 'Lesbian':
        mappedOrientation = 'LESBIAN';
        break;
      case 'Aromantic':
        mappedOrientation = 'AROMATIC';
        break;
      case 'Asexual':
        mappedOrientation = 'ASEXUAL';
        break;
      case 'Bisexual':
        mappedOrientation = 'BISEXUAL';
        break;
      case 'Demisexual':
        mappedOrientation = 'DEMISEXUAL';
        break;
      case 'Pansexual':
        mappedOrientation = 'PANSEXUAL';
        break;
      case 'Queer':
        mappedOrientation = 'QUEER';
        break;
      case 'Not listed':
        mappedOrientation = 'NOT_LISTED';
        break;
    }

    await EditProfileApiService.updateInterestedIn(
      mappedInterestedIn,
      mappedOrientation,
    );
  }

  // API Update for Basic Details
  Future<String?> saveBasicDetails() async {
    int? parsedHeight;
    try {
      if (state.height.contains('cm')) {
        final parts = state.height.split('·');
        if (parts.length > 1) {
          final cmStr = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
          if (cmStr.isNotEmpty) parsedHeight = int.parse(cmStr);
        } else {
          final cmStr = state.height.replaceAll(RegExp(r'[^0-9]'), '');
          if (cmStr.isNotEmpty) parsedHeight = int.parse(cmStr);
        }
      } else {
        final heightStr = state.height.replaceAll(RegExp(r'[^0-9]'), '');
        if (heightStr.isNotEmpty) {
          parsedHeight = int.parse(heightStr);
        }
      }
    } catch (_) {}

    String mapGender(String g) {
      if (g.toLowerCase() == 'man') return 'MEN';
      if (g.toLowerCase() == 'woman') return 'WOMEN';
      return g.toUpperCase().replaceAll(' ', '_');
    }

    String formatEnum(String val) {
      if (val == 'Aromantic') return 'AROMATIC';
      return val.toUpperCase().replaceAll(' ', '_');
    }

    final data = {
      "full_name": state.fullName,
      "email": state.email,
      "birth_date": state.dob.replaceAll(' ', ''),
      if (parsedHeight != null) "height": parsedHeight,
      if (state.gender.isNotEmpty) "gender": mapGender(state.gender),
      if (state.genderIdentity.isNotEmpty)
        "gender_option": formatEnum(state.genderIdentity),
      if (state.languageIds != null) "languageIds": state.languageIds,
      if (state.zodiac.isNotEmpty) "zodiac": formatEnum(state.zodiac),
      if (state.loveLanguage.isNotEmpty)
        "loveLanguage": formatEnum(state.loveLanguage),
      if (state.communication.isNotEmpty)
        "communicationStyle": formatEnum(state.communication),
    };

    // Make sure we have a fallback for gender_option if required
    if (!data.containsKey("gender_option")) {
      data["gender_option"] = "NOT_LISTED";
    }

    return await EditProfileApiService.updateBasicDetails(data);
  }

  // Location
  void updateArea(String val) => emit(state.copyWith(area: val));
  void updateCity(String val) => emit(state.copyWith(city: val));
  void updateStateLocation(String val) =>
      emit(state.copyWith(stateLocation: val));
  void updateShowDistance(bool val) => emit(state.copyWith(showDistance: val));

  // VIP Networking Intent
  void updateNetworkingIntents(List<String> intents) =>
      emit(state.copyWith(networkingIntents: intents));
  void updateNetworkingInYourWords(String val) =>
      emit(state.copyWith(networkingInYourWords: val));

  // Education & Career
  void updateCollege(String val) {
    emit(state.copyWith(college: val));
    saveCareerDetails();
  }

  void updateHighestEducation(String val) {
    emit(state.copyWith(highestEducation: val));
    saveCareerDetails();
  }

  void updateDegreeCourse(String val) {
    emit(state.copyWith(degreeCourse: val));
    saveCareerDetails();
  }

  void updateGraduationYear(String val) {
    emit(state.copyWith(graduationYear: val));
    saveCareerDetails();
  }

  void updateProfession(String val, int? id) {
    emit(state.copyWith(profession: val, professionId: id));
    saveCareerDetails();
  }

  void updateCompany(String val) {
    emit(state.copyWith(company: val));
    saveCareerDetails();
  }

  void updateExperience(String val, int? id) {
    emit(state.copyWith(experience: val, experienceId: id));
    saveCareerDetails();
  }

  void updateEmploymentType(String val, int? id) {
    emit(state.copyWith(employmentType: val, employmentTypeId: id));
    saveCareerDetails();
  }

  void updateSalaryRange(String val, int? id) {
    emit(state.copyWith(salaryRange: val, salaryRangeId: id));
    saveCareerDetails();
  }

  void updateAmbitionLevel(String val, int? id) {
    emit(state.copyWith(ambitionLevel: val, ambitionId: id));
    saveCareerDetails();
  }

  void updateBigDreams(String val) {
    emit(state.copyWith(bigDreams: val));
    saveCareerDetails();
  }

  void updateWorkStyle(String val) =>
      emit(state.copyWith(workStyle: val)); // WorkStyle not in save as per user

  void saveCareerDetails() async {
    String mapHighestEdu(String val) {
      return val.toUpperCase().replaceAll(' ', '_').replaceAll('-', '_');
    }

    final data = <String, dynamic>{};
    if (state.highestEducation.isNotEmpty)
      data["highestEdu"] = mapHighestEdu(state.highestEducation);
    if (state.degreeCourse.isNotEmpty) data["degree"] = state.degreeCourse;
    if (state.college.isNotEmpty) data["collegeName"] = state.college;
    if (state.graduationYear.isNotEmpty)
      data["graduationYear"] = int.tryParse(state.graduationYear) ?? 0;
    if (state.professionId != null) data["professionId"] = state.professionId;
    if (state.company.isNotEmpty) data["companyName"] = state.company;
    if (state.employmentTypeId != null)
      data["employmentTypeId"] = state.employmentTypeId;
    if (state.experienceId != null) data["experienceId"] = state.experienceId;
    if (state.ambitionId != null) data["ambitionId"] = state.ambitionId;
    if (state.salaryRangeId != null)
      data["salaryRangeId"] = state.salaryRangeId;
    if (state.bigDreams.isNotEmpty) data["bigDreams"] = state.bigDreams;

    if (data.isNotEmpty) {
      await EditProfileApiService.updateCareer(data);
    }
  }

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

  Future<void> removePhoto(int index) async {
    final updatedPhotos = List<ProfilePhoto?>.from(state.photos);
    final photoToRemove = updatedPhotos[index];

    // Optimistic UI update
    updatedPhotos.removeAt(index);
    updatedPhotos.add(null);
    emit(state.copyWith(photos: updatedPhotos));

    // Call API if it exists on backend
    if (photoToRemove != null && photoToRemove.id != null) {
      await EditProfileApiService.deletePhoto(photoToRemove.id!);
    }
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
      error = await EditProfileApiService.updateSpecificPhoto(
        existingPhoto!.id!,
        photo.path,
      );
    } else {
      final response = await EditProfileApiService.addPhoto(photo.path);
      error = response['error'];
      if (error == null) {
        // try to extract new photo id from data
        final data = response['data'];
        if (data != null && data['data'] != null) {
          final photoData = data['data'];
          if (photoData is Map) {
            newPhotoId =
                photoData['_id'] ?? photoData['id'] ?? photoData['photoId'];
          } else if (photoData is List && photoData.isNotEmpty) {
            final lastPhoto = photoData.last;
            if (lastPhoto is Map) {
              newPhotoId =
                  lastPhoto['_id'] ?? lastPhoto['id'] ?? lastPhoto['photoId'];
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
      finishedPhotos[index] = finishedPhotos[index]?.copyWith(
        isUploading: false,
        uploadError: error,
      );
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
  void updateFamilyIncome(String val) =>
      emit(state.copyWith(familyIncome: val));
  void updateFamilyDynamic(String val) =>
      emit(state.copyWith(familyDynamic: val));
}
