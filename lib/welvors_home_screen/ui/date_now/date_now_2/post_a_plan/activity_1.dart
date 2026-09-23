import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'details_2.dart';
import 'location_3.dart';
import 'review_4.dart';
import 'success_5.dart';
import 'bloc/post_plan_bloc.dart';
import 'bloc/post_plan_event.dart';
import 'bloc/post_plan_state.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/date_api_service/date_now_api_service.dart';

class Activity1Screen extends StatelessWidget {
  final PostPlanState? initialState;
  final int initialStep;

  const Activity1Screen({Key? key, this.initialState, this.initialStep = 1})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = PostPlanBloc(initialState: initialState);
        if (initialStep != 1) {
          bloc.add(JumpToStepEvent(initialStep));
        }
        return bloc;
      },
      child: const Activity1ScreenBody(),
    );
  }
}

class Activity1ScreenBody extends StatefulWidget {
  const Activity1ScreenBody({Key? key}) : super(key: key);

  @override
  _Activity1ScreenBodyState createState() => _Activity1ScreenBodyState();
}

class _Activity1ScreenBodyState extends State<Activity1ScreenBody> {
  // Step 1 Data (local state until continue is pressed)
  String? _selectedActivity;
  String? _selectedActivityId;
  String? _selectedActivityImage;
  List<dynamic> _activities = [];
  bool _isLoading = true;
  bool _isCreatingPlan = false;

