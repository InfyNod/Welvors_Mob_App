import 'package:equatable/equatable.dart';
import '../models/profile_photo.dart';

class ProfileEditState extends Equatable {
  final String fullName;
  final String email;
  final String dob;
  final String height;
  final String gender;
  final String genderIdentity;
  final String religionCaste;
  final String motherTongue;
  final String zodiac;
  final String loveLanguage;
  final String communication;
  final String interestedIn;
  final String sexualOrientation;
  
  final String drinking;
  final String smoking;
  final String workout;
  final String diet;
  final String travel;
  final String sleep;
  final List<String> pets;
  final List<String> interests;
  final List<Map<String, String>> prompts;
  
  // Location
  final String area;
  final String city;
  final String stateLocation;
  final bool showDistance;
  
  // VIP Networking Intent
  final List<String> networkingIntents;
  final String networkingInYourWords;
  
  // Education & Career
  final String college;
  final String highestEducation;
  final String degreeCourse;
  final String graduationYear;
  final String profession;
  final String company;
  final String experience;
  final String employmentType;
  final String salaryRange;
  final String ambitionLevel;
  final String bigDreams;
  final String workStyle;
  
  // Family
  final String familyType;
  final String father;
  final String mother;
  final String sisters;
  final String brothers;
  final String familyHome;
  final String nativePlace;
  final String familyIncome;
  final String familyDynamic;
  
  final String bio;
  final String intention;
  
  final List<ProfilePhoto?> photos;
  final String? videoPath;

  const ProfileEditState({
    required this.fullName,
    required this.email,
    required this.dob,
    required this.height,
    required this.gender,
    required this.genderIdentity,
    required this.religionCaste,
    required this.motherTongue,
    required this.zodiac,
    required this.loveLanguage,
    required this.communication,
    required this.interestedIn,
    required this.sexualOrientation,
    required this.drinking,
    required this.smoking,
    required this.workout,
    required this.diet,
    required this.travel,
    required this.sleep,
    required this.pets,
    required this.interests,
    required this.prompts,
    required this.area,
    required this.city,
    required this.stateLocation,
    required this.showDistance,
    required this.networkingIntents,
    required this.networkingInYourWords,
    required this.college,
    required this.highestEducation,
    required this.degreeCourse,
    required this.graduationYear,
    required this.profession,
    required this.company,
    required this.experience,
    required this.employmentType,
    required this.salaryRange,
    required this.ambitionLevel,
    required this.bigDreams,
    required this.workStyle,
    required this.familyType,
    required this.father,
    required this.mother,
    required this.sisters,
    required this.brothers,
    required this.familyHome,
    required this.nativePlace,
    required this.familyIncome,
    required this.familyDynamic,
    required this.bio,
    required this.intention,
    required this.photos,
    this.videoPath,
  });

  factory ProfileEditState.initial() {
    return ProfileEditState(
      fullName: '',
      email: '',
      dob: '',
      height: '',
      gender: '',
      genderIdentity: '',
      religionCaste: '',
      motherTongue: '',
      zodiac: '',
      loveLanguage: '',
      communication: '',
      interestedIn: '',
      sexualOrientation: '',
      drinking: '',
      smoking: '',
      workout: '',
      diet: '',
      travel: '',
      sleep: '',
      pets: const [],
      interests: const [],
      prompts: const [],
      area: '',
      city: '',
      stateLocation: '',
      showDistance: true,
      networkingIntents: const [],
      networkingInYourWords: '',
      college: '',
      highestEducation: '',
      degreeCourse: '',
      graduationYear: '',
      profession: '',
      company: '',
      experience: '',
      employmentType: '',
      salaryRange: '',
      ambitionLevel: '',
      bigDreams: '',
      workStyle: '',
      familyType: '',
      father: '',
      mother: '',
      sisters: '',
      brothers: '',
      familyHome: '',
      nativePlace: '',
      familyIncome: '',
      familyDynamic: '',
      bio: '',
      intention: '',
      photos: List.filled(6, null),
      videoPath: null,
    );
  }

