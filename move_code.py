import re

my_plan_file = "/Users/salauddinansari/StudioProjects/Velvors/lib/welvors_home_screen/ui/date_now/date_now_2/my_plans/my_plan_screen.dart"
manage_plan_file = "/Users/salauddinansari/StudioProjects/Velvors/lib/welvors_home_screen/ui/date_now/date_now_2/my_plans/manage_plan.dart"

with open(my_plan_file, "r") as f:
    lines = f.readlines()

# Find where _showManageBottomSheet starts
start_idx = -1
for i, line in enumerate(lines):
    if "void _showManageBottomSheet(" in line:
        start_idx = i
        break

if start_idx != -1:
    extracted_lines = lines[start_idx:-1] # excluding the last '}\n' of the class
    kept_lines = lines[:start_idx] + ["}\n"]

    # Write kept lines back
    with open(my_plan_file, "w") as f:
        f.writelines(kept_lines)
    
    # Process extracted lines: change private to public
    extracted_text = "".join(extracted_lines)
    extracted_text = extracted_text.replace("void _showManageBottomSheet", "void showManageBottomSheet")
    extracted_text = extracted_text.replace("void _showReviewBottomSheet", "void showReviewBottomSheet")
    extracted_text = extracted_text.replace("void _showWhoCameBottomSheet", "void showWhoCameBottomSheet")
    extracted_text = extracted_text.replace("void _showFeedbackBottomSheet", "void showFeedbackBottomSheet")
    extracted_text = extracted_text.replace("_showReviewBottomSheet", "showReviewBottomSheet")
    extracted_text = extracted_text.replace("_showWhoCameBottomSheet", "showWhoCameBottomSheet")
    extracted_text = extracted_text.replace("_showFeedbackBottomSheet", "showFeedbackBottomSheet")
    
    # We also need to extract _buildManageOptionRow
    extracted_text = extracted_text.replace("Widget _buildManageOptionRow", "Widget buildManageOptionRow")
    extracted_text = extracted_text.replace("_buildManageOptionRow", "buildManageOptionRow")

    # Write to manage_plan.dart
    with open(manage_plan_file, "w") as f:
        f.write("import 'package:flutter/material.dart';\n\n")
        f.write(extracted_text)
        
    # Also we need to update my_plan_screen.dart to call showManageBottomSheet instead of _showManageBottomSheet
    with open(my_plan_file, "r") as f:
        content = f.read()
    
    content = content.replace("_showManageBottomSheet", "showManageBottomSheet")
    
    # Add import statement after the last import
    lines = content.split('\n')
    last_import = 0
    for i, line in enumerate(lines):
        if line.startswith('import '):
            last_import = i
            
    lines.insert(last_import + 1, "import 'manage_plan.dart';")
    
    with open(my_plan_file, "w") as f:
        f.write('\n'.join(lines))

print("Done moving code")
