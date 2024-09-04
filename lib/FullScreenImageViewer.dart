import 'package:flutter/material.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context); // ปิดหน้าจอเมื่อกดที่รูป
        },
        child: Center(
          child: InteractiveViewer(
            boundaryMargin: EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }
}
