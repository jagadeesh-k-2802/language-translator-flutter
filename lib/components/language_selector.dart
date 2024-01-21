import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:language_translator/data/language.dart';
import 'package:language_translator/extensions/map.dart';

typedef ValueSetter<T> = void Function(T value);

class LanguageSelector extends StatefulWidget {
  final String? from;
  final String? to;
  final ValueSetter<String?> onFromChange;
  final ValueSetter<String?> onToChange;

  const LanguageSelector({
    Key? key,
    required this.from,
    required this.to,
    required this.onFromChange,
    required this.onToChange,
  }) : super(key: key);

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final inversedLanguageList = languageList.inverse;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('From'),
        DropdownButton<String>(
          value: languageList[widget.from],
          icon: const Icon(CupertinoIcons.chevron_down),
          elevation: 16,
          isExpanded: true,
          style: const TextStyle(
            fontSize: 18.0,
            color: Colors.black,
          ),
          underline: Container(
            height: 0,
          ),
          onChanged: (String? value) {
            widget.onFromChange(inversedLanguageList[value]);
          },
          items: languageList.values.map<DropdownMenuItem<String>>((
            String value,
          ) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
        const Divider(),
        const SizedBox(height: 10),
        const Text('To'),
        DropdownButton<String>(
          value: languageList[widget.to],
          icon: const Icon(CupertinoIcons.chevron_down),
          elevation: 16,
          isExpanded: true,
          style: const TextStyle(
            fontSize: 18.0,
            color: Colors.black,
          ),
          underline: Container(
            height: 0,
          ),
          onChanged: (String? value) {
            widget.onToChange(inversedLanguageList[value]);
          },
          items: languageList.values.map<DropdownMenuItem<String>>((
            String value,
          ) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
