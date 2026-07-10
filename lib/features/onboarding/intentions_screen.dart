import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text.dart';
import '../../widgets/primary_button.dart';
import '../../services/api_service.dart';
import 'user_data.dart';

class IntentionsScreen extends StatefulWidget {
  final VoidCallback onNext;
  const IntentionsScreen({super.key, required this.onNext});

  @override
  State<IntentionsScreen> createState() => _IntentionsScreenState();
}

class _IntentionsScreenState extends State<IntentionsScreen> {
  String? _selectedIntention;
  String _apiTitle = '';
  String _apiDescription = '';
  List<Map<String, dynamic>> _intentions = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchIntentions();
  }

  Future<void> _fetchIntentions() async {
    final response = await ApiService.fetchIntentions();
    if (mounted) {
      setState(() {
        if (response.isNotEmpty) {
          if (response['title'] != null && response['title'].toString().isNotEmpty) {
            _apiTitle = response['title'];
          }
          if (response['description'] != null && response['description'].toString().isNotEmpty) {
            _apiDescription = response['description'].toString().replaceAll('"', '');
          }
          _intentions = response['options'] ?? [];
        }
        _isLoading = false;
      });
    }
  }

  bool get _isFormValid => _selectedIntention != null;

  Widget _buildCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pinkSoft.withOpacity(0.5)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.pinkDeep : AppColors.line,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.body.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.pinkDeep : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppText.sub.copyWith(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.pinkDeep : AppColors.line,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'YOUR INTENTIONS',
                  style: AppText.eyebrow.copyWith(
                    color: AppColors.pinkDeep,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _apiTitle,
                  style: AppText.display.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  _apiDescription,
                  style: AppText.body.copyWith(
                    color: AppColors.ink60,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: AppColors.pinkDeep),
                  )
                else
                  ..._intentions.map((intention) {
                    return _buildCard(
                      title: intention['title'] ?? '',
                      subtitle: intention['subtitle'] ?? '',
                      isSelected: _selectedIntention == intention['title'],
                      onTap: () {
                        setState(() {
                          _selectedIntention = intention['title'];
                        });
                      },
                    );
                  }),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppDimens.pad, 16, AppDimens.pad, 20),
          child: PrimaryButton(
            _isSaving ? 'Saving...' : 'Continue',
            onTap: _isFormValid && !_isLoading && !_isSaving
                ? () async {
                    setState(() => _isSaving = true);

                    userData.intentions = _selectedIntention ?? 'A long-term relationship';
                    
                    // Simulate API delay
                    await Future.delayed(const Duration(seconds: 1));

                    if (mounted) {
                      setState(() => _isSaving = false);
                      widget.onNext();
                    }
                  }
                : null,
          ),
        ),
      ],
    );
  }
}
