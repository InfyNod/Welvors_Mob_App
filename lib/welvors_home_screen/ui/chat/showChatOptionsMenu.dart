// import 'package:flutter/material.dart';

// void showChatOptionsMenu(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (context) => const ChatOptionsMenuSheet(),
//   );
// }

// class ChatOptionsMenuSheet extends StatefulWidget {
//   const ChatOptionsMenuSheet({Key? key}) : super(key: key);

//   @override
//   State<ChatOptionsMenuSheet> createState() => _ChatOptionsMenuSheetState();
// }

// class _ChatOptionsMenuSheetState extends State<ChatOptionsMenuSheet> {
//   bool _isMuted = false;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Top Drag Handle Bar
//           Container(
//             width: 40,
//             height: 4,
//             margin: const EdgeInsets.only(bottom: 20),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),

//           // Profile Picture with Online Badge
//           Stack(
//             children: [
//               const CircleAvatar(
//                 radius: 42,
//                 backgroundImage: NetworkImage(
//                   'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
//                 ),
//               ),
//               Positioned(
//                 bottom: 2,
//                 right: 2,
//                 child: Container(
//                   width: 14,
//                   height: 14,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF27AE60),
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white, width: 2.5),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Name and Online Status
//           const Text(
//             'Aanya',
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: const [
//               Icon(Icons.circle, color: Color(0xFF27AE60), size: 8),
//               SizedBox(width: 4),
//               Text(
//                 'Online',
//                 style: TextStyle(
//                   color: Color(0xFF27AE60),
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: const [
//               Icon(Icons.location_on_outlined, color: Colors.grey, size: 14),
//               SizedBox(width: 2),
//               Text(
//                 'Mumbai, India',
//                 style: TextStyle(color: Colors.grey, fontSize: 13),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           const Divider(height: 1, color: Color(0xFFF0F0F0)),
//           const SizedBox(height: 16),

//           // Section 1: PREFERENCES
//           _buildSectionHeader('PREFERENCES'),
//           const SizedBox(height: 12),

//           _buildMenuItem(
//             icon: Icons.favorite,
//             iconColor: const Color(0xFFEE5370),
//             title: 'Relationship Tags',
//             subtitle: 'Define how you connect',
//             onTap: () {},
//           ),
//           const SizedBox(height: 12),

//           _buildSwitchItem(
//             icon: Icons.notifications_off_outlined,
//             title: 'Mute Notifications',
//             value: _isMuted,
//             onChanged: (val) {
//               setState(() {
//                 _isMuted = val;
//               });
//             },
//           ),
//           const SizedBox(height: 12),

//           _buildMenuItem(
//             icon: Icons.photo_outlined,
//             iconColor: Colors.black54,
//             title: 'Media, Links & Docs',
//             subtitle: '48 shared items',
//             onTap: () {},
//           ),
//           const SizedBox(height: 20),

//           // Section 2: PRIVACY & SAFETY
//           _buildSectionHeader('PRIVACY & SAFETY'),
//           const SizedBox(height: 12),

//           _buildDangerItem(
//             icon: Icons.error_outline_rounded,
//             title: 'Report User',
//             onTap: () {},
//           ),
//           const SizedBox(height: 12),

//           _buildDangerItem(
//             icon: Icons.block,
//             title: 'Block Aanya',
//             onTap: () {},
//           ),
//           const SizedBox(height: 24),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.bold,
//           color: Colors.grey,
//           letterSpacing: 0.8,
//         ),
//       ),
//     );
//   }

//   Widget _buildMenuItem({
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF7F7F8),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: iconColor, size: 20),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 Text(
//                   subtitle,
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//           const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
//         ],
//       ),
//     );
//   }

//   Widget _buildSwitchItem({
//     required IconData icon,
//     required String title,
//     required bool value,
//     required ValueChanged<bool> onChanged,
//   }) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: const Color(0xFFF7F7F8),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, color: Colors.black54, size: 20),
//         ),
//         const SizedBox(width: 14),
//         Expanded(
//           child: Text(
//             title,
//             style: const TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//         ),
//         Switch(
//           value: value,
//           onChanged: onChanged,
//           activeColor: const Color(0xFFEE5370),
//         ),
//       ],
//     );
//   }

//   Widget _buildDangerItem({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: const Color(0xFFFDE8ED),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: const Color(0xFFEE5370), size: 20),
//           ),
//           const SizedBox(width: 14),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFFEE5370),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
