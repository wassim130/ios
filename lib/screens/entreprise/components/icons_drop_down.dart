import 'package:flutter/material.dart';

import '../../../dictionary/entreprise_icons.dart';

class IconsDropDown extends StatefulWidget {
  final Function? callBack;
  final IconData? icon;
  const IconsDropDown({super.key, this.callBack,this.icon});

  @override
  State<IconsDropDown> createState() => _IconsDropDownState();
}

class _IconsDropDownState extends State<IconsDropDown> {
  IconData? selectedIcon;
  @override
  void initState() {
    super.initState();
    selectedIcon = widget.icon;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: DropdownButtonFormField<IconData>(
        menuMaxHeight: 200,
        decoration: InputDecoration(
            labelText: "Icons",
            labelStyle: TextStyle(color: Colors.black),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black54, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white),
        dropdownColor: Colors.white,
        style: TextStyle(fontSize: 18, color: Colors.black),
        value: selectedIcon,
        hint: Text('Select an icon'),
        isExpanded: true,
        items: icons.entries.map((entry) {
          return DropdownMenuItem<IconData>(
            value: entry.value, // Assigning the IconData value
            child: Row(
              children: [
                Icon(entry.value, color: Colors.black), // Display the icon
                SizedBox(width: 10),
                Text(entry.key), // Display the icon name
              ],
            ),
          );
        }).toList(),
        onChanged: (newIcon) {
          selectedIcon = newIcon;
          if (widget.callBack != null) {
            widget.callBack!(newIcon);
          }
        },
      ),
    );
  }
}
