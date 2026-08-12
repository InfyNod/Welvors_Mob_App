import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../bloc/platinum_verification_state.dart';

// --------------------------------------------------
// INITIAL DATA
// --------------------------------------------------

class PlatinumInitialData {
  final String paymentMethod;
  final String incomeBracket;
  final String residenceState;
  final String contactName;
  final String relationship;
  final String contactMobile;
  final bool contactConsent;

  const PlatinumInitialData({
    required this.paymentMethod,
    required this.incomeBracket,
    required this.residenceState,
    required this.contactName,
    required this.relationship,
    required this.contactMobile,
    required this.contactConsent,
  });
}

// --------------------------------------------------
// REPOSITORY
// --------------------------------------------------

class PlatinumVerificationRepository {
  // --------------------------------------------------
  // INITIAL DATA
  // --------------------------------------------------

  Future<PlatinumInitialData> getInitialData() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return const PlatinumInitialData(
      paymentMethod: 'UPI',
      incomeBracket: '20–50 LPA',
      residenceState: 'Maharashtra',
      contactName: 'Meera Sharma',
      relationship: 'Mother',
      contactMobile: '+91 98765 43210',
      contactConsent: true,
    );
  }

  // --------------------------------------------------
  // PAYMENT
  // --------------------------------------------------

  Future<void> startPayment({required String paymentMethod}) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  // --------------------------------------------------
  // PICK INCOME PROOF FILE
  // --------------------------------------------------

  Future<File?> pickIncomeProofFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      allowMultiple: false,
      withData: false,
    );

    // User cancelled picker
    if (result == null || result.files.isEmpty) {
      return null;
    }

    final pickedFile = result.files.first;

    // File path check
    if (pickedFile.path == null) {
      throw Exception('Unable to access selected file');
    }

    // --------------------------------------------------
    // MAX FILE SIZE = 5 MB
    // --------------------------------------------------

    const maxSize = 5 * 1024 * 1024;

    if (pickedFile.size > maxSize) {
      throw Exception('File size must be less than 5MB');
    }

    return File(pickedFile.path!);
  }

  // --------------------------------------------------
  // SAVE FOR LATER
  // --------------------------------------------------

  Future<void> saveForLater(PlatinumVerificationState state) async {
    await Future.delayed(const Duration(milliseconds: 250));
  }
}
