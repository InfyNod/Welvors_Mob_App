import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:velvors/welvors_home_screen/ui/home/home_screen.dart';
import 'package:velvors/welvors_home_screen/ui/top_and_bottom_nav_screen.dart';
import 'package:velvors/welvors_home_screen/home_bloc/home_bloc.dart';
import 'package:velvors/welvors_home_screen/services/token_helper.dart';

// Mock HomeBloc to feed the current user's data to HomeScreen without changing its code!
class PreviewHomeBloc extends Bloc<HomeEvent, HomeState> implements HomeBloc {
  PreviewHomeBloc(ProfileModel profile)
    : super(HomeLoaded(profiles: [profile])) {
    on<HomeEvent>((event, emit) {
      emit(HomeLoaded(profiles: [profile]));
    });
  }

  @override
  bool get hasSwipedProfiles => false;

  @override
  int get swipedCount => 0;
}

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  ProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    _fetchProfileDetails();
  }

  Future<void> _fetchProfileDetails() async {
    try {
      final token = (await TokenHelper.getToken() ?? "");

      // 1. First get the userId from onboarding-details
      final onboardingUrl = Uri.parse(
        'https://api.welvors.com/api/user/onboarding-details',
      );
      final onboardingRes = await http.get(
        onboardingUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (onboardingRes.statusCode != 200) {
        if (mounted)
          setState(
            () => _errorMessage =
                'Error ${onboardingRes.statusCode} getting user ID',
          );
        return;
      }

      final obDecoded = json.decode(onboardingRes.body);
      if (obDecoded['success'] != true) {
        if (mounted) setState(() => _errorMessage = 'Failed to load user ID');
        return;
      }

      dynamic rawObData = obDecoded['data'];
      if (rawObData is Map && rawObData['data'] != null) {
        rawObData = rawObData['data'];
      }
      final String userId = rawObData['userId']?.toString() ?? '';

      if (userId.isEmpty) {
        if (mounted) setState(() => _errorMessage = 'User ID not found');
        return;
      }

      // 2. Now fetch the full profile using the same API as ProfileDetailScreen
      final url = Uri.parse('https://api.welvors.com/api/user/details/$userId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          final data = decoded['data'];
          final profileData = data['profile'] ?? {};

          String extractString(dynamic val) {
            if (val == null) return '';
            if (val is String) return val;
            if (val is Map) {
              return (val['QUESTION'] ??
                      val['question'] ??
                      val['prompt'] ??
                      val['PROMPT'] ??
                      val['bio'] ??
                      val['name'] ??
                      val['label'] ??
                      val['title'] ??
                      val['value'] ??
                      val.toString())
                  .toString();
            }
            return val.toString();
          }

          Map<String, dynamic>? cleanMap(dynamic input) {
            if (input == null || input is! Map) return null;
            return input.map(
              (key, value) => MapEntry(key.toString(), extractString(value)),
            );
          }

          List<dynamic>? cleanList(dynamic input) {
            if (input == null || input is! List) return null;
            return input.map((item) {
              if (item is Map) {
                return item.map(
                  (k, v) => MapEntry(k.toString(), extractString(v)),
                );
              }
              return extractString(item);
            }).toList();
          }

          final eduWork = data['eduWork'] as Map<String, dynamic>? ?? {};
          var rawCareer = data['career'] ?? profileData['career'];
          if (rawCareer is Map &&
              rawCareer['highestEducation'] == null &&
              rawCareer['highestEdu'] != null) {
            // Normalize highestEdu to highestEducation
            rawCareer = Map<String, dynamic>.from(rawCareer);
            rawCareer['highestEducation'] = rawCareer['highestEdu'];
          }
          final mappedCareer = cleanMap(
            (data['career'] != null || profileData['career'] != null)
                ? rawCareer
                : (eduWork.isNotEmpty
                      ? {
                          'highestEducation': extractString(
                            eduWork['highestEdu'],
                          ),
                          'degree': extractString(eduWork['degree']),
                          'collegeName': extractString(eduWork['collegeName']),
                          'profession': extractString(eduWork['profession']),
                          'employmentType': extractString(
                            eduWork['employmentType'],
                          ),
                          'experience': extractString(eduWork['experience']),
                          'ambition': extractString(eduWork['ambition']),
                          'salaryRange': extractString(eduWork['salaryRange']),
                          'companyName': extractString(eduWork['companyName']),
                          'bigDreams': extractString(eduWork['bigDreams']),
                        }
                      : null),
          );

          final familyProfile =
              data['familyProfile'] as Map<String, dynamic>? ?? {};
          final mappedFamily = cleanMap(
            (data['family'] != null || profileData['family'] != null)
                ? (data['family'] ?? profileData['family'])
                : (familyProfile.isNotEmpty
                      ? {
                          'familyStatus': extractString(
                            familyProfile['familyStatus'],
                          ),
                          'familyType': extractString(
                            familyProfile['familyType'],
                          ),
                          'fatherOccupation': extractString(
                            familyProfile['fatherOccupation'],
                          ),
                          'motherOccupation': extractString(
                            familyProfile['motherOccupation'],
                          ),
                          'fatherOrganisation': extractString(
                            familyProfile['fatherOrganisation'],
                          ),
                          'motherOrganisation': extractString(
                            familyProfile['motherOrganisation'],
                          ),
                          'familyHome': extractString(
                            familyProfile['familyHome'],
                          ),
                          'nativePlace': extractString(
                            familyProfile['nativePlace'],
                          ),
                          'familyIncome': extractString(
                            familyProfile['familyIncome'],
                          ),
                        }
                      : null),
          );

          final answers = data['answer'] as List<dynamic>? ?? [];
          List<dynamic>? extractAnswers(String screen) {
            final filtered = answers
                .where((a) {
                  final q = a['question'];
                  return q is Map && q['screen'] == screen;
                })
                .map((a) {
                  final q = a['question'] as Map;
                  final o = a['option'] as Map?;
                  final answerStr = extractString(o ?? a['answer']);
                  return {
                    "id": q['id'],
                    "name": answerStr, // For interests which checks 'name'
                    "question":
                        q['title'], // For lifestyle which checks 'question'
                    "answer": answerStr, // For lifestyle which checks 'answer'
                  };
                })
                .toList();
            return filtered.isNotEmpty ? filtered : null;
          }

          final mappedLifestyle =
              cleanList(data['lifestyle'] ?? profileData['lifestyle']) ??
              extractAnswers('LIFESTYLE');
          final mappedInterests =
              cleanList(data['interests'] ?? profileData['interests']) ??
              extractAnswers('THINGS_U_LOVE');
          final mappedNetworking =
              cleanList(
                data['networkingIntent'] ??
                    profileData['networkingIntent'] ??
                    data['networkingAnswers'] ??
                    profileData['networkingAnswers'],
              ) ??
              extractAnswers('NETWORKING_INTENT');

          final List<dynamic> rawPrompts =
              (data['prompts'] as List?) ??
              (data['userPrompts'] as List?) ??
              [];
          final mappedPrompts = rawPrompts
              .map((p) {
                if (p is Map) {
                  final pt = p['prompt'] ?? p['question'];
                  return {
                    "question": extractString(pt),
                    "answer": extractString(p['answer']),
                  };
                }
                return {"question": "", "answer": ""};
              })
              .where((m) => m["question"].toString().isNotEmpty)
              .toList();

          final photos = data['photos'] as List<dynamic>? ?? [];
          final images = photos
              .where((p) => p['media_type'] == 'IMAGE')
              .map((p) => p['media_url']?.toString() ?? '')
              .toList();
          final videos = photos
              .where((p) => p['media_type'] == 'VIDEO')
              .map((p) => p['media_url']?.toString() ?? '')
              .toList();

          List<String> locParts = [];
          if (profileData['area'] != null && profileData['area'].toString().isNotEmpty) locParts.add(extractString(profileData['area']));
          if (profileData['city'] != null && profileData['city'].toString().isNotEmpty) locParts.add(extractString(profileData['city']));
          if (profileData['state'] != null && profileData['state'].toString().isNotEmpty) locParts.add(extractString(profileData['state']));
          String combinedLocation = locParts.join(', ');

          // Create base profile. We use fallback values in case the API doesn't provide them.
          final baseProfile = ProfileModel(
            id: userId,
            images: images.isNotEmpty
                ? images
                : [
                    'https://images.unsplash.com/photo-1517365830460-955ce3ccd263?auto=format&fit=crop&w=800&q=80',
                  ],
            videoUrl: videos.isNotEmpty ? videos.first : null,
            name: extractString(data['full_name']).isNotEmpty
                ? extractString(data['full_name'])
                : 'User',
            age: data['age'] is int
                ? data['age']
                : (int.tryParse(data['age']?.toString() ?? '') ?? 25),
            location: combinedLocation,
            job: '',
            intent: extractString(
              profileData['lookingFor'] ?? data['lookingFor'],
            ),
            matchPercentage: '100% Match',
            trustPercentage: '100% Trust',
            replyTime: '~1m Replies',
          );

          // Build a completely flat and perfectly typed map for copyWithDetails
          final Map<String, dynamic> cleanDetails = {
            'fullName': extractString(data['full_name']),
            'age': data['age'],
            'area': extractString(profileData['area']),
            'city': extractString(profileData['city']),
            'state': extractString(profileData['state']),
            'career': mappedCareer,
            'lifestyle': mappedLifestyle,
            'interests': mappedInterests,
            'family': mappedFamily,
            'networkingIntent': mappedNetworking,
            'lookingFor': extractString(
              data['intention']?['option'] ??
                  profileData['lookingFor'] ??
                  data['lookingFor'],
            ),
            'lookingFor_subtitle': extractString(
              data['intention']?['optDescription'],
            ),
            'bio': extractString(profileData['bio'] ?? data['bio']),
            'height': data['height'] ?? profileData['height'],
            'dob': data['birth_date'] ?? profileData['dob'],
            'religion': extractString(
              profileData['religion'] is Map
                  ? profileData['religion']['name']
                  : profileData['religion'],
            ),
            'community': extractString(
              profileData['community'] is Map
                  ? profileData['community']['name']
                  : profileData['community'],
            ),
            'motherTongue': extractString(
              profileData['motherTongue'] ??
                  (profileData['languages'] != null &&
                          (profileData['languages'] as List).isNotEmpty
                      ? (profileData['languages'][0]['language'] != null
                            ? profileData['languages'][0]['language']['name']
                            : '')
                      : ''),
            ),
            'zodiac': extractString(
              data['about']?['zodiac'] ?? profileData['zodiac'],
            ),
            'loveLanguage': extractString(
              data['about']?['loveLanguage'] ?? profileData['loveLanguage'],
            ),
            'communicationStyle': extractString(
              data['about']?['communicationStyle'] ??
                  profileData['communicationStyle'],
            ),
            'prompts': mappedPrompts,
          };

          // Use the existing copyWithDetails logic to map the rest of the fields
          final fullProfile = baseProfile.copyWithDetails(cleanDetails);

          if (mounted) {
            setState(() {
              _profile = fullProfile;
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _errorMessage = 'Failed to load details.';
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Error ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error in _fetchProfileDetails: $e');
      debugPrint('StackTrace: $stackTrace');
      if (mounted) {
        setState(() {
          _errorMessage = 'Connection error: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                });
                _fetchProfileDetails();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_profile == null) {
      return const Center(child: Text('No profile data.'));
    }

    return BlocProvider<HomeBloc>(
      create: (context) => PreviewHomeBloc(_profile!),
      child: const HomeScreen(isPreview: true, isSelfPreview: true),
    );
  }
}
