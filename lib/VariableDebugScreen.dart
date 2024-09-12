// import 'package:flutter/material.dart';

// class VariableCheckScreen extends StatelessWidget {
//   // ตัวแปรทั้งหมดที่คุณให้มา
//   final String tutorName;
//   final String currentUser;
//   final String currentUserImage;
//   final String idUser;
//   final String? additionalData;
//   final String tutorId;
//   final String tutorImage;
//   final String profileImageUrl;
//   final String recipientImage;
//   final String userName;
//   final String userRole;
//   final VoidCallback? onProfileUpdated;
//   final bool canEdit;
//   final String username;

//   VariableCheckScreen({
//     required this.tutorName,
//     required this.currentUser,
//     required this.currentUserImage,
//     required this.idUser,
//     this.additionalData,
//     required this.tutorId,
//     required this.tutorImage,
//     required this.profileImageUrl,
//     required this.recipientImage,
//     required this.userName,
//     required this.userRole,
//     this.onProfileUpdated,
//     this.canEdit = false,
//     required this.username, required String userId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // ข้อมูลของตัวแปรทั้งหมดที่จะแสดง
//     List<Map<String, dynamic>> variables = [
//       {"Variable": "tutorName", "Value": tutorName},
//       {"Variable": "currentUser", "Value": currentUser},
//       {"Variable": "currentUserImage", "Value": currentUserImage},
//       {"Variable": "idUser", "Value": idUser},
//       {"Variable": "additionalData", "Value": additionalData},
//       {"Variable": "tutorId", "Value": tutorId},
//       {"Variable": "tutorImage", "Value": tutorImage},
//       {"Variable": "profileImageUrl", "Value": profileImageUrl},
//       {"Variable": "recipientImage", "Value": recipientImage},
//       {"Variable": "userName", "Value": userName},
//       {"Variable": "userRole", "Value": userRole},
//       {"Variable": "canEdit", "Value": canEdit},
//       {"Variable": "username", "Value": username},
//     ];

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('ตรวจสอบตัวแปร'),
//         backgroundColor: Colors.teal,
//       ),
//       body: ListView.builder(
//         padding: EdgeInsets.all(16.0),
//         itemCount: variables.length,
//         itemBuilder: (context, index) {
//           var variable = variables[index];
//           return Card(
//             elevation: 4,
//             margin: EdgeInsets.symmetric(vertical: 8),
//             child: ListTile(
//               title: Text(variable["Variable"]),
//               subtitle: Text(
//                 variable["Value"] != null
//                     ? variable["Value"].toString()
//                     : "null",
//                 style: TextStyle(
//                   color: variable["Value"] != null ? Colors.black : Colors.red,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
