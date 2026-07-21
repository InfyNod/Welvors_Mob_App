import re

with open("lib/welvors_home_screen/ui/date_now/date_now_2/my_plans/manage_plan.dart", "r") as f:
    content = f.read()

# Update signatures
content = content.replace("void showManageBottomSheet(BuildContext context, Map<String, dynamic> plan) {", "void showManageBottomSheet(BuildContext context, Map<String, dynamic> plan, VoidCallback onPlanClosed) {")
content = content.replace("void showReviewBottomSheet(BuildContext context, Map<String, dynamic> plan) {", "void showReviewBottomSheet(BuildContext context, Map<String, dynamic> plan, VoidCallback onPlanClosed) {")
content = content.replace("void showWhoCameBottomSheet(BuildContext context, Map<String, dynamic> plan) {", "void showWhoCameBottomSheet(BuildContext context, Map<String, dynamic> plan, VoidCallback onPlanClosed) {")
content = content.replace("void showFeedbackBottomSheet(\n  BuildContext context,\n  Map<String, dynamic> plan,\n  Map<String, dynamic> attendee,\n) {", "void showFeedbackBottomSheet(\n  BuildContext context,\n  Map<String, dynamic> plan,\n  Map<String, dynamic> attendee,\n  VoidCallback onPlanClosed,\n) {")
content = content.replace("void showThanksBottomSheet(BuildContext context, Map<String, dynamic> plan, Map<String, dynamic> attendee, int overallExperience, int ratePerson) {", "void showThanksBottomSheet(BuildContext context, Map<String, dynamic> plan, Map<String, dynamic> attendee, int overallExperience, int ratePerson, VoidCallback onPlanClosed) {")
content = content.replace("void showReportIssueBottomSheet(BuildContext context, Map<String, dynamic> plan, Map<String, dynamic> attendee, [int overallExperience = 0, int ratePerson = 0]) {", "void showReportIssueBottomSheet(BuildContext context, Map<String, dynamic> plan, Map<String, dynamic> attendee, VoidCallback onPlanClosed, [int overallExperience = 0, int ratePerson = 0]) {")
content = content.replace("void showNoOneCameBottomSheet(BuildContext context, Map<String, dynamic> plan) {", "void showNoOneCameBottomSheet(BuildContext context, Map<String, dynamic> plan, VoidCallback onPlanClosed) {")

# Update calls
content = content.replace("showReviewBottomSheet(context, plan);", "showReviewBottomSheet(context, plan, onPlanClosed);")
content = content.replace("showWhoCameBottomSheet(context, plan);", "showWhoCameBottomSheet(context, plan, onPlanClosed);")
content = content.replace("showFeedbackBottomSheet(\n                          context,\n                          plan,\n                          attendees[selectedIndex!],\n                        );", "showFeedbackBottomSheet(\n                          context,\n                          plan,\n                          attendees[selectedIndex!],\n                          onPlanClosed,\n                        );")
content = content.replace("showFeedbackBottomSheet(context, plan, attendee);", "showFeedbackBottomSheet(context, plan, attendee, onPlanClosed);")
content = content.replace("showThanksBottomSheet(context, plan, attendee, overallExperience, ratePerson);", "showThanksBottomSheet(context, plan, attendee, overallExperience, ratePerson, onPlanClosed);")
content = content.replace("showReportIssueBottomSheet(context, plan, attendee, overallExperience, ratePerson);", "showReportIssueBottomSheet(context, plan, attendee, onPlanClosed, overallExperience, ratePerson);")
content = content.replace("showNoOneCameBottomSheet(context, plan);", "showNoOneCameBottomSheet(context, plan, onPlanClosed);")

