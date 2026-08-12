import 'package:flutter/material.dart';
import '../bloc/upload_id_state.dart';
import '../models/upload_id_model.dart';
import '../../../instant_verification/widget/instant_verification_screen.dart';
import '../../../../utils/mycolor.dart';
import '../../../../utils/sizesboxs.dart';

class UploadIdBottomButton extends StatelessWidget {
  final VoidCallback? onSubmit;
  final bool loading;
  final UploadIdState state;

  const UploadIdBottomButton({
    super.key,
    required this.onSubmit,
    required this.loading,
    required this.state,
  });
  String getSubmitText() {
    if (state.isConfirmed == false) {
      return 'Submit for review';
    }

    switch (state.selectedIdType) {
      case IdType.aadhaar:
        return 'Submit Aadhaar for review';

      case IdType.pan:
        return 'Submit PAN for review';

      // Agar enum me ye values hain to uncomment/use karo:
      case IdType.drivingLicence:
        return 'Submit Driving License for review';

      case IdType.voterId:
        return 'Submit Voter ID for review';

      case IdType.passport:
        return 'Submit Passport for review';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: loading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Mycolor.pink,
              disabledBackgroundColor: const Color(0xFFE9A5C2),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    getSubmitText(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        hSized10,
        InkWell(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => InstantVerificationScreen()),
            );
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('⚡', style: TextStyle(fontSize: 20)),
              SizedBox(width: 6),
              Text(
                'Verify instantly instead',
                style: TextStyle(
                  color: Color(0xFF9D969C),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
