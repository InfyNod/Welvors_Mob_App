import 'dart:io';

enum IdType { aadhaar, pan, passport, drivingLicence, voterId }

extension IdTypeExtension on IdType {
  String get title {
    switch (this) {
      case IdType.aadhaar:
        return 'Aadhaar';
      case IdType.pan:
        return 'PAN';
      case IdType.passport:
        return 'Passport';
      case IdType.drivingLicence:
        return 'Driving Licence';
      case IdType.voterId:
        return 'Voter ID';
    }
  }

  String get emoji {
    switch (this) {
      case IdType.aadhaar:
        return '🆔';
      case IdType.pan:
        return '💳';
      case IdType.passport:
        return '🛂';
      case IdType.drivingLicence:
        return '🚗';
      case IdType.voterId:
        return '📦';
    }
  }

  String get frontTitle {
    switch (this) {
      case IdType.aadhaar:
        return 'Tap to upload front of Aadhaar';
      case IdType.pan:
        return 'Tap to upload front of PAN';
      case IdType.passport:
        return 'Tap to upload passport';
      case IdType.drivingLicence:
        return 'Tap to upload front of Driving Licence';
      case IdType.voterId:
        return 'Tap to upload front of Voter ID';
    }
  }

  String get backTitle {
    switch (this) {
      case IdType.aadhaar:
        return 'Tap to upload back of Aadhaar';
      case IdType.pan:
        return 'Tap to upload back of PAN';
      case IdType.passport:
        return 'Tap to upload back of passport';
      case IdType.drivingLicence:
        return 'Tap to upload back of Driving Licence';
      case IdType.voterId:
        return 'Tap to upload back of Voter ID';
    }
  }

  String get frontLabel {
    switch (this) {
      case IdType.aadhaar:
      case IdType.pan:
      case IdType.passport:
      case IdType.drivingLicence:
      case IdType.voterId:
        return 'FRONT (PHOTO SIDE)';
    }
  }

  String get backLabel {
    switch (this) {
      case IdType.aadhaar:
      case IdType.pan:
      case IdType.passport:
      case IdType.drivingLicence:
      case IdType.voterId:
        return 'BACK (ADDRESS SIDE)';
    }
  }
}

class UploadIdModel {
  final IdType idType;
  final String idNumber;
  final String fullName;
  final File? frontFile;
  final File? backFile;
  final bool isConfirmed;

  const UploadIdModel({
    required this.idType,
    required this.idNumber,
    required this.fullName,
    this.frontFile,
    this.backFile,
    required this.isConfirmed,
  });
}
