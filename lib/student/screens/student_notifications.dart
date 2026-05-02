import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/app_colors.dart';
import '../../widgets/rounded_container.dart';
import '../../services/notification_service.dart';

class StudentNotificationsScreen extends StatefulWidget {
  const StudentNotificationsScreen({super.key});

  @override
  State<StudentNotificationsScreen> createState() =>
      _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState extends State<StudentNotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  final int _studentId = 5; // Replace with actual userId when auth is implemented

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifications =
          await _notificationService.fetchNotifications(_studentId);
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });

      // Mark all as read
      await _notificationService.markAllAsRead(_studentId);
    } catch (e) {
      setState(() {
        _error = 'Failed to load notifications';
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: () async {
                await _notificationService.markAllAsRead(_studentId);
                await _fetchNotifications();
              },
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.rejected,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error ?? 'Something went wrong',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _fetchNotifications,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications yet',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchNotifications,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          final message = notification['message'] ?? '';
                          final isRead = notification['isread'] ?? false;
                          final timestamp = notification['createdat'];

                          final style =
                              _notificationService.getNotificationStyle(message);
                          final icon = style['icon'] as IconData;
                          final color = style['color'] as Color;

                          return GestureDetector(
                            onTap: () async {
                              // Mark as read on tap
                              if (!isRead) {
                                await _notificationService
                                    .markAsRead(notification['notificationid']);
                                await _fetchNotifications();
                              }
                            },
                            child: RoundedContainer(
                              margin: const EdgeInsets.only(bottom: 12),
                              backgroundColor: isRead
                                  ? (isDark
                                      ? Colors.grey.shade900
                                      : Colors.white)
                                  : color.withOpacity(0.05),
                              borderColor: isRead
                                  ? Colors.grey.shade300
                                  : color.withOpacity(0.3),
                              borderRadius: 15.0,
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Icon with colored background
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      icon,
                                      color: color,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Message and timestamp
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isRead
                                                ? FontWeight.normal
                                                : FontWeight.w600,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            height: 1.4,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _notificationService
                                              .formatTimestamp(timestamp),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Unread indicator
                                  if (!isRead)
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

