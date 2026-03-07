import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as provider;
import '../models/opportunity.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/opportunity_mappers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/opportunities_provider.dart';

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

  // Form state variables
  String? _formError;
  bool _isSubmitting = false;
  @override
  void initState() {
    super.initState();
  }

  String? _validateOpportunityForm() {
    // Title validation
    if (titleController.text.trim().isEmpty) {
      return 'Title is required';
    }
    if (titleController.text.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }

    // Company validation
    if (companyController.text.trim().isEmpty) {
      return 'Company name is required';
    }
    if (companyController.text.trim().length < 2) {
      return 'Company name must be at least 2 characters';
    }

    // Location validation
    if (locationController.text.trim().isEmpty) {
      return 'Location is required';
    }
    if (locationController.text.trim().length < 2) {
      return 'Location must be at least 2 characters';
    }

    // Description is optional - only validate if provided
    if (descriptionController.text.trim().isNotEmpty) {
      if (descriptionController.text.trim().length < 10) {
        return 'Description must be at least 10 characters if provided';
      }
    }

    // Skills is optional - only validate if provided
    if (skillsController.text.trim().isNotEmpty) {
      if (skillsController.text.trim().length < 3) {
        return 'Required skills must be at least 3 characters if provided';
      }
    }

    // Deadline validation
    if (selectedDeadline == null) {
      return 'Deadline is required';
    }

    // External URL validation (if external application method)
    if (applicationMethod == 'EXTERNAL') {
      if (externalUrlController.text.trim().isEmpty) {
        return 'External application URL is required';
      }

      // Basic URL validation
      final url = externalUrlController.text.trim();
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        return 'Please enter a valid URL (e.g., https://example.com)';
      }
    }

    // Deadline must be in the future
    if (selectedDeadline != null &&
        selectedDeadline!.isBefore(DateTime.now())) {
      return 'Deadline must be in the future';
    }

    return null; // No validation errors
  }

  void _showValidationError(String error) {
    setState(() {
      _formError = error;
    });

    // Auto-scroll to absolute top of the form dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_formScrollController.hasClients) {
        _formScrollController.animateTo(
          0.0, // Absolute top position
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearFormError() {
    setState(() {
      _formError = null;
    });
  }

  Future<void> _showDeleteConfirmationDialog(Opportunity opportunity) async {
    final themeProvider = provider.Provider.of<ThemeProvider>(
      context,
      listen: false,
    );
    final isDark = themeProvider.isDarkMode;

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.card,
            borderRadius: BorderRadius.circular(20),
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
              // HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentAlert.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: AppColors.accentAlertText,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Delete Opportunity',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.w600,
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBackground
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.close,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                    ),
                  ),),
                ],
              ),

              const SizedBox(height: 20),

              // OPPORTUNITY INFO
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Opportunity to Delete',
                      style: AppTextStyles.label.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      opportunity.title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
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

              const SizedBox(height: 20),

              // WARNING MESSAGE
              Text(
                'Are you sure you want to delete this opportunity? This action cannot be undone.',
                style: AppTextStyles.body.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // ACTIONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        side: BorderSide(
                          color: isDark
                              ? AppColors.darkDivider
                              : AppColors.border,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentAlertText,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = provider.Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final opportunitiesAsync = ref.watch(opportunitiesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER WITH TITLE AND ADD BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Opportunities Management',
                  style: AppTextStyles.h1.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showOpportunityForm(context);
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Opportunity'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.interactive,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// SEARCH + FILTER
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchTerm = v),
                    decoration: InputDecoration(
                      hintText: 'Search opportunities by title or company...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.inputHint,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.inputHint,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkCard
                          : AppColors.inputBackground,

                      contentPadding: const EdgeInsets.symmetric(vertical: 14),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppColors.radius),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkDivider
                              : AppColors.inputBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppColors.radius),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.darkDivider
                              : AppColors.inputBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppColors.radius),
                        borderSide: BorderSide(
                          color: AppColors.interactive,
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppColors.radius),
                        borderSide: BorderSide(
                          color: AppColors.interactive,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),
                SizedBox(
                  width: 180, // 👈 REQUIRED
                  child: _typeSorter(isDark),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// TABLE
            Expanded(
              child: opportunitiesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (opportunities) {
                  if (opportunities.isEmpty) {
                    return const Center(child: Text('No opportunities found'));
                  }

                  final filtered = opportunities.where((opp) {
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

                    return matchesSearch && matchesFilter;
                  }).toList();

                  return _buildTable(filtered, isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- TABLE HEADER ----------------

  Widget _tableHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkDivider : AppColors.divider,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _rowText(
        title: 'Title',
        company: 'Company',
        type: 'Type',
        status: 'Method',
        location: 'Location',
        workMode: 'Mode',
        paid: 'Paid',
        audience: 'Audience',
        description: 'Description',
        skills: 'Skills',
        applicants: 'Applicants',
        deadline: 'Deadline',
        actions: 'Actions',
        isHeader: true,
        isDark: isDark,
      ),
    );
  }
  // ---------------- BUILD TABLE ----------------

  Widget _buildTable(List<Opportunity> opportunities, bool isDark) {
    return Scrollbar(
      controller: _verticalController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _verticalController,
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 1500),
          child: Scrollbar(
            controller: _horizontalController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalController,
              child: Column(
                children: [
                  _tableHeader(isDark),
                  ...opportunities.map((opp) => _tableRow(opp, isDark)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- SORTER ----------------

  Widget _typeSorter(bool isDark) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade300, Colors.grey.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filterType,
          icon: const Icon(Icons.arrow_drop_down),
          iconSize: 26,
          isExpanded: true,
          dropdownColor: Colors.white, // 👈 menu background
          style: const TextStyle(fontSize: 16, color: Colors.black),
          onChanged: (value) {
            setState(() => _filterType = value!);
          },
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

  // ---------------- TABLE ROW ----------------

  Widget _tableRow(Opportunity opp, bool isDark) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkDivider : AppColors.border,
            ),
          ),
        ),
        child: _rowText(
          title: opp.title,
          company: opp.company,
          type: opp.type,
          status: opp.applicationMethod,
          location: opp.location ?? '-',
          workMode: opp.workMode ?? '-',
          paid: opp.paidStatus ? 'Yes' : 'No',
          audience: opp.targetAudience,
          description: opp.description ?? '-',
          skills: opp.requiredSkills ?? '-',
          applicants: opp.applicants.toString(),
          deadline: DateFormat('yyyy-MM-dd').format(opp.deadline),
          actions: '',
          isHeader: false,
          isDark: isDark,
          opportunity: opp,
        ),
      ),
    );
  }

  Widget _rowText({
    required String title,
    required String company,
    required String type,
    required String status,
    required String location,
    required String workMode,
    required String paid,
    required String audience,
    required String description,
    required String skills,
    required String applicants,
    required String deadline,
    required String actions,
    bool isHeader = false,
    required bool isDark,
    Opportunity? opportunity,
  }) {
    final textStyle = isHeader ? AppTextStyles.caption : AppTextStyles.body;

    return Row(
      children: [
        _cell(title, flex: 3, style: textStyle, isDark: isDark),
        _cell(company, flex: 2, style: textStyle, isDark: isDark),
        _typeBadge(type, isDark),
        _statusBadge(status, isDark),

        _cell(location, flex: 2, style: textStyle, isDark: isDark),
        _cell(workMode, flex: 1, style: textStyle, isDark: isDark),
        _cell(paid, flex: 1, style: textStyle, isDark: isDark),
        _cell(audience, flex: 1, style: textStyle, isDark: isDark),
        isHeader
            ? _cell(description, flex: 5, style: textStyle, isDark: isDark)
            : _buildDescriptionCell(opportunity!, isDark),
        _cell(skills, flex: 4, style: textStyle, isDark: isDark),
        _cell(applicants, flex: 1, style: textStyle, isDark: isDark),
        _cell(deadline, flex: 1, style: textStyle, isDark: isDark),

        if (isHeader)
          _cell(actions, flex: 1, style: textStyle, isDark: isDark)
        else
          _buildActionButtons(opportunity!, isDark),
      ],
    );
  }

  Widget _cell(
    String text, {
    required int flex,
    required TextStyle style,
    required bool isDark,
  }) {
    return SizedBox(
      width: flex * 140.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          text,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(
            color: isDark ? AppColors.darkTextPrimary : null,
          ),
        ),
      ),
    );
  }
  // ---------------- Description ----------------

  Widget _buildDescriptionCell(Opportunity opp, bool isDark) {
    final isExpanded = expandedRows.contains(opp.id);

    return SizedBox(
      width: 5 * 140.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              opp.description ?? '-',
              maxLines: isExpanded ? 8 : 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                color: isDark ? AppColors.darkTextPrimary : null,
              ),
            ),

            if ((opp.description ?? '').length > 80)
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      expandedRows.remove(opp.id);
                    } else {
                      expandedRows.add(opp.id);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    isExpanded ? "Show less" : "Show more",
                    style: TextStyle(
                      color: AppColors.interactive,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------- BADGES ----------------

  Widget _typeBadge(String type, bool isDark) {
    Color bg;
    Color fg;

    switch (type) {
      case 'Training':
        bg = Colors.purple.withOpacity(0.15);
        fg = Colors.purple;
        break;
      case 'Internship':
        bg = Colors.blue.withOpacity(0.15);
        fg = Colors.blue;
        break;
      default:
        bg = Colors.green.withOpacity(0.15);
        fg = Colors.green;
    }

    return _badge(type, bg, fg, isDark);
  }

  Widget _statusBadge(String status, bool isDark) {
    final bool isInternal = status == 'INTERNAL';
    return _badge(
      status,
      isInternal
          ? AppColors.interactive.withOpacity(0.15)
          : (isDark ? AppColors.darkDivider : AppColors.border),
      isInternal
          ? AppColors.interactive
          : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
      isDark,
    );
  }

  Widget _badge(String text, Color bg, Color fg, bool isDark) {
    return SizedBox(
      width: 140,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(color: fg),
        ),
      ),
    );
  }

  // ---------------- OPPORTUNITY FORM ----------------
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
      externalUrlController.clear();
      selectedDeadline = null;
      paidStatus = false;
      selectedWorkMode = 'ONSITE';
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: isDark ? AppColors.darkCard : AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                controller: _formScrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE
                    Text(
                      isEditing ? 'Edit Opportunity' : 'Add Opportunity',
                      style: AppTextStyles.h2,
                    ),

                    const SizedBox(height: 20),

                    // ERROR DISPLAY
                    if (_formError != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accentAlert.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.accentAlert.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.accentAlertText,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
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

                    _buildFormField('Title', titleController, '', isDark),
                    const SizedBox(height: 16),

                    _buildFormField('Company', companyController, '', isDark),
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

                    /// PAID SWITCH
                    SwitchListTile(
                      value: paidStatus,
                      title: const Text('Paid Opportunity'),
                      onChanged: (v) => setState(() => paidStatus = v),
                    ),

                    const SizedBox(height: 16),

                    /// DEADLINE PICKER
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setState(() => selectedDeadline = picked);
                        }
                      },
                      child: AbsorbPointer(
                        child: _buildFormField(
                          'Deadline',
                          TextEditingController(
                            text: selectedDeadline == null
                                ? ''
                                : DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(selectedDeadline!),
                          ),
                          '',
                          isDark,
                        ),
                      ),
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
                        'External URL',
                        externalUrlController,
                        '',
                        isDark,
                      ),
                    ],

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            // Clear previous error
                            setState(() {
                              _formError = null;
                            });

                            // Validate form
                            final validationError = _validateOpportunityForm();
                            if (validationError != null) {
                              setState(() {
                                _formError = validationError;
                              });
                              return;
                            }

                            if (isEditing) {
                              await ref
                                  .read(opportunitiesProvider.notifier)
                                  .updateOpportunity(opportunity!.id, {
                                    'title': titleController.text.trim(),
                                    'company_name': companyController.text
                                        .trim(),
                                    'location': locationController.text.trim(),
                                    'description': descriptionController.text
                                        .trim(),
                                    'requiredskills': skillsController.text
                                        .trim(),
                                    'work_mode': selectedWorkMode,
                                    'paidstatus': paidStatus,
                                    'type': uiToDbType(selectedType),
                                    'deadline': selectedDeadline!
                                        .toIso8601String(),
                                    'target_audience': selectedAudience,
                                    'application_method': applicationMethod,
                                    'external_apply_url':
                                        applicationMethod == 'EXTERNAL'
                                        ? externalUrlController.text.trim()
                                        : null,
                                  });
                            } else {
                              await ref
                                  .read(opportunitiesProvider.notifier)
                                  .addOpportunity({
                                    'type': uiToDbType(selectedType),
                                    'title': titleController.text.trim(),
                                    'description': descriptionController.text
                                        .trim(),
                                    'company_name': companyController.text
                                        .trim(),
                                    'location': locationController.text.trim(),
                                    'work_mode': selectedWorkMode,
                                    'requiredskills': skillsController.text
                                        .trim(),
                                    'paidstatus': paidStatus,
                                    'deadline': selectedDeadline!
                                        .toIso8601String(),
                                    'postedbyadminid': widget.adminId,
                                    'target_audience': selectedAudience,
                                    'application_method': applicationMethod,
                                    'external_apply_url':
                                        applicationMethod == 'EXTERNAL'
                                        ? externalUrlController.text.trim()
                                        : null,
                                  });
                            }
                            Navigator.pop(context);
                          },
                          child: Text(isEditing ? 'Update' : 'Add'),
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
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.inputHint,
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.darkDivider
                : AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkDivider : AppColors.inputBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkDivider : AppColors.inputBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.interactive, width: 1.5),
            ),
          ),
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkDivider : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppColors.darkDivider : AppColors.inputBorder,
            ),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: isDark ? AppColors.darkCard : AppColors.card,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
            underline: SizedBox(), // Remove the underline
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Opportunity opportunity, bool isDark) {
    return SizedBox(
      width: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              _showOpportunityForm(context, opportunity: opportunity);
            },
            icon: Icon(Icons.edit, color: AppColors.interactive, size: 18),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: () => _showDeleteConfirmationDialog(opportunity),
            icon: Icon(Icons.delete, color: Colors.red, size: 18),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    companyController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    skillsController.dispose();
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }
}
