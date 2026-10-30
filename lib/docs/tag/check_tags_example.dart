import 'package:flutter/material.dart';
import 'package:widgets_easier/widgets_easier.dart';

/// Picks a set of interests with controlled [CheckTag]s and echoes the
/// selection back, the way a filter bar would.
class CheckTagsExample extends StatefulWidget {
  const CheckTagsExample({super.key});

  @override
  State<CheckTagsExample> createState() => _CheckTagsExampleState();
}

class _CheckTagsExampleState extends State<CheckTagsExample> {
  static const List<String> _options = [
    'Flutter',
    'Dart',
    'Vue',
    'TypeScript',
    'Rust',
    'Go',
  ];

  final Set<String> _selected = {'Flutter'};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in _options)
              CheckTag(
                option,
                checked: _selected.contains(option),
                showCheckIcon: true,
                onChanged: (checked) {
                  setState(() {
                    if (checked) {
                      _selected.add(option);
                    } else {
                      _selected.remove(option);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text('已选择：${_selected.isEmpty ? '无' : _selected.join('、')}'),
      ],
    );
  }
}
