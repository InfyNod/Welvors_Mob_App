import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../filter_bloc/filter_bloc.dart';
import '../filter_bloc/filter_event.dart';

class TrustScoreScreen extends StatefulWidget {
  const TrustScoreScreen({super.key});

  @override
  State<TrustScoreScreen> createState() => _TrustScoreScreenState();
}

class _TrustScoreScreenState extends State<TrustScoreScreen> {
  RangeValues _currentRangeValues = const RangeValues(0, 20);

  @override
  void initState() {
    super.initState();
    final currentState = context.read<FilterBloc>().state;
    _currentRangeValues = RangeValues(
      currentState.minTrustScore,
      currentState.maxTrustScore,
    );
  }

  void _onDone() {
    context.read<FilterBloc>().add(
      UpdateTrustScore(
        minTrustScore: _currentRangeValues.start,
        maxTrustScore: _currentRangeValues.end,
      ),
    );
    Navigator.pop(context);
  }

  Widget _buildTopCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF25A7A), Color(0xFFC72449)], // Pink/Red gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC72449).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 20),
              duration: const Duration(seconds: 1),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: value / 100,
                      strokeWidth: 4,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                    Center(
                      child: Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR TRUST SCORE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Basic verified',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'You can browse members verified up to 20 - reach 21 to unlock the next layer',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRaiseTrustButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'Raise my trust score →',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE43A6A),
          ),
        ),
      ),
    );
  }

  Widget _buildRangeSlider() {
    return Column(
      children: [
        Center(
          child: Text(
            '${_currentRangeValues.start.round()} – ${_currentRangeValues.end.round()}',
            style: const TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'Times New Roman', // matching premium numbers
            ),
          ),
        ),
        const SizedBox(height: 0),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFE43A6A),
            inactiveTrackColor: Colors.grey.shade200,
            trackHeight: 4.0,
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 10,
              elevation: 4,
            ),
            overlayColor: const Color(0xFFE43A6A).withValues(alpha: 0.2),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
            activeTickMarkColor: Colors.transparent,
            inactiveTickMarkColor: Colors.transparent,
          ),
          child: RangeSlider(
            values: _currentRangeValues,
            min: 0,
            max: 100,
            divisions: 100,
            onChanged: (RangeValues values) {
              setState(() {
                double newStart = values.start;
                double newEnd = values.end;

                // Restrict max selectable value to 20
                if (newEnd > 20) newEnd = 20;
                if (newStart > 20) newStart = 20; // just in case

                _currentRangeValues = RangeValues(newStart, newEnd);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLayerCard({
    required String icon,
    required String title,
    required String range,
    required String subtitle,
    required String badgeText,
    required bool isInRange,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isInRange ? const Color(0xFFE43A6A) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 12),
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        range,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: isInRange ? const Color(0xFFE43A6A) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isInRange ? Colors.white : Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 70,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Trust score',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: _onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE43A6A),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildTopCard(),
              const SizedBox(height: 20),
              _buildRaiseTrustButton(),
              const SizedBox(height: 20),
              _buildRangeSlider(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'THE 4 VERIFICATION LAYERS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              _buildLayerCard(
                icon: '📱',
                title: 'Basic verified',
                range: '1–20',
                subtitle: 'Mobile, email & city confirmed — stops fake signups',
                badgeText: 'In your range',
                isInRange: true,
              ),
              _buildLayerCard(
                icon: '🪪',
                title: 'Identity verified',
                range: '21–40',
                subtitle: 'Government ID, selfie match & live video check',
                badgeText: 'Needs 21+ score',
                isInRange: false,
              ),
              _buildLayerCard(
                icon: '🎓',
                title: 'High trust',
                range: '41–70',
                subtitle: 'Education & profession verified by our team',
                badgeText: 'Needs 41+ score',
                isInRange: false,
              ),
              _buildLayerCard(
                icon: '👑',
                title: 'Platinum verified',
                range: '71–100',
                subtitle: 'Background check, income proof & emergency contact',
                badgeText: 'Needs 71+ score',
                isInRange: false,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
