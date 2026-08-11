part of 'home_bloc.dart';

class ProfileModel extends Equatable {
  final String id;
  final List<String> images;
  final String? videoUrl;
  final String name;
  final int age;
  final String location;
  final String job;
  final String intent;
  final String matchPercentage;
  final String trustPercentage;
  final String replyTime;
  
  // Details (nullable because they are fetched later)
  final bool detailsLoaded;
  final String about;
  final String lookingFor;
  final String lookingForSubtitle;
  final String height;
  final String religion;
  final String community;
  final String motherTongue;
  final String dob;
  final String zodiac;
  final String loveLanguage;
  final String communication;
  final List<Map<String, String>> prompts;
  final Map<String, dynamic>? career;
  final List<dynamic>? lifestyle;
  final List<dynamic>? interests;
  final Map<String, dynamic>? family;
  final List<dynamic>? networkingIntent;

  const ProfileModel({
    required this.id,
    required this.images,
    this.videoUrl,
    required this.name,
    required this.age,
    required this.location,
    required this.job,
    required this.intent,
    required this.matchPercentage,
    required this.trustPercentage,
    required this.replyTime,
    this.detailsLoaded = false,
    this.about = '',
    this.lookingFor = '',
    this.lookingForSubtitle = '',
    this.height = '',
    this.religion = '',
    this.community = '',
    this.motherTongue = '',
    this.dob = '',
    this.zodiac = '',
    this.loveLanguage = '',
    this.communication = '',
    this.prompts = const [],
    this.career,
    this.lifestyle,
    this.interests,
    this.family,
    this.networkingIntent,
  });

  factory ProfileModel.fromFeedJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    String? parsedVideo;
    if (json['photos'] != null) {
      for (var photo in json['photos']) {
        final url = photo['media_url'] ?? photo['url'];
        final type = photo['media_type'] ?? photo['mediaType'];
        if (type == 'VIDEO' && parsedVideo == null) {
          parsedVideo = url;
        } else if (url != null) {
          parsedImages.add(url.toString());
        }
      }
    }

    String city = '';
    if (json['profile'] != null) {
      city = json['profile']['city'] ?? '';
    }

    String profession = '';
    if (json['eduWork'] != null && json['eduWork']['profession'] != null) {
      profession = json['eduWork']['profession']['name'] ?? '';
    }

    return ProfileModel(
      id: json['id'] ?? '',
      images: parsedImages,
      videoUrl: parsedVideo,
      name: json['full_name'] ?? json['fullName'] ?? 'Unknown',
      age: json['age'] ?? 0,
      location: city,
      job: profession,
      intent: 'New friends', // Default or parse if available
      matchPercentage: '${json['matchScore'] ?? 0}% Match',
      trustPercentage: '${json['trust'] ?? 0}% Trust',
      replyTime: json['replyTime']?.toString() ?? '',
      height: json['height'] != null ? '${json['height']} cm' : '',
      dob: json['birth_date'] ?? '',
    );
  }

  ProfileModel copyWithDetails(Map<String, dynamic> details) {
    // Parse photos again in case details has higher quality or more images
    List<String> parsedImages = List.from(this.images);
    String? parsedVideo = this.videoUrl;
    if (details['photos'] != null) {
      parsedImages = [];
      for (var photo in details['photos']) {
        final url = photo['url'] ?? photo['media_url'];
        final type = photo['mediaType'] ?? photo['media_type'];
        if (type == 'VIDEO' && parsedVideo == null) {
          parsedVideo = url;
        } else if (url != null) {
          parsedImages.add(url.toString());
        }
      }
    }

    String loc = this.location;
    if (details['city'] != null) {
      loc = details['city'];
      if (details['state'] != null) {
        loc += ', ${details['state']}';
      }
    }

    List<Map<String, String>> parsedPrompts = [];
    if (details['prompts'] != null) {
      for (var p in details['prompts']) {
        String question = p['question']?.toString() ?? '';
        if (question.isEmpty && p['prompt'] != null) {
          if (p['prompt'] is Map) {
            question = p['prompt']['question']?.toString() ?? '';
          } else {
            question = p['prompt'].toString();
          }
        }
        parsedPrompts.add({
          'prompt': question,
          'answer': p['answer']?.toString() ?? '',
        });
      }
    }

    return ProfileModel(
      id: this.id,
      images: parsedImages.isNotEmpty ? parsedImages : this.images,
      videoUrl: parsedVideo,
      name: details['fullName'] ?? this.name,
      age: details['age'] ?? this.age,
      location: loc,
      job: details['career']?['profession'] ?? this.job,
      intent: details['lookingFor'] ?? this.intent,
      matchPercentage: details['matchScore'] != null ? '${details['matchScore']}% Match' : this.matchPercentage,
      trustPercentage: details['trust'] != null ? '${details['trust']}% Trust' : this.trustPercentage,
      replyTime: details['replyTime']?.toString() ?? this.replyTime,
      detailsLoaded: true,
      about: details['bio'] ?? '',
      lookingFor: (details['lookingFor'] != null && details['lookingFor'].toString().isNotEmpty) ? details['lookingFor'] : this.intent,
      lookingForSubtitle: details['lookingFor_subtitle'] ?? '',
      height: details['height'] != null ? '${details['height']} cm' : this.height,
      religion: details['religion'] ?? '',
      community: details['community'] ?? '',
      motherTongue: details['motherTongue'] ?? '',
      dob: this.dob,
      zodiac: details['zodiac'] ?? '',
      loveLanguage: details['loveLanguage'] ?? '',
      communication: details['communicationStyle'] ?? '',
      prompts: parsedPrompts,
      career: details['career'],
      lifestyle: details['lifestyle'],
      interests: details['interests'],
      family: details['family'],
      networkingIntent: details['networkingAnswers'] ?? details['networkingIntent'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    images,
    videoUrl,
    name,
    age,
    location,
    job,
    intent,
    matchPercentage,
    trustPercentage,
    replyTime,
    detailsLoaded,
    about,
    lookingFor,
    lookingForSubtitle,
    height,
    religion,
    community,
    motherTongue,
    dob,
    zodiac,
    loveLanguage,
    communication,
    prompts,
    career,
    lifestyle,
    interests,
    family,
    networkingIntent,
  ];
}

abstract class HomeState extends Equatable {
  final int remainingSwipes;
  final String? cursor;
  const HomeState({this.remainingSwipes = 25, this.cursor});

  @override
  List<Object?> get props => [remainingSwipes, cursor];
}

class HomeInitial extends HomeState {
  const HomeInitial() : super(remainingSwipes: 25);
}

class HomeLoading extends HomeState {
  const HomeLoading({super.remainingSwipes, super.cursor});
}

class HomeLoaded extends HomeState {
  final List<ProfileModel> profiles;

  const HomeLoaded({required this.profiles, super.remainingSwipes, super.cursor});

  @override
  List<Object?> get props => [profiles, remainingSwipes, cursor];
}

class HomeEmpty extends HomeState {
  const HomeEmpty({super.remainingSwipes, super.cursor});
}
