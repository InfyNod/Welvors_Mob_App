import '../../../export.dart';

class VerificationStepper extends StatelessWidget {
  final int currentStep;

  const VerificationStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StepItem(step: 1, title: 'Document', currentStep: currentStep),
          _Line(completed: currentStep > 1),
          _StepItem(step: 2, title: 'Sign in', currentStep: currentStep),
          _Line(completed: currentStep > 2),
          _StepItem(step: 3, title: 'Consent', currentStep: currentStep),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int step;
  final String title;
  final int currentStep;

  const _StepItem({
    required this.step,
    required this.title,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final completed = step < currentStep;
    final active = step == currentStep;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed
                  ? const Color(0xFF2FA36B)
                  : active
                  ? Colors.white
                  : const Color(0xFFF7F4F5),
              border: active
                  ? Border.all(color: const Color(0xFFE72B7A), width: 3)
                  : null,
            ),
            child: Center(
              child: completed
                  ? const Icon(Icons.check, color: Colors.white, size: 23)
                  : Text(
                      '$step',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: active
                            ? const Color(0xFFE72B7A)
                            : const Color(0xFF9B9499),
                      ),
                    ),
            ),
          ),
          hSized10,
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: completed
                  ? const Color(0xFF2FA36B)
                  : active
                  ? const Color(0xFFE72B7A)
                  : const Color(0xFF9B9499),
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final bool completed;

  const _Line({required this.completed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 2,
      margin: const EdgeInsets.only(bottom: 25),
      color: completed ? const Color(0xFF2FA36B) : const Color(0xFFE8E1E4),
    );
  }
}
