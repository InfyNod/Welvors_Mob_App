import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text.dart';
import '../../widgets/primary_button.dart';
import '../../services/api_service.dart';

class AboutScreen extends StatefulWidget {
  final VoidCallback onNext;
  const AboutScreen({super.key, required this.onNext});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with AutomaticKeepAliveClientMixin  {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await ApiService.fetchOnboardingDetails('STORY');
    if (data != null && mounted) {
      setState(() {
        if (data['bio'] != null) {
          _controller.text = data['bio'];
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

    @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.pad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ABOUT YOU',
                            style: AppText.eyebrow.copyWith(
                              color: AppColors.pinkDeep,
                              fontSize: 11,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tell us your story.',
                            style: AppText.display.copyWith(fontSize: 32),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'A few honest lines about who you are and\nwhat you\'re looking for. This sits at the top of\nyour profile.',
                            style: AppText.sub.copyWith(
                              color: AppColors.ink60,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'About you',
                            style: AppText.body.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _controller,
                            maxLength: 300,
                            maxLines: 5,
                            onChanged: (val) {
                              setState(() {}); // To update char counter
                            },
                            cursorColor: AppColors.pinkDeep,
                            style: AppText.body.copyWith(fontSize: 15),
                            decoration: InputDecoration(
                              hintText:
                                  'Building products by day,\nplanning my next trek by night.\nLooking for someone equally\ndriven and equally curious...',
                              hintMaxLines: 4,
                              hintStyle: AppText.body.copyWith(
                                color: AppColors.muted.withOpacity(0.6),
                                fontSize: 15,
                                height: 1.4,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(16),
                              counterText:
                                  '', // Hide default counter, we'll build our own
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.line,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.pinkDeep,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${_controller.text.length} / 300',
                              style: AppText.body.copyWith(
                                color: AppColors.muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.pad,
                      16,
                      AppDimens.pad,
                      0,
                    ),
                    child: Column(
                      children: [
                        PrimaryButton(
                          _isSubmitting ? 'Saving...' : 'Continue',
                          onTap: (_isSubmitting || _controller.text.trim().isEmpty)
                              ? null
                              : () async {
                                  setState(() => _isSubmitting = true);

                                  final error = await ApiService.submitBio(
                                    _controller.text.trim(),
                                  );

                                  setState(() => _isSubmitting = false);

                                  if (error != null) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(error)),
                                      );
                                    }
                                  } else {
                                    widget.onNext();
                                  }
                                },
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _isSubmitting ? null : widget.onNext,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.ink60,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: Text(
                            'Skip for now',
                            style: AppText.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink60,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
