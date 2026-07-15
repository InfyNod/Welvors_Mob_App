import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../bloc/home_bloc.dart';
import '../../onbording_allpage/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoaded && state.profiles.isNotEmpty) {
          final currentProfile = state.profiles.first;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  height:
                      MediaQuery.of(context).size.height *
                      0.75, // Scalable height for cards
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: _CardsStack(),
                  ),
                ),
                _ProfileDetailsView(profile: currentProfile),
                const SizedBox(height: 14),
              ],
            ),
          );
        } else {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _CardsStack(),
          );
        }
      },
    );
  }
}

class _ProfileDetailsView extends StatelessWidget {
  final ProfileModel profile;

  const _ProfileDetailsView({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Match Tags Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPillTag(profile.matchPercentage, Colors.blue),
              _buildPillTag(profile.trustPercentage, Colors.green),
              _buildPillTag(profile.replyTime, Colors.orange),
            ],
          ),
          const SizedBox(height: 16),

          // ABOUT Section
          _buildDetailCard(
            title: 'ABOUT',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.about,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.black12, height: 1),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.pinkAccent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'LOOKING FOR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.pinkAccent,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.pink.shade50.withOpacity(0.6),
                            Colors.pinkAccent.withOpacity(0.03),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.pinkAccent.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pinkAccent.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.pinkAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              profile.lookingFor,
                              style: const TextStyle(
                                color: AppColors.pinkDeep,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // THE BASICS Section
          _buildDetailCard(
            title: 'THE BASICS',
            child: Column(
              children: [
                _buildBasicRow(
                  Icons.cake_outlined,
                  'Age',
                  '${profile.age} years old',
                  '19 Feb 1999',
                ),
                const Divider(height: 32, color: Colors.black12),
                _buildBasicRow(
                  Icons.height_outlined,
                  'Height',
                  profile.height.split(' • ').first,
                  profile.height.split(' • ').last,
                ),
                const Divider(height: 32, color: Colors.black12),
                _buildBasicRow(
                  Icons.mosque_outlined,
                  'Religion',
                  profile.religion.split(' • ').first,
                  profile.religion.split(' • ').last,
                ),
                const Divider(height: 32, color: Colors.black12),
                _buildBasicRow(
                  Icons.location_on_outlined,
                  'Lives in',
                  profile.location.split(', ').first,
                  profile.location.split(', ').last,
                ),
                const Divider(height: 32, color: Colors.black12),
                _buildBasicRow(
                  Icons.translate,
                  'Mother tongue',
                  profile.motherTongue,
                  '',
                ),
                const Divider(height: 32, color: Colors.black12),
                _buildBasicRow(Icons.nightlight_round, 'Zodiac', 'Scorpio', ''),
                const Divider(height: 32, color: Colors.black12),
                _buildBasicRow(
                  Icons.favorite,
                  'Love language',
                  'Words of affirmation',
                  'Compliments mean the most',
                ),
                const Divider(height: 32, color: Colors.black12),
                _buildBasicRow(
                  Icons.phone_in_talk_outlined,
                  'Communication',
                  'Phone calls over texts',
                  '',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Video Intro Player
          const ProfileVideoPlayer(videoPath: 'assets/video.mp4'),
          const SizedBox(height: 16),

          // Prompt Card
          Container(
            padding: const EdgeInsets.only(
              left: 20,
              top: 20,
              right: 20,
              bottom: 12,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'The way to win me over is..',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.pinkAccent,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'A good book rec and a strong chai opinion.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.only(left: 2.0),
                        child: Text('🌹', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // CAREER & AMBITION Section
          _buildDetailCard(
            title: 'CAREER & AMBITION',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBasicRow(
                  Icons.school_outlined,
                  'Education',
                  'NIFT Pune',
                  'B. Des Fashion Design · 3rd year',
                ),
                const Divider(height: 32, color: Colors.black12),
                _buildBasicRow(
                  Icons.work_outline_rounded,
                  'Work as',
                  'Fashion Design',
                  'Freelance · 2 yrs exp',
                ),
                const Divider(height: 32, color: Colors.black12),
                _buildBasicRow(
                  Icons.attach_money_rounded,
                  'Income',
                  '₹8-12 L / year',
                  'Growing steadily',
                ),
                const Divider(height: 32, color: Colors.black12),
                _buildBasicRow(
                  Icons.computer_rounded,
                  'Work style',
                  'Creative · Hybrid',
                  '',
                ),
                const Divider(height: 32, color: Colors.black12),
                _buildBasicRow(
                  Icons.trending_up_rounded,
                  'Ambition level',
                  'HIGHLY DRIVEN',
                  '',
                ),
                const Divider(height: 32, color: Colors.black12),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'HER BIG DREAM',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.pinkAccent,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Launch her own sustainable Indian fashion label — handcrafted, slow fashion made with heart. Also wants to travel every fashion capital before 30.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Additional Profile Photo
          Container(
            width: double.infinity,
            height: 550,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: DecorationImage(
                image: NetworkImage(profile.imageUrl),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Second Prompt Card
          Container(
            padding: const EdgeInsets.only(
              left: 20,
              top: 20,
              right: 20,
              bottom: 12,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My simple pleasures..',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.pinkAccent,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Roadside chai after a long trek, no signal, good company.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.only(left: 2.0),
                        child: Text('🌹', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // INTERESTS & HOBBIES Section
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'INTERESTS & HOBBIES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.pinkAccent,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 12,
                  children: [
                    _buildInterestPill('✈️', 'Travel'),
                    _buildInterestPill('☕️', 'Coffee'),
                    _buildInterestPill('⛰️', 'Trekking'),
                    _buildInterestPill('📸', 'Photography'),
                    _buildInterestPill('🎵', 'Music'),
                    _buildInterestPill('🥘', 'Cooking'),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.only(left: 2.0),
                        child: Text('🌹', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // LIFESTYLE Section
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'LIFESTYLE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.pinkAccent,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLifestyleRow(
                  Icons.restaurant_outlined,
                  'Diet',
                  'Vegetarian',
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildLifestyleRow(
                  Icons.wine_bar_outlined,
                  'Drinking',
                  'Socially',
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildLifestyleRow(
                  Icons.smoking_rooms_outlined,
                  'Smoking',
                  'Non-smoker',
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildLifestyleRow(
                  Icons.fitness_center_outlined,
                  'Fitness',
                  'Gym 4×/week',
                  subValue: 'Yoga · Trekking',
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildLifestyleRow(
                  Icons.flight_takeoff_outlined,
                  'Travel',
                  '4–5 trips/year',
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildLifestyleRow(Icons.pets_outlined, 'Pets', 'Cat parent'),
                const Divider(height: 1, color: Colors.black12),
                _buildLifestyleRow(
                  Icons.dark_mode_outlined,
                  'Sleep',
                  'Night Owl',
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.only(left: 2.0),
                        child: Text('🌹', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Additional Profile Photo 2
          Container(
            width: double.infinity,
            height: 550,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: DecorationImage(
                image: NetworkImage(profile.imageUrl),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // FAMILY Section
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'FAMILY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.pinkAccent,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLifestyleRow(
                  Icons.people_alt_outlined,
                  'Family type',
                  'Nuclear',
                  subValue: 'Close-knit',
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildLifestyleRow(
                  Icons.person_outline,
                  'Father',
                  'Retired banker',
                  subValue: 'Bank of Maharashtra',
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildLifestyleRow(
                  Icons.woman_outlined,
                  'Mother',
                  'Homemaker',
                  subValue: 'Former school teacher',
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildLifestyleRow(
                  Icons.group_outlined,
                  'Siblings',
                  'Sister — unmarried, studying',
                  subValue: 'Brother — married, working',
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildLifestyleRow(
                  Icons.location_on_outlined,
                  'Family home',
                  'Pune',
                  subValue: 'Native: Nashik',
                ),
                const Divider(height: 1, color: Colors.black12),
                _buildLifestyleRow(
                  Icons.account_balance_wallet_outlined,
                  'Family income',
                  '₹25–40 L / year',
                  subValue: 'Household, approx',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Grew up in a close, easy-going Marathi family that values ambition as much as togetherness. My parents married for love and never made it about timelines — they\'d want the same warmth for me.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.only(left: 2.0),
                        child: Text('🌹', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Final Profile Photo
          Container(
            width: double.infinity,
            height: 550,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: DecorationImage(
                image: NetworkImage(profile.imageUrl),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Third Prompt Card
          Container(
            padding: const EdgeInsets.only(
              left: 20,
              top: 20,
              right: 20,
              bottom: 12,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'We\'ll get along if…',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.pinkAccent,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'You can debate me for an hour and still want dessert after.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.only(left: 2.0),
                        child: Text('🌹', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillTag(String text, Color dotColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: dotColor.withOpacity(0.2), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: dotColor.withOpacity(0.08),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: dotColor.withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestPill(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.pink.shade100, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade50,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleRow(
    IconData icon,
    String label,
    String value, {
    String? subValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: subValue != null
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.pinkDeep, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              if (subValue != null) ...[
                const SizedBox(height: 4),
                Text(
                  subValue,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black45,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.06),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.pinkAccent,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildBasicRow(
    IconData icon,
    String title,
    String value,
    String subtitle,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.pink.shade50.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.pinkDeep, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CardsStack extends StatelessWidget {
  const _CardsStack();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoaded) {
          if (state.profiles.isEmpty) {
            return const Center(
              child: Text(
                'No more profiles for today!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return Stack(
            children: state.profiles
                .asMap()
                .entries
                .map((entry) {
                  final index = entry.key;
                  final profile = entry.value;
                  final isFront = index == 0;

                  final widgetKey = ValueKey(profile.imageUrl);

                  return isFront
                      ? _DraggableCard(key: widgetKey, profile: profile)
                      : _StaticCard(key: widgetKey, profile: profile);
                })
                .toList()
                .reversed
                .toList(),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _StaticCard extends StatelessWidget {
  final ProfileModel profile;
  const _StaticCard({required this.profile, super.key});

  @override
  Widget build(BuildContext context) {
    return _ProfileCardUI(profile: profile, glowColor: Colors.transparent);
  }
}

class _DraggableCard extends StatefulWidget {
  final ProfileModel profile;
  const _DraggableCard({required this.profile, super.key});

  @override
  State<_DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<_DraggableCard>
    with SingleTickerProviderStateMixin {
  Offset _position = Offset.zero;
  bool _isDragging = false;
  late AnimationController _animController;
  late Animation<Offset> _animOffset;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animController.addListener(() {
      setState(() {
        _position = _animOffset.value;
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() => _isDragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _isDragging = false);

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.4;

    if (_position.dx > threshold) {
      // Swiped Right
      _animateOut(Offset(screenWidth * 1.5, 0), true);
    } else if (_position.dx < -threshold) {
      // Swiped Left
      _animateOut(Offset(-screenWidth * 1.5, 0), false);
    } else {
      // Snap Back
      _animOffset = Tween<Offset>(begin: _position, end: Offset.zero).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
      );
      _animController.forward(from: 0);
    }
  }

  void _animateOut(Offset target, bool isRightSwipe) {
    _animOffset = Tween<Offset>(
      begin: _position,
      end: target,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward(from: 0).then((_) {
      if (mounted) {
        context.read<HomeBloc>().add(
          SwipeProfileEvent(isRightSwipe: isRightSwipe),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final angle = _position.dx / 400; // slight rotation

    // Calculate glow opacity based on drag distance
    final double dragPercent = (_position.dx / 150).clamp(-1.0, 1.0);
    Color glowColor = Colors.transparent;

    if (dragPercent > 0) {
      glowColor = Colors.green.withOpacity(
        dragPercent * 0.6,
      ); // Green for right
    } else if (dragPercent < 0) {
      glowColor = Colors.red.withOpacity(
        dragPercent.abs() * 0.6,
      ); // Red for left
    }

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _position,
        child: Transform.rotate(
          angle: angle,
          child: _ProfileCardUI(profile: widget.profile, glowColor: glowColor),
        ),
      ),
    );
  }
}

class _ProfileCardUI extends StatelessWidget {
  final ProfileModel profile;
  final Color glowColor;

  const _ProfileCardUI({required this.profile, required this.glowColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(profile.imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Directional Glow Overlay (Red/Green based on swipe)
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: glowColor,
              ),
            ),
          ),
          // Top-left rotate icon
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh, size: 20, color: Colors.black87),
            ),
          ),
          // Top-right diamond icon
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.pink.shade50.withOpacity(0.95),
                shape: BoxShape.circle,
              ),
              child: Lottie.asset(
                'assets/Red_Diamond.json',
                width: 38,
                height: 38,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Bottom gradient & details
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.95),
                    Colors.black.withOpacity(0.0),
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags row
                  Row(
                    children: [
                      _buildTag(profile.matchPercentage, Colors.blue),
                      const SizedBox(width: 8),
                      _buildTag(profile.trustPercentage, Colors.green),
                      const SizedBox(width: 8),
                      _buildTag(profile.replyTime, Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Name & Age
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        profile.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        profile.age.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified,
                        color: Colors.pinkAccent,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Location
                  _buildInfoRow(Icons.location_on, profile.location),
                  const SizedBox(height: 4),
                  // Job
                  _buildInfoRow(Icons.work, profile.job),
                  const SizedBox(height: 4),
                  // Intent
                  _buildInfoRow(Icons.favorite, profile.intent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color dotColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ProfileVideoPlayer extends StatefulWidget {
  final String videoPath;
  const ProfileVideoPlayer({super.key, required this.videoPath});

  @override
  State<ProfileVideoPlayer> createState() => _ProfileVideoPlayerState();
}

class _ProfileVideoPlayerState extends State<ProfileVideoPlayer> {
  late VideoPlayerController _controller;
  bool _showControls = true;
  bool _isMuted = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize()
          .then((_) {
            _controller.setLooping(true);
            _controller.setVolume(_isMuted ? 0.0 : 1.0);
            // Video is initially paused, so we don't start the hide timer yet
            setState(() {});
          })
          .catchError((error) {
            debugPrint("Video Init Error: $error");
            // We can just stop loading by calling setState
            if (mounted) {
              setState(() {});
            }
          });

    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  String _formatDuration(Duration duration) {
    String minutes = duration.inMinutes.toString();
    String seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _showControls = true;
      _startHideTimer();
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 550,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_controller.value.isInitialized)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                )
              else
                Container(
                  color: Colors.grey.shade900,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.pinkAccent),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 120,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Center(
                child: AnimatedOpacity(
                  opacity: _showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.black87,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _controller.value.isInitialized
                        ? 'Video intro · ${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}'
                        : 'Video intro',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (_controller.value.isInitialized)
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: GestureDetector(
                    onTap: _toggleMute,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isMuted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
