import re

with open('lib/welvors_home_screen/ui/date_now/requests_sent_screen.dart', 'r') as f:
    content = f.read()

# Rename MyPlanScreen to RequestsSentScreen in requests_sent_screen.dart
content = content.replace('class MyPlanScreen extends', 'class RequestsSentScreen extends')
content = content.replace('State<MyPlanScreen>', 'State<RequestsSentScreen>')
content = content.replace('_MyPlanScreenState', '_RequestsSentScreenState')
content = content.replace('MyPlanScreen({super.key})', 'RequestsSentScreen({super.key})')

# Extract vars
var_pattern = re.compile(r"(  String _selectedDayFilter = 'Today';.*?];\n\n)", re.DOTALL)
var_match = var_pattern.search(content)
extracted_vars = var_match.group(1) if var_match else ""

if var_match:
    content = content[:var_match.start()] + content[var_match.end():]

# Extract methods
methods_pattern = re.compile(r"(  Widget _buildMyPlansTab\(\) \{.*)\}\n$", re.DOTALL)
methods_match = methods_pattern.search(content)
extracted_methods = methods_match.group(1) if methods_match else ""

if methods_match:
    content = content[:methods_match.start()] + "}\n"

content = content.replace('_buildMyPlansTab()', 'const MyPlanScreen()')

import_statement = "import 'my_plan_screen.dart';\n"
content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + import_statement)

with open('lib/welvors_home_screen/ui/date_now/requests_sent_screen.dart', 'w') as f:
    f.write(content)

my_plan_content = f"""import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class MyPlanScreen extends StatefulWidget {{
  const MyPlanScreen({{super.key}});

  @override
  State<MyPlanScreen> createState() => _MyPlanScreenState();
}}

class _MyPlanScreenState extends State<MyPlanScreen> {{
{extracted_vars}
  @override
  Widget build(BuildContext context) {{
    return _buildMyPlansTab();
  }}

{extracted_methods}
}}
"""

with open('lib/welvors_home_screen/ui/date_now/my_plan_screen.dart', 'w') as f:
    f.write(my_plan_content)

print("Split completed successfully!")
