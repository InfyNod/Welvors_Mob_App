import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';

/// Modal bottom sheet for choosing a contact from the device's address book.
class ChatContactPickerSheet extends StatelessWidget {
  final List<Contact> contacts;

  const ChatContactPickerSheet({super.key, required this.contacts});

  static Future<Contact?> show(BuildContext context, List<Contact> contacts) {
    return showModalBottomSheet<Contact>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => ChatContactPickerSheet(contacts: contacts),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Text('Select Contact', style: AppText.h1),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (ctx, index) {
                  final contact = contacts[index];
                  final displayName = contact.displayName ?? '';
                  final phone = contact.phones.isNotEmpty
                      ? contact.phones.first.number
                      : '';

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(displayName),
                    subtitle: Text(
                      phone.isNotEmpty ? phone : 'No phone number',
                    ),
                    onTap: () {
                      Navigator.pop(ctx, contact);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
