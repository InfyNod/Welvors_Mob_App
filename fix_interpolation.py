import os

files_to_update = [
    '/Users/salauddinansari/StudioProjects/Velvors/lib/welvors_home_screen/ui/date_now/send_request_drawer.dart',
    '/Users/salauddinansari/StudioProjects/Velvors/lib/welvors_home_screen/ui/date_now/date_now_screen.dart',
    '/Users/salauddinansari/StudioProjects/Velvors/lib/welvors_home_screen/ui/date_now/profile/profile_detail.dart',
    '/Users/salauddinansari/StudioProjects/Velvors/lib/welvors_home_screen/ui/date_now/date_now_2/requests_sent/requests_sent_screen.dart'
]

for file_path in files_to_update:
    if not os.path.exists(file_path):
        continue
    with open(file_path, 'r') as f:
        content = f.read()

    # Fix formatting from python script error: $(await TokenHelper.getToken() ?? "") -> ${await TokenHelper.getToken() ?? ""}
    content = content.replace('$(await TokenHelper.getToken() ?? "")', '${await TokenHelper.getToken() ?? ""}')

    with open(file_path, 'w') as f:
        f.write(content)
