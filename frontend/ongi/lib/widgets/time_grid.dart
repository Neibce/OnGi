import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ongi/core/app_colors.dart';

class TimeGrid extends StatefulWidget {
  final List<int> initialSelected;
  final Color cellColor;
  final Color cellSelectedColor;
  final Color borderColor;
  final ValueChanged<List<int>>? onValueChanged;

  const TimeGrid({
    Key? key,
    this.initialSelected = const [],
    this.cellColor = Colors.white,
    this.cellSelectedColor = AppColors.ongiOrange,
    this.borderColor = AppColors.ongiOrange,
    this.onValueChanged,
  }) : super(key: key);

  @override
  _TimeGridState createState() => _TimeGridState();
}

class _TimeGridState extends State<TimeGrid> {
  late Set<int> _selected;
  static const int _startHour = 6;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected.toSet();
  }

  @override
  void didUpdateWidget(covariant TimeGrid old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.initialSelected, widget.initialSelected)) {
      _selected = widget.initialSelected.toSet();
    }
  }

  String _formatHour(int h) {
    final period = h < 12 ? '오전' : '오후';
    var disp = h % 12;
    if (disp == 0) disp = 12;
    return '$period ${disp}시';
  }

  @override
  Widget build(BuildContext context) {
    final hours = List<int>.generate(24, (i) => (_startHour + i) % 24);

    return SingleChildScrollView(
      child: Column(
        children: [
          for (var hour in hours)
            Row(
              children: [
                Container(
                  width: 80,
                  height: 38,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    _formatHour(hour),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                for (int seg = 0; seg < 6; seg++)
                  GestureDetector(
                    onTap: () {
                      final idx = hour * 6 + seg;
                      setState(() {
                        if (_selected.contains(idx))
                          _selected.remove(idx);
                        else
                          _selected.add(idx);
                        widget.onValueChanged?.call(_selected.toList()..sort());
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 1.0,
                        vertical: 1.0,
                      ),
                      width: 40,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _selected.contains(hour * 6 + seg)
                            ? widget.cellSelectedColor
                            : widget.cellColor,
                        border: Border.all(color: widget.borderColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
