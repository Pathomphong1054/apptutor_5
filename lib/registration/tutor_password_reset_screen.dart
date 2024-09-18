// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ResetPasswordScreen extends StatefulWidget {
//   final String userRole;

//   ResetPasswordScreen({required this.userRole});

//   @override
//   _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
// }

// class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   bool _isLoading = false;

//   Future<void> resetPassword() async {
//     final String email = _emailController.text;

//     setState(() {
//       _isLoading = true;
//     });

//     final response = await http.post(
//       Uri.parse('http://10.5.50.138/tutoring_app/reset_password.php'),
//       body: {
//         'email': email,
//         'role': widget.userRole,
//       },
//     );

//     setState(() {
//       _isLoading = false;
//     });

//     if (response.statusCode == 200) {
//       final responseData = json.decode(response.body);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(responseData['message'])),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to parse response')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Reset Password'),
//         backgroundColor: const Color.fromARGB(255, 28, 195, 198),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               const Color.fromARGB(255, 28, 195, 198),
//               const Color.fromARGB(255, 249, 249, 249)
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Center(
//           child: Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Card(
//               elevation: 10,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16.0),
//               ),
//               child: Padding(
//                 padding: EdgeInsets.all(24.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'Enter your email to reset your password:',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 20),
//                     TextFormField(
//                       controller: _emailController,
//                       decoration: InputDecoration(
//                         labelText: 'Email',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         prefixIcon: Icon(Icons.email),
//                       ),
//                       keyboardType: TextInputType.emailAddress,
//                     ),
//                     SizedBox(height: 20),
//                     _isLoading
//                         ? CircularProgressIndicator()
//                         : ElevatedButton(
//                             onPressed: resetPassword,
//                             style: ElevatedButton.styleFrom(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 40, vertical: 15),
//                               backgroundColor: Colors.blueAccent,
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                             ),
//                             child: Text(
//                               'Send Reset Link',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
