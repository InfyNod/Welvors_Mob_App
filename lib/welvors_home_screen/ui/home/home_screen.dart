// import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../home_bloc/home_bloc.dart';
import '../../../onbording_allpage/theme/app_colors.dart';

class SectionColor {
  final Color bg;
  final Color icon;
  const SectionColor(this.bg, this.icon);
}

abstract class SectionColors {
  static const intent = SectionColor(Color(0xFFFBEAF0), Color(0xFF993556));
  static const basics = SectionColor(Color(0xFFE6F1FB), Color(0xFF185FA5));
  static const career = SectionColor(Color(0xFFFAEEDA), Color(0xFF854F0B));
  static const interests = SectionColor(Color(0xFFEEEDFE), Color(0xFF534AB7));
  static const lifestyle = SectionColor(Color(0xFFE1F5EE), Color(0xFF0F6E56));
  static const family = SectionColor(Color(0xFFFAECE7), Color(0xFF993C1D));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoaded && state.profiles.isNotEmpty) {
          final currentProfile = state.profiles.first;
          return LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeBloc>().add(LoadHomeDataEvent());
                  await Future.delayed(const Duration(milliseconds: 800));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: constraints
                            .maxHeight, // Exactly fits the visible viewport
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
                ),
              );
            },
          );
        } else if (state is HomeEmpty) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeBloc>().add(LoadHomeDataEvent());
                  await Future.delayed(const Duration(milliseconds: 800));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: _buildEmptyState(context),
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.pink),
          );
        }
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_empty_rounded,
              size: 64,
              color: AppColors.pinkDeep,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "You're all caught up!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              "We are looking for more profiles for you. Check back later or pull down to refresh.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.read<HomeBloc>().add(LoadHomeDataEvent());
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              "Refresh Profiles",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pink,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailsView extends StatelessWidget {
  final ProfileModel profile;

  const _ProfileDetailsView({required this.profile});

  @override
  Widget build(BuildContext context) {
    final bool hasVideo = profile.videoUrl != null;
    final int slot2Index = hasVideo ? 1 : 2;
    final int slot3Index = hasVideo ? 2 : 3;
    final int slot4Index = hasVideo ? 3 : 4;
    final int bottomIndexStart = hasVideo ? 4 : 5;

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '✦',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF831843), // Unique elegant burgundy
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ABOUT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF831843),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Divider(
                        color: const Color(0xFF831843).withOpacity(0.3),
                        height: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // The paragraph
                _ExpandableText(
                  text: profile.about,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                // The elegant divider
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: Colors.black12, height: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: const Text('✦', style: TextStyle(fontSize: 14)),
                    ),
                    const Expanded(
                      child: Divider(color: Colors.black12, height: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // LOOKING FOR Container
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFE5E5E5),
                    ), // Opaque grey border
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 60,
                          decoration: BoxDecoration(
                            color: SectionColors.intent.bg, // Colored tint
                          ),
                          child: Center(
                            child: Icon(
                              Icons.favorite_border_rounded,
                              color:
                                  SectionColors.intent.icon, // Dark tint icon
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  profile.lookingFor,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getLookingForSubtitle(profile.lookingFor),
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // THE BASICS Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
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
                        Text(
                          '✦',
                          style: TextStyle(
                            fontSize: 16,
                            color: SectionColors.basics.icon,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'THE BASICS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: SectionColors.basics.icon,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          color: SectionColors.basics.icon.withOpacity(0.3),
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double itemWidth = (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildBentoPill(
                          Icons.calendar_today_outlined,
                          '${profile.age} years old',
                          '19 Feb 1999',
                          itemWidth,
                          stacked: true,
                        ),
                        _buildBentoPill(
                          Icons.straighten_outlined,
                          profile.height.split(' • ').first,
                          profile.height.split(' • ').last,
                          itemWidth,
                        ),
                        _buildBentoPill(
                          Icons.temple_hindu_outlined,
                          profile.religion.split(' • ').first,
                          profile.religion.split(' • ').last,
                          itemWidth,
                          stacked: true,
                        ),
                        _buildBentoPill(
                          Icons.location_on_outlined,
                          profile.location.split(', ').first,
                          profile.location.split(', ').length > 1
                              ? profile.location.split(', ')[1]
                              : '',
                          itemWidth,
                          stacked: true,
                        ),
                        _buildBentoPill(
                          Icons.translate,
                          profile.motherTongue,
                          '',
                          itemWidth,
                        ),
                        _buildBentoPill(
                          Icons.nightlight_round,
                          'Scorpio',
                          '',
                          itemWidth,
                        ),
                        _buildBentoPill(
                          Icons.favorite_border,
                          'Words of affirmation',
                          'Compliments mean the most',
                          constraints.maxWidth,
                          stacked: true,
                        ),
                        _buildBentoPill(
                          Icons.phone_in_talk_outlined,
                          'Phone calls over texts',
                          'I prefer real conversations',
                          constraints.maxWidth,
                          stacked: true,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Slot 1: After THE BASICS
          if (hasVideo) ...[
            ProfileVideoPlayer(videoPath: profile.videoUrl!),
            const SizedBox(height: 16),
          ] else if (profile.images.length > 1) ...[
            _buildImageWithRose(profile.images[1]),
            const SizedBox(height: 16),
          ],

          // Prompt Card
          Container(
            padding: const EdgeInsets.only(
              left: 24,
              right: 15,
              top: 10,
              bottom: 24,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '✦',
                      style: TextStyle(
                        fontSize: 14,
                        color: SectionColors.intent.icon,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'THE WAY TO WIN ME OVER IS..?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: SectionColors.intent.icon,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(
                      child: Text(
                        'A good book rec and a strong chai opinion.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 35,
                      height: 35,
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 40, 22, 28),
                            Color.fromARGB(255, 220, 184, 181),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Lottie.asset(
                          'assets/message.json',
                          fit: BoxFit.cover,
                          alignment: const Alignment(0.9, 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // CAREER & AMBITION Section
          Container(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
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
                        Text(
                          '✦',
                          style: TextStyle(
                            fontSize: 16,
                            color: SectionColors.career.icon,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'CAREER & AMBITION',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: SectionColors.career.icon,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          color: SectionColors.career.icon.withOpacity(0.3),
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildBasicRow(
                  Icons.school_outlined,
                  'Education',
                  'NIFT Pune',
                  'Fashion Design · 3rd year',
                  color: SectionColors.career,
                ),
                const SizedBox(height: 8),
                _buildBasicRow(
                  Icons.work_outline_rounded,
                  'Work as',
                  'Fashion Design',
                  'Freelance · 2 yrs exp',
                  color: SectionColors.career,
                ),
                const SizedBox(height: 8),
                _buildBasicRow(
                  Icons.attach_money_rounded,
                  'Income',
                  '₹8-12 L / year',
                  'Growing steadily',
                  color: SectionColors.career,
                ),
                const SizedBox(height: 8),
                _buildBasicRow(
                  Icons.computer_rounded,
                  'Work style',
                  'Creative · Hybrid',
                  '',
                  color: SectionColors.career,
                ),
                const SizedBox(height: 8),
                _buildBasicRow(
                  Icons.trending_up_rounded,
                  'Ambition level',
                  'HIGHLY DRIVEN',
                  '',
                  color: SectionColors.career,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: SectionColors.career.icon.withOpacity(0.3),
                        height: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '✦',
                        style: TextStyle(
                          fontSize: 14,
                          color: SectionColors.career.icon,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: SectionColors.career.icon.withOpacity(0.3),
                        height: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'HER BIG DREAM',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Launch her own sustainable Indian fashion label — handcrafted, slow fashion made with heart. Also wants to travel every fashion capital before 30.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Slot 2: After CAREER
          if (profile.images.length > slot2Index) ...[
            _buildImageWithRose(profile.images[slot2Index]),
            const SizedBox(height: 16),
          ],

          // Second Prompt Card
          Container(
            padding: const EdgeInsets.only(
              left: 24,
              right: 15,
              top: 10,
              bottom: 24,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '✦',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B21A8), // Dark purple
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'MY SIMPLE PLEASURES..?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF6B21A8), // Dark purple
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(
                      child: Text(
                        'Roadside chai after a long trek, no signal, good company.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 35,
                      height: 35,
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 40, 22, 28),
                            Color.fromARGB(255, 220, 184, 181),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Lottie.asset(
                          'assets/message.json',
                          fit: BoxFit.cover,
                          alignment: const Alignment(0.9, 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // INTERESTS & HOBBIES Section
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              // border removed to match benefits drawer design
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
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
                        Text(
                          '✦',
                          style: TextStyle(
                            fontSize: 16,
                            color: SectionColors.interests.icon,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'INTERESTS & HOBBIES',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: SectionColors.interests.icon,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          color: SectionColors.interests.icon.withOpacity(0.3),
                          height: 1,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: SectionColors.interests.bg, // Faint smooth tint
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '4 in common',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: SectionColors
                              .interests
                              .icon, // Dark text on faint bg
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 12,
                  children: [
                    _buildInterestPill(
                      Icons.flight_takeoff_outlined,
                      'Travel',
                      isMatch: true,
                    ),
                    _buildInterestPill(
                      Icons.coffee_outlined,
                      'Coffee',
                      isMatch: true,
                    ),
                    _buildInterestPill(
                      Icons.landscape_outlined,
                      'Trekking',
                      isMatch: true,
                    ),
                    _buildInterestPill(
                      Icons.menu_book_outlined,
                      'Books',
                      isMatch: false,
                    ),
                    _buildInterestPill(
                      Icons.self_improvement_outlined,
                      'Yoga',
                      isMatch: false,
                    ),
                    _buildInterestPill(
                      Icons.music_note_outlined,
                      'Indie music',
                      isMatch: true,
                    ),
                    _buildInterestPill(
                      Icons.restaurant_outlined,
                      'Cooking',
                      isMatch: false,
                    ),
                    _buildInterestPill(
                      Icons.camera_alt_outlined,
                      'Photography',
                      isMatch: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // LIFESTYLE Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
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
                        Text(
                          '✦',
                          style: TextStyle(
                            fontSize: 16,
                            color: SectionColors.lifestyle.icon,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'LIFESTYLE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: SectionColors.lifestyle.icon,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          color: SectionColors.lifestyle.icon.withOpacity(0.3),
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double itemWidth = (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildBentoPill(
                          Icons.restaurant_outlined,
                          'Diet',
                          'Vegetarian',
                          itemWidth,
                          stacked: true,
                          color: SectionColors.lifestyle,
                        ),
                        _buildBentoPill(
                          Icons.wine_bar_outlined,
                          'Drinking',
                          'Socially',
                          itemWidth,
                          stacked: true,
                          color: SectionColors.lifestyle,
                        ),
                        _buildBentoPill(
                          Icons.smoking_rooms_outlined,
                          'Smoking',
                          'Non-smoker',
                          itemWidth,
                          stacked: true,
                          color: SectionColors.lifestyle,
                        ),
                        _buildBentoPill(
                          Icons.flight_takeoff_outlined,
                          'Travel',
                          '4–5 trips/year',
                          itemWidth,
                          stacked: true,
                          color: SectionColors.lifestyle,
                        ),
                        _buildBentoPill(
                          Icons.pets_outlined,
                          'Pets',
                          'Cat parent',
                          itemWidth,
                          stacked: true,
                          color: SectionColors.lifestyle,
                        ),
                        _buildBentoPill(
                          Icons.dark_mode_outlined,
                          'Sleep',
                          'Night Owl',
                          itemWidth,
                          stacked: true,
                          color: SectionColors.lifestyle,
                        ),
                        _buildBentoPill(
                          Icons.fitness_center_outlined,
                          'Gym 4×/week',
                          'Yoga · Trekking',
                          constraints.maxWidth,
                          stacked: true,
                          color: SectionColors.lifestyle,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Slot 3: After LIFESTYLE
          if (profile.images.length > slot3Index) ...[
            _buildImageWithRose(profile.images[slot3Index]),
            const SizedBox(height: 16),
          ],

          // NETWORKING INTENT Section
          _buildNetworkingIntentSection(),
          const SizedBox(height: 16),

          // FAMILY Section
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
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
                        Text(
                          '✦',
                          style: TextStyle(
                            fontSize: 16,
                            color: SectionColors.family.icon,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'FAMILY',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: SectionColors.family.icon,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          color: SectionColors.family.icon.withOpacity(0.3),
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildBasicRow(
                  Icons.people_alt_outlined,
                  'Family type',
                  'Nuclear',
                  'Close-knit',
                  color: SectionColors.family,
                ),
                const SizedBox(height: 8),
                _buildBasicRow(
                  Icons.person_outline,
                  'Father',
                  'Retired banker',
                  'Bank of Maharashtra',
                  color: SectionColors.family,
                ),
                const SizedBox(height: 8),
                _buildBasicRow(
                  Icons.woman_outlined,
                  'Mother',
                  'Homemaker',
                  'Former school teacher',
                  color: SectionColors.family,
                ),
                const SizedBox(height: 8),
                _buildBasicRow(
                  Icons.group_outlined,
                  'Siblings',
                  'Sister—unmarried, studying\nBrother—married, working',
                  '',
                  color: SectionColors.family,
                ),
                const SizedBox(height: 8),
                _buildBasicRow(
                  Icons.location_on_outlined,
                  'Family home',
                  'Pune',
                  'Native: Nashik',
                  color: SectionColors.family,
                ),
                const SizedBox(height: 8),
                _buildBasicRow(
                  Icons.account_balance_wallet_outlined,
                  'Family income',
                  '₹25–40 L / year',
                  'Household, approx',
                  color: SectionColors.family,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: SectionColors.family.icon.withOpacity(0.3),
                        height: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '✦',
                        style: TextStyle(
                          fontSize: 14,
                          color: SectionColors.family.icon,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: SectionColors.family.icon.withOpacity(0.3),
                        height: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'THE FAMILY DYNAMIC',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Grew up in a close, easy-going Marathi family that values ambition as much togetherness. My parents married for love and never made it about timelines — they\'d want the same warmth for me.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Slot 4: After FAMILY
          if (profile.images.length > slot4Index) ...[
            _buildImageWithRose(profile.images[slot4Index]),
            const SizedBox(height: 16),
          ],

          // Third Prompt Card
          Container(
            padding: const EdgeInsets.only(
              left: 24,
              right: 15,
              top: 10,
              bottom: 24,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '✦',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(
                          0xFFC05621,
                        ), // Dark terracotta/orange for peach bg
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'WE\'LL GET ALONG IF..?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFC05621),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(
                      child: Text(
                        'You can debate me for an hour and still want dessert after.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 35,
                      height: 35,
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 40, 22, 28),
                            Color.fromARGB(255, 220, 184, 181),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Lottie.asset(
                          'assets/message.json',
                          fit: BoxFit.cover,
                          alignment: const Alignment(0.9, 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bottom Slots: Extra photos below "We'll get along if..."
          if (profile.images.length > bottomIndexStart) ...[
            for (int i = bottomIndexStart; i < profile.images.length; i++) ...[
              _buildImageWithRose(profile.images[i]),
              const SizedBox(height: 16),
            ],
          ],
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

  Widget _buildInterestPill(
    IconData icon,
    String text, {
    bool isMatch = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isMatch ? SectionColors.interests.bg : const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: isMatch ? Colors.transparent : Colors.black12,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isMatch ? 4 : 5.2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isMatch ? Colors.white : SectionColors.interests.bg,
              border: isMatch
                  ? Border.all(
                      color: SectionColors.interests.icon.withOpacity(0.5),
                      width: 1.2,
                    )
                  : null,
            ),
            child: Icon(icon, size: 14, color: SectionColors.interests.icon),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isMatch ? SectionColors.interests.icon : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkingIntentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4A3C31), // Soft Premium Mocha
            Color(0xFF2C221C), // Deep Espresso
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF956630).withOpacity(0.5), // antiqueGold
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'NETWORKING INTENT',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFD4A85F), // luxuryGold
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFAB8F63),
                      Color(0xFFEFC676),
                    ], // royalGold to premiumGold
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'VIP & VIP Elite',
                  style: TextStyle(
                    color: Color(0xFF1E1715), // black
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // LOOKING FOR
          _buildNetworkingCategory('LOOKING FOR', [
            'Mentorship',
            'Career advice',
          ]),

          // CIRCLES
          _buildNetworkingCategory('CIRCLES', ['Founder circles', 'Creators']),

          // MEETS OVER
          _buildNetworkingCategory('MEETS OVER', [
            'Coffee chats',
            'Curated dinners',
          ]),

          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: const Color(0xFF956630).withOpacity(0.5),
                  height: 1,
                ), // antiqueGold
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '✦',
                  style: TextStyle(fontSize: 14, color: Color(0xFFD4A85F)),
                ), // luxuryGold
              ),
              Expanded(
                child: Divider(
                  color: const Color(0xFF956630).withOpacity(0.5),
                  height: 1,
                ), // antiqueGold
              ),
            ],
          ),
          const SizedBox(height: 12),

          // IN HER WORDS
          const Center(
            child: Text(
              'IN HER WORDS',
              style: TextStyle(
                color: Color(0xFFD4A85F), // luxuryGold
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Happy to swap notes on building a brand — coffee over pitch decks. Dating first, network second.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFBF5D2), // ivoryGlow
              fontSize: 13,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkingCategory(String title, List<String> tags) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFAB8F63), // royalGold
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF493628).withOpacity(0.3), // darkBrown
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(
                      0xFF956630,
                    ).withOpacity(0.6), // antiqueGold
                    width: 1,
                  ),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Color(0xFFCCB688), // champagne
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
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
    return Row(
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (subValue != null) ...[
                const SizedBox(height: 2),
                Text(
                  subValue,
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

  Widget _buildImageWithRose(String imageUrl) {
    return Container(
      width: double.infinity,
      height: 550,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
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
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: 38,
                height: 38,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 40, 22, 28),
                      Color.fromARGB(255, 220, 184, 181),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Lottie.asset(
                    'assets/message.json',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0.8, 0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        // border removed to match benefits drawer design
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  String _getLookingForSubtitle(String lookingFor) {
    switch (lookingFor) {
      case 'A long-term relationship':
        return 'Looking to build something that lasts';
      case 'Let’s see where it goes':
        return 'Open and unhurried, no fixed expectations';
      case 'Open to marriage, when it’s right':
        return 'Serious, on the right timeline - not rushed';
      case 'New friends & connections':
        return 'Meeting genuine people first';
      case 'Long-term, marriage-open.':
        return 'Looking to build something that lasts, open to taking the next big step.';
      default:
        return 'Seeking meaningful connections';
    }
  }

  Widget _buildBasicRow(
    IconData icon,
    String title,
    String value,
    String subtitle, {
    SectionColor? color,
  }) {
    String combinedInfo = value;
    if (subtitle.isNotEmpty) {
      combinedInfo = '$value  ·  $subtitle';
    }

    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(color != null ? 7.2 : 6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color != null ? color.bg : Colors.transparent,
              border: color != null
                  ? null
                  : Border.all(color: Colors.black87, width: 1.2),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color != null ? color.icon : Colors.black87,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  combinedInfo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoPill(
    IconData icon,
    String text1,
    String text2,
    double width, {
    bool stacked = false,
    SectionColor? color,
  }) {
    final c = color ?? SectionColors.basics;
    return Container(
      width: width,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8), // Very light grey pill
        borderRadius: BorderRadius.circular(50), // Fully rounded
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7.2),
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.bg),
            child: Icon(icon, size: 16, color: c.icon),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: stacked
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text1,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (text2.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          text2,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  )
                : Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: text1),
                        if (text2.isNotEmpty) ...[
                          const TextSpan(
                            text: '  •  ',
                            style: TextStyle(color: Colors.black38),
                          ),
                          TextSpan(
                            text: text2,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      ),
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
            clipBehavior: Clip.none,
            children: state.profiles
                .asMap()
                .entries
                .map((entry) {
                  final index = entry.key;
                  final profile = entry.value;
                  final isFront = index == 0;

                  final widgetKey = ValueKey(profile.images.first);

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
    return _ProfileCardUI(
      profile: profile,
      glowColor: Colors.transparent,
      dragPercent: 0.0,
    );
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
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          context.read<HomeBloc>().add(
            SwipeProfileEvent(isRightSwipe: isRightSwipe),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
      onHorizontalDragStart: _onPanStart,
      onHorizontalDragUpdate: _onPanUpdate,
      onHorizontalDragEnd: _onPanEnd,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.translate(
            offset: _position,
            child: Transform.rotate(
              angle: angle,
              child: _ProfileCardUI(
                profile: widget.profile,
                glowColor: glowColor,
                dragPercent: dragPercent,
              ),
            ),
          ),

          // Cross Animation (Visible on Left Swipe) sliding in from Left Edge
          if (dragPercent < 0)
            Positioned(
              left: -125 + (dragPercent.abs() * ((screenWidth / 2) + 55)),
              top: MediaQuery.of(context).size.height * 0.25,
              child: Opacity(
                opacity: dragPercent.abs().clamp(0.0, 1.0),
                child: IgnorePointer(
                  child: Lottie.asset(
                    'assets/nolike.json',
                    width: 110,
                    height: 110,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

          // Like Animation (Visible on Right Swipe) sliding in from Right Edge
          if (dragPercent > 0)
            Positioned(
              right: -200 + (dragPercent * ((screenWidth / 2) + 90)),
              top: MediaQuery.of(context).size.height * 0.20,
              child: Opacity(
                opacity: dragPercent.clamp(0.0, 1.0),
                child: IgnorePointer(
                  child: Lottie.asset(
                    'assets/like.json',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileCardUI extends StatelessWidget {
  final ProfileModel profile;
  final Color glowColor;
  final double dragPercent;

  const _ProfileCardUI({
    required this.profile,
    required this.glowColor,
    required this.dragPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(profile.images.first),
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
            child: GestureDetector(
              onTap: () {
                context.read<HomeBloc>().add(UndoSwipeEvent());
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.replay_rounded,
                  size: 22,
                  color: Colors.orange.shade500,
                ),
              ),
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
  bool _isMuted = false;
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
    return VisibilityDetector(
      key: Key(widget.videoPath),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 0 &&
            _controller.value.isPlaying) {
          _controller.pause();
          setState(() {
            _showControls = true;
          });
        }
      },
      child: Container(
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
                      child: CircularProgressIndicator(
                        color: Colors.pinkAccent,
                      ),
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
                    bottom: 72,
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
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Container(
                    width: 38,
                    height: 38,
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 40, 22, 28),
                          Color.fromARGB(255, 220, 184, 181),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Lottie.asset(
                        'assets/message.json',
                        fit: BoxFit.cover,
                        alignment: const Alignment(0.8, 0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle style;

  const _ExpandableText({
    Key? key,
    required this.text,
    this.maxLines = 4,
    required this.style,
  }) : super(key: key);

  @override
  __ExpandableTextState createState() => __ExpandableTextState();
}

class __ExpandableTextState extends State<_ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: widget.style);
        final tp = TextPainter(
          text: span,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        );
        tp.layout(maxWidth: constraints.maxWidth);

        if (tp.didExceedMaxLines) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.text,
                maxLines: isExpanded ? null : widget.maxLines,
                overflow:
                    isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: widget.style,
              ),
              if (!isExpanded) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = true;
                    });
                  },
                  child: const Text(
                    'See more',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF831843), // Matches ABOUT section burgundy
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          );
        } else {
          return Text(widget.text, style: widget.style);
        }
      },
    );
  }
}
