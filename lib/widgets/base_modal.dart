import 'package:flutter/material.dart';

class BaseModal extends StatelessWidget {
  final String title;
  final Widget child;
  final double? heightFactor;
  final List<Widget>? actions;

  const BaseModal({
    super.key,
    required this.title,
    required this.child,
    this.heightFactor = 0.9,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * heightFactor!,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Fixed Header
          Padding(
            padding: const EdgeInsets.all(25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Row(
                  children: [
                    if (actions != null) ...actions!,
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  static void show({
    required BuildContext context,
    required String title,
    required Widget child,
    double? heightFactor,
    List<Widget>? actions,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => BaseModal(
        title: title,
        heightFactor: heightFactor,
        actions: actions,
        child: child,
      ),
    );
  }
}
