with open('lib/welvors_home_screen/ui/date_now/requests_sent_screen.dart', 'r') as f:
    lines = f.readlines()

# We want to remove lines 41 to 90 (0-indexed: 40 to 90)
# We also want to remove lines 771 to 1263 (0-indexed: 770 to 1262)

# But wait, lines might have shifted. Let's do it by finding the start and end indices.
start_var = -1
end_var = -1
for i, line in enumerate(lines):
    if "String _selectedDayFilter = 'Today';" in line:
        start_var = i
    if "final List<Map<String, dynamic>> _plans = [" in line:
        end_var = i - 1
        break

if start_var != -1 and end_var != -1:
    del lines[start_var:end_var]

start_method = -1
end_method = -1
for i, line in enumerate(lines):
    if "Widget _buildMyPlansTab() {" in line:
        start_method = i
        break

if start_method != -1:
    # Keep the closing brace of the class
    end_method = len(lines) - 1
    del lines[start_method:end_method]

with open('lib/welvors_home_screen/ui/date_now/requests_sent_screen.dart', 'w') as f:
    f.writelines(lines)
