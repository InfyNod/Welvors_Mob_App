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
        bio,
        intention,
        photos,
        videoPath,
      ];
}
