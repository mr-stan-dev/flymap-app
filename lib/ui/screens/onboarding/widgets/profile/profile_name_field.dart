import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flymap/entity/user_profile.dart';

class ProfileNameField extends StatefulWidget {
  const ProfileNameField({
    required this.initialValue,
    required this.onChanged,
    super.key,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<ProfileNameField> createState() => _ProfileNameFieldState();
}

class _ProfileNameFieldState extends State<ProfileNameField> {
  late final TextEditingController _controller = TextEditingController(
    text: _capDisplayName(widget.initialValue),
  );

  @override
  void didUpdateWidget(covariant ProfileNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue == widget.initialValue) return;
    final cappedValue = _capDisplayName(widget.initialValue);
    if (_controller.text == cappedValue) return;
    _controller.value = TextEditingValue(
      text: cappedValue,
      selection: TextSelection.collapsed(offset: cappedValue.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textCapitalization: TextCapitalization.words,
      inputFormatters: [
        LengthLimitingTextInputFormatter(UserProfile.maxDisplayNameLength),
      ],
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: 'Your name',
        prefixIcon: const Icon(Icons.person_outline_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  String _capDisplayName(String value) {
    if (value.length <= UserProfile.maxDisplayNameLength) {
      return value;
    }
    return value.substring(0, UserProfile.maxDisplayNameLength);
  }
}
