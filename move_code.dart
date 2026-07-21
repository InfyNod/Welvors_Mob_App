import 'dart:io';

void main() {
  final myPlanFile = File('/Users/salauddinansari/StudioProjects/Velvors/lib/welvors_home_screen/ui/date_now/date_now_2/my_plans/my_plan_screen.dart');
  final managePlanFile = File('/Users/salauddinansari/StudioProjects/Velvors/lib/welvors_home_screen/ui/date_now/date_now_2/my_plans/manage_plan.dart');

  final lines = myPlanFile.readAsLinesSync();
  int startIdx = -1;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('void _showManageBottomSheet(')) {
      startIdx = i;
      break;
    }
  }

  if (startIdx != -1) {
    final extractedLines = lines.sublist(startIdx, lines.length - 1);
    final keptLines = lines.sublist(0, startIdx);
    keptLines.add('}\n');

    String extractedText = extractedLines.join('\n');
    extractedText = extractedText.replaceAll('void _showManageBottomSheet', 'void showManageBottomSheet');
    extractedText = extractedText.replaceAll('void _showReviewBottomSheet', 'void showReviewBottomSheet');
    extractedText = extractedText.replaceAll('void _showWhoCameBottomSheet', 'void showWhoCameBottomSheet');
    extractedText = extractedText.replaceAll('void _showFeedbackBottomSheet', 'void showFeedbackBottomSheet');
    extractedText = extractedText.replaceAll('_showReviewBottomSheet', 'showReviewBottomSheet');
    extractedText = extractedText.replaceAll('_showWhoCameBottomSheet', 'showWhoCameBottomSheet');
    extractedText = extractedText.replaceAll('_showFeedbackBottomSheet', 'showFeedbackBottomSheet');
    extractedText = extractedText.replaceAll('Widget _buildManageOptionRow', 'Widget buildManageOptionRow');
    extractedText = extractedText.replaceAll('_buildManageOptionRow', 'buildManageOptionRow');

    managePlanFile.writeAsStringSync("import 'package:flutter/material.dart';\n\n" + extractedText);

    String newContent = keptLines.join('\n');
    newContent = newContent.replaceAll('_showManageBottomSheet', 'showManageBottomSheet');
    
    // add import
    final keptLinesSplit = newContent.split('\n');
    int lastImport = 0;
    for (int i = 0; i < keptLinesSplit.length; i++) {
      if (keptLinesSplit[i].startsWith('import ')) {
        lastImport = i;
      }
    }
    keptLinesSplit.insert(lastImport + 1, "import 'manage_plan.dart';");

    myPlanFile.writeAsStringSync(keptLinesSplit.join('\n'));
    print('Dart script done');
  }
}