# Update Done button in Thanks
content = re.sub(
    r"(GestureDetector\(\n\s*onTap:\s*\(\)\s*=>\s*Navigator\.pop\(context\),\n\s*child:\s*Container\(\n\s*width:\s*double\.infinity,\n\s*padding:\s*const\s*EdgeInsets\.symmetric\(vertical:\s*16\),\n\s*decoration:\s*BoxDecoration\(\n\s*gradient:\s*const\s*LinearGradient\(\n\s*colors:\s*\[Color\(0xFFFA6A85\),\s*Color\(0xFFDE2957\)\],\n\s*\),\n\s*borderRadius:\s*BorderRadius\.circular\(16\),\n\s*\),\n\s*child:\s*const\s*Center\(\n\s*child:\s*Text\(\n\s*'Done',)",
    r"GestureDetector(\n                        onTap: () {\n                          Navigator.pop(context);\n                          onPlanClosed();\n                        },\n                        child: Container(\n                          width: double.infinity,\n                          padding: const EdgeInsets.symmetric(vertical: 16),\n                          decoration: BoxDecoration(\n                            gradient: const LinearGradient(\n                              colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],\n                            ),\n                            borderRadius: BorderRadius.circular(16),\n                          ),\n                          child: const Center(\n                            child: Text(\n                              'Done',",
    content
)

# Update Submit report button in Report Issue
content = re.sub(
    r"(GestureDetector\(\n\s*onTap:\s*\(\)\s*=>\s*Navigator\.pop\(context\),\n\s*child:\s*Container\(\n\s*width:\s*double\.infinity,\n\s*padding:\s*const\s*EdgeInsets\.symmetric\(vertical:\s*16\),\n\s*decoration:\s*BoxDecoration\(\n\s*gradient:\s*const\s*LinearGradient\(\n\s*colors:\s*\[Color\(0xFFFA6A85\),\s*Color\(0xFFDE2957\)\],\n\s*\),\n\s*borderRadius:\s*BorderRadius\.circular\(16\),\n\s*\),\n\s*child:\s*const\s*Center\(\n\s*child:\s*Text\(\n\s*'Submit report',)",
    r"GestureDetector(\n                            onTap: () {\n                              Navigator.pop(context);\n                              onPlanClosed();\n                            },\n                            child: Container(\n                              width: double.infinity,\n                              padding: const EdgeInsets.symmetric(vertical: 16),\n                              decoration: BoxDecoration(\n                                gradient: const LinearGradient(\n                                  colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],\n                                ),\n                                borderRadius: BorderRadius.circular(16),\n                              ),\n                              child: const Center(\n                                child: Text(\n                                  'Submit report',",
    content
)

# Update Submit & close plan button in No One Came
content = re.sub(
    r"(GestureDetector\(\n\s*onTap:\s*\(\)\s*\{\n\s*if\s*\(isFormValid\)\s*\{\n\s*Navigator\.pop\(context\);\n\s*\}\n\s*\},\n\s*child:\s*Container\(\n\s*width:\s*double\.infinity,\n\s*padding:\s*const\s*EdgeInsets\.symmetric\(vertical:\s*16\),\n\s*decoration:\s*BoxDecoration\(\n\s*color:\s*isFormValid\s*\?\s*const\s*Color\(0xFFE43A6A\)\s*:\s*const\s*Color\(0xFFF1B4C3\),\n\s*borderRadius:\s*BorderRadius\.circular\(16\),\n\s*\),\n\s*child:\s*const\s*Center\(\n\s*child:\s*Text\(\n\s*'Submit & close plan',)",
    r"GestureDetector(\n                            onTap: () {\n                              if (isFormValid) {\n                                Navigator.pop(context);\n                                onPlanClosed();\n                              }\n                            },\n                            child: Container(\n                              width: double.infinity,\n                              padding: const EdgeInsets.symmetric(vertical: 16),\n                              decoration: BoxDecoration(\n                                color: isFormValid ? const Color(0xFFE43A6A) : const Color(0xFFF1B4C3),\n                                borderRadius: BorderRadius.circular(16),\n                              ),\n                              child: const Center(\n                                child: Text(\n                                  'Submit & close plan',",
    content
)

with open("lib/welvors_home_screen/ui/date_now/date_now_2/my_plans/manage_plan.dart", "w") as f:
    f.write(content)
