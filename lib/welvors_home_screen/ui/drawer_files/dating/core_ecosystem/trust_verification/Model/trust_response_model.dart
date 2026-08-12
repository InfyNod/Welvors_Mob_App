import 'verfication.dart';

class TrustScoreModel {
  final int score;
  final int maxScore;
  final int nextPoints;
  final int remainingPoints;
  final double progress;
  final String nextHint;
  final String badgeLabel;
  final String remainingLabel;

  const TrustScoreModel({
    required this.score,
    required this.maxScore,
    required this.nextPoints,
    required this.remainingPoints,
    required this.progress,
    this.nextHint = 'Verify Government ID next for\n +10 pts',
    this.badgeLabel = 'Verified Profiles Only',
    this.remainingLabel = '+80 pts to go',
  });

  TrustScoreModel copyWith({
    int? score,
    int? maxScore,
    int? nextPoints,
    int? remainingPoints,
    double? progress,
    String? nextHint,
    String? badgeLabel,
    String? remainingLabel,
  }) {
    return TrustScoreModel(
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      nextPoints: nextPoints ?? this.nextPoints,
      remainingPoints: remainingPoints ?? this.remainingPoints,
      progress: progress ?? this.progress,
      nextHint: nextHint ?? this.nextHint,
      badgeLabel: badgeLabel ?? this.badgeLabel,
      remainingLabel: remainingLabel ?? this.remainingLabel,
    );
  }
}

class TrustResponseModel {
  final TrustScoreModel trustScore;
  final List<VerificationSectionModel> sections;
  final String safetyTitle;
  final String safetySubtitle;

  const TrustResponseModel({
    required this.trustScore,
    required this.sections,
    this.safetyTitle = 'Your data is always safe',
    this.safetySubtitle =
        'Documents are encrypted, never shared with other users, and deleted after processing.',
  });

  TrustResponseModel copyWith({
    TrustScoreModel? trustScore,
    List<VerificationSectionModel>? sections,
    String? safetyTitle,
    String? safetySubtitle,
  }) {
    return TrustResponseModel(
      trustScore: trustScore ?? this.trustScore,
      sections: sections ?? this.sections,
      safetyTitle: safetyTitle ?? this.safetyTitle,
      safetySubtitle: safetySubtitle ?? this.safetySubtitle,
    );
  }
}
