import 'package:go_router/go_router.dart';
import 'package:velvors/utils/navigation/app_routes.dart';
import '../../../../../../../services/logger_service.dart';
import '../../export.dart';
class VerificationCard extends StatelessWidget {
  const VerificationCard({super.key, required this.items, this.onVerifyItem});

  final List<VerificationItemModel> items;
  final void Function(int itemIndex)? onVerifyItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return VerificationItem(
                item: items[index],
                showDivider: index < items.length - 1,
                // onVerify: onVerifyItem == null
                //     ? null
                //     : () => onVerifyItem!(index),
                onVerify: () {
                  AppLogger.d('VerificationCard', '<<<<${items[index].buttonIds}>>>>');
                  if (items[index].buttonIds == 'government_id_verification') {
                    context.push(AppRoutes.governmentVerification);
                  } else if (items[index].buttonIds == "face_verification") {
                    context.push(AppRoutes.faceVerification);
                  } else if (items[index].buttonIds == "video_verification") {
                    context.push(AppRoutes.videoVerification);
                  } else if (items[index].buttonIds ==
                      'education_verification') {
                    context.push(AppRoutes.educationVerification);
                  } else if (items[index].buttonIds ==
                      'professional_verification') {
                    context.push(AppRoutes.professionalVerification);
                  } else if (items[index].buttonIds == 'income_verification') {
                    context.push(AppRoutes.incomeVerification);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
