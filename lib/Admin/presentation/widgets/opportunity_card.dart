import 'package:flutter/material.dart';
import '../../domain/entities/opportunity.dart';

class OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {


    return Container(); 
  }
}