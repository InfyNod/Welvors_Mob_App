part of 'home_bloc.dart';

class ProfileModel extends Equatable {
  final String imageUrl;
  final String name;
  final int age;
  final String location;
  final String job;
  final String intent;
  final String matchPercentage;
  final String trustPercentage;
  final String replyTime;
  final String about;
  final String lookingFor;
  final String height;
  final String religion;
  final String motherTongue;

  const ProfileModel({
    required this.imageUrl,
    required this.name,
    required this.age,
    required this.location,
    required this.job,
    required this.intent,
    required this.matchPercentage,
    required this.trustPercentage,
    required this.replyTime,
    required this.about,
    required this.lookingFor,
    required this.height,
    required this.religion,
    required this.motherTongue,
  });

  @override
  List<Object?> get props => [
    imageUrl,
    name,
    age,
    location,
    job,
    intent,
    matchPercentage,
    trustPercentage,
    replyTime,
    about,
    lookingFor,
    height,
    religion,
    motherTongue,
  ];
}

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ProfileModel> profiles;

  const HomeLoaded({required this.profiles});

  @override
  List<Object?> get props => [profiles];
}

class HomeEmpty extends HomeState {}
