import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_project/Admin/presentation/viewmodels/opportunities_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/opportunity_remote_datasource.dart';
import '../../data/repositories/opportunity_repository_impl.dart';
import '../../domain/repositories/opportunity_repository.dart';
import '../../domain/usecases/get_opportunities.dart';
import '../../domain/usecases/delete_opportunity.dart';
import '../../domain/usecases/add_opportunity.dart';
import '../../domain/usecases/update_opportunity.dart';
import '../../domain/entities/opportunity.dart';
/// Repository
final opportunityRepositoryProvider =
    Provider<OpportunityRepository>((ref) {
  final client = Supabase.instance.client;

  return OpportunityRepositoryImpl(
    OpportunityRemoteDataSource(client),
  );
});

/// UseCases
final getOpportunitiesProvider = Provider(
  (ref) => GetOpportunities(ref.read(opportunityRepositoryProvider)),
);

final deleteOpportunityProvider = Provider(
  (ref) => DeleteOpportunity(ref.read(opportunityRepositoryProvider)),
);

final addOpportunityProvider = Provider(
  (ref) => AddOpportunity(ref.read(opportunityRepositoryProvider)),
);

final updateOpportunityProvider = Provider(
  (ref) => UpdateOpportunity(ref.read(opportunityRepositoryProvider)),
);

/// ViewModel
final opportunitiesProvider =
    StateNotifierProvider<OpportunitiesNotifier,
        AsyncValue<List<Opportunity>>>((ref) {
  return OpportunitiesNotifier(
    ref.read(getOpportunitiesProvider),
    ref.read(deleteOpportunityProvider),
    ref.read(addOpportunityProvider),
    ref.read(updateOpportunityProvider),
  );
});