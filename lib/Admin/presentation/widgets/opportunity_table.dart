import 'package:flutter/material.dart';
import '../../domain/entities/opportunity.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
class OpportunityTable extends StatefulWidget {
  final List<Opportunity> opportunities;
  final bool isDark;
  final Function(String id) onDelete;
  final Function(Opportunity) onEdit;

  const OpportunityTable({
    super.key,
    required this.opportunities,
    required this.isDark,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<OpportunityTable> createState() => _OpportunityTableState();
}

class _OpportunityTableState extends State<OpportunityTable> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  _tableHeader(widget.isDark),
                  ...widget.opportunities.map((opp) => _tableRow(opp, widget.isDark)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
        isHeader
            ? _cell(company, flex: 2, style: textStyle, isDark: isDark)
            : _companyCell(company, opportunity?.companyLogoUrl, isDark),
        _typeBadge(type, isDark),
        _statusBadge(status, isDark),

        _cell(location, flex: 2, style: textStyle, isDark: isDark),
        _cell(workMode, flex: 1, style: textStyle, isDark: isDark),
        _cell(paid, flex: 1, style: textStyle, isDark: isDark),
        _cell(audience, flex: 1, style: textStyle, isDark: isDark),
        isHeader
            ? _cell(description, flex: 5, style: textStyle, isDark: isDark)
            : _cell(description, flex: 5, style: textStyle, isDark: isDark),
        _cell(skills, flex: 4, style: textStyle, isDark: isDark),
        _cell(applicants, flex: 1, style: textStyle, isDark: isDark),
        _cell(deadline, flex: 1, style: textStyle, isDark: isDark),

        if (isHeader)
          _cell(actions, flex: 1, style: textStyle, isDark: isDark)
        else
         SizedBox(
  width: 140,
  child: Row(
    children: [
      IconButton(
        icon: Icon(Icons.edit),
        onPressed: () => widget.onEdit(opportunity!),
      ),
      IconButton(
        icon: Icon(Icons.delete),
        onPressed: () => widget.onDelete(opportunity!.id),
      ),
    ],
  ),
)
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

  Widget _companyCell(String company, String? logoUrl, bool isDark) {
  return SizedBox(
    width: 2 * 140.0, // matches flex: 2
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Logo or fallback icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: isDark ? Colors.white10 : Colors.grey.shade100,
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.grey.shade200,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: logoUrl != null && logoUrl.isNotEmpty
                ? Image.network(
                    logoUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.business,
                      size: 18,
                      color: isDark ? Colors.white38 : Colors.grey.shade400,
                    ),
                  )
                : Icon(
                    Icons.business,
                    size: 18,
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                  ),
          ),
          const SizedBox(width: 8),
          // Company name
          Expanded(
            child: Text(
              company,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: AppTextStyles.body.copyWith(
                color: isDark ? AppColors.darkTextPrimary : null,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}