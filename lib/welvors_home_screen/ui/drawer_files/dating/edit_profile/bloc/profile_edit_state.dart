import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

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
  
  // Family
  final String familyType;
  final String father;
  final String mother;
  final String sisters;
  final String brothers;
  final String familyHome;
  final String nativePlace;
  final String familyIncome;
  
  final String bio;
  final String intention;
  
  final List<XFile?> photos;
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
    required this.familyType,
    required this.father,
    required this.mother,
    required this.sisters,
    required this.brothers,
    required this.familyHome,
    required this.nativePlace,
    required this.familyIncome,
    required this.bio,
    required this.intention,
    required this.photos,
    this.videoPath,
  });

  factory ProfileEditState.initial() {
    return ProfileEditState(
      fullName: 'Ananya D',
      email: 'ananya.d@email.com',
      dob: '12 / 08 / 1997',
      height: "5'5\" · 165 cm",
      gender: 'Woman',
      genderIdentity: 'Cis woman',
      religionCaste: 'Hindu · Brahmin',
      motherTongue: 'Hindi',
      zodiac: 'Leo',
      loveLanguage: 'Quality time',
      communication: 'Phone calls over texts',
      interestedIn: 'Men',
      sexualOrientation: 'Straight',
      drinking: 'On special occasions',
      smoking: 'Non-smoker',
      workout: 'Often',
      diet: 'Vegetarian',
      travel: '4–5 trips/year',
      sleep: 'Night owl',
      pets: const [],
      interests: const ['✈️ Travel', '☕ Coffee', '🥾 Trekking', '📚 Books', '🧘 Yoga', '🎧 Indie music'],
      college: 'IIM Ahmedabad',
      highestEducation: 'Master',
      degreeCourse: 'MBA · Business & Strategy',
      graduationYear: '2019',
      profession: 'Product Manager',
      company: 'Flipkart',
      experience: '5–10 yrs',
      employmentType: 'Full-time',
      salaryRange: '30–45 LPA',
      ambitionLevel: 'Highly driven',
      bigDreams: 'Building products by day, planning my next trek by night. Looking for someone equally driven and equally curious.',
      familyType: 'Nuclear · Close-knit',
      father: 'Retired banker · Bank of Maharashtra',
      mother: 'Former school teacher · Homemaker',
      sisters: 'Sisters · None',
      brothers: '2\n1: Married, Working\n2: Unmarried, Studying',
      familyHome: 'Pune',
      nativePlace: 'Nashik',
      familyIncome: '₹25–40 L / year',
      bio: 'Building products by day, planning my next trek by night. Looking for someone equally driven and equally curious.',
      intention: 'Open to marriage, when it’s right',
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
    String? familyType,
    String? father,
    String? mother,
    String? sisters,
    String? brothers,
    String? familyHome,
    String? nativePlace,
    String? familyIncome,
    String? bio,
    String? intention,
    List<XFile?>? photos,
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
      familyType: familyType ?? this.familyType,
      father: father ?? this.father,
      mother: mother ?? this.mother,
      sisters: sisters ?? this.sisters,
      brothers: brothers ?? this.brothers,
      familyHome: familyHome ?? this.familyHome,
      nativePlace: nativePlace ?? this.nativePlace,
      familyIncome: familyIncome ?? this.familyIncome,
      bio: bio ?? this.bio,
      intention: intention ?? this.intention,
      photos: photos ?? this.photos,
      videoPath: videoPath ?? this.videoPath,
    );
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
        familyType,
        father,
        mother,
        sisters,
        brothers,
        familyHome,
        nativePlace,
        familyIncome,
        bio,
        intention,
        photos,
        videoPath,
      ];
}
