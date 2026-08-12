import '../Model/education_model.dart';
import '../export.dart';

class EducationRepository {
  Future<EducationResponse> fetchEducation() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return const EducationResponse(
      title: "Education ID",
      bannerMessage: "🎓 Confirms highest qualification and college.",
      bannerColor: Mycolor.creamlight,
      bannertitle: "Choose how to verify",
      methods: [
        VerificationMethod(
          id: "Instant",
          icon: "⚡",
          title: "Instant",
          subtitle:
              "Fetch your degree from official govt academic records - instant.",
          recommended: true,
          iconBackground: Mycolor.creamlight1,
          type: "Auto",
          arrow: true,
        ),
        VerificationMethod(
          id: "manual_edu",
          icon: "🎓",
          title: "Manually",
          subtitle:
              "Add your collage, degreee & marksheet - reviewed in 24-48h.",
          recommended: false,
          iconBackground: Mycolor.creamlight2,
          type: "",
          arrow: true,
        ),
        VerificationMethod(
          id: "Encrypted",
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
