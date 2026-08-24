import '../../export.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: InkWell(
            onTap: () => Navigator.pop(context),
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
          'Trust & Verification',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 19,
          ),
        ),
      ),
      body: BlocBuilder<TrustBloc, TrustState>(
        builder: (context, state) {
          if (state is TrustLoading || state is TrustInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TrustError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<TrustBloc>().add(const LoadTrustData()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is TrustLoaded) {
            return _TrustBody(data: state.data);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _TrustBody extends StatelessWidget {
  const _TrustBody({required this.data});

  final TrustResponseModel data;

  @override
  Widget build(BuildContext context) {
    final score = data.trustScore;

    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        TrustScoreCard(
          score: score.score,
          maxScore: score.maxScore,
          nextPoints: score.nextPoints,
          remainingPoints: score.remainingPoints,
          progress: score.progress,
          nextHint: score.nextHint,
          badgeLabel: score.badgeLabel,
          remainingLabel: score.remainingLabel,
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < data.sections.length; i++) ...[
          _VerificationSectionView(section: data.sections[i], sectionIndex: i),
          if (i < data.sections.length - 1) const SizedBox(height: 24),
        ],
        hSized20,
        _SafetyBanner(title: data.safetyTitle, subtitle: data.safetySubtitle),
        hSized20,
      ],
    );
  }
}

class _VerificationSectionView extends StatefulWidget {
  const _VerificationSectionView({
    required this.section,
    required this.sectionIndex,
  });

  final VerificationSectionModel section;
  final int sectionIndex;

  @override
  State<_VerificationSectionView> createState() =>
      _VerificationSectionViewState();
}

class _VerificationSectionViewState extends State<_VerificationSectionView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  bool _hasAnimated = false;
  @override
  void initState() {
    super.initState();

    final progress = widget.section.max == 0
        ? 0.0
        : (widget.section.min / widget.section.max).clamp(0.0, 1.0);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final section = widget.section;

    return Column(
      children: [
        VerificationTile(
          index: section.index,
          counttextboxcolor: section.countTextBoxColor,
          title: section.title,
          subtitle: section.subtitle,
          verified: section.verified,
          verifiedColor: section.verifiedColor,
          buttonfirstColor: section.buttonFirstColor,
          buttonsecondColor: section.buttonSecondColor,
          buttontextColor: section.buttonTextColor,
          buttontext: section.buttonText,
        ),

        hSized15,

        // Animated Progress
        VisibilityDetector(
          key: Key('trust-progress-${widget.sectionIndex}'),
          onVisibilityChanged: (info) {
            if (info.visibleFraction > 0.1 && !_hasAnimated) {
              _hasAnimated = true;
              _controller.forward();
            }
          },
          child: AnimatedBuilder(
            animation: _progressAnimation,
            child: Text(
              section.progressLabel,
              style: const TextStyle(
                color: Color(0xff9a9298),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            builder: (context, child) {
              return Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 7,
                      decoration: BoxDecoration(
                        color: Mycolor.grey1,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  child!,
                ],
              );
            },
          ),
        ),
        hSized20,

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 10,
                spreadRadius: 1,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: VerificationCard(
              items: section.items,
              onVerifyItem: (itemIndex) {
                context.read<TrustBloc>().add(
                  VerifyItemRequested(
                    sectionIndex: widget.sectionIndex,
                    itemIndex: itemIndex,
                  ),
                );
              },
            ),
          ),
        ),

        hSized20,

        Container(
          decoration: BoxDecoration(
            color: section.tipBackground,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(15),
          child: Center(
            child: Text(
              section.tip,
              style: TextStyle(
                color: section.tipTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SafetyBanner extends StatelessWidget {
  const _SafetyBanner({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xfff7f0f0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('🔒', style: TextStyle(fontSize: 18)),
            ),
          ),
          wSized10,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Mycolor.grey1,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
