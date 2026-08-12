import '../bloc/platinum_verification_bloc.dart';
import '../bloc/platinum_verification_event.dart';
import '../bloc/platinum_verification_state.dart';
import '../widgets/platinum_widgets.dart';
import '../../../export.dart';

class PlatinumPaymentScreen extends StatelessWidget {
  const PlatinumPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlatinumVerificationBloc>();

    return Scaffold(
      backgroundColor: Mycolor.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 18, bottom: 5, right: 18, top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<PlatinumVerificationBloc, PlatinumVerificationState>(
              builder: (_, state) {
                return BottomAction(
                  color: [Mycolor.dark, Mycolor.dark2],
                  colorshdow: [
                    BoxShadow(
                      color: Mycolor.colorc4bec4,
                      blurRadius: 25,
                      offset: Offset(0, 12),
                    ),
                  ],
                  text: state.status == PlatinumStatus.submitting
                      ? 'Processing...'
                      : '👑 Pay ₹500 & Start Verification',
                  onPressed: () {
                    if (state.status != PlatinumStatus.submitting) {
                      bloc.add(StartVerification());
                    }
                  },
                  secondaryText: 'Maybe later',
                  onSecondary: () {
                    bloc.add(SaveForLater());
                  },
                );
              },
            ),
          ],
        ),
      ),
      // appBar: const PlatinumAppBar(title: 'Platinum Verification'),
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
          'Platinum Verification',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 17),
              children: [
                const PlatinumHeroCard(),

                const SizedBox(height: 28),

                const PlatinumBenefitsCard(),

                const SizedBox(height: 28),

                const Text(
                  'Choose Payment Method',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 14),

                BlocBuilder<
                  PlatinumVerificationBloc,
                  PlatinumVerificationState
                >(
                  builder: (_, state) {
                    return Column(
                      children: [
                        PaymentTile(
                          icon: '📱',
                          title: 'UPI',
                          subtitle: 'GPay · PhonePe · Paytm · BHIM',
                          selected: state.paymentMethod == 'UPI',
                          onTap: () {
                            bloc.add(const SelectPaymentMethod('UPI'));
                          },
                        ),
                        PaymentTile(
                          icon: '💳',
                          title: 'Credit / Debit Card',
                          subtitle: 'Visa · Mastercard · Rupay',
                          selected: state.paymentMethod == 'CARD',
                          onTap: () {
                            bloc.add(const SelectPaymentMethod('CARD'));
                          },
                        ),
                        PaymentTile(
                          icon: '🏦',
                          title: 'Net Banking',
                          subtitle: 'All major Indian banks supported',
                          selected: state.paymentMethod == 'BANK',
                          onTap: () {
                            bloc.add(const SelectPaymentMethod('BANK'));
                          },
                        ),
                      ],
                    );
                  },
                ),

                const SecurityBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
