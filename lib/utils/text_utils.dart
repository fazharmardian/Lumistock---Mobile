import 'package:flutter/material.dart';
class TextUtil extends StatelessWidget {
  String text;
  Color? color;
  double? size;
  bool? weight;
  TextUtil({super.key,required this.text,this.size,this.color,this.weight});

  @override
  Widget build(BuildContext context) {
    return  Text(text,

      style: TextStyle(color:color??Colors.white,fontSize:size?? 16,
          fontWeight:weight==null?FontWeight.w600: FontWeight.w700
      ),);
  }
}
  // 100: Color.fromRGBO(26, 31, 54, 1), // #1a1f36
  // 200: Color.fromRGBO(21, 25, 53, 1), // #151935
  // 300: Color.fromRGBO(16, 18, 46, 1), // #10122e
  // 400: Color.fromRGBO(10, 12, 41, 1), // #0a0c29
  // 500: Color.fromRGBO(5, 9, 34, 1),   // #050922
  // 600: Color.fromRGBO(4, 8, 29, 1),   // #04081d
  // 700: Color.fromRGBO(3, 6, 23, 1),   // #030617
  // 800: Color.fromRGBO(2, 5, 18, 1),   // #020512
  // 900: Color.fromRGBO(1, 3, 12, 1)  