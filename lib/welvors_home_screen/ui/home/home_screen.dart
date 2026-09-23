// import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../services/logger_service.dart';
import 'send_compliment/complimenting.dart';
import 'match/match_analysis_screen.dart';
import 'trust_score/trust_screen.dart';
import 'reply/reply_drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../home_bloc/home_bloc.dart';
import '../../../onbording_allpage/theme/app_colors.dart';
import '../drawer_files/dating/edit_profile/bloc/profile_edit_cubit.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:screen_protector/screen_protector.dart';

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

class HomeScreen extends StatefulWidget {
  final bool isPreview;
  final bool isSelfPreview;
  const HomeScreen({
    super.key,
    this.isPreview = false,
    this.isSelfPreview = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _protectScreen();
    // Safety check: if splash screen was bypassed, load data now.
    if (context.read<HomeBloc>().state is HomeInitial) {
      context.read<HomeBloc>().add(const LoadHomeDataEvent(isRefresh: true));
    }
  }

  Future<void> _protectScreen() async {
    try {
      await ScreenProtector.preventScreenshotOn();
      await ScreenProtector.protectDataLeakageWithBlur();
    } catch (e) {
      AppLogger.e('HomeScreen', 'Screen protection error: $e', error: e);
    }
  }

  @override
  void dispose() {
    _unprotectScreen();
    super.dispose();
  }

  Future<void> _unprotectScreen() async {
    try {
      await ScreenProtector.preventScreenshotOff();
      await ScreenProtector.protectDataLeakageWithBlurOff();
    } catch (e) {
      AppLogger.e('HomeScreen', 'Screen unprotection error: $e', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoaded && state.profiles.isNotEmpty) {
          final currentProfile = state.profiles.first;
          return LayoutBuilder(
            builder: (context, constraints) {
              Widget child = SingleChildScrollView(
                physics: widget.isPreview
                    ? const BouncingScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                child: Column(
                  children: [
                    SizedBox(
                      height: constraints
                          .maxHeight, // Exactly fits the visible viewport
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: _CardsStack(
                          isPreview: widget.isPreview,
                          isSelfPreview: widget.isSelfPreview,
                        ),
                      ),
                    ),
                    _ProfileDetailsView(
                      profile: currentProfile,
                      isSelfPreview: widget.isSelfPreview,
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              );

              if (widget.isPreview) {
                return child;
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeBloc>().add(
                    const LoadHomeDataEvent(isRefresh: true),
                  );
                  await Future.delayed(const Duration(milliseconds: 800));
                },
                child: child,
              );
            },
          );
        } else if (state is HomeEmpty) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeBloc>().add(
                    const LoadHomeDataEvent(isRefresh: true),
                  );
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
              context.read<HomeBloc>().add(
                const LoadHomeDataEvent(isRefresh: true),
              );
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
  final bool isSelfPreview;

  const _ProfileDetailsView({
    required this.profile,
    this.isSelfPreview = false,
  });

  bool _hasValidData(dynamic data) {
    if (data == null) return false;
    if (data is Map) {
      if (data.isEmpty) return false;
      return data.entries.any((entry) {
        final key = entry.key.toString();
        if (key == '_id' ||
            key == 'id' ||
            key == 'userId' ||
            key == 'createdAt' ||
            key == 'updatedAt' ||
            key == '__v') {
          return false;
        }
        final v = entry.value;
        if (v == null) return false;
        if (v is String) return v.trim().isNotEmpty;
        if (v is List) return v.isNotEmpty;
        if (v is Map) return v.isNotEmpty;
        return true;
      });
    } else if (data is List) {
      return data.isNotEmpty;
    }
    return false;
  }

  bool _hasCareerData() {
    if (profile.career == null) return false;
    final c = profile.career!;
    if (c['highestEducation'] != null &&
        c['highestEducation'].toString().isNotEmpty)
      return true;
    if (c['collegeName'] != null && c['collegeName'].toString().isNotEmpty)
      return true;
    if (c['profession'] != null && c['profession'].toString().isNotEmpty)
      return true;
    if (c['companyName'] != null && c['companyName'].toString().isNotEmpty)
      return true;
    if (c['salaryRange'] != null && c['salaryRange'].toString().isNotEmpty)
      return true;
    if (c['employmentType'] != null &&
        c['employmentType'].toString().isNotEmpty)
      return true;
    if (c['ambition'] != null && c['ambition'].toString().isNotEmpty)
      return true;
    if (c['bigDreams'] != null && c['bigDreams'].toString().trim().isNotEmpty)
      return true;
    return false;
  }

  bool _hasFamilyData() {
    if (profile.family == null) return false;
    final f = profile.family!;
    if (f['familyType'] != null && f['familyType'].toString().isNotEmpty)
      return true;
    if (f['familyStatus'] != null && f['familyStatus'].toString().isNotEmpty)
      return true;
    if (f['fatherOccupation'] != null &&
        f['fatherOccupation'].toString().isNotEmpty)
      return true;
    if (f['fatherOrganisation'] != null &&
        f['fatherOrganisation'].toString().isNotEmpty)
      return true;
    if (f['motherOccupation'] != null &&
        f['motherOccupation'].toString().isNotEmpty)
      return true;
    if (f['motherOrganisation'] != null &&
        f['motherOrganisation'].toString().isNotEmpty)
      return true;
    if (f['numberOfSiblings'] != null &&
        f['numberOfSiblings'].toString().isNotEmpty)
      return true;
    return false;
  }

  String formatDob(String? dob) {
    if (dob == null || dob.isEmpty) return '';

    try {
      final date = DateTime.parse(dob);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dob;
    }
  }

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
              _buildPillTag(
                profile.matchPercentage,
                Colors.blue,
                onTap: () {
                  if (isSelfPreview) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MatchAnalysisScreen(matchName: profile.name),
                    ),
                  );
                },
              ),
              _buildPillTag(
                profile.trustPercentage,
                Colors.green,
                onTap: () {
                  if (isSelfPreview) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrustScreen(),
                    ),
                  );
                },
              ),
              _buildPillTag(
                profile.replyTime,
                Colors.orange,
                onTap: () {
                  if (isSelfPreview) return;
                  ReplyDrawer.show(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!profile.detailsLoaded)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.pink),
              ),
            )
          else ...[
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
                          if (profile.dob.isNotEmpty)
                            _buildBentoPill(
                              Icons.calendar_today_outlined,
                              '${profile.age} years old',
                              formatDob(profile.dob),
                              itemWidth,
                              stacked: true,
                            ),
                          if (profile.height.isNotEmpty)
                            _buildBentoPill(
                              Icons.straighten_outlined,
                              profile.height.split(RegExp(r'\s*[•·]\s*')).first,
                              profile.height.split(RegExp(r'\s*[•·]\s*')).last,
                              itemWidth,
                            ),
                          if (profile.religion.isNotEmpty)
                            _buildBentoPill(
                              Icons.temple_hindu_outlined,
                              profile.religion,
                              profile.community,
                              itemWidth,
                              stacked: true,
                            ),
                          if (profile.location.isNotEmpty)
                            _buildBentoPill(
                              Icons.location_on_outlined,
                              profile.location.split(', ').first,
                              profile.location.split(', ').length > 1
                                  ? profile.location
                                        .split(', ')
                                        .skip(1)
                                        .join(', ')
                                  : '',
                              itemWidth,
                              stacked: true,
                            ),
                          if (profile.motherTongue.isNotEmpty)
                            _buildBentoPill(
                              Icons.translate,
                              profile.motherTongue,
                              '',
                              itemWidth,
                            ),
                          if (profile.zodiac.isNotEmpty)
                            _buildBentoPill(
                              Icons.nightlight_round,
                              profile.zodiac,
                              '',
                              itemWidth,
                            ),
                          if (profile.loveLanguage.isNotEmpty)
                            Builder(
                              builder: (context) {
                                final data = _getLoveLanguageData(
                                  profile.loveLanguage,
                                );
                                return _buildBentoPill(
                                  Icons.favorite_border,
                                  data['title']!,
                                  data['subtitle']!,
                                  constraints.maxWidth,
                                  stacked: true,
                                );
                              },
                            ),
                          if (profile.communication.isNotEmpty)
                            Builder(
                              builder: (context) {
                                final data = _getCommunicationData(
                                  profile.communication,
                                );
                                return _buildBentoPill(
                                  Icons.phone_in_talk_outlined,
                                  data['title']!,
                                  data['subtitle']!,
                                  constraints.maxWidth,
                                  stacked: true,
                                );
                              },
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
              ProfileVideoPlayer(
                videoPath: profile.videoUrl!,
                isSelfPreview: isSelfPreview,
                profile: profile,
              ),
              const SizedBox(height: 16),
            ] else if (profile.images.length > 1) ...[
              _buildImageWithRose(context, profile.images[1]),
              const SizedBox(height: 16),
            ],

            // Prompt Card
            if (profile.prompts.isNotEmpty) ...[
              _buildPromptCard(
                context,
                profile.prompts[0]['prompt'] ?? '',
                profile.prompts[0]['answer'] ?? '',
              ),
              const SizedBox(height: 16),
            ],

            // CAREER & AMBITION Section
            if (_hasCareerData()) ...[
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
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
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
                    if (profile.career?['highestEducation'] != null ||
                        profile.career?['collegeName'] != null) ...[
                      _buildBasicRow(
                        Icons.school_outlined,
                        'Education',
                        _formatEnumText(
                              profile.career?['highestEducation']?.toString(),
                            ) ??
                            profile.career?['collegeName']?.toString() ??
                            '',
                        profile.career?['degree']?.toString() ?? '',
                        color: SectionColors.career,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (profile.career?['profession'] != null ||
                        profile.career?['companyName'] != null) ...[
                      _buildBasicRow(
                        Icons.work_outline_rounded,
                        'Work as',
                        profile.career?['profession']?.toString() ?? '',
                        (profile.career?['companyName']?.toString() ?? '') +
                            (profile.career?['experience'] != null &&
                                    profile.career!['experience']
                                        .toString()
                                        .isNotEmpty
                                ? ' · ${profile.career!['experience']}'
                                : ''),
                        color: SectionColors.career,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (profile.career?['salaryRange'] != null) ...[
                      _buildBasicRow(
                        Icons.attach_money_rounded,
                        'Income',
                        profile.career!['salaryRange'].toString(),
                        '',
                        color: SectionColors.career,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (profile.career?['employmentType'] != null) ...[
                      _buildBasicRow(
                        Icons.computer_rounded,
                        'Work style',
                        _formatEnumText(
                          profile.career!['employmentType'].toString(),
                        )!,
                        '',
                        color: SectionColors.career,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (profile.career?['ambition'] != null) ...[
                      _buildBasicRow(
                        Icons.trending_up_rounded,
                        'Ambition level',
                        profile.career!['ambition'].toString().toUpperCase(),
                        '',
                        color: SectionColors.career,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (profile.career?['bigDreams'] != null &&
                        profile.career!['bigDreams'].toString().isNotEmpty) ...[
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
                      Center(
                        child: Text(
                          profile.career!['bigDreams'].toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Slot 2: After CAREER
            if (profile.images.length > slot2Index) ...[
              _buildImageWithRose(context, profile.images[slot2Index]),
              const SizedBox(height: 16),
            ],

            // Second Prompt Card
            if (profile.prompts.length > 1) ...[
              _buildPromptCard(
                context,
                profile.prompts[1]['prompt'] ?? '',
                profile.prompts[1]['answer'] ?? '',
              ),
              const SizedBox(height: 16),
            ],

            // INTERESTS & HOBBIES Section
            if (profile.interests != null && profile.interests!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        final currentUserInterests = context
                            .watch<ProfileEditCubit>()
                            .state
                            .interests;

                        bool isMatch(String label) {
                          final cleanLabel = label.toLowerCase().trim();
                          return currentUserInterests.any((item) {
                            final parts = item.split(' ');
                            final textPart = parts.length > 1
                                ? parts.sublist(1).join(' ')
                                : item;
                            return textPart.toLowerCase().trim() == cleanLabel;
                          });
                        }

                        int commonCount = 0;
                        for (var interest in profile.interests!) {
                          String label = interest is String
                              ? interest
                              : (interest['answer']?.toString() ??
                                    interest['name']?.toString() ??
                                    'Interest');
                          if (isMatch(label)) commonCount++;
                        }

                        return Column(
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Divider(
                                      color: SectionColors.interests.icon
                                          .withOpacity(0.3),
                                      height: 1,
                                    ),
                                  ),
                                ),
                                if (commonCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: SectionColors.interests.bg,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$commonCount in common',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: SectionColors.interests.icon,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 12,
                              children: profile.interests!.map<Widget>((
                                interest,
                              ) {
                                String label = interest is String
                                    ? interest
                                    : (interest['answer']?.toString() ??
                                          interest['name']?.toString() ??
                                          'Interest');
                                return _buildInterestPill(
                                  _getInterestIcon(label),
                                  label,
                                  isMatch: isMatch(label),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // LIFESTYLE Section
            if (_hasValidData(profile.lifestyle)) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
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
                              color: SectionColors.lifestyle.icon.withOpacity(
                                0.3,
                              ),
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final double itemWidth =
                            (constraints.maxWidth - 12) / 2;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: profile.lifestyle!.map<Widget>((item) {
                            String question =
                                item['question']?.toString() ?? 'Lifestyle';
                            String option =
                                item['answer']?.toString() ??
                                item['option']?.toString() ??
                                '';
                            return _buildBentoPill(
                              _getLifestyleIcon(question),
                              question,
                              option,
                              itemWidth,
                              stacked: true,
                              color: SectionColors.lifestyle,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 16),

            // Slot 3: After LIFESTYLE
            if (profile.images.length > slot3Index) ...[
              _buildImageWithRose(context, profile.images[slot3Index]),
              const SizedBox(height: 16),
            ],

            // NETWORKING INTENT Section
            if (profile.networkingIntent != null &&
                profile.networkingIntent!.isNotEmpty) ...[
              _buildNetworkingIntentSection(profile.networkingIntent!),
              const SizedBox(height: 16),
            ],
            // FAMILY Section
            if (_hasFamilyData()) ...[
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
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
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
                    if (profile.family?['familyType'] != null ||
                        profile.family?['familyStatus'] != null) ...[
                      _buildBasicRow(
                        Icons.people_alt_outlined,
                        'Family type',
                        profile.family?['familyType']?.toString() ?? '',
                        profile.family?['familyStatus']?.toString() ?? '',
                        color: SectionColors.family,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (profile.family?['fatherOccupation'] != null ||
                        profile.family?['fatherOrganisation'] != null) ...[
                      _buildBasicRow(
                        Icons.person_outline,
                        'Father',
                        profile.family?['fatherOccupation']?.toString() ?? '',
                        profile.family?['fatherOrganisation']?.toString() ?? '',
                        color: SectionColors.family,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (profile.family?['motherOccupation'] != null ||
                        profile.family?['motherOrganisation'] != null) ...[
                      _buildBasicRow(
                        Icons.woman_outlined,
                        'Mother',
                        profile.family?['motherOccupation']?.toString() ?? '',
                        profile.family?['motherOrganisation']?.toString() ?? '',
                        color: SectionColors.family,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (profile.family?['siblings'] != null &&
                        (profile.family?['siblings'] as List).isNotEmpty) ...[
                      _buildBasicRow(
                        Icons.people_alt_outlined,
                        'Siblings',
                        _formatSiblings(
                          profile.family!['siblings'] as List<dynamic>,
                        ),
                        '',
                        color: SectionColors.family,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (profile.family?['familyHome'] != null ||
                        profile.family?['nativePlace'] != null) ...[
                      _buildBasicRow(
                        Icons.location_on_outlined,
                        'Family home',
                        profile.family?['familyHome']?.toString() ?? '',
                        profile.family?['nativePlace'] != null
                            ? 'Native: ${profile.family!['nativePlace']}'
                            : '',
                        color: SectionColors.family,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (profile.family?['familyIncome'] != null) ...[
                      _buildBasicRow(
                        Icons.account_balance_wallet_outlined,
                        'Family income',
                        profile.family!['familyIncome'].toString(),
                        '',
                        color: SectionColors.family,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 16),

            // Slot 4: After FAMILY
            if (profile.images.length > slot4Index) ...[
              _buildImageWithRose(context, profile.images[slot4Index]),
              const SizedBox(height: 16),
            ],

            // Third Prompt Card
            if (profile.prompts.length > 2) ...[
              _buildPromptCard(
                context,
                profile.prompts[2]['prompt'] ?? '',
                profile.prompts[2]['answer'] ?? '',
              ),
              const SizedBox(height: 16),
            ],

            // Bottom Slots: Extra photos below "We'll get along if..."
            if (profile.images.length > bottomIndexStart) ...[
              for (
                int i = bottomIndexStart;
                i < profile.images.length;
                i++
              ) ...[
                _buildImageWithRose(context, profile.images[i]),
                const SizedBox(height: 16),
              ],
            ],
          ], // Closes the else block for details
        ],
      ),
    );
  }

  Widget _buildPillTag(String text, Color dotColor, {VoidCallback? onTap}) {
    Widget content = Container(
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
    );

    return Expanded(
      child: onTap != null
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: content,
            )
          : content,
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

  Widget _buildNetworkingIntentSection(List<dynamic> networkingIntent) {
    // Group intents by question
    Map<String, List<String>> categories = {};
    String? inHerWords;

    for (var intent in networkingIntent) {
      String q = intent['question']?.toString() ?? 'OTHER';
      String a =
          intent['answer']?.toString() ?? intent['option']?.toString() ?? '';

      if (intent['description'] != null &&
          intent['description'].toString().isNotEmpty) {
        inHerWords ??= intent['description'].toString();
      }

      if (!categories.containsKey(q)) {
        categories[q] = [];
      }
      if (a.isNotEmpty) {
        categories[q]!.add(a);
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 57, 46, 38), // Soft Premium Mocha
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

          ...categories.entries.map((entry) {
            return _buildNetworkingCategory(
              entry.key.toUpperCase(),
              entry.value,
            );
          }).toList(),

          if (inHerWords != null) ...[
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
            Center(
              child: Text(
                inHerWords,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFBF5D2), // ivoryGlow
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ],
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

  Widget _buildImageWithRose(BuildContext context, String imageUrl) {
    return Container(
      width: double.infinity,
      height: 550,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: imageUrl.startsWith('http')
              ? NetworkImage(imageUrl) as ImageProvider
              : FileImage(File(imageUrl)),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
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
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 6,
            right: 2,
            child: GestureDetector(
              onTap: () {
                if (isSelfPreview) return;
                ComplimentingBottomSheet.show(
                  context,
                  type: 'PHOTO',
                  complimentingID: profile.id.toString(),
                  user_ID: profile.id.toString(),
                  profilemodel: profile,
                );
              },
              child: Container(
                width: 65,
                height: 65,
                child: ClipOval(
                  child: Image.asset(
                    'assets/final.png',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0.9, 0),
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

  Map<String, String> _getLoveLanguageData(String enumValue) {
    switch (enumValue.toUpperCase()) {
      case 'WORDS_OF_AFFIRMATION':
        return {
          'title': 'Words of affirmation',
          'subtitle': 'Compliments and encouragement mean the world to you.',
        };
      case 'QUALITY_TIME':
        return {
          'title': 'Quality time',
          'subtitle': 'Undivided attention and spending time together.',
        };
      case 'RECEIVING_GIFTS':
        return {
          'title': 'Receiving gifts',
          'subtitle': 'Thoughtful gifts make you feel truly special.',
        };
      case 'ACTS_OF_SERVICE':
        return {
          'title': 'Acts of service',
          'subtitle': 'Actions speak louder than words for you.',
        };
      case 'PHYSICAL_TOUCH':
        return {
          'title': 'Physical touch',
          'subtitle': 'Hugs, holding hands, and physical closeness.',
        };
      default:
        return {
          'title': enumValue.replaceAll('_', ' ').toLowerCase(),
          'subtitle': '',
        };
    }
  }

  Map<String, String> _getCommunicationData(String enumValue) {
    switch (enumValue.toUpperCase()) {
      case 'PHONE_CALLS_OVER_TEXTS':
        return {
          'title': 'Phone calls over texts',
          'subtitle': 'You prefer hearing their voice over reading messages.',
        };
      case 'TEXTS_OVER_PHONE_CALLS':
        return {
          'title': 'Texts over phone calls',
          'subtitle': 'You prefer quick messages throughout the day.',
        };
      case 'IN_PERSON_ONLY':
        return {
          'title': 'In person only',
          'subtitle': 'You prefer face-to-face conversations above all.',
        };
      case 'VIDEO_CALLS':
        return {
          'title': 'Video calls',
          'subtitle': 'You prefer seeing their face when talking.',
        };
      default:
        return {
          'title': enumValue.replaceAll('_', ' ').toLowerCase(),
          'subtitle': '',
        };
    }
  }

  String? _formatEnumText(String? text) {
    if (text == null || text.isEmpty) return text;
    return text
        .split('_')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  IconData _getLifestyleIcon(String question) {
    switch (question.toLowerCase().trim()) {
      case 'diet':
        return Icons.restaurant_menu_rounded;
      case 'drinking':
        return Icons.wine_bar_rounded;
      case 'smoking':
        return Icons.smoking_rooms_rounded;
      case 'travel':
        return Icons.flight_takeoff_rounded;
      case 'pets':
        return Icons.pets_rounded;
      case 'sleep':
        return Icons.nights_stay_rounded;
      case 'workout':
      case 'gym':
        return Icons.fitness_center_rounded;
      case 'social media':
        return Icons.tag_rounded;
      case 'hobbies':
        return Icons.palette_rounded;
      case 'weekend':
        return Icons.weekend_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  IconData _getInterestIcon(String interest) {
    final lower = interest.toLowerCase();
    if (lower.contains('nba') ||
        lower.contains('basketball') ||
        lower.contains('sports'))
      return Icons.sports_basketball_rounded;
    if (lower.contains('soccer') || lower.contains('football'))
      return Icons.sports_soccer_rounded;
    if (lower.contains('cricket')) return Icons.sports_cricket_rounded;
    if (lower.contains('tennis')) return Icons.sports_tennis_rounded;
    if (lower.contains('music') ||
        lower.contains('singing') ||
        lower.contains('guitar'))
      return Icons.music_note_rounded;
    if (lower.contains('art') ||
        lower.contains('painting') ||
        lower.contains('drawing'))
      return Icons.palette_rounded;
    if (lower.contains('reading') || lower.contains('book'))
      return Icons.menu_book_rounded;
    if (lower.contains('movie') ||
        lower.contains('cinema') ||
        lower.contains('film') ||
        lower.contains('netflix'))
      return Icons.movie_filter_rounded;
    if (lower.contains('travel') || lower.contains('trip'))
      return Icons.flight_rounded;
    if (lower.contains('food') ||
        lower.contains('cooking') ||
        lower.contains('baking'))
      return Icons.restaurant_rounded;
    if (lower.contains('coffee')) return Icons.local_cafe_rounded;
    if (lower.contains('photo') || lower.contains('camera'))
      return Icons.camera_alt_rounded;
    if (lower.contains('game') || lower.contains('gaming'))
      return Icons.videogame_asset_rounded;
    if (lower.contains('gym') ||
        lower.contains('fitness') ||
        lower.contains('workout'))
      return Icons.fitness_center_rounded;
    if (lower.contains('nature') ||
        lower.contains('hiking') ||
        lower.contains('mountain'))
      return Icons.landscape_rounded;
    if (lower.contains('tech') ||
        lower.contains('coding') ||
        lower.contains('program'))
      return Icons.computer_rounded;
    if (lower.contains('dance') || lower.contains('dancing'))
      return Icons.music_video_rounded;
    if (lower.contains('pet') || lower.contains('dog') || lower.contains('cat'))
      return Icons.pets_rounded;

    return Icons.star_border_rounded;
  }

  String _formatSiblings(List<dynamic> siblings) {
    if (siblings.isEmpty) return 'No siblings';
    if (siblings.length == 1) {
      final s = siblings.first;
      String relation = s['relation']?.toString() ?? 'Sibling';
      String marital = s['marital']?.toString() ?? '';
      String occupation = s['occupation']?.toString() ?? '';
      List<String> details = [];
      if (marital.isNotEmpty) details.add(marital);
      if (occupation.isNotEmpty) details.add(occupation);
      return details.isEmpty ? relation : '$relation — ${details.join(', ')}';
    }

    int brothers = 0;
    int sisters = 0;
    for (var s in siblings) {
      if (s['relation']?.toString().toLowerCase() == 'brother') brothers++;
      if (s['relation']?.toString().toLowerCase() == 'sister') sisters++;
    }

    List<String> parts = [];
    if (brothers > 0) parts.add('$brothers Brother${brothers > 1 ? 's' : ''}');
    if (sisters > 0) parts.add('$sisters Sister${sisters > 1 ? 's' : ''}');

    if (parts.isEmpty) return '${siblings.length} Siblings';
    return parts.join(', ');
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

  Widget _buildPromptCard(BuildContext context, String prompt, String answer) {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 15, top: 10, bottom: 24),
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
                  prompt.toUpperCase(),
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(right: 60.0, bottom: 0),
                child: Text(
                  answer,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                    height: 1.4,
                  ),
                ),
              ),
              Positioned(
                bottom: -18,
                right: -13,
                child: GestureDetector(
                  onTap: () {
                    if (isSelfPreview) return;
                    ComplimentingBottomSheet.show(
                      context,
                      type: 'PROMPT',
                      complimentingID: profile.id.toString(),
                      user_ID: profile.id.toString(),
                      profilemodel: profile,
                    );
                  },
                  child: Container(
                    width: 65,
                    height: 65,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/final.png',
                        fit: BoxFit.cover,
                        alignment: const Alignment(0.9, 0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardsStack extends StatelessWidget {
  final bool isPreview;
  final bool isSelfPreview;
  const _CardsStack({this.isPreview = false, this.isSelfPreview = false});

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

                  final widgetKey = ValueKey(
                    profile.id,
                  ); // Stable key instead of images.first

                  return isFront && !isPreview
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
        image: profile.images.isNotEmpty
            ? DecorationImage(
                image: profile.images.first.startsWith('http')
                    ? NetworkImage(profile.images.first) as ImageProvider
                    : FileImage(File(profile.images.first)),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              )
            : null,
        gradient: profile.images.isEmpty
            ? LinearGradient(
                colors: [const Color(0xFF2C2C32), const Color(0xFF18181B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Stack(
        children: [
          if (profile.images.isEmpty)
            const Positioned.fill(
              child: Center(
                child: Icon(
                  Icons.person_rounded,
                  size: 80,
                  color: Colors.white24,
                ),
              ),
            ),
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
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (!context.read<HomeBloc>().hasSwipedProfiles)
                  return const SizedBox.shrink();
                return GestureDetector(
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
                );
              },
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
              padding: const EdgeInsets.only(
                left: 16,
                right: 20,
                top: 20,
                bottom: 10,
              ),
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
                  const SizedBox(height: 3),
                  // Name & Age
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          profile.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                  const SizedBox(height: 2),
                  // Location
                  _buildInfoRow(Icons.location_on, profile.location),
                  // Job
                  _buildInfoRow(Icons.work, profile.job),
                  // Intent on Image
                  _buildInfoRow(Icons.favorite_rounded, profile.lookingFor),
                  if (profile.lookingFor.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 24, bottom: 4),
                      child: Text(
                        profile.lookingForSubtitle.isNotEmpty
                            ? profile.lookingForSubtitle
                            : _getLookingForSubtitle(profile.lookingFor),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color dotColor, {VoidCallback? onTap}) {
    Widget tag = Container(
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

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: tag,
      );
    }
    return tag;
  }

  Widget _buildInfoRow(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.bold,
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

class ProfileVideoPlayer extends StatefulWidget {
  final String videoPath;
  final bool isSelfPreview;
  final ProfileModel? profile;
  const ProfileVideoPlayer({
    super.key,
    required this.videoPath,
    this.isSelfPreview = false,
    this.profile,
  });

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
    if (widget.videoPath.startsWith('http')) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoPath),
      );
    } else if (widget.videoPath.startsWith('assets/')) {
      _controller = VideoPlayerController.asset(widget.videoPath);
    } else {
      _controller = VideoPlayerController.file(File(widget.videoPath));
    }
    _controller
        .initialize()
        .then((_) {
          _controller.setLooping(true);
          _controller.setVolume(_isMuted ? 0.0 : 1.0);
          // Video is initially paused, so we don't start the hide timer yet
          setState(() {});
        })
        .catchError((error) {
          AppLogger.e('HomeScreen', 'Video Init Error: $error', error: error);
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
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
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 6,
              right: 2,
              child: GestureDetector(
                onTap: () {
                  if (widget.isSelfPreview) return;
                  ComplimentingBottomSheet.show(
                    context,
                    type: 'VIDEO',
                    complimentingID: widget.profile!.id.toString(),
                    user_ID: widget.profile!.id.toString(),
                    profilemodel: widget.profile,
                  );
                },
                child: Container(
                  width: 65,
                  height: 65,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/final.png',
                      fit: BoxFit.cover,
                      alignment: const Alignment(0.9, 0),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
                overflow: isExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
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
                      color: Color(
                        0xFF831843,
                      ), // Matches ABOUT section burgundy
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
