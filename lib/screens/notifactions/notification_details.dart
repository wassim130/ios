// notification_details.dart
import 'package:ahmini/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import '../../models/notification.dart';
import '../../controllers/theme_controller.dart';

bool isSameDay(DateTime date1, DateTime? date2) {
  date2 = date2 ?? DateTime.now();
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationModel>? notifications;
  bool isSelectionMode = false;
  Set<int> selectedNotifications = {}; // Changed to int to match the model
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    notifications = await NotificationModel.fetchAll();
    print(notifications);
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleSelection(int notificationId) {
    // Changed to int
    setState(() {
      if (selectedNotifications.contains(notificationId)) {
        selectedNotifications.remove(notificationId);
        if (selectedNotifications.isEmpty) {
          isSelectionMode = false;
        }
      } else {
        selectedNotifications.add(notificationId);
      }
      print(selectedNotifications);
    });
  }

  void _startSelectionMode() {
    setState(() {
      isSelectionMode = true;
    });
  }

  void _cancelSelection() {
    setState(() {
      isSelectionMode = false;
      selectedNotifications.clear();
    });
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Gérer l'interaction avec la notification ici
    // Par exemple, mettre à jour l'état de lecture dans la base de données
  }

  void _deleteSelection() async {
    final response = await NotificationModel.delete(selectedNotifications);
    _fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    if (notifications != null) {
      notifications!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final primaryColorTheme = isDark ? darkPrimaryColor : primaryColor;
      final backgroundColorTheme = isDark ? darkBackgroundColor : backgroundColor;
      final secondaryColorTheme = isDark ? darkSecondaryColor : secondaryColor;

      return Scaffold(
        backgroundColor: primaryColorTheme,
        appBar: AppBar(
          backgroundColor: primaryColorTheme,
          elevation: 0,
          title: Text(
            isSelectionMode
                ? '${selectedNotifications.length} sélectionné(s)'
                : 'Notifications'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              isSelectionMode ? Icons.close : Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              if (isSelectionMode) {
                _cancelSelection();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            if (!isSelectionMode) ...[
              IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: _startSelectionMode,
              ),
            ] else ...[
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () async {
                  _deleteSelection();
                },
              ),
              IconButton(
                icon: Icon(Icons.done_all, color: Colors.white),
                onPressed: () async {
                  // Implémenter le marquage comme lu
                  _cancelSelection();
                  await _fetchNotifications();
                },
              ),
            ],
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                textAlign: TextAlign.center,
                'Gérez vos notifications et restez informé des mises à jour importantes'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColorTheme,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: notifications == null
                    ? Center(
                  child: CircularProgressIndicator(
                    color: primaryColorTheme,
                  ),
                )
                    : GroupedListView<NotificationModel, DateTime>(
                  padding: EdgeInsets.only(top: 20, bottom: 50),
                  order: GroupedListOrder.DESC,
                  elements: notifications!
                    ..sort((b, a) {
                      int groupComparison =
                      b.createdAt.compareTo(a.createdAt);
                      if (groupComparison == 0) {
                        // If in the same group, sort notifications in ASC order (oldest first)
                        return a.createdAt.compareTo(b.createdAt);
                      }
                      return groupComparison;
                    }),
                  groupBy: (notification) => DateTime(
                    notification.createdAt.year,
                    notification.createdAt.month,
                    notification.createdAt.day,
                  ),
                  groupHeaderBuilder: (notification) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: secondaryColorTheme,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isSameDay(notification.createdAt, null)
                              ? "Aujourd'hui"
                              : isSameDay(
                              notification.createdAt,
                              DateTime.now()
                                  .subtract(Duration(days: 1)))
                              ? "Hier"
                              : DateFormat.yMMMMEEEEd()
                              .format(notification.createdAt),
                          style: TextStyle(
                            color: isDark ? Colors.white.withOpacity(0.87) : Colors.black.withOpacity(0.87),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  itemBuilder: (context, notification) => NotificationCard(
                    notification,
                    isSelected:
                    selectedNotifications.contains(notification.id),
                    onSelect: () => _toggleSelection(notification.id),
                    isSelectionMode: isSelectionMode,
                    onTap: () => _handleNotificationTap(notification),
                    isDark: isDark,
                    primaryColor: primaryColorTheme,
                    secondaryColor: secondaryColorTheme,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isSelected;
  final VoidCallback onSelect;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;

  const NotificationCard(
      this.notification, {
        super.key,
        required this.isSelected,
        required this.onSelect,
        required this.isSelectionMode,
        required this.onTap,
        required this.isDark,
        required this.primaryColor,
        required this.secondaryColor,
      });

  @override
  Widget build(BuildContext context) {
    final notificationTheme = _getNotificationTheme(notification.type);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: isSelectionMode ? onSelect : onTap,
        onLongPress: !isSelectionMode ? onSelect : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? secondaryColor.withOpacity(0.5)
                : isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : Colors.grey.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: primaryColor,
                  ),
                ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: notificationTheme.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notificationTheme.icon,
                  color: notificationTheme.color,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white.withOpacity(0.87) : Colors.black.withOpacity(0.87),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      notification.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white.withOpacity(0.70) : Colors.black.withOpacity(0.54),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: isDark ? Colors.white.withOpacity(0.60) : Colors.grey,
                        ),
                        SizedBox(width: 4),
                        Text(
                          DateFormat.Hm().format(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white.withOpacity(0.60) : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationTheme {
  final Color color;
  final IconData icon;

  NotificationTheme({required this.color, required this.icon});
}

NotificationTheme _getNotificationTheme(String type) {
  switch (type) {
    case "alert":
      return NotificationTheme(
        color: primaryColor,
        icon: Icons.error_outline,
      );
    case "warning":
      return NotificationTheme(
        color: Colors.orange,
        icon: Icons.warning_amber_outlined,
      );
    case "success":
      return NotificationTheme(
        color: Colors.green,
        icon: Icons.check_circle_outline,
      );
    case "info":
      return NotificationTheme(
        color: Colors.blue,
        icon: Icons.info_outline,
      );
    default:
      return NotificationTheme(
        color: Color.fromARGB(255, 0, 0, 0),
        icon: Icons.notifications_outlined,
      );
  }
}