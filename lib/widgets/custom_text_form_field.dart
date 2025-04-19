import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final String valueKey;
  final TextInputType inputType;

  CustomTextFormField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    required this.valueKey,
    required this.inputType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: const Color.fromARGB(255, 211, 211, 211)
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: const Color.fromARGB(255, 131, 131, 131)
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        
      ),
      textInputAction: TextInputAction.next,
      controller: controller,
      key: ValueKey(valueKey),
      validator:(value) {
        if (value.toString().isEmpty){
          return "Field can't be empty";
        } else {
          return null;
        }
      },
      keyboardType: inputType,
    );
  }
}