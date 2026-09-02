import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text.dart';
import '../../widgets/primary_button.dart';
import 'user_data.dart';
import '../../services/api_service.dart';

class ReviewScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const ReviewScreen({super.key, required this.onFinish});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> with AutomaticKeepAliveClientMixin  {
  bool _isLoading = false;

  Future<void> _handleFinish() async {
    setState(() => _isLoading = true);
    final success = await ApiService.completeOnboarding();
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        widget.onFinish();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to complete onboarding. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatValue(String text) {
    if (text.isEmpty) return 'Not specified';
    final replaced = text.replaceAll('_', ' ');
    if (replaced.isEmpty) return '';
    return replaced[0].toUpperCase() + replaced.substring(1);
  }

  Widget _buildRow(String label, String value, {bool isLast = false}) {
    final displayValue = _formatValue(value);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: AppColors.line.withOpacity(0.5)),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppText.body.copyWith(
                color: AppColors.ink60,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              displayValue,
              textAlign: TextAlign.right,
              style: AppText.body.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterests() {
    final interests = userData.interests;
    if (interests.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.line.withOpacity(0.5)),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: interests.map((i) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.pinkDeep.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(i['emoji']!, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  i['label']!,
                  style: AppText.body.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pinkDeep,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

    @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ALMOST DONE',
                    style: AppText.eyebrow.copyWith(
                      color: AppColors.pinkDeep,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Looks good?',
                    style: AppText.display.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Here\'s your profile so far. You can change\nanything later.',
                    style: AppText.sub.copyWith(
                      color: AppColors.ink60,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppColors.shadow,
                      border: Border.all(
                        color: AppColors.line.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2B89B),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.ink.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  image: userData.photos.isNotEmpty
                                      ? DecorationImage(
                                          image: FileImage(
                                            userData.photos.first!,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${userData.name}, ${userData.age}',
                                      style: AppText.body.copyWith(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      userData.career.isNotEmpty
                                          ? userData.career
                                          : 'Ready to date',
                                      style: AppText.body.copyWith(
                                        color: AppColors.ink60,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.check,
                                            color: Colors.green,
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Phone verified',
                                            style: AppText.body.copyWith(
                                              color: Colors.green,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 1,
                          color: AppColors.line.withOpacity(0.5),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              _buildRow('Gender', userData.gender),
                              _buildRow('Interested in', userData.interestedIn),
                              _buildRow('Looking for', userData.intentions),
                              _buildRow(
                                'Lifestyle',
                                userData.lifestyle.isEmpty
                                    ? 'Not specified'
                                    : userData.lifestyle.join(' · '),
                              ),
                              _buildRow('Education', userData.education),
                              _buildRow(
                                'Photos',
                                '${userData.photoCount} added',
                              ),
                              _buildInterests(),
                              _buildRow(
                                'Location',
                                userData.location,
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pad,
            8,
            AppDimens.pad,
            24,
          ),
          child: PrimaryButton(
            'Create my profile', 
            onTap: _isLoading ? null : _handleFinish,
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }
}
