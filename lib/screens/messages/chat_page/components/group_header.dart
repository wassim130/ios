import 'package:ahmini/models/message.dart';
import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

bool isSameDay(DateTime date1, {DateTime? date2}) {
  date2 = date2 ?? DateTime.now();
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

bool isWithinLastWeek(DateTime timestamp) {
  DateTime lastWeek = DateTime.now().subtract(Duration(days: 6));
  lastWeek = DateTime(lastWeek.year, lastWeek.month, lastWeek.day);

  return timestamp.isAfter(lastWeek);
}



class GroupHeader extends StatelessWidget {
  final MessagesModel message;
  const GroupHeader({super.key,required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Center(
        child: Card(
          color: secondaryColor,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              isSameDay(message.timestamp)
                  ? DateFormat.Hm().format(message.timestamp)
                  : isWithinLastWeek(message.timestamp)
                      ? DateFormat('E HH:mm'.tr).format(message.timestamp)
                      : DateFormat('EEEE d-MM-y'.tr).format(message.timestamp),
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}