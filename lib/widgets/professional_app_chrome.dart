import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../fresh_grads/utils/opportunities_provider.dart';
import '../fresh_grads/utils/profile_provider.dart';
import '../providers/CachedChatProvider.dart';
import '../services/fresh_grad_home_service.dart';
import '../services/theme_provider.dart';
import '../services/user_session.dart';
import '../signIn.dart';

class ProfessionalAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final int unreadNotificationCount;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onChatbotPressed;
  final VoidCallback? onTrackingPressed;
  final VoidCallback? onSupportPressed;
  final VoidCallback? onLogoutPressed;
  final VoidCallback? onThemeToggle;
  final List<Widget>? additionalActions;
  final String? photoUrl;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ProfessionalAppBar({
    super.key,
    this.unreadNotificationCount = 0,
    this.onNotificationsPressed,
    this.onProfilePressed,
    this.onChatbotPressed,
    this.onTrackingPressed,
    this.onSupportPressed,
    this.onLogoutPressed,
    this.onThemeToggle,
    this.additionalActions,
    this.photoUrl,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final barColor = backgroundColor ?? colorScheme.surface;
    final iconColor = foregroundColor ?? colorScheme.onSurface;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: barColor,
      elevation: 0,
      leadingWidth: 64.w,
      titleSpacing: 0,
      leading: IconButton(
        tooltip: 'Menu',
        onPressed: () => _openMenu(context),
        icon: Icon(Icons.menu_rounded, color: iconColor),
      ),
      title: const SizedBox.shrink(),
      actions: [
        IconButton(
          tooltip: 'Chatbot',
          onPressed: onChatbotPressed ?? () => _openChatbot(context),
          icon: Icon(Icons.smart_toy_outlined, color: iconColor),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Notifications',
              onPressed: onNotificationsPressed,
              icon: Icon(Icons.notifications_outlined, color: iconColor),
            ),
            if (unreadNotificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 18.w,
                    minHeight: 18.w,
                  ),
                  child: Center(
                    child: Text(
                      unreadNotificationCount > 99
                          ? '99+'
                          : unreadNotificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(right: 14.w, left: 2.w),
          child: GestureDetector(
            onTap: onProfilePressed,
            child: _ProfileAvatar(
              photoUrl: photoUrl,
              size: 34,
            ),
          ),
        ),
        if (additionalActions != null) ...additionalActions!,
      ],
    );
  }

  void _openMenu(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Menu',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerLeft,
          child: SafeArea(
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: mathMin(MediaQuery.of(dialogContext).size.width * 0.84, 340),
                child: _DrawerPanel(
                  onProfilePressed: onProfilePressed,
                  onTrackingPressed: onTrackingPressed,
                  onSupportPressed: onSupportPressed,
                  onThemeToggle: onThemeToggle,
                  onLogoutPressed: onLogoutPressed,
                  photoUrl: photoUrl,
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

        return SlideTransition(
          position: slide,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  void _openChatbot(BuildContext context) {
    showChatbotSheet(context);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DrawerPanel extends StatelessWidget {
  final VoidCallback? onProfilePressed;
  final VoidCallback? onTrackingPressed;
  final VoidCallback? onSupportPressed;
  final VoidCallback? onThemeToggle;
  final VoidCallback? onLogoutPressed;
  final String? photoUrl;

  const _DrawerPanel({
    required this.onProfilePressed,
    required this.onTrackingPressed,
    required this.onSupportPressed,
    required this.onThemeToggle,
    required this.onLogoutPressed,
    required this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final userName = UserSession.instance.name?.trim().isNotEmpty == true
        ? UserSession.instance.name!.trim()
        : 'AAST Connect';
    final role = UserSession.instance.role?.trim().isNotEmpty == true
        ? UserSession.instance.role!.trim().replaceAll('_', ' ')
        : 'Account';

    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 12.h),
            child: Row(
              children: [
                _ProfileAvatar(photoUrl: photoUrl, size: 52),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.6)),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              children: [
                _DrawerTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  onTap: onProfilePressed,
                ),
                _DrawerTile(
                  icon: Icons.track_changes_outlined,
                  label: 'Tracking',
                  onTap: onTrackingPressed,
                ),
                _DrawerTile(
                  icon: Icons.support_agent_outlined,
                  label: 'Support',
                  onTap: onSupportPressed,
                ),
                _DrawerTile(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {},
                  showChevron: false,
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                  value: isDark,
                  onChanged: (_) {
                    if (onThemeToggle != null) {
                      onThemeToggle!.call();
                    } else {
                      context.read<ThemeProvider>().toggleTheme();
                    }
                  },
                  title: Text(
                    'Dark mode',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  secondary: Icon(
                    isDark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onLogoutPressed ?? () => _defaultLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _defaultLogout(BuildContext context) {
    context.read<ProfileProvider>().reset();
    context.read<OpportunitiesProvider>().reset();
    context.read<CachedChatProvider>().clearActiveSession();
    FreshGradHomeService.invalidateCache();
    UserSession.instance.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool showChevron;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onTap != null;

    return ListTile(
      enabled: enabled,
      dense: true,
      minLeadingWidth: 24,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      leading: Icon(
        icon,
        color: enabled ? scheme.onSurfaceVariant : scheme.onSurfaceVariant.withValues(alpha: 0.45),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: enabled ? scheme.onSurface : scheme.onSurface.withValues(alpha: 0.45),
        ),
      ),
      trailing: showChevron
          ? Icon(
              Icons.chevron_right_rounded,
              color: enabled
                  ? scheme.onSurfaceVariant
                  : scheme.onSurfaceVariant.withValues(alpha: 0.4),
            )
          : null,
      onTap: () {
        Navigator.of(context).pop();
        if (onTap != null) {
          Future.microtask(onTap!);
        }
      },
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final double size;

  const _ProfileAvatar({
    required this.photoUrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final name = UserSession.instance.name?.trim().isNotEmpty == true
        ? UserSession.instance.name!.trim()
        : '';
    final initials = _initials(name);
    final scheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: scheme.primary.withValues(alpha: 0.16),
      backgroundImage:
          (photoUrl != null && photoUrl!.trim().isNotEmpty)
              ? NetworkImage(photoUrl!)
              : null,
      child: (photoUrl != null && photoUrl!.trim().isNotEmpty)
          ? null
          : Text(
              initials,
              style: TextStyle(
                fontSize: size * 0.34,
                fontWeight: FontWeight.w800,
                color: scheme.primary,
              ),
            ),
    );
  }

  String _initials(String value) {
    if (value.isEmpty) return '?';
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

void showChatbotSheet(BuildContext context) {
  final controller = TextEditingController();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.82,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant
                              .withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
                            child: Icon(
                              Icons.smart_toy_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Chatbot',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Expanded(
                        child: Consumer<CachedChatProvider>(
                          builder: (context, chatProvider, child) {
                            final messages = chatProvider.messages;
                            return ListView.builder(
                              controller: scrollController,
                              reverse: false,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                final isDark =
                                    Theme.of(context).brightness ==
                                    Brightness.dark;
                                final scheme =
                                    Theme.of(context).colorScheme;
                                final bubbleColor = message.isUser
                                    ? scheme.primary.withValues(
                                        alpha: isDark ? 0.22 : 0.12,
                                      )
                                    : (isDark
                                        ? const Color(0xFF2A3440)
                                        : const Color(0xFFF3F7FB));
                                final bubbleBorder = !message.isUser
                                    ? Border.all(
                                        color: isDark
                                            ? const Color(0xFF3B4A58)
                                            : const Color(0xFFD8E5F2),
                                      )
                                    : null;
                                return Align(
                                  alignment: message.isUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    margin:
                                        EdgeInsets.only(bottom: 12.h),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 12.h,
                                    ),
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width * 0.78,
                                    ),
                                    decoration: BoxDecoration(
                                      color: bubbleColor,
                                      border: bubbleBorder,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Text(
                                      message.text,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : scheme.onSurface,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                hintText: 'Ask something...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                isDense: true,
                              ),
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(
                                context,
                                controller,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Material(
                            color: Theme.of(context).colorScheme.primary,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _sendMessage(context, controller),
                              child: const SizedBox(
                                width: 48,
                                height: 48,
                                child: Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

void _sendMessage(BuildContext context, TextEditingController controller) {
  final text = controller.text.trim();
  if (text.isEmpty) return;
  controller.clear();
  context.read<CachedChatProvider>().sendMessage(text);
}

double mathMin(double a, double b) => a < b ? a : b;
