import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PushNotificationScreen extends StatefulWidget {
  const PushNotificationScreen({super.key});

  @override
  State<PushNotificationScreen> createState() => _PushNotificationScreenState();
}

class _PushNotificationScreenState extends State<PushNotificationScreen> {
  bool newMatches = true;
  bool messages = true;
  bool likesAndRoses = true;
  bool eventsNearYou = false;
  bool promotionsOffers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        255,
        255,
        255,
      ), // Light beige background
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 16,
              ),
            ),
          ),
        ),
        title: const Text(
          'Push Notifications',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSwitchItem(
                    emoji: '💖',
                    iconBgColor: const Color(0xFFFCE8EE),
                    title: 'New matches',
                    value: newMatches,
                    onChanged: (val) => setState(() => newMatches = val),
                  ),
                  _buildDivider(),
                  _buildSwitchItem(
                    emoji: '💬',
                    iconBgColor: const Color(0xFFE8F1FC),
                    title: 'Messages',
                    value: messages,
                    onChanged: (val) => setState(() => messages = val),
                  ),
                  _buildDivider(),
                  _buildSwitchItem(
                    emoji: '⭐',
                    iconBgColor: const Color(0xFFFBF4E4),
                    title: 'Likes & Roses',
                    value: likesAndRoses,
                    onChanged: (val) => setState(() => likesAndRoses = val),
                  ),
                  _buildDivider(),
                  _buildSwitchItem(
                    emoji: '🎉',
                    iconBgColor: const Color(0xFFE8F4FC), // Light blue-ish
                    title: 'Events near you',
                    value: eventsNearYou,
                    onChanged: (val) => setState(() => eventsNearYou = val),
                  ),
                  _buildDivider(),
                  _buildSwitchItem(
                    emoji: '🎁',
                    iconBgColor: const Color(0xFFEAFCE8), // Light green
                    title: 'Promotions & offers',
                    value: promotionsOffers,
                    onChanged: (val) => setState(() => promotionsOffers = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                'Turn off promotions to only get notified about real activity.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
      indent: 64, // To align with the text, skipping the icon
      endIndent: 16,
    );
  }

  Widget _buildSwitchItem({
    required String emoji,
    required Color iconBgColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFE43A6A),
          ),
        ],
      ),
    );
  }
}