  @override
  void initState() {
    super.initState();
    _fetchActivities();
    // Pre-fill if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<PostPlanBloc>().state;
      if (state.selectedActivityName != null) {
        setState(() {
          _selectedActivity = state.selectedActivityName;
          _selectedActivityImage = state.selectedActivityImage;
        });
      }
    });
  }

  Future<void> _fetchActivities() async {
    final activities = await DateNowApiService.getOptions('ACTIVITY');
    if (mounted) {
      setState(() {
        _activities = activities ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostPlanBloc, PostPlanState>(
      builder: (context, state) {
        final currentStep = state.currentStep;

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
                onTap: () {
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black87,
                    size: 16,
                  ),
                ),
              ),
            ),
            title: const Text(
              'Post a Plan',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stepper
                if (currentStep < 5) _buildStepper(currentStep),

                // Main Content
                Expanded(
                  child: currentStep == 1
                      ? _buildStep1Content(context)
                      : currentStep == 2
                      ? Details2View(
                          onContinue: () {
                            // Details2View updates BLoC internally, we just jump
                          },
                          onBack: () {
                            context.read<PostPlanBloc>().add(
                              JumpToStepEvent(1),
                            );
                          },
                        )
                      : currentStep == 3
                      ? Location3View(
                          onContinue: () {
                            // Location3View updates BLoC internally, we just jump
                          },
                          onBack: () {
                            context.read<PostPlanBloc>().add(
                              JumpToStepEvent(2),
                            );
                          },
                        )
                      : currentStep == 4
                      ? Review4View(
                          onBack: () {
                            context.read<PostPlanBloc>().add(
                              JumpToStepEvent(3),
                            );
                          },
                        )
                      : Success5View(
                          onBackToDateNow: () {
                            Navigator.pop(context);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9EE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFDE8C4)),
        ),
        child: Row(
          children: [
            const Text('📋', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date Plan Balance',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF9E7019),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '3 plans left • any type',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF9E7019).withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showTopUpBottomSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFDE8C4)),
                ),
                child: const Text(
                  '+ Top up',
                  style: TextStyle(
                    color: Color(0xFF9E7019),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTopUpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Top up Date Plans',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Paid from your Welvors Wallet · you have 🪙 2,240 coins.\nEach plan lets you post once · any activity type.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTopUpOption('1 plan', '100 coins'),
                const SizedBox(height: 10),
                _buildTopUpOption('3 plans', '270 coins'),
                const SizedBox(height: 10),
                _buildTopUpOption('10 plans', '800 coins'),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopUpOption(String title, String coins) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text('🪙 ', style: TextStyle(fontSize: 12)),
                    Text(
                      coins,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // Buy action
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE43A6A),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Buy',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Content(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Balance Banner
              _buildBalanceBanner(),
              const SizedBox(height: 16),

              // Header Texts
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "What's the plan?",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Pick what you want to do right now. People nearby will see it live.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Choose an activity',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Grid
              _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE43A6A),
                        ),
                      ),
                    )
                  : GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 20,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: _activities.length,
                      itemBuilder: (context, index) {
                        final act = _activities[index];
                        final isSelected = _selectedActivity == act['label'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedActivity = act['label'];
                              _selectedActivityId = act['id'];
                              _selectedActivityImage = act['icon'];
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: isSelected
                                  ? Border.all(
                                      color: const Color(0xFFE43A6A),
                                      width: 2.5,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 13,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: isSelected
                                        ? const BorderRadius.vertical(
                                            top: Radius.circular(13),
                                          )
                                        : const BorderRadius.vertical(
                                            top: Radius.circular(16),
                                          ),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                         CachedNetworkImage(
                                           imageUrl: act['icon'] ?? '',
                                           fit: BoxFit.cover,
                                           placeholder: (context, url) => Container(
                                             color: Colors.grey.shade200,
                                           ),
                                           errorWidget:
                                               (context, url, error) =>
                                                   const Icon(
                                                     Icons.error,
                                                     color: Colors.grey,
                                                   ),
                                         ),
                                        if (isSelected)
                                          Container(
                                            color: const Color(
                                              0xFFE43A6A,
                                            ).withOpacity(0.3),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    act['label'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w900
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? const Color(0xFFE43A6A)
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),

        // Bottom Continue Button (Step 1)
        Container(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20,
            top: 12,
          ),
          child: SafeArea(
            top: false,
            child: GestureDetector(
              onTap: (_selectedActivity != null && !_isCreatingPlan)
                  ? () async {
                      setState(() {
                        _isCreatingPlan = true;
                      });
                      try {
                        final currentState = context.read<PostPlanBloc>().state;
                        String finalPlanId = currentState.planId ?? '';
                        bool isSuccess = true;

                        if (currentState.planId != null && currentState.planId!.isNotEmpty) {
                          // EDIT MODE
                          if (_selectedActivityId != null) {
                            final response = await DateNowApiService.patchPlanActivity(currentState.planId!, {
                              "activityId": _selectedActivityId,
                            });
                            isSuccess = response != null && response['success'] == true;
                          }
                        } else {
                          // CREATE MODE
                          final response = await DateNowApiService.postPlan({
                            "activityId": _selectedActivityId,
                          });
                          if (response != null && response['success'] == true) {
                            finalPlanId = response['data']['id'];
                          } else {
                            isSuccess = false;
                          }
                        }

                        if (isSuccess) {
                          if (mounted) {
                            context.read<PostPlanBloc>().add(
                              UpdateStep1Event(
                                activityName: _selectedActivity!,
                                activityImage: _selectedActivityImage ?? '',
                                planId: finalPlanId,
                              ),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to create plan. Please try again.',
                                ),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'An error occurred. Please try again.',
                              ),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isCreatingPlan = false;
                          });
                        }
                      }
                    }
                  : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _selectedActivity != null
                      ? const Color(0xFFE43A6A)
                      : const Color(0xFFF2EFEA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _isCreatingPlan
                    ? const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              color: _selectedActivity != null
                                  ? Colors.white
                                  : Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: _selectedActivity != null
                                ? Colors.white
                                : Colors.grey,
                            size: 18,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepper(int currentStep) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          _buildStep(
            1,
            'ACTIVITY',
            status: currentStep == 1 ? 'active' : 'completed',
          ),
          _buildLine(isCompleted: currentStep > 1),
          _buildStep(
            2,
            'DETAILS',
            status: currentStep == 2
                ? 'active'
                : (currentStep > 2 ? 'completed' : 'pending'),
          ),
          _buildLine(isCompleted: currentStep > 2),
          _buildStep(
            3,
            'LOCATION',
            status: currentStep == 3
                ? 'active'
                : (currentStep > 3 ? 'completed' : 'pending'),
          ),
          _buildLine(isCompleted: currentStep > 3),
          _buildStep(
            4,
            'REVIEW',
            status: currentStep == 4 ? 'active' : 'pending',
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int step, String label, {required String status}) {
    Color circleColor;
    Color textColor;
    Widget innerWidget;

    if (status == 'completed') {
      circleColor = const Color(0xFFE43A6A);
      textColor = const Color(0xFFE43A6A);
      innerWidget = const Icon(Icons.check, color: Colors.white, size: 16);
    } else if (status == 'active') {
      circleColor = Colors.black;
      textColor = Colors.black;
      innerWidget = Text(
        step.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    } else {
      circleColor = const Color(0xFFF2F2F2);
      textColor = Colors.grey;
      innerWidget = Text(
        step.toString(),
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(shape: BoxShape.circle, color: circleColor),
          child: Center(child: innerWidget),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLine({required bool isCompleted}) {
    return Expanded(
      child: Container(
        height: 2,
        color: isCompleted ? const Color(0xFFE43A6A) : Colors.grey.shade300,
        margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      ),
    );
  }
}
