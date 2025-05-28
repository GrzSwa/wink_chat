import 'package:flutter/material.dart';

class Field extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String placeholder;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<String>? radioOptions;
  final String? selectedRadioValue;
  final Function(String)? onRadioChanged;
  final List<String>? dropdownOptions;
  final String? selectedDropdownValue;
  final Function(String)? onDropdownChanged;

  const Field._({
    Key? key,
    required this.controller,
    this.label,
    required this.placeholder,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.radioOptions,
    this.selectedRadioValue,
    this.onRadioChanged,
    this.dropdownOptions,
    this.selectedDropdownValue,
    this.onDropdownChanged,
  }) : super(key: key);

  factory Field.email({
    required TextEditingController controller,
    String placeholder = 'Enter your email',
    String label = "Email",
  }) {
    return Field._(
      controller: controller,
      label: label,
      placeholder: placeholder,
      keyboardType: TextInputType.emailAddress,
    );
  }

  factory Field.password({
    required TextEditingController controller,
    String placeholder = 'Enter your password',
    String label = "Password",
  }) {
    return Field._(
      controller: controller,
      label: label,
      placeholder: placeholder,
      obscureText: true,
    );
  }

  factory Field.input({
    required TextEditingController controller,
    String label = 'Input',
    String placeholder = 'Enter value',
  }) {
    return Field._(
      controller: controller,
      label: label,
      placeholder: placeholder,
    );
  }

  factory Field.radio({
    String label = "Radio button",
    required List<String> options,
    required String selectedValue,
    required Function(String) onChanged,
  }) {
    return Field._(
      controller: TextEditingController(),
      label: label,
      placeholder: '',
      radioOptions: options,
      selectedRadioValue: selectedValue,
      onRadioChanged: onChanged,
    );
  }

  factory Field.select({
    String label = "Select",
    required List<String> options,
    required String selectedValue,
    required Function(String) onChanged,
  }) {
    return Field._(
      controller: TextEditingController(),
      label: label,
      placeholder: '',
      dropdownOptions: options,
      selectedDropdownValue: selectedValue,
      onDropdownChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (radioOptions != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label!, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children:
                radioOptions!
                    .map(
                      (option) => Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Radio<String>(
                            value: option,
                            groupValue: selectedRadioValue,
                            onChanged: (value) {
                              if (value != null && onRadioChanged != null) {
                                onRadioChanged!(value);
                              }
                            },
                          ),
                          Text(option),
                        ],
                      ),
                    )
                    .toList(),
          ),
        ],
      );
    }

    if (dropdownOptions != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label!, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: selectedDropdownValue,
              isExpanded: true,
              underline: Container(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              items:
                  dropdownOptions!.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null && onDropdownChanged != null) {
                  onDropdownChanged!(newValue);
                }
              },
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label!, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black12, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black12, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black12, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
