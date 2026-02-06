import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/opportunity.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OpportunitiesScreen extends StatefulWidget {
  final int adminId;
  const OpportunitiesScreen({super.key , required this.adminId,});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  List<Opportunity> _opportunities = [];
  bool _isLoading = true;
  final titleController = TextEditingController();
  final companyController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final skillsController = TextEditingController();
  String selectedType = 'Internship';
String selectedWorkMode = 'ONSITE';
bool paidStatus = false;
DateTime? selectedDeadline;

  String _searchTerm = '';
  String _filterType = 'all';
  final supabase = Supabase.instance.client;
  final Map<String, String> typeMap = {
  'Internship': 'INTERNSHIP',
  'Training': 'TRAINING',
  'Job': 'JOB',
  'Volunteer': 'VOLUNTEER',
  'Competition': 'COMPETITION',
};
  @override
  void initState() {
    super.initState();
    _fetchOpportunities();
  }

Future<void> _fetchOpportunities() async {
  try {
    final response = await supabase
        .from('vacancies')
        .select('*')
        .order('created_at', ascending: false);

    debugPrint('FETCHED ROWS: ${response.length}');
    debugPrint(response.toString());

    setState(() {
      _opportunities = response.map<Opportunity>((row) {
        return Opportunity(
          id: row['id'].toString(),
          title: row['title'],
          company: row['company_name'] ?? '—',
          type: row['type'],
          status: 'Active',
          applicants: 0,
          posted: DateTime.parse(row['created_at']),
          deadline: DateTime.parse(row['deadline']),
        );
      }).toList();
      _isLoading = false;
    });
  } catch (e) {
    debugPrint('FETCH ERROR: $e');
    setState(() => _isLoading = false);
  }
}

  List<Opportunity> get _filteredOpportunities {
    return _opportunities.where((opp) {
      final matchesSearch =
          opp.title.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          opp.company.toLowerCase().contains(_searchTerm.toLowerCase());

      final matchesFilter =
          _filterType == 'all' ||
typeMap[_filterType] == opp.type;


      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.card,
        elevation: 0,
        title: Text(
          'AAST Connect',
          style: AppTextStyles.h1.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode_outlined,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textSecondary,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
          const SizedBox(width: 12),
        ],
      ),
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
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                        color: isDark ? AppColors.darkTextSecondary : AppColors.inputHint,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(Icons.search, color: isDark ? AppColors.darkTextSecondary : AppColors.inputHint),
                      filled: true,
                      fillColor: isDark ? AppColors.darkCard : AppColors.inputBackground,

      contentPadding: const EdgeInsets.symmetric(vertical: 14),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.radius),
        borderSide: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppColors.radius),
        borderSide: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.inputBorder),
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
  child: _isLoading
      ? const Center(child: CircularProgressIndicator())
      : _opportunities.isEmpty
          ? const Center(child: Text('No opportunities found'))
          : Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkDivider : AppColors.border,
                ),
              ),
              child: ListView(
                children: [
                  _tableHeader(isDark),
                  ..._filteredOpportunities
                      .map((opp) => _tableRow(opp, isDark)),
                ],
              ),
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
        status: 'Status',
        applicants: 'Applicants',
        deadline: 'Deadline',
        actions: 'Actions',
        isHeader: true,
        isDark: isDark,
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
        colors: [
          Colors.grey.shade300,
          Colors.grey.shade100,
        ],
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
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        onChanged: (value) {
          setState(() => _filterType = value!);
        },
        items: const [
          DropdownMenuItem(
            value: 'all',
            child: Text('All Types'),
          ),
          DropdownMenuItem(
            value: 'Internship',
            child: Text('Internship'),
          ),
          DropdownMenuItem(
            value: 'Training',
            child: Text('Training'),
          ),
          DropdownMenuItem(
            value: 'Job',
            child: Text('Job'),
          ),
          DropdownMenuItem(
            value: 'Volunteer',
            child: Text('Volunteer'),
          ),
          DropdownMenuItem(
            value: 'Competition',
            child: Text('Competition'),
          ),
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
            top: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.border),
          ),
        ),
        child: _rowText(
          title: opp.title,
          company: opp.company,
          type: opp.type,
          status: opp.status,
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
    required String applicants,
    required String deadline,
    required String actions,
    bool isHeader = false,
    required bool isDark,
    Opportunity? opportunity,
  }) {
    final textStyle =
        isHeader ? AppTextStyles.caption : AppTextStyles.body;

    return Row(
      children: [
        _cell(title, flex: 3, style: textStyle, isDark: isDark),
        _cell(company, flex: 2, style: textStyle, isDark: isDark),
        _typeBadge(type, isDark),
        _statusBadge(status, isDark),
        _cell(applicants, flex: 1, style: textStyle, isDark: isDark),
        _cell(deadline, flex: 1, style: textStyle, isDark: isDark),
        if (isHeader)
          _cell(actions, flex: 1, style: textStyle, isDark: isDark)
        else
          _buildActionButtons(opportunity!, isDark),
      ],
    );
  }

  Widget _cell(String text,
      {required int flex, required TextStyle style, required bool isDark}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          text, 
          style: style.copyWith(
            color: isDark ? AppColors.darkTextPrimary : null,
          ),
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
    final bool isInternal = status == 'Internal';
    return _badge(
      status,
      isInternal
          ? AppColors.interactive.withOpacity(0.15)
          : (isDark ? AppColors.darkDivider : AppColors.border),
      isInternal ? AppColors.interactive : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
      isDark,
    );
  }

  Widget _badge(String text, Color bg, Color fg, bool isDark) {
    return Expanded(
      flex: 1,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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


  void _showOpportunityForm(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final deadlineController = TextEditingController();
    String selectedType = 'Internship';
    String selectedStatus = 'Active';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: isDark ? AppColors.darkCard : AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
  width: MediaQuery.of(context).size.width * 0.8,
  constraints: BoxConstraints(
    maxHeight: MediaQuery.of(context).size.height * 0.85,
  ),
  padding: const EdgeInsets.all(24),
  child: SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- HEADER ----------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Add New Opportunity',
              style: AppTextStyles.h2.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.close,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ---------- FORM ----------
        _buildFormField(
          'Title',
          titleController,
          'Enter opportunity title',
          isDark,
        ),
        const SizedBox(height: 16),
        _buildFormField(
          'Company',
          companyController,
          'Enter company name',
          isDark,
        ),
        const SizedBox(height: 16),

       _buildFormField(
  'Location',
  locationController,
  'e.g. Cairo, Alexandria, Dubai',
  isDark,
),

        const SizedBox(height: 16),

        _buildDropdownField(
          'Type',
          selectedType,
          ['Internship', 'Training', 'Job', 'Volunteer', 'Competition'],
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
          'e.g. Flutter, Dart, REST APIs',
          isDark,
          maxLines: 2,
        ),
        const SizedBox(height: 16),

        _buildFormField(
          'Description',
          descriptionController,
          'Enter opportunity description',
          isDark,
          maxLines: 3,
        ),
        const SizedBox(height: 16),

        // ---------- PAID SWITCH ----------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Paid Opportunity',
              style: AppTextStyles.label.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            Switch(
              value: paidStatus,
              onChanged: (v) => setState(() => paidStatus = v),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ---------- DEADLINE PICKER ----------
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
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
                    : DateFormat('yyyy-MM-dd')
                        .format(selectedDeadline!),
              ),
              'Select deadline',
              isDark,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // ---------- ACTION BUTTONS ----------
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
                if (selectedDeadline == null) return;

                await _saveOpportunityToSupabase(
                  title: titleController.text,
                  description: descriptionController.text,
                  type: typeMap[selectedType]!,
                  location: locationController.text,
                  skills: skillsController.text,
                  paidStatus: paidStatus,
                  deadline: selectedDeadline!,
                  selectedWorkMode: selectedWorkMode,
                );
                await _fetchOpportunities();

                Navigator.pop(context);
              },
              child: const Text('Add Opportunity'),
            ),
          ],
        ),
      ],
    ),
  ),),
);

          },
        );
      },
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
            fillColor: isDark ? AppColors.darkDivider : AppColors.inputBackground,
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
              borderSide: BorderSide(
                color: AppColors.interactive,
                width: 1.5,
              ),
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
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            underline: SizedBox(), // Remove the underline
          ),
        ),
      ],
    );
  }

  Future<void> _saveOpportunityToSupabase({
  required String title,
  required String description,
  required String type,
  required String location,
  required String skills,
  required String selectedWorkMode,
  required bool paidStatus,
  required DateTime deadline,
}) async {
  try {
    await supabase.from('vacancies').insert({
  'title': title,
  'description': description,
  'type': type,
  'company_name': companyController.text.trim(),
  'location': locationController.text.trim(), // ✅ real place
  'work_mode': selectedWorkMode,              // ✅ enum
  'requiredskills': skills,
  'paidstatus': paidStatus,
  'deadline': deadline.toIso8601String(),
  'postedbyadminid': widget.adminId,
});
  titleController.clear();
    companyController.clear();
    descriptionController.clear();
    locationController.clear();
    skillsController.clear();

    setState(() {
      selectedDeadline = null;
      paidStatus = false;
      selectedWorkMode = 'ONSITE';
      selectedType = 'Internship';
    });
  } catch (e) {
    debugPrint('Insert error: $e');
  }
}


  Widget _buildActionButtons(Opportunity opportunity, bool isDark) {
    return Expanded(
      flex: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              _showEditOpportunityForm(context, opportunity);
            },
            icon: Icon(
              Icons.edit,
              color: AppColors.interactive,
              size: 18,
            ),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: () {
              _deleteOpportunity(opportunity);
            },
            icon: Icon(
              Icons.delete,
              color: Colors.red,
              size: 18,
            ),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  void _showEditOpportunityForm(BuildContext context, Opportunity opportunity) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    final editTitleController =
    TextEditingController(text: opportunity.title);
final editCompanyController =
    TextEditingController(text: opportunity.company);

    final descriptionController = TextEditingController();
    final deadlineController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(opportunity.deadline),
    );
    String selectedType = opportunity.type;
    String selectedStatus = opportunity.status;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: isDark ? AppColors.darkCard : AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Opportunity',
                          style: AppTextStyles.h2.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Form Fields
                    _buildFormField(
                      'Title',
                      editTitleController,
                      'Enter opportunity title',
                      isDark,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildFormField(
                      'Company',
                      editCompanyController,
                      'Enter company name',
                      isDark,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildDropdownField(
                      'Type',
                      selectedType,
                      ['Internship', 'Training', 'Job', 'Volunteer', 'Competition'],
                      (value) => setState(() => selectedType = value!),
                      isDark,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildDropdownField(
                      'Status',
                      selectedStatus,
                      ['Active', 'Inactive', 'Closed'],
                      (value) => setState(() => selectedStatus = value!),
                      isDark,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildFormField(
                      'Deadline',
                      deadlineController,
                      'YYYY-MM-DD',
                      isDark,
                      keyboardType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildFormField(
                      'Description',
                      descriptionController,
                      'Enter opportunity description',
                      isDark,
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            _updateOpportunity(
                              opportunity.id,
                              titleController.text,
                              companyController.text,
                              selectedType,
                              selectedStatus,
                              deadlineController.text,
                              descriptionController.text,
                            );
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.interactive,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Update Opportunity'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _updateOpportunity(
    String id,
    String title,
    String company,
    String type,
    String status,
    String deadline,
    String description,
  ) {
    if (title.isEmpty || company.isEmpty || deadline.isEmpty) {
      // Show error message or validation
      return;
    }

    setState(() {
      final index = _opportunities.indexWhere((opp) => opp.id == id);
      if (index != -1) {
        _opportunities[index] = Opportunity(
          id: id,
          title: title,
          company: company,
          type: type,
          status: status,
          applicants: _opportunities[index].applicants, // Keep existing applicants
          posted: _opportunities[index].posted, // Keep original posted date
          deadline: DateTime.tryParse(deadline) ?? _opportunities[index].deadline,
        );
      }
    });
  }

  void _deleteOpportunity(Opportunity opportunity) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: isDark ? AppColors.darkCard : AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Delete Opportunity',
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete "${opportunity.title}" from ${opportunity.company}?',
                  style: AppTextStyles.body.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        setState(() {
                          _opportunities.removeWhere((opp) => opp.id == opportunity.id);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  @override
void dispose() {
  titleController.dispose();
  companyController.dispose();
  descriptionController.dispose();
  locationController.dispose();
  skillsController.dispose();
  super.dispose();
}

}



