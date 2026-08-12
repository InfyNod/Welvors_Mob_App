import '../../../export.dart';

class BottomSection extends StatelessWidget {
  const BottomSection();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: BlocBuilder<EducationBloc_instant, EducationState_instant>(
        builder: (context, state) {
          final isLoading = state.status == EducationStatus.loading;
          return Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BottomButton(
                  shadowColor: Mycolor.redshadow,
                  colors: [Mycolor.pink, Mycolor.pink1],
                  title: isLoading ? 'Fetching...' : '⚡ Fetch & verify degree',
                  onTap: isLoading
                      ? null
                      : () {
                          context.read<EducationBloc_instant>().add(
                            FetchDegree(),
                          );
                        },
                ),

                hSized10,

                GestureDetector(
                  onTap: () {
                    debugPrint('Upload manually instead clicked');

                    // Manual upload screen
                  },
                  child: const Text(
                    'Upload manually instead',
                    style: TextStyle(
                      color: Color(0xFF999399),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                // hSized20,
              ],
            ),
          );
        },
      ),
    );
  }
}
