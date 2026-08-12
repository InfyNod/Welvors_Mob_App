import '../../../export.dart';

class DocumentStep extends StatelessWidget {
  const DocumentStep();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstantVerificationBloc, InstantVerificationState>(
      builder: (context, state) {
        final bloc = context.read<InstantVerificationBloc>();

        final documents = [
          const VerificationDocument(
            type: VerificationDocumentType.aadhaar,
            title: 'Aadhaar',
            subtitle: 'Issued by UIDAI · available in DigiLocker',
            icon: '🆔',
            recommended: true,
          ),
          const VerificationDocument(
            type: VerificationDocumentType.pan,
            title: 'PAN',
            subtitle: 'Issued by Income Tax Dept · available in DigiLocker',
            icon: '💳',
          ),
          const VerificationDocument(
            type: VerificationDocumentType.drivingLicence,
            title: 'Driving Licence',
            subtitle:
                'Issued by Ministry of Road Transport · available in DigiLocker',
            icon: '🚗',
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DigiLockerInfoCard(
              icon: "'🏛️'",
              title: "Connect DigiLocker",
              subtitle: // 'Government of India’s secure document wallet.\n'
                  'Pick the document you’d like to verify — we\n'
                  'fetch & verify it instantly.',
            ),

            const SizedBox(height: 28),

            const Text(
              'Choose a document',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 16),

            ...documents.map((document) {
              return DocumentCard(
                document: document,
                selected: state.selectedDocument?.type == document.type,
                onTap: () {
                  bloc.add(SelectDocument(document));
                },
              );
            }),
            GreenInfoBox(
              text:
                  "You’re always in control — nothing is fetched without your consent",
            ),
          ],
        );
      },
    );
  }
}
