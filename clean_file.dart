import 'dart:io';

void main() {
  final myPlanFile = File('lib/welvors_home_screen/ui/date_now/date_now_2/my_plans/my_plan_screen.dart');
  
  final lines = myPlanFile.readAsLinesSync();
  int endIdx = -1;
  for (int i = 0; i < lines.length; i++) {
    // We look for where _buildManageButton ends. 
    // Wait, the last change I did accidentally added '}' instead of 'void _showReviewBottomSheet...'
    if (lines[i].contains('String cleanTitle = rawTitle;')) {
      // this is inside the broken _showReviewBottomSheet.
      // Let's just find the end of `Widget _buildManageButton` which is around line 668.
      // Actually, we can just search backwards from the top.
    }
  }

  // Let's just truncate the file at the end of `Widget _buildManageButton`.
  // `Widget _buildManageButton` ends at a `  }` before `}` that I injected.
  int cutOff = -1;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i] == '  Widget _buildManageButton(Map<String, dynamic> plan) {') {
      // Find the closing brace for this method.
      int indent = 0;
      for (int j = i; j < lines.length; j++) {
        if (lines[j].contains('{')) indent++;
        if (lines[j].contains('}')) indent--;
        if (indent == 0) {
          cutOff = j;
          break;
        }
      }
      break;
    }
  }

  if (cutOff != -1) {
    // Keep lines up to cutOff, then add one more '}' for the class.
    final keptLines = lines.sublist(0, cutOff + 1);
    keptLines.add('}');
    myPlanFile.writeAsStringSync(keptLines.join('\n') + '\n');
    print('Successfully cleaned my_plan_screen.dart');
  } else {
    print('Could not find _buildManageButton');
  }
}
