import os
import re

files_to_update = [
    '/Users/salauddinansari/StudioProjects/Velvors/lib/welvors_home_screen/ui/date_now/date_api_service/date_now_api_service.dart',
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

    # Add import if missing
    if 'token_helper.dart' not in content:
        rel_path = os.path.relpath('/Users/salauddinansari/StudioProjects/Velvors/lib/welvors_home_screen/services/token_helper.dart', os.path.dirname(file_path))
        content = f"import '{rel_path}';\n" + content
    
    if 'date_now_api_service.dart' in file_path:
        header_pattern = re.compile(r'  static const String _token =[^;]+;\s+static Map<String, String> get _headers => \{[^}]+\};', re.MULTILINE)
        new_header = '''  static Future<Map<String, String>> get _headers async {
    final token = await TokenHelper.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }'''
        content = header_pattern.sub(new_header, content)
        content = content.replace('headers: _headers', 'headers: await _headers')
        content = content.replace(': _headers;', ': await _headers;')
        content = content.replace("'Authorization': 'Bearer ${overrideToken ?? _token}',", "'Authorization': 'Bearer ${overrideToken ?? (await TokenHelper.getToken() ?? \"\")}',")
    else:
        # For the UI files, we remove the static const _userToken or testToken declaration
        # and replace its usages inside the http calls directly.
        # But this is tricky because the token string literal is used.
        # Let's just find the token string and replace it with `(await TokenHelper.getToken() ?? "")`
        token_regex = re.compile(r"['\"]eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\.[a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+['\"]")
        # However, we can't replace it if it's inside `static const String _userToken = ...` because `await` is invalid there.
        # Instead, let's replace `static const String _userToken = '...';` with `String get _userToken => "";` temporarily?
        # Better: we just replace the constant declaration with a late string or remove `const`.
        # Actually, let's remove `static const String _userToken = '...';` entirely, and replace `_userToken` inside the file with `(await TokenHelper.getToken() ?? "")`.
        
        # 1. Remove `static const String _userToken = '...';`
        content = re.sub(r"  static const String _userToken =\s*['\"]eyJhbGci[^;]+;", "", content)
        # 2. Replace `_userToken` with `(await TokenHelper.getToken() ?? "")`
        content = re.sub(r"\b_userToken\b", '(await TokenHelper.getToken() ?? "")', content)

        # Do the same for testToken
        content = re.sub(r"final testToken = ['\"]eyJhbGci[^;]+;", "final testToken = (await TokenHelper.getToken() ?? \"\");", content)

        # Replace any other raw tokens just in case (like inline strings)
        content = token_regex.sub('(await TokenHelper.getToken() ?? "")', content)

    with open(file_path, 'w') as f:
        f.write(content)
    print(f'Updated {os.path.basename(file_path)}')
