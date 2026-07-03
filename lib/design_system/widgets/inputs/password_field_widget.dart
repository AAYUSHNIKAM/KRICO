import 'package:flutter/material.dart';
import 'text_field_widget.dart';

class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.hint = 'Enter password',
    this.label = 'Password',
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final String hint;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      obscure: true,
      keyboardType: TextInputType.visiblePassword,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
