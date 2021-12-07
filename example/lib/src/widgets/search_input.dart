import 'package:flutter/material.dart';

class SearchInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController textEditingController;
  final Function(String)? onTextChange;
  final Function()? onTap;
  final Widget? prefix;
  final Widget? suffix;

  const SearchInput({
    Key? key,
    this.label,
    this.hint,
    required this.textEditingController,
    this.onTextChange,
    this.onTap,
    this.prefix,
    this.suffix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      onChanged: onTextChange,
      maxLines: 1,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[400],
        border: InputBorder.none,
        hintText: hint,
        prefix: prefix,
        suffix: suffix,
      ),
    );
  }
}
