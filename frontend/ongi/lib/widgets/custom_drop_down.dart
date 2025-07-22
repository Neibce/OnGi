import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ongi/core/app_colors.dart';

class CustomDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final Function(String?) onChanged;
  final String? hint;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.ongiOrange, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: SvgPicture.asset(
            'assets/images/dropdown_icon.svg',
            width: 36,
          ),
          style: const TextStyle(
            fontSize: 25,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(15),
          elevation: 8,
          hint: hint != null ? Text(hint!, style: const TextStyle(color: Colors.grey)) : null,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String itemValue) {
            return DropdownMenuItem<String>(
              value: itemValue,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  itemValue,
                  style: TextStyle(
                      fontSize: 22,
                      color: itemValue == value
                          ? Colors.black
                          : Colors.grey,
                      fontWeight: FontWeight.w400
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}