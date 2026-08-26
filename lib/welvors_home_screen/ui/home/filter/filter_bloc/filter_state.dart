import 'package:equatable/equatable.dart';

class FilterState extends Equatable {
  final double minAge;
  final double maxAge;
  final double distance;
  final String showMe;
  final String showMePreference;
  final List<String> lookingFor;
  final double? minHeight;
  final double? maxHeight;
  final List<String> education;
  final List<String> languages;
  final List<String> lifestyle;
  final List<String> religion;
  final List<String> profession;
  final String zodiac;
  final double minTrustScore;
  final double maxTrustScore;
  final double minIncome;
  final double maxIncome;
  final List<String> networkingIntent;
  final List<String> ambition;

  const FilterState({
    this.minAge = 19.0,
    this.maxAge = 32.0,
    this.distance = 26.0,
    this.showMe = 'Women',
    this.showMePreference = '',
    this.lookingFor = const [],
    this.minHeight,
    this.maxHeight,
    this.education = const [],
    this.languages = const [],
    this.lifestyle = const [],
    this.religion = const [],
    this.profession = const [],
    this.zodiac = 'Any',
    this.minTrustScore = 0.0,
    this.maxTrustScore = 20.0,
    this.minIncome = 5.0,
    this.maxIncome = 200.0,
    this.networkingIntent = const [],
    this.ambition = const [],
  });

  FilterState copyWith({
    double? minAge,
    double? maxAge,
    double? distance,
    String? showMe,
    String? showMePreference,
    List<String>? lookingFor,
    double? minHeight,
    double? maxHeight,
    List<String>? education,
    List<String>? languages,
    List<String>? lifestyle,
    List<String>? religion,
    List<String>? profession,
    String? zodiac,
    double? minTrustScore,
    double? maxTrustScore,
    double? minIncome,
    double? maxIncome,
    List<String>? networkingIntent,
    List<String>? ambition,
  }) {
    return FilterState(
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      distance: distance ?? this.distance,
      showMe: showMe ?? this.showMe,
      showMePreference: showMePreference ?? this.showMePreference,
      lookingFor: lookingFor ?? this.lookingFor,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      education: education ?? this.education,
      languages: languages ?? this.languages,
      lifestyle: lifestyle ?? this.lifestyle,
      religion: religion ?? this.religion,
      profession: profession ?? this.profession,
      zodiac: zodiac ?? this.zodiac,
      minTrustScore: minTrustScore ?? this.minTrustScore,
      maxTrustScore: maxTrustScore ?? this.maxTrustScore,
      minIncome: minIncome ?? this.minIncome,
      maxIncome: maxIncome ?? this.maxIncome,
      networkingIntent: networkingIntent ?? this.networkingIntent,
      ambition: ambition ?? this.ambition,
    );
  }

  @override
  List<Object?> get props => [minAge, maxAge, distance, showMe, showMePreference, lookingFor, minHeight, maxHeight, education, languages, lifestyle, religion, profession, zodiac, minTrustScore, maxTrustScore, minIncome, maxIncome, networkingIntent, ambition];

  bool get hasActiveFilters => this != const FilterState();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "minAge": minAge.toInt(),
      "maxAge": maxAge.toInt(),
    };

    if (minHeight != null) data["minHeight"] = minHeight!.toInt();
    if (maxHeight != null) data["maxHeight"] = maxHeight!.toInt();
    
    // For now we pass the strings as values since we don't have ID mappings.
    // The backend might need exact IDs but this gets the structure right.
    if (education.isNotEmpty) {
      data["education"] = [
        {"key": "education", "values": education}
      ];
    }
    
    if (languages.isNotEmpty) {
      data["languages"] = [
        {"key": "languages", "values": languages}
      ];
    }
    
    if (lifestyle.isNotEmpty) {
      // Typically lifestyle is broken into sleep, diet, pets, etc. based on key.
      // We'll pass it broadly or skip it until backend specifies.
    }
    
    if (religion.isNotEmpty) {
      // data["religionIds"] = religion; // needs mapping
    }
    
    if (profession.isNotEmpty) {
      // data["professionIds"] = profession; // needs mapping
    }
    
    if (zodiac != 'Any') {
      data["zodiac"] = [zodiac.toUpperCase()];
    }
    
    // Add income if not max bounds
    if (minIncome > 5 || maxIncome < 200) {
      data["familyIncomeMin"] = (minIncome * 100000).toInt();
      data["familyIncomeMax"] = (maxIncome * 100000).toInt();
    }
    
    return data;
  }
}
