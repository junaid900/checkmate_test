import 'package:flutter/material.dart';

class ShadowInputField extends StatefulWidget {
  final String hintText;
  bool obscureText = false;
  final TextEditingController? controller;
  Function? onChange;

  ShadowInputField({super.key, required this.hintText, this.controller, this.obscureText = false, this.onChange = null});

  @override
  State<ShadowInputField> createState() => _ShadowInputFieldState();
}

class _ShadowInputFieldState extends State<ShadowInputField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: Colors.white, // Hind Grey
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.1),
            // Slight shadow color
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.obscureText,
        onChanged: (value){
          if(widget.onChange != null)
            widget.onChange!(value);
        },
        decoration: InputDecoration(
          hintText: widget.hintText,
          // hintText:"",
          hintStyle: TextStyle(color: Colors.black.withOpacity(.8)),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
      ),
    );
  }
}

// class ShadowInputField extends StatelessWidget {
//   final String hintText;
//   final TextEditingController? controller;
//
//   ShadowInputField({super.key, required this.hintText, this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.only(left: 16),
//       decoration: BoxDecoration(
//         color: Colors.white, // Hind Grey
//         borderRadius: BorderRadius.circular(10.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(.1),
//             // Slight shadow color
//             spreadRadius: 1,
//             blurRadius: 3,
//             offset:
//             Offset(0, 2), // changes position of shadow
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(
//           hintText: hintText,
//           // hintText:"",
//           hintStyle:
//           TextStyle(color: Colors.black.withOpacity(.8)),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.symmetric(
//               horizontal: 16.0, vertical: 12.0),
//         ),
//       ),
//     );
//   }
// }
