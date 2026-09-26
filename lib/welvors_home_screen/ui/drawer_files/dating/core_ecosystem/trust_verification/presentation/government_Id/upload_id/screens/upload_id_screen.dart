import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/upload_id_bloc.dart';
import '../bloc/upload_id_event.dart';
import '../bloc/upload_id_state.dart';
import '../data/upload_id_repository_impl.dart';
import '../models/upload_id_model.dart';
import '../../../instant_verification/widget/aadhaarVerifiedScreen.dart';
import '../../../../utils/mycolor.dart';
import '../../../../utils/sizesboxs.dart';

import '../widgets/document_upload_box.dart';
import '../widgets/id_type_chip.dart';
import '../widgets/upload_id_bottom_button.dart';

class UploadIdScreen extends StatelessWidget {
  const UploadIdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UploadIdBloc(repository: UploadIdRepositoryImpl()),
      child: const _UploadIdView(),
    );
  }
}

class _UploadIdView extends StatefulWidget {
  const _UploadIdView();

  @override
  State<_UploadIdView> createState() => _UploadIdViewState();
}

class _UploadIdViewState extends State<_UploadIdView> {
  late final TextEditingController _aadhaarController;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();

    _aadhaarController = TextEditingController();
    _nameController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument({required bool front}) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    final pickedFile = result.files.single;

    // 5 MB validation
    if (pickedFile.size > 5 * 1024 * 1024) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File size must be less than 5MB')),
      );

      return;
    }

    final file = File(pickedFile.path!);

    if (!mounted) return;

    if (front) {
      context.read<UploadIdBloc>().add(FrontDocumentSelected(file));
    } else {
      context.read<UploadIdBloc>().add(BackDocumentSelected(file));
    }
  }

  String getButtonTitle(UploadIdState state) {
    if (state.isConfirmed == false) {
      return 'Submit for review';
    }

    switch (state.selectedIdType) {
      case IdType.aadhaar:
        return 'Submit Aadhaar for review';

      case IdType.pan:
        return 'Submit PAN for review';

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
    return BlocListener<UploadIdBloc, UploadIdState>(
      listener: (context, state) {
        if (state.status == UploadIdStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Something went wrong'),
            ),
          );
        }

        if (state.status == UploadIdStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document submitted successfully')),
          );
          final title = switch (state.selectedIdType) {
            IdType.aadhaar => 'Aadhaar submitted for review',
            IdType.pan => 'PAN submitted for review',
            IdType.drivingLicence => 'Driving License submitted for review',
            IdType.voterId => 'Voter ID submitted for review',
            IdType.passport => 'Passport submitted for review',
          };
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AadhaarVerifiedScreen(
                title: title,
                score: 20,
                icon: Icon(Icons.access_time_rounded),
                iconcolor: Mycolor.iconyellow,
                subtitle:
                    "Your PAN is under review. We’ll notify you within 24–48 hours once it’s approved. You can switch to instant DigiLocker verification anytime.",
                cardbottomtext: "Pending review · score updates on approval",
              ),
            ),
          );
          // Navigator.push(...)
        }
      },
      child: Scaffold(
        backgroundColor: Mycolor.white,
        appBar: _buildAppBar(),
        body: BlocBuilder<UploadIdBloc, UploadIdState>(
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 24, 18, 30),
                    child: _buildContent(context, state),
                  ),
                ),

                _buildBottomSection(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      automaticallyImplyLeading: false,
      titleSpacing: 18,
      centerTitle: true,
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
                  color: Colors.black.withValues(alpha: 0.04),
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
        'Upload ID',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, UploadIdState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBox(),

        hSized20,

        _sectionTitle('SELECT ID TYPE'),

        hSized10,

        _buildIdTypes(context, state),

        hSized20,

        if (state.selectedIdType == IdType.aadhaar) ...[
          _sectionTitle('AADHAAR NUMBER'),

          hSized14,

          _buildAadhaarField(context, state),

          hSized12,

          const Text(
            'Your 12-digit Aadhaar. Encrypted — only last 4 digits are ever stored.',
            style: TextStyle(
              color: Color(0xFF9B949A),
              fontSize: 12,
              height: 1.55,
            ),
          ),

          hSized10,
        ],

        _sectionTitle(
          'FULL NAME (AS ON ${state.selectedIdType.title.toUpperCase()})',
        ),

        hSized14,

        _buildNameField(context, state),

        hSized20,

        _sectionTitle(state.selectedIdType.frontLabel),

        hSized14,

        DocumentUploadBox(
          title: state.selectedIdType.frontTitle,
          file: state.frontFile,
          onTap: () {
            _pickDocument(front: true);
          },
        ),

        hSized20,

        _sectionTitle(state.selectedIdType.backLabel),

        hSized14,

        DocumentUploadBox(
          title: state.selectedIdType.backTitle,
          file: state.backFile,
          onTap: () {
            _pickDocument(front: false);
          },
        ),

        hSized24,

        _buildConfirmation(context, state),

        hSized10,

        _buildReviewInfo(),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
      decoration: BoxDecoration(
        color: Mycolor.pinklight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              '📄 Choose your ID, enter its number and upload clear photos. All corners & text must be visible.',
              style: TextStyle(
                color: Color(0xFFD41464),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdTypes(BuildContext context, UploadIdState state) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: IdType.values.map((type) {
        return IdTypeChip(
          idType: type,
          selected: state.selectedIdType == type,
          onTap: () {
            context.read<UploadIdBloc>().add(SelectIdType(type));
          },
        );
      }).toList(),
    );
  }

  Widget _buildAadhaarField(BuildContext context, UploadIdState state) {
    return TextField(
      keyboardType: TextInputType.number,
      maxLength: 12,
      cursorColor: const Color(0xFF9A9298),
      controller: _aadhaarController,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Mycolor.black,
      ),

      decoration: InputDecoration(
        hintText: '1234 5678 9012',

        hintStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: Color(0xFF9A9298),
        ),

        // Remove character counter
        counterText: '',

        filled: true,
        fillColor: Colors.white,

        // Exact spacing like screenshot
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 13,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF0E8E8), width: 2),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF0E8E8), width: 2),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Mycolor.pink2, width: 2),
        ),
      ),

      onChanged: (value) {
        context.read<UploadIdBloc>().add(AadhaarNumberChanged(value));
      },
    );
  }

  Widget _buildNameField(BuildContext context, UploadIdState state) {
    return TextField(
      keyboardType: TextInputType.name,
      maxLength: 10,
      cursorColor: const Color(0xFF9A9298),
      controller: _nameController,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Mycolor.black,
      ),

      decoration: InputDecoration(
        hintText: 'FULL NAME',

        hintStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: Color(0xFF9A9298),
        ),

        // Remove character counter
        counterText: '',

        filled: true,
        fillColor: Colors.white,

        // Exact spacing like screenshot
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 13,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF0E8E8), width: 2),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF0E8E8), width: 2),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Mycolor.pink2, width: 2),
        ),
      ),

      onChanged: (value) {
        context.read<UploadIdBloc>().add(FullNameChanged(value));
      },
    );
  }

  Widget _buildConfirmation(BuildContext context, UploadIdState state) {
    return GestureDetector(
      onTap: () {
        context.read<UploadIdBloc>().add(
          ConfirmationChanged(!state.isConfirmed),
        );
      },

      // child: Container(
      //   width: double.infinity,
      //   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      //   decoration: BoxDecoration(
      //     color: Colors.white,
      //     borderRadius: BorderRadius.circular(18),
      //     border: Border.all(color: const Color(0xFFE8E1E4)),
      //   ),
      //   child: Row(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       AnimatedContainer(
      //         duration: const Duration(milliseconds: 150),
      //         width: 20,
      //         height: 20,
      //         decoration: BoxDecoration(
      //           color: state.isConfirmed ? Mycolor.pink : Colors.white,
      //           borderRadius: BorderRadius.circular(2),
      //           border: Border.all(
      //             color: state.isConfirmed
      //                 ? Mycolor.pink
      //                 : Mycolor.color0xFFE5DFE2,
      //             width: 2,
      //           ),
      //         ),
      //         child: state.isConfirmed
      //             ? const Icon(Icons.check, color: Colors.white, size: 16)
      //             : null,
      //       ),
      //       const SizedBox(width: 16),
      //       const Expanded(
      //         child: Text(
      //           'I confirm this ID belongs to me and the details are accurate. False documents lead to a permanent ban.',
      //           style: TextStyle(
      //             color: Color(0xFF625D63),
      //             fontSize: 11,
      //             height: 1.55,
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: state.isConfirmed ? Mycolor.colorfce4ef : Mycolor.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: state.isConfirmed ? Mycolor.pink : Mycolor.color0xFFE8E1E4,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: state.isConfirmed ? Mycolor.colore11d74 : Mycolor.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: state.isConfirmed
                      ? Mycolor.colore11d74
                      : Mycolor.colorfce4ef,
                  width: 1,
                ),
              ),
              child: state.isConfirmed
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),

            wSized18,

            const Expanded(
              child: Text(
                'I confirm this ID belongs to me and the details are accurate. False documents lead to a permanent ban.',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.5,
                  color: Color(0xFF252126),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE5FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        '⏱ Manual review takes 24–48 hours. You’ll get a notification once it’s approved — or verify instantly via DigiLocker.',
        style: TextStyle(
          color: Color(0xFF713BEE),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, UploadIdState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      decoration: BoxDecoration(color: Mycolor.white),
      child: UploadIdBottomButton(
        loading: state.status == UploadIdStatus.loading,
        state: state,
        onSubmit: () {
          context.read<UploadIdBloc>().add(const SubmitUploadId());
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF9B949A),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}
