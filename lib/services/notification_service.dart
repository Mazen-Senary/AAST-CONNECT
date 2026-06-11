import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all notifications for a student
  Future<List<Map<String, dynamic>>> fetchNotifications(int userId) async {
    try {
      final response = await _supabase
          .from('notification')
          .select()
          .eq('userid', userId)
          .order('createdat', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching notifications: $e');
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  /// Get count of unread notifications
  Future<int> getUnreadCount(int userId) async {
    try {
      final response = await _supabase
          .from('notification')
          .select()
          .eq('userid', userId)
          .eq('isread', false);

      return response.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  /// Mark a single notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _supabase
          .from('notification')
          .update({'isread': true})
          .eq('notificationid', notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(int userId) async {
    try {
      await _supabase
          .from('notification')
          .update({'isread': true})
          .eq('userid', userId)
          .eq('isread', false);
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  /// Delete a single notification from database
  Future<void> deleteNotification(int notificationId) async {
    try {
      print('🗑️ Attempting to delete notificationid: $notificationId');
      
      final response = await _supabase
          .from('notification')
          .delete()
          .eq('notificationid', notificationId);
      
      print('✅ Successfully deleted notification $notificationId');
      print('Response: $response');
    } catch (e) {
      print('❌ Error deleting notification $notificationId: $e');
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Mark notification as deleted and read (for persistence across app restarts)
  Future<void> markNotificationAsDeletedAndRead(int notificationId) async {
    try {
      print('📌 Marking notificationid $notificationId as read AND deleted');
      
      // Mark as read so it doesn't show even if delete fails
      await _supabase
          .from('notification')
          .update({'isread': true})
          .eq('notificationid', notificationId);
      
      print('✅ Marked as read: $notificationId');
    } catch (e) {
      print('❌ Error marking as read: $e');
      throw Exception('Failed to mark as read: $e');
    }
  }

  /// Listen to new notifications in real-time
  RealtimeChannel listenToNotifications(
    int userId,
    Function(Map<String, dynamic>) onNewNotification,
  ) {
    final channel = _supabase.channel('notifications:userid.eq.$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notification',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'userid',
            value: userId,
          ),
          callback: (payload) {
            onNewNotification(payload.newRecord);
          },
        )
        .subscribe();

    return channel;
  }

  /// Format timestamp relative to now
  /// Returns "5m ago", "2h ago", etc. for < 24h
  /// Returns "May 2" or "May 2, 3:45 PM" for >= 24h
  String formatTimestamp(dynamic rawTimestamp) {
    if (rawTimestamp == null) return '';
    try {
      final createdAt = DateTime.parse(rawTimestamp.toString());
      final now = DateTime.now();
      final diff = now.difference(createdAt);

      // Less than 1 minute
      if (diff.inSeconds < 60) {
        return 'just now';
      }
      // Less than 1 hour
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      }
      // Less than 1 day
      if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      }

      // 24+ hours — use date format
      final dateOnly = createdAt.month == now.month && createdAt.day == now.day
          ? 'Today'
          : '${_monthName(createdAt.month)} ${createdAt.day}';

      return '$dateOnly, ${_formatTime(createdAt)}';
    } catch (_) {
      return '';
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Get icon and color based on notification message
  Map<String, dynamic> getNotificationStyle(String message) {
    if (message.contains('approved') || message.contains('accepted')) {
      return {
        'icon': Icons.check_circle_outline,
        'color': const Color(0xFF4CAF50), // AppColors.approved
      };
    }
    if (message.contains('rejected')) {
      return {
        'icon': Icons.cancel_outlined,
        'color': const Color(0xFFF44336), // AppColors.rejected
      };
    }
    if (message.contains('New opportunity') || message.contains('opportunity')) {
      return {
        'icon': Icons.work_outline,
        'color': const Color(0xFF2196F3), // Blue
      };
    }
    if (message.contains('Deadline')) {
      return {
        'icon': Icons.alarm_outlined,
        'color': const Color(0xFFFFC107), // AppColors.pending
      };
    }
    return {
      'icon': Icons.notifications_outlined,
      'color': const Color(0xFF284B8C), // AppColors.lightPrimary
    };
  }

  /// Extract rejection reason from notification message
  /// Returns the reason part if it contains "Reason: ", otherwise returns empty string
  String extractRejectionReason(String message) {
    if (!message.contains('Reason:')) return '';
    final reasonIndex = message.indexOf('Reason:');
    return message.substring(reasonIndex + 8).trim();
  }

  /// Get default rejection message if admin didn't provide reason
  String getDefaultRejectionReason() {
    return 'No reason provided';
  }
}


