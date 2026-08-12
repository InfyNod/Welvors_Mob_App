// import 'package:welvors/export.dart';

// class CameraProgressCircle extends StatefulWidget {
//   const CameraProgressCircle({super.key});

//   @override
//   State<CameraProgressCircle> createState() => _CameraProgressCircleState();
// }

// class _CameraProgressCircleState extends State<CameraProgressCircle>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat(); // Infinite rotation
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 260,
//       height: 260,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           RotationTransition(
//             turns: _controller,
//             child: SizedBox(
//               width: MediaQuery.of(context).size.width * 0.50,
//               height: MediaQuery.of(context).size.width * 0.50,
//               child: CircularProgressIndicator(
//                 value: 0.25,
//                 strokeWidth: 3,
//                 strokeCap: StrokeCap.round,
//                 backgroundColor: Color(0xffF3EDEE),
//                 valueColor: AlwaysStoppedAnimation(Mycolor.redlight),
//               ),
//             ),
//           ),

//           Container(
//             width: MediaQuery.of(context).size.width * 0.40,
//             height: MediaQuery.of(context).size.width * 0.40,
//             decoration: const BoxDecoration(
//               shape: BoxShape.circle,
//               color: Color(0xffF6F2F4),
//             ),
//             child: const Center(
//               child: Text("😀", style: TextStyle(fontSize: 55)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
