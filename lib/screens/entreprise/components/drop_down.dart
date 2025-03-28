import 'package:ahmini/services/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SelectDropdown extends StatefulWidget {
  const SelectDropdown({super.key});
  @override
  _SelectDropdownState createState() => _SelectDropdownState();
}

class _SelectDropdownState extends State<SelectDropdown> {
  List<dynamic> _options = []; // Holds fetched options
  String? _selectedValue; // Stores selected value

  @override
  void initState() {
    super.initState();
    fetchOptions(); // Fetch data when widget initializes
  }

  // Function to fetch data from the API
  Future<void> fetchOptions() async {
    final url = Uri.parse(
        '$httpURL/api/technologies/?id=0'); // Replace with your API URL
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _options = data['technologies'];
        });
      }
    } catch (e) {
      print('Error fetching options: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: DropdownButtonFormField<String>(
        menuMaxHeight: 200,
        decoration: InputDecoration(
          labelText: "Technologies",
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black), // Default border color
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors.black54, width: 2), // Color when focused
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
        ),
        dropdownColor: Colors.white,
        style: TextStyle(
          fontSize: 18,
          color: Colors.black,
        ),
        value: _selectedValue,
        hint: Text('Select an option'),
        isExpanded: true,
        items: _options.map((option) {
          return DropdownMenuItem<String>(
            value: option['id']
                .toString(), // Adjust based on API response structure
            child: Text(option['name']), // Adjust based on API response
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedValue = newValue;
          });
        },
      ),
    );
  }
}
