import 'package:flutter/material.dart';
import 'package:grad_project/Admin/presentation/widgets/student_card.dart';
import 'package:provider/provider.dart' as provider;
import '../../theme/app_colors.dart';
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
  
    @override
  Widget build(BuildContext context) {
    final themeProvider = provider.Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final state = ref.watch(studentProfilesProvider);
    final notifier = ref.read(studentProfilesProvider.notifier);
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// SEARCH
            TextField(
              onChanged:notifier.updateSearch,
              decoration: InputDecoration(
                hintText:
                    'Search by ID...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.inputHint,
                ),
                prefixIcon: Icon(Icons.search, color: isDark ? AppColors.darkTextSecondary : AppColors.inputHint),
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.card,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppColors.radius),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkDivider : AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppColors.radius),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkDivider : AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppColors.radius),
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
      :state.error != null
          ? Center(
              child: Text(
                state.error!,
                style: TextStyle(color: Colors.red),
              ),
            )
          : ListView.separated(
          itemCount: state.filteredStudents.length,
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          itemBuilder: (_, index) =>
              StudentCard(
                student: state.filteredStudents[index],
                isDark: isDark,
                onToggle: notifier.toggleExpanded,
              ),
        ),
),


          ],
        ),
      ),
    );
  }
  

}
