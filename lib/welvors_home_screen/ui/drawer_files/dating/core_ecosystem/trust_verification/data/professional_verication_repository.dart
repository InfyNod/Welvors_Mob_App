import '../Model/professional_verfication_model.dart';
import '../export.dart';

class ProfessionalverificationRepository {
  Future<ProfessionalVerificationResponse> fetchProfessionverification() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return const ProfessionalVerificationResponse(
      title: "Professional",
      bannerMessage: "💼 Verifies profession and company details.",
      bannerColor: Mycolor.creamlight,
      bannertitle: "Choose how to verify",
      methods: [
        VerificationMethod(
          id: "Professional_Instant",
          icon: '✉️',
          title: "Instant",
          subtitle: "Get an OTP on your official company email —\ninstant",
          recommended: true,
          iconBackground: Mycolor.creamlight1,
          type: "Auto",
          arrow: true,
        ),
        VerificationMethod(
          id: "manual_Professional",
          icon: '📄',

          title: "Manually",
          subtitle: "Add company, role & proof — reviewed in 24–\n48h.",
          recommended: false,
          iconBackground: Mycolor.creamlight2,
          type: "",
          arrow: true,
        ),
        VerificationMethod(
          id: "Professional_Encrypted",
          icon: "🔒",
          title: "Encrypted & private",
          subtitle:
              "Your ID is used only to confirm identity & age. It is never shown on your profile or shared.",
          recommended: false,
          iconBackground: Mycolor.creamlight2,
          type: "",
          arrow: false,
        ),
      ],
    );
  }
}
