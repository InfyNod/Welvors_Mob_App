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
  final int? religionId;
  final int? communityId;
  final List<int>? languageIds;
  final String motherTongue;
  final String zodiac;
  final String loveLanguage;
  final String communication;
  final String interestedIn;
  final String sexualOrientation;
  
  final List<Map<String, dynamic>> lifestyle;
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
  final int? professionId;
  final String company;
  final String experience;
  final int? experienceId;
  final String employmentType;
  final int? employmentTypeId;
  final String salaryRange;
  final int? salaryRangeId;
  final String ambitionLevel;
  final int? ambitionId;
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
  final String? videoId;
  
  final int profileScore;

  const ProfileEditState({
    required this.fullName,
    required this.email,
    required this.dob,
    required this.height,
    required this.gender,
    required this.genderIdentity,
    required this.religionCaste,
    this.religionId,
    this.communityId,
    this.languageIds,
    required this.motherTongue,
    required this.zodiac,
    required this.loveLanguage,
    required this.communication,
    required this.interestedIn,
    required this.sexualOrientation,
    required this.lifestyle,
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
    this.professionId,
    required this.company,
    required this.experience,
    this.experienceId,
    required this.employmentType,
    this.employmentTypeId,
    required this.salaryRange,
    this.salaryRangeId,
    required this.ambitionLevel,
    this.ambitionId,
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
    this.videoId,
    required this.profileScore,
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
      religionId: null,
      communityId: null,
      languageIds: null,
      motherTongue: '',
      zodiac: '',
      loveLanguage: '',
      communication: '',
      interestedIn: '',
      sexualOrientation: '',
      lifestyle: const [],
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
      photos: const [null, null, null, null, null, null],
      videoPath: null,
      videoId: null,
      profileScore: 0,
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
    int? religionId,
    int? communityId,
    List<int>? languageIds,
    String? motherTongue,
    String? zodiac,
    String? loveLanguage,
    String? communication,
    String? interestedIn,
    String? sexualOrientation,
    List<Map<String, dynamic>>? lifestyle,
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
    int? professionId,
    String? company,
    String? experience,
    int? experienceId,
    String? employmentType,
    int? employmentTypeId,
    String? salaryRange,
    int? salaryRangeId,
    String? ambitionLevel,
    int? ambitionId,
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
    String? videoId,
    int? profileScore,
  }) {
    return ProfileEditState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      genderIdentity: genderIdentity ?? this.genderIdentity,
      religionCaste: religionCaste ?? this.religionCaste,
      religionId: religionId ?? this.religionId,
      communityId: communityId ?? this.communityId,
      languageIds: languageIds ?? this.languageIds,
      motherTongue: motherTongue ?? this.motherTongue,
      zodiac: zodiac ?? this.zodiac,
      loveLanguage: loveLanguage ?? this.loveLanguage,
      communication: communication ?? this.communication,
      interestedIn: interestedIn ?? this.interestedIn,
      sexualOrientation: sexualOrientation ?? this.sexualOrientation,
      lifestyle: lifestyle ?? this.lifestyle,
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
      professionId: professionId ?? this.professionId,
      company: company ?? this.company,
      experience: experience ?? this.experience,
      experienceId: experienceId ?? this.experienceId,
      employmentType: employmentType ?? this.employmentType,
      employmentTypeId: employmentTypeId ?? this.employmentTypeId,
      salaryRange: salaryRange ?? this.salaryRange,
      salaryRangeId: salaryRangeId ?? this.salaryRangeId,
      ambitionLevel: ambitionLevel ?? this.ambitionLevel,
      ambitionId: ambitionId ?? this.ambitionId,
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
      videoId: videoId ?? this.videoId,
      profileScore: profileScore ?? this.profileScore,
    );
  }

  double get completionPercentage {
    return profileScore / 100.0;
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
        religionId,
        communityId,
        languageIds,
        motherTongue,
        zodiac,
        loveLanguage,
        communication,
        interestedIn,
        sexualOrientation,
        lifestyle,
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
        professionId,
        company,
        experience,
        experienceId,
        employmentType,
        employmentTypeId,
        salaryRange,
        salaryRangeId,
        ambitionLevel,
        ambitionId,
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
        videoId,
        profileScore,
      ];
}
