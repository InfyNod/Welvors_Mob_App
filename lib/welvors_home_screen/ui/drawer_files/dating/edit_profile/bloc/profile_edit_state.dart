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
        bio,
        intention,
        photos,
        videoPath,
      ];
}
