import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../constants/app_colors.dart';
import '../../widgets/rounded_container.dart';
import '../../services/notification_service.dart';
import '../../services/user_session.dart';

class StudentNotificationsScreen extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function()? loadExtraNotifications;
  final Future<void> Function(Map<String, dynamic> notification)?
      onExtraNotificationRead;
  final Future<void> Function()? onAllExtraNotificationsRead;

  const StudentNotificationsScreen({
    super.key,
    this.loadExtraNotifications,
    this.onExtraNotificationRead,
    this.onAllExtraNotificationsRead,
  });

  @override
  State<StudentNotificationsScreen> createState() =>
      _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState extends State<StudentNotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  int get _studentId => UserSession.instance.userId!;

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
      final allNotifications =
          await _notificationService.fetchNotifications(_studentId);
      final extraNotifications =
          await widget.loadExtraNotifications?.call() ??
          <Map<String, dynamic>>[];
      
      // Filter to only show unread notifications
      final unreadNotifications = allNotifications
          .where((notif) => notif['isread'] == false)
          .toList();
      unreadNotifications.addAll(extraNotifications);
      unreadNotifications.sort((a, b) {
        final aDate = DateTime.tryParse(a['createdat']?.toString() ?? '');
        final bDate = DateTime.tryParse(b['createdat']?.toString() ?? '');
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate);
      });
      
      setState(() {
        _notifications = unreadNotifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load notifications';
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  /// Delete notification from database and remove from local list
  Future<void> _deleteNotification(dynamic notificationId, int index) async {
    try {
      if (_isExtraNotification(index)) {
        await widget.onExtraNotificationRead?.call(_notifications[index]);
        setState(() {
          if (index < _notifications.length) {
            _notifications.removeAt(index);
          }
        });
        return;
      }

      // First mark as read (so it persists even if delete fails)
      await _notificationService.markNotificationAsDeletedAndRead(
        notificationId as int,
      );
      
      // Then try to delete
      try {
        await _notificationService.deleteNotification(notificationId);
      } catch (e) {
        // Don't throw - it's marked as read so it won't show
      }

      // Remove from local list immediately (no refetch!)
      setState(() {
        if (index < _notifications.length) {
          _notifications.removeAt(index);
        }
      });

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Notification deleted'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 1200),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Mark all as read and hide read notifications
  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead(_studentId);
      await widget.onAllExtraNotificationsRead?.call();

      // Update UI: filter out all read notifications
      setState(() {
        _notifications = [];
      });
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  /// Mark single notification as read and remove from list
  Future<void> _markAsRead(dynamic notificationId, int index) async {
    try {
      if (_isExtraNotification(index)) {
        await widget.onExtraNotificationRead?.call(_notifications[index]);
        setState(() {
          if (index < _notifications.length) {
            _notifications.removeAt(index);
          }
        });
        return;
      }

      if (!_notifications[index]['isread']) {
        await _notificationService.markAsRead(notificationId as int);

        // Remove from list immediately for better UX
        setState(() {
          if (index < _notifications.length) {
            _notifications.removeAt(index);
          }
        });
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  bool _isExtraNotification(int index) {
    if (index >= _notifications.length) return false;
    return _notifications[index]['is_virtual_opportunity'] == true;
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
              onPressed: _markAllAsRead,
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
                            'No notifications',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'All caught up! You\'re all set.',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
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
                          final notificationId = notification['notificationid'];

                          final style =
                              _notificationService.getNotificationStyle(message);
                          final icon = style['icon'] as IconData;
                          final color = style['color'] as Color;

                          // Extract rejection reason if present
                          final rejectionReason =
                              _notificationService.extractRejectionReason(message);
                          final hasReason = rejectionReason.isNotEmpty;

                          // Parse main message and reason part
                          String displayMessage = message;
                          if (hasReason) {
                            final reasonIndex = message.indexOf('Reason:');
                            displayMessage = message.substring(0, reasonIndex).trim();
                          }

                          return Slidable(
                            key: ValueKey(notificationId),
                            startActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              dismissible: DismissiblePane(
                                onDismissed: () {
                                  _deleteNotification(notificationId, index);
                                },
                              ),
                              children: [
                                 SlidableAction(
                                   onPressed: (_) => _deleteNotification(
                                       notificationId, index),
                                   backgroundColor: AppColors.rejected,
                                   foregroundColor: Colors.white,
                                   icon: Icons.delete_outline,
                                   label: 'Delete',
                                   borderRadius: BorderRadius.circular(18.0),
                                 ),
                               ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18.0),
                              child: GestureDetector(
                                onTap: () =>
                                    _markAsRead(notificationId, index),
                                child: RoundedContainer(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  backgroundColor: isRead
                                      ? (isDark
                                          ? Colors.grey.shade900
                                          : Colors.white)
                                      : color.withValues(alpha: 0.08),
                                  borderColor: isRead
                                      ? (isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade200)
                                      : color.withValues(alpha: 0.25),
                                  borderRadius: 18.0,
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header: Icon + Message + Unread badge
                                      Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Colored circular icon container
                                        Container(
                                          padding:
                                              const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.18),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            icon,
                                            color: color,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        // Main message
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                displayMessage,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: isRead
                                                      ? FontWeight.w500
                                                      : FontWeight.w700,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                  height: 1.35,
                                                ),
                                                maxLines: 3,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Unread indicator badge
                                        if (!isRead)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: color,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),

                                    // Rejection reason (if present)
                                    if (hasReason) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: color.withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Reason: ',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                ),
                                              ),
                                              TextSpan(
                                                text: rejectionReason,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],

                                    // Timestamp
                                    const SizedBox(height: 10),
                                    Text(
                                      _notificationService
                                          .formatTimestamp(timestamp),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

