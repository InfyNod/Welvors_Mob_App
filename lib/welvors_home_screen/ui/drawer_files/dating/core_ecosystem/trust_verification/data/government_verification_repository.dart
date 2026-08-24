import '../Model/government_verification_response.dart';
import '../export.dart';

class GovernmentVerificationRepository {
  Future<GovernmentVerificationResponse> fetchGovernmentVerification() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return const GovernmentVerificationResponse(
      title: "Government ID",
      bannerMessage:
          "🪪 Verify your government ID to confirm you're a real person. Choose how you'd like to verify.",
      bannerColor: Mycolor.tipbackground,
      methods: [
        VerificationMethod(
          id: "instant_verification",
          icon: "⚡",
          title: "Instant verification",
          subtitle:
              "Connect DigiLocker / Aadhaar — verified automatically in ~30 seconds. No waiting.",
          recommended: true,
          iconBackground: Mycolor.creamlight1,

          type: "Recommended",
          arrow: true,
        ),
        VerificationMethod(
          id: "upload_manual",
          icon: "📄",
          title: "Upload manually",
          subtitle:
              "Upload a photo of your ID. Our team reviews within 24–48 hours.",
          recommended: false,
          iconBackground: Mycolor.creamlight2,
          type: "",
          arrow: true,
        ),
        VerificationMethod(
          id: "encrypted_private",
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