  ProfileEditState copyWith({
    String? fullName,
    String? email,
    String? dob,
    String? height,
    String? gender,
    String? genderIdentity,
    String? religionCaste,
    String? motherTongue,
    String? zodiac,
    String? loveLanguage,
    String? communication,
    String? interestedIn,
    String? sexualOrientation,
    String? drinking,
    String? smoking,
    String? workout,
    String? diet,
    String? travel,
    String? sleep,
    List<String>? pets,
    List<String>? interests,
    List<Map<String, String>>? prompts,
    String? area,
    String? city,
    String? stateLocation,
    bool? showDistance,
    List<String>? networkingIntents,
    String? networkingInYourWords,
    String? college,
    String? highestEducation,
    String? degreeCourse,
    String? graduationYear,
    String? profession,
    String? company,
    String? experience,
    String? employmentType,
    String? salaryRange,
    String? ambitionLevel,
    String? bigDreams,
    String? workStyle,
    String? familyType,
    String? father,
    String? mother,
    String? sisters,
    String? brothers,
    String? familyHome,
    String? nativePlace,
    String? familyIncome,
    String? familyDynamic,
    String? bio,
    String? intention,
    List<ProfilePhoto?>? photos,
    String? videoPath,
  }) {
    return ProfileEditState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      genderIdentity: genderIdentity ?? this.genderIdentity,
      religionCaste: religionCaste ?? this.religionCaste,
      motherTongue: motherTongue ?? this.motherTongue,
      zodiac: zodiac ?? this.zodiac,
      loveLanguage: loveLanguage ?? this.loveLanguage,
      communication: communication ?? this.communication,
      interestedIn: interestedIn ?? this.interestedIn,
      sexualOrientation: sexualOrientation ?? this.sexualOrientation,
      drinking: drinking ?? this.drinking,
      smoking: smoking ?? this.smoking,
      workout: workout ?? this.workout,
      diet: diet ?? this.diet,
      travel: travel ?? this.travel,
      sleep: sleep ?? this.sleep,
      pets: pets ?? this.pets,
      interests: interests ?? this.interests,
      prompts: prompts ?? this.prompts,
      area: area ?? this.area,
      city: city ?? this.city,
      stateLocation: stateLocation ?? this.stateLocation,
      showDistance: showDistance ?? this.showDistance,
      networkingIntents: networkingIntents ?? this.networkingIntents,
      networkingInYourWords: networkingInYourWords ?? this.networkingInYourWords,
      college: college ?? this.college,
      highestEducation: highestEducation ?? this.highestEducation,
      degreeCourse: degreeCourse ?? this.degreeCourse,
      graduationYear: graduationYear ?? this.graduationYear,
      profession: profession ?? this.profession,
      company: company ?? this.company,
      experience: experience ?? this.experience,
      employmentType: employmentType ?? this.employmentType,
      salaryRange: salaryRange ?? this.salaryRange,
      ambitionLevel: ambitionLevel ?? this.ambitionLevel,
      bigDreams: bigDreams ?? this.bigDreams,
      workStyle: workStyle ?? this.workStyle,
      familyType: familyType ?? this.familyType,
      father: father ?? this.father,
      mother: mother ?? this.mother,
      sisters: sisters ?? this.sisters,
      brothers: brothers ?? this.brothers,
      familyHome: familyHome ?? this.familyHome,
      nativePlace: nativePlace ?? this.nativePlace,
      familyIncome: familyIncome ?? this.familyIncome,
      familyDynamic: familyDynamic ?? this.familyDynamic,
      bio: bio ?? this.bio,
      intention: intention ?? this.intention,
      photos: photos ?? this.photos,
      videoPath: videoPath ?? this.videoPath,
    );
  }

  double get completionPercentage {
    int total = 0;
    int filled = 0;
    
    for (var prop in props) {
      if (prop is bool) continue; // Ignore boolean toggles like showDistance
      
      total++;
      if (prop is String) {
        if (prop.trim().isNotEmpty) filled++;
      } else if (prop is List) {
        if (prop.isNotEmpty) {
          if (prop.every((e) => e == null || (e is ProfilePhoto && e.isEmpty))) {
            // All empty (like empty photos list), don't count
          } else {
            filled++;
          }
        }
      } else if (prop != null) {
        filled++; // For other non-null objects
      }
    }
    
    return total == 0 ? 0.0 : filled / total;
  }

  @override
  List<Object?> get props => [
        fullName,
        email,
        dob,
        height,
        gender,
        genderIdentity,
        religionCaste,
        motherTongue,
        zodiac,
        loveLanguage,
        communication,
        interestedIn,
        sexualOrientation,
        drinking,
        smoking,
        workout,
        diet,
        travel,
        sleep,
        pets,
        interests,
        prompts,
        area,
        city,
        stateLocation,
        showDistance,
        networkingIntents,
        networkingInYourWords,
        college,
        highestEducation,
        degreeCourse,
        graduationYear,
        profession,
        company,
        experience,
        employmentType,
        salaryRange,
        ambitionLevel,
        bigDreams,
        workStyle,
        familyType,
        father,
        mother,
        sisters,
        brothers,
        familyHome,
        nativePlace,
        familyIncome,
        familyDynamic,
        bio,
        intention,
        photos,
        videoPath,
      ];
}
