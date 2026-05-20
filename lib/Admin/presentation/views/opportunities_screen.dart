import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as provider;
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/opportunity_mappers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/opportunity_providers.dart';
import '../../domain/entities/opportunity.dart';
import '../widgets/opportunity_table.dart';

class OpportunitiesScreen extends ConsumerStatefulWidget {
  final int adminId;
  const OpportunitiesScreen({super.key, required this.adminId});

  @override
  ConsumerState<OpportunitiesScreen> createState() =>
      _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends ConsumerState<OpportunitiesScreen> {
  final titleController = TextEditingController();
  final companyController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final skillsController = TextEditingController();
  final companyLogoUrlController = TextEditingController();
  String selectedWorkMode = 'ONSITE';
  bool paidStatus = false;
  DateTime? selectedDeadline;
  String selectedAudience = 'STUDENT';
  String applicationMethod = 'INTERNAL';
  final externalUrlController = TextEditingController();
  final Set<String> expandedRows = {};
  String _searchTerm = '';
  String _filterType = 'all';
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  final ScrollController _formScrollController = ScrollController();
  final supabase = Supabase.instance.client;

  String? _formError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  // ─────────────────────────────────────────────
  // VALIDATION
  // ─────────────────────────────────────────────
  String? _validateOpportunityForm() {
    if (titleController.text.trim().isEmpty) return 'Title is required';
    if (titleController.text.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (companyController.text.trim().isEmpty) {
      return 'Company name is required';
    }
    if (companyController.text.trim().length < 2) {
      return 'Company name must be at least 2 characters';
    }
    if (locationController.text.trim().isEmpty) return 'Location is required';
    if (locationController.text.trim().length < 2) {
      return 'Location must be at least 2 characters';
    }
    if (descriptionController.text.trim().isNotEmpty &&
        descriptionController.text.trim().length < 10) {
      return 'Description must be at least 10 characters if provided';
    }
    if (skillsController.text.trim().isNotEmpty &&
        skillsController.text.trim().length < 3) {
      return 'Required skills must be at least 3 characters if provided';
    }
    if (selectedDeadline == null) return 'Deadline is required';
    if (selectedDeadline != null &&
        selectedDeadline!.isBefore(DateTime.now())) {
      return 'Deadline must be in the future';
    }
    if (applicationMethod == 'EXTERNAL') {
      if (externalUrlController.text.trim().isEmpty) {
        return 'External application URL is required';
      }
      final url = externalUrlController.text.trim();
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        return 'Please enter a valid URL (e.g., https://example.com)';
      }
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // DELETE DIALOG
  // ─────────────────────────────────────────────
  Future<void> _showDeleteConfirmationDialog(Opportunity opportunity) async {
    final isDark = provider.Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.card,
            borderRadius: BorderRadius.circular(AppColors.radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentAlert.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: AppColors.accentAlertText,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Delete Opportunity',
                      style: AppTextStyles.h3.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBackground
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Opportunity info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Opportunity to delete',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      opportunity.title,
                      style: AppTextStyles.label.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      opportunity.company,
                      style: AppTextStyles.body.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Are you sure you want to delete this opportunity? This action cannot be undone.',
                style: AppTextStyles.body.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        textStyle: AppTextStyles.button,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppColors.radius),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ref
                            .read(opportunitiesProvider.notifier)
                            .deleteOpportunity(opportunity.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentAlert,
                        foregroundColor: AppColors.accentAlertText,
                        textStyle: AppTextStyles.button,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppColors.radius),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = provider.Provider.of<ThemeProvider>(context).isDarkMode;
    final opportunitiesAsync = ref.watch(opportunitiesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Opportunities Management',
                  style: AppTextStyles.h3.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showOpportunityForm(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Opportunity'),
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(180, 46),
                    backgroundColor: AppColors.interactive,
                    foregroundColor: Colors.white,
                    textStyle: AppTextStyles.button,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppColors.radius),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Search + filter row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchTerm = v),
                    style: AppTextStyles.body.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search opportunities by title or company...',
                      hintStyle: AppTextStyles.body.copyWith(
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.inputHint,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.inputHint,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkCard
                          : AppColors.inputBackground,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppColors.radius),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.inputBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppColors.radius),
                        borderSide: const BorderSide(
                          color: AppColors.interactive,
                          width: 1.5,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppColors.radius),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(width: 180, child: _buildTypeSorter(isDark)),
              ],
            ),

            const SizedBox(height: 24),

            // Table
            Expanded(
              child: opportunitiesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Error: $e', style: AppTextStyles.body)),
                data: (opportunities) {
                  if (opportunities.isEmpty) {
                    return Center(
                      child: Text(
                        'No opportunities found',
                        style: AppTextStyles.body.copyWith(
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted,
                        ),
                      ),
                    );
                  }
                  final filtered = opportunities.where((opp) {
                    final notExpired = opp.deadline.isAfter(DateTime.now());
                    final matchesSearch =
                        opp.title.toLowerCase().contains(
                          _searchTerm.toLowerCase(),
                        ) ||
                        opp.company.toLowerCase().contains(
                          _searchTerm.toLowerCase(),
                        );
                    final matchesFilter =
                        _filterType == 'all' ||
                        uiToDbType(_filterType) == opp.type;
                    return notExpired && matchesSearch && matchesFilter;
                  }).toList();

                  return OpportunityTable(
                    opportunities: filtered,
                    isDark: isDark,
                    onDelete: (id) => _showDeleteConfirmationDialog(
                      filtered.firstWhere((e) => e.id == id),
                    ),
                    onEdit: (opp) =>
                        _showOpportunityForm(context, opportunity: opp),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TYPE SORTER DROPDOWN
  // ─────────────────────────────────────────────
  Widget _buildTypeSorter(bool isDark) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppColors.radius),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filterType,
          isExpanded: true,
          dropdownColor: isDark ? AppColors.darkCard : AppColors.card,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
          ),
          style: AppTextStyles.body.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onChanged: (value) => setState(() => _filterType = value!),
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All Types')),
            DropdownMenuItem(value: 'Internship', child: Text('Internship')),
            DropdownMenuItem(value: 'Training', child: Text('Training')),
            DropdownMenuItem(value: 'Job', child: Text('Job')),
            DropdownMenuItem(value: 'Volunteer', child: Text('Volunteer')),
            DropdownMenuItem(value: 'Competition', child: Text('Competition')),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // OPPORTUNITY FORM DIALOG
  // ─────────────────────────────────────────────
  void _showOpportunityForm(BuildContext context, {Opportunity? opportunity}) {
    final isDark = provider.Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;
    final bool isEditing = opportunity != null;
    String selectedType = isEditing
        ? dbToUiType(opportunity.type)
        : 'Internship';

    if (isEditing) {
      titleController.text = opportunity.title;
      companyController.text = opportunity.company;
      locationController.text = opportunity.location ?? '';
      descriptionController.text = opportunity.description ?? '';
      skillsController.text = opportunity.requiredSkills ?? '';
      companyLogoUrlController.text = opportunity.companyLogoUrl ?? '';
      selectedWorkMode = opportunity.workMode ?? 'ONSITE';
      paidStatus = opportunity.paidStatus;
      selectedDeadline = opportunity.deadline;
      selectedAudience = opportunity.targetAudience;
      applicationMethod = opportunity.applicationMethod;
      externalUrlController.text = opportunity.externalApplyUrl ?? '';
    } else {
      titleController.clear();
      companyController.clear();
      descriptionController.clear();
      locationController.clear();
      skillsController.clear();
      companyLogoUrlController.clear();
      externalUrlController.clear();
      selectedDeadline = null;
      paidStatus = false;
      selectedWorkMode = 'ONSITE';
      selectedAudience = 'STUDENT';
      applicationMethod = 'INTERNAL';
    }

    // Reset form error when opening
    _formError = null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          final Color primaryText = isDark
              ? AppColors.darkTextPrimary
              : AppColors.textPrimary;
          final Color mutedText = isDark
              ? AppColors.darkTextMuted
              : AppColors.textMuted;
          final Color activeColor = isDark
              ? AppColors.darkInteractive
              : AppColors.interactive;
          final Color surfaceColor = isDark
              ? AppColors.darkCard
              : AppColors.card;

          return Dialog(
            backgroundColor: surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppColors.radius),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                controller: _formScrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dialog title
                    Text(
                      isEditing ? 'Edit Opportunity' : 'Add Opportunity',
                      style: AppTextStyles.h2.copyWith(color: primaryText),
                    ),

                    const SizedBox(height: 20),

                    // Error banner
                    if (_formError != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentAlert.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppColors.radius),
                          border: Border.all(
                            color: AppColors.accentAlert.withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.accentAlertText,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _formError!,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.accentAlertText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    _buildFormField('Title', titleController, '', isDark),
                    const SizedBox(height: 16),

                    _buildFormField('Company', companyController, '', isDark),
                    const SizedBox(height: 16),

                    _buildFormField(
                      'Company Logo URL (optional)',
                      companyLogoUrlController,
                      'https://',
                      isDark,
                    ),
                    const SizedBox(height: 16),

                    _buildFormField('Location', locationController, '', isDark),
                    const SizedBox(height: 16),

                    _buildDropdownField(
                      'Type',
                      selectedType,
                      [
                        'Internship',
                        'Training',
                        'Job',
                        'Volunteer',
                        'Competition',
                      ],
                      (v) => setState(() => selectedType = v!),
                      isDark,
                    ),
                    const SizedBox(height: 16),

                    _buildDropdownField(
                      'Work Mode',
                      selectedWorkMode,
                      ['REMOTE', 'ONSITE', 'HYBRID'],
                      (v) => setState(() => selectedWorkMode = v!),
                      isDark,
                    ),
                    const SizedBox(height: 16),

                    _buildFormField(
                      'Required Skills',
                      skillsController,
                      '',
                      isDark,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    _buildFormField(
                      'Description',
                      descriptionController,
                      '',
                      isDark,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Paid toggle
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBackground
                            : AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(AppColors.radius),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.inputBorder,
                        ),
                      ),
                      child: SwitchListTile(
                        value: paidStatus,
                        title: Text(
                          'Paid Opportunity',
                          style: AppTextStyles.label.copyWith(
                            color: primaryText,
                          ),
                        ),
                        subtitle: Text(
                          'Toggle if this opportunity offers compensation',
                          style: AppTextStyles.caption.copyWith(
                            color: mutedText,
                          ),
                        ),
                        activeColor: activeColor,
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppColors.radius),
                        ),
                        onChanged: (v) => setState(() => paidStatus = v),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Deadline picker
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deadline',
                          style: AppTextStyles.label.copyWith(
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDeadline ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                              builder: (context, child) => Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: activeColor,
                                    onPrimary: Colors.white,
                                    surface: surfaceColor,
                                    onSurface: primaryText,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              setState(() => selectedDeadline = picked);
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkBackground
                                  : AppColors.inputBackground,
                              borderRadius: BorderRadius.circular(
                                AppColors.radius,
                              ),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.inputBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: mutedText,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  selectedDeadline == null
                                      ? 'Select a date'
                                      : DateFormat(
                                          'MMM d, yyyy',
                                        ).format(selectedDeadline!),
                                  style: AppTextStyles.body.copyWith(
                                    color: selectedDeadline == null
                                        ? mutedText
                                        : primaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildDropdownField(
                      'Target Audience',
                      selectedAudience,
                      ['STUDENT', 'GRADUATE', 'BOTH'],
                      (v) => setState(() => selectedAudience = v!),
                      isDark,
                    ),
                    const SizedBox(height: 16),

                    _buildDropdownField(
                      'Application Method',
                      applicationMethod,
                      ['INTERNAL', 'EXTERNAL'],
                      (v) => setState(() => applicationMethod = v!),
                      isDark,
                    ),

                    if (applicationMethod == 'EXTERNAL') ...[
                      const SizedBox(height: 16),
                      _buildFormField(
                        'External Apply URL',
                        externalUrlController,
                        'https://',
                        isDark,
                      ),
                    ],

                    const SizedBox(height: 28),

                    Divider(
                      color: isDark ? AppColors.darkDivider : AppColors.divider,
                      height: 1,
                    ),

                    const SizedBox(height: 20),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            fixedSize: const Size(110, 46),
                            foregroundColor: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            textStyle: AppTextStyles.button,
                            side: BorderSide(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.border,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppColors.radius,
                              ),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () async {
                                  setState(() {
                                    _formError = null;
                                    _isSubmitting = true;
                                  });

                                  final validationError =
                                      _validateOpportunityForm();
                                  if (validationError != null) {
                                    setState(() {
                                      _formError = validationError;
                                      _isSubmitting = false;
                                    });
                                    _formScrollController.animateTo(
                                      0,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeOut,
                                    );
                                    return;
                                  }

                                  try {
                                    if (isEditing) {
                                      await ref
                                          .read(opportunitiesProvider.notifier)
                                          .updateOpportunity(opportunity!.id, {
                                            'title': titleController.text
                                                .trim(),
                                            'company_name': companyController
                                                .text
                                                .trim(),
                                            'company_logo_url':
                                                companyLogoUrlController.text
                                                    .trim()
                                                    .isEmpty
                                                ? null
                                                : companyLogoUrlController.text
                                                      .trim(),
                                            'location': locationController.text
                                                .trim(),
                                            'description': descriptionController
                                                .text
                                                .trim(),
                                            'requiredskills': skillsController
                                                .text
                                                .trim(),
                                            'work_mode': selectedWorkMode,
                                            'paidstatus': paidStatus,
                                            'type': uiToDbType(selectedType),
                                            'deadline': selectedDeadline!
                                                .toIso8601String(),
                                            'target_audience': selectedAudience,
                                            'application_method':
                                                applicationMethod,
                                            'external_apply_url':
                                                applicationMethod == 'EXTERNAL'
                                                ? externalUrlController.text
                                                      .trim()
                                                : null,
                                          });
                                    } else {
                                      await ref
                                          .read(opportunitiesProvider.notifier)
                                          .addOpportunity({
                                            'type': uiToDbType(selectedType),
                                            'title': titleController.text
                                                .trim(),
                                            'description': descriptionController
                                                .text
                                                .trim(),
                                            'company_name': companyController
                                                .text
                                                .trim(),
                                            'company_logo_url':
                                                companyLogoUrlController.text
                                                    .trim()
                                                    .isEmpty
                                                ? null
                                                : companyLogoUrlController.text
                                                      .trim(),
                                            'location': locationController.text
                                                .trim(),
                                            'work_mode': selectedWorkMode,
                                            'requiredskills': skillsController
                                                .text
                                                .trim(),
                                            'paidstatus': paidStatus,
                                            'deadline': selectedDeadline!
                                                .toIso8601String(),
                                            'postedbyadminid': widget.adminId,
                                            'target_audience': selectedAudience,
                                            'application_method':
                                                applicationMethod,
                                            'external_apply_url':
                                                applicationMethod == 'EXTERNAL'
                                                ? externalUrlController.text
                                                      .trim()
                                                : null,
                                          });
                                    }
                                    Navigator.pop(context);
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isSubmitting = false);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(110, 46),
                            backgroundColor: activeColor,
                            foregroundColor: Colors.white,
                            textStyle: AppTextStyles.button,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppColors.radius,
                              ),
                            ),
                          ),
                          child: _isSubmitting
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(isEditing ? 'Update' : 'Add'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // FORM FIELD HELPER
  // ─────────────────────────────────────────────
  Widget _buildFormField(
    String label,
    TextEditingController controller,
    String hintText,
    bool isDark, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTextStyles.body.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText.isEmpty ? null : hintText,
            hintStyle: AppTextStyles.body.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.inputHint,
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.darkBackground
                : AppColors.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppColors.radius),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppColors.radius),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.darkInteractive
                    : AppColors.interactive,
                width: 1.5,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppColors.radius),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // DROPDOWN FIELD HELPER
  // ─────────────────────────────────────────────
  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkBackground
                : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(AppColors.radius),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.inputBorder,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: isDark ? AppColors.darkCard : AppColors.card,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
              style: AppTextStyles.body.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
              onChanged: onChanged,
              items: items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: AppTextStyles.body.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // DISPOSE
  // ─────────────────────────────────────────────
  @override
  void dispose() {
    titleController.dispose();
    companyController.dispose();
    companyLogoUrlController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    skillsController.dispose();
    externalUrlController.dispose();
    _horizontalController.dispose();
    _verticalController.dispose();
    _formScrollController.dispose();
    super.dispose();
  }
}
