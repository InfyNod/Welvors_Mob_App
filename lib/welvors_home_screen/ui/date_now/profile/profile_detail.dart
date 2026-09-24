import '../../../services/token_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/home_screen.dart';
import 'package:velvors/welvors_home_screen/home_bloc/home_bloc.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/send_request_drawer.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/date_api_service/date_now_api_service.dart';

// Mock HomeBloc to feed the single fetched profile to the HomeScreen.
class ProfileDetailHomeBloc extends Bloc<HomeEvent, HomeState>
    implements HomeBloc {
  ProfileDetailHomeBloc(ProfileModel profile)
    : super(HomeLoaded(profiles: [profile])) {
    on<HomeEvent>((event, emit) {
      // Keep emitting the same profile so it stays on screen
      emit(HomeLoaded(profiles: [profile]));
    });
  }

  @override
  bool get hasSwipedProfiles => false;

  @override
  int get swipedCount => 0;
}

class ProfileDetailScreen extends StatefulWidget {
  final String userId;
  final String? profileImageUrl;
  final String? profileName;
  final Map<String, dynamic>? plan;
  final VoidCallback? onPlanAction;
  final Widget? customBottomWidget;

  const ProfileDetailScreen({
    super.key,
    required this.userId,
    this.profileImageUrl,
    this.profileName,
    this.plan,
    this.onPlanAction,
    this.customBottomWidget,
  });

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  bool _isLoading = true;
  ProfileModel? _profile;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchProfileDetails();
  }

  Future<void> _fetchProfileDetails() async {
    try {
      final token = (await TokenHelper.getToken() ?? "");

      final url = Uri.parse(
        'https://api.welvors.com/api/user/details/${widget.userId}',
      );

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
          if (profileData['area'] != null &&
              profileData['area'].toString().isNotEmpty)
            locParts.add(extractString(profileData['area']));
          if (profileData['city'] != null &&
              profileData['city'].toString().isNotEmpty)
            locParts.add(extractString(profileData['city']));
          if (profileData['state'] != null &&
              profileData['state'].toString().isNotEmpty)
            locParts.add(extractString(profileData['state']));
          String combinedLocation = locParts.join(', ');

          // Create base profile. We use fallback values in case the API doesn't provide them.
          final baseProfile = ProfileModel(
            id: widget.userId,
            images: images.isNotEmpty
                ? images
                : (widget.profileImageUrl != null
                      ? [widget.profileImageUrl!]
                      : []),
            videoUrl: videos.isNotEmpty ? videos.first : null,
            name:
                widget.profileName ??
                (extractString(data['full_name']).isNotEmpty
                    ? extractString(data['full_name'])
                    : 'User'),
            age: data['age'] is int
                ? data['age']
                : (int.tryParse(data['age']?.toString() ?? '') ?? 25),
            location: combinedLocation,
            job: '',
            intent: extractString(
              profileData['lookingFor'] ?? data['lookingFor'],
            ),
            matchPercentage: '0% Match',
            trustPercentage: '0% Trust',
            replyTime: '',
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
            'prompts':
                mappedPrompts, // This is handled internally by copyWithDetails
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFF05C91).withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF966EB4).withOpacity(0.10),
                    blurRadius: 30,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF242424),
                size: 16,
              ),
            ),
          ),
        ),
        title: Text(
          widget.profileName ?? 'Profile',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.pink),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
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
      return const Center(child: Text('No profile data found.'));
    }

    // Wrap the HomeScreen inside a BlocProvider to supply the fetched profile
    Widget homeScreen = BlocProvider<HomeBloc>(
      create: (context) => ProfileDetailHomeBloc(_profile!),
      child: const HomeScreen(isPreview: true),
    );

    if (widget.plan != null) {
      return Column(
        children: [
          Expanded(child: homeScreen),
          Container(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 8,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE4EC), // Light pink
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFFE43A6A)),
                      onPressed: () async {
                        final testToken = (await TokenHelper.getToken() ?? "");

                        // Call API in the background
                        DateNowApiService.skipPlan(
                          widget.plan!['id'],
                          overrideToken: testToken,
                        );

                        if (widget.onPlanAction != null) {
                          widget.onPlanAction!();
                        }
                        Navigator.pop(context); // Go back after skipping
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            final requestSent =
                                await showRequestDateBottomSheet(
                                  context,
                                  widget.plan!,
                                );
                            if (mounted && requestSent == true) {
                              if (widget.onPlanAction != null) {
                                widget.onPlanAction!();
                              }
                              Navigator.pop(
                                context,
                              ); // Go back after request sent
                            }
                          },
                          child: const Center(
                            child: Text(
                              'Request Date',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (widget.customBottomWidget != null) {
      return Column(
        children: [
          Expanded(child: homeScreen),
          widget.customBottomWidget!,
        ],
      );
    }

    return homeScreen;
  }
}
