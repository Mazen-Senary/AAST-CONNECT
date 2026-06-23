import 'package:flutter/material.dart';
import 'package:grad_project/Admin/presentation/widgets/student_card.dart';
import 'package:provider/provider.dart' as provider;
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/student_providers.dart';

class StudentProfilesScreen extends ConsumerStatefulWidget {
  const StudentProfilesScreen({super.key});

  @override
  ConsumerState<StudentProfilesScreen> createState() =>
      _StudentProfilesScreenState();
}

class _StudentProfilesScreenState extends ConsumerState<StudentProfilesScreen> {
  final _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    // ✅ Trigger loadMore when near bottom
    _scrollController.addListener(() {
      print(
        '📜 scroll: ${_scrollController.position.pixels} / ${_scrollController.position.maxScrollExtent}',
      );
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(studentProfilesProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = provider.Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final state = ref.watch(studentProfilesProvider);
    final notifier = ref.read(studentProfilesProvider.notifier);
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ADMIN PANEL',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Student Profiles',
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            /// SEARCH
            TextField(
              onChanged: notifier.updateSearch,
              decoration: InputDecoration(
                hintText: 'Search by ID...',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.inputHint,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.inputHint,
                ),
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppColors.radius),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkDivider : AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppColors.radius),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkDivider : AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppColors.radius),
                  borderSide: BorderSide(
                    color: AppColors.interactive,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// GRID
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                  ? Center(
                      child: Text(
                        state.error!,
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      itemCount:
                          state.filteredStudents.length +
                          (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (_, index) {
                        if (index == state.filteredStudents.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return StudentCard(
                          student: state.filteredStudents[index],
                          isDark: isDark,
                          onToggle: notifier.toggleExpanded,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
