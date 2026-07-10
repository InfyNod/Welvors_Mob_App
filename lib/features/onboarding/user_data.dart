import 'dart:io';

class UserData {
  static final UserData _instance = UserData._internal();
  factory UserData() => _instance;
  UserData._internal();

  String name = 'Velvors User';
  int age = 22;
  String phone = '+91 98765 43210';
  String email = 'user@example.com';
  String welvorsId = 'WLV-1XN6-8256';
  String gender = 'Man';
  String sexualOrientation = 'Not specified';
  String interestedIn = 'Everyone';
  String intentions = 'A long-term relationship';
  List<String> lifestyle = [];
  String education = 'Other';
  String college = '';
  String degree = '';
  String gradYear = '';
  
  String career = 'Other';
  String company = '';
  String profession = 'Other';
  String experience = 'Other';
  String employmentType = 'Other';
  String salaryRange = 'Other';
  String ambitionLevel = 'Other';
  String dreams = '';

  List<Map<String, String>> interests = [];
  int photoCount = 0;
  List<File?> photos = [];
  String location = 'Fetching...';
  String locationAuto = 'Auto';
}

final UserData userData = UserData();
