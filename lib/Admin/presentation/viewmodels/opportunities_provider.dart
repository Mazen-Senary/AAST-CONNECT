import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grad_project/Admin/domain/usecases/add_opportunity.dart';
import 'package:grad_project/Admin/domain/usecases/delete_opportunity.dart';
import 'package:grad_project/Admin/domain/usecases/get_opportunities.dart';
import 'package:grad_project/Admin/domain/usecases/update_opportunity.dart';
import 'package:grad_project/Admin/domain/entities/opportunity.dart';


class OpportunitiesNotifier
    extends StateNotifier<AsyncValue<List<Opportunity>>> {
  OpportunitiesNotifier(
    this.getOpportunities,
  this.deleteOpportunityUseCase,
  this.addOpportunityUseCase,
  this.updateOpportunityUseCase,
  ) : super(const AsyncLoading()) {
    fetchOpportunities();
  }
final GetOpportunities getOpportunities;
final DeleteOpportunity deleteOpportunityUseCase;
final AddOpportunity addOpportunityUseCase;
final UpdateOpportunity updateOpportunityUseCase;

  // ✅ FETCH
  Future<void> fetchOpportunities() async {
  state = const AsyncLoading();

  try {
    final data = await getOpportunities();
    state = AsyncData(data);
  } catch (e, st) {
    state = AsyncError(e, st);
  }
}

  // ✅ DELETE
  Future<void> deleteOpportunity(String id) async {
  await deleteOpportunityUseCase(id);
  await fetchOpportunities();
}

  // ✅ ADD
 Future<void> addOpportunity(Map<String, dynamic> data) async {
  await addOpportunityUseCase(data);
  await fetchOpportunities();
}

  // ✅ UPDATE
 Future<void> updateOpportunity(
  String id,
  Map<String, dynamic> data,
) async {
  await updateOpportunityUseCase(id, data);
  await fetchOpportunities();
}
}