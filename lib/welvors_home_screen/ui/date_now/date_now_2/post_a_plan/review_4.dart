import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/post_plan_bloc.dart';
import 'bloc/post_plan_event.dart';
import 'bloc/post_plan_state.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/date_api_service/date_now_api_service.dart';

class Review4View extends StatefulWidget {
  final VoidCallback onBack;

  const Review4View({Key? key, required this.onBack}) : super(key: key);

  @override
  State<Review4View> createState() => _Review4ViewState();
}

class _Review4ViewState extends State<Review4View> {
  bool _isPublishing = false;

  Future<void> _submitPublish(BuildContext context, PostPlanState state) async {
    final planId = state.planId;
    if (planId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan ID is missing. Please restart.')));
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      final response = await DateNowApiService.publishPlan(planId);
      if (response != null) {
        if (mounted) {
          context.read<PostPlanBloc>().add(JumpToStepEvent(5));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to publish plan. Please try again.')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An error occurred. Please try again.')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostPlanBloc, PostPlanState>(
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children: [
                  const Text(
                    "Review your plan",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "This is exactly how people near you will see your plan.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Image Card
                  Container(
                    width: double.infinity,
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      image: DecorationImage(
                        image: NetworkImage(
                          state.selectedActivityImage ??
                              'https://images.unsplash.com/photo-1544148103-0773bf10d330?auto=format&fit=crop&w=800&q=80',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Gradient Overlay for text readability
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.5),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.9),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Top Badges
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2EAA5F), // Green
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'Live · ${state.locationName.isNotEmpty ? state.locationName : 'Starbucks Reserve'}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  children: [
                                    Text('📍', style: TextStyle(fontSize: 12)),
                                    SizedBox(width: 4),
                                    Text(
                                      "You're here",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Bottom Details
                        Positioned(
                          bottom: 24,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _buildImageChip('📅', state.whenDate),
                                  const SizedBox(width: 8),
                                  _buildImageChip(
                                    '⏰',
                                    state.time?.format(context) ?? '5:30 PM',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildImageChip(
                                    _getActivityEmoji(
                                      state.selectedActivityName ?? '',
                                    ),
                                    state.selectedActivityName ?? 'Dinner',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                state.title.isNotEmpty
                                    ? state.title
                                    : 'Coffee & deep talks',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text(
                                    '🤝 ',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${state.whoPays ?? 'Split (TTMM)'} · 👥 ${state.groupSize ?? '1 person'}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Summary Group 1 (Activity, Venue, When, Bill, Group)
                  _buildSummaryItem(
                    'Activity',
                    '${_getActivityEmoji(state.selectedActivityName ?? '')} ${state.selectedActivityName ?? 'Dinner'}',
                    () => context.read<PostPlanBloc>().add(JumpToStepEvent(1)),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryItem(
                    'Venue',
                    '${state.locationName} · ${state.locationSubtitle}',
                    () => context.read<PostPlanBloc>().add(JumpToStepEvent(3)),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryItem(
                    'When',
                    '${state.whenDate} · ${state.time?.format(context) ?? '5:30 PM'} · ${state.howLong ?? '1 hour'}',
                    () => context.read<PostPlanBloc>().add(JumpToStepEvent(3)),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryItem(
                    'Bill',
                    state.whoPays ?? 'Split (TTMM)',
                    () => context.read<PostPlanBloc>().add(JumpToStepEvent(3)),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryItem(
                    'Group',
                    state.groupSize ?? '1 person',
                    () => context.read<PostPlanBloc>().add(JumpToStepEvent(3)),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryItem(
                    'Who can request',
                    state.whoCanRequest ?? 'Anyone',
                    () => context.read<PostPlanBloc>().add(JumpToStepEvent(3)),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryItem(
                    'Visible to',
                    state.visibility,
                    () => context.read<PostPlanBloc>().add(JumpToStepEvent(3)),
                  ),
                  const SizedBox(height: 32),

                  // Final Configurations
                  const Text(
                    'Who can join',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildJoinChip('1 person', state),
                      const SizedBox(width: 8),
                      _buildJoinChip('2 people', state),
                      const SizedBox(width: 8),
                      _buildJoinChip('Small group', state),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Toggles
                  _buildToggle(
                    'Verified members only',
                    'Only ID-verified people can request to join',
                    state.verifiedMembersOnly,
                    (val) => context.read<PostPlanBloc>().add(
                      UpdateReviewSettingsEvent(verifiedMembersOnly: val),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildToggle(
                    'Auto-approve requests',
                    'Off = you approve each person yourself',
                    state.autoApproveRequests,
                    (val) => context.read<PostPlanBloc>().add(
                      UpdateReviewSettingsEvent(autoApproveRequests: val),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Alerts
                  _buildInfoCard(
                    emoji: '🛡️',
                    baseColor: const Color(0xFF2EAA5F), // Green
                    title: 'Privacy Protected',
                    subtitle:
                        'Your exact location stays hidden. Requesters only see the public venue, and you approve who joins.',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    emoji: '📋',
                    baseColor: const Color(0xFF95691F),
                    customBgColor: const Color(0xFFFFF4E0),
                    customTextColor: const Color(0xFF95691F),
                    title: 'Uses 1 Date Plan',
                    subtitle:
                        'This will be deducted from your balance. You have 3 plans left.',
                  ),
                  const SizedBox(height: 0),
                ],
              ),
            ),

            // Bottom Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade100, width: 1),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _isPublishing
                          ? null
                          : () {
                              _submitPublish(context, state);
                            },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _isPublishing 
                              ? const Color.fromARGB(255, 224, 222, 220)
                              : const Color(0xFFE43A6A),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: _isPublishing 
                              ? [] 
                              : [
                                  BoxShadow(
                                    color: const Color(0xFFE43A6A).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: _isPublishing
                            ? const Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('🔴', style: TextStyle(fontSize: 12)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Go live · uses 1 plan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: widget.onBack,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Center(
                          child: Text(
                            'Back',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
      },
    );
  }

  Widget _buildImageChip(String icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, VoidCallback onEdit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onEdit,
            child: const Text(
              'Edit',
              style: TextStyle(
                color: Color(0xFFE43A6A),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinChip(String label, PostPlanState state) {
    final isSelected = state.finalWhoCanJoin == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<PostPlanBloc>().add(
            UpdateReviewSettingsEvent(finalWhoCanJoin: label),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFE43A6A).withOpacity(0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFE43A6A)
                  : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFE43A6A) : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFFE43A6A),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String emoji,
    required Color baseColor,
    required String title,
    required String subtitle,
    Color? customBgColor,
    Color? customTextColor,
  }) {
    final bgColor = customBgColor ?? baseColor.withOpacity(0.04);
    final textColor = customTextColor ?? baseColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textColor.withOpacity(0.75),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getActivityEmoji(String name) {
    switch (name.toLowerCase()) {
      case 'coffee':
        return '☕';
      case 'dinner':
        return '🍝';
      case 'drinks':
        return '🍸';
      case 'walk':
        return '🚶';
      case 'brunch':
        return '🥞';
      case 'movie':
        return '🍿';
      case 'dessert':
        return '🍦';
      case 'gallery':
        return '🎨';
      case 'live music':
        return '🎸';
      case 'beach':
        return '🏖️';
      case 'shopping':
        return '🛍️';
      case 'games':
        return '🎲';
      default:
        return '✨';
    }
  }
}
