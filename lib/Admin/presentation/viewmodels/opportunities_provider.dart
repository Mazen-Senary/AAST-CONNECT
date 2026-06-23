import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/opportunities_state.dart';
import '../../domain/usecases/get_opportunities_page.dart';
import '../../domain/usecases/add_opportunity.dart';
import '../../domain/usecases/delete_opportunity.dart';
import '../../domain/usecases/update_opportunity.dart';

class OpportunitiesNotifier extends StateNotifier<OpportunitiesState> {
  OpportunitiesNotifier(
    this.getOpportunitiesPage,
    this.deleteOpportunityUseCase,
    this.addOpportunityUseCase,
    this.updateOpportunityUseCase,
  ) : super(const OpportunitiesState(isLoading: true)) {
    fetchFirstPage();
  }

  final GetOpportunitiesPage getOpportunitiesPage;
  final DeleteOpportunity deleteOpportunityUseCase;
  final AddOpportunity addOpportunityUseCase;
  final UpdateOpportunity updateOpportunityUseCase;

  static const int pageSize = 20;
  int _page = 0;
  String _search = '';
  String _type = 'all';

  Future<void> fetchFirstPage({String? search, String? type}) async {
    _search = search ?? _search;
    _type = type ?? _type;
    _page = 0;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await getOpportunitiesPage(
        page: 0,
        pageSize: pageSize,
        search: _search,
        type: _type,
      );
      state = OpportunitiesState(
        items: result.opportunities,
        hasMore: result.hasMore,
        isLoading: false,
      );
    } catch (e) {
      print('Fetch error: $e'); 
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = _page + 1;
    try {
      final result = await getOpportunitiesPage(
        page: nextPage,
        pageSize: pageSize,
        search: _search,
        type: _type,
      );
      _page = nextPage;
      state = state.copyWith(
        items: [...state.items, ...result.opportunities],
        hasMore: result.hasMore,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e);
    }
  }

  void updateSearch(String search) => fetchFirstPage(search: search);
  void updateTypeFilter(String type) => fetchFirstPage(type: type);

  Future<void> deleteOpportunity(String id) async {
    final previous = state.items;
    state = state.copyWith(items: previous.where((o) => o.id != id).toList());
    try {
      await deleteOpportunityUseCase(id);
    } catch (e) {
      state = state.copyWith(items: previous, error: e);
      rethrow;
    }
  }

  Future<void> addOpportunity(Map<String, dynamic> data) async {
    await addOpportunityUseCase(data);
    await fetchFirstPage();
  }

  Future<void> updateOpportunity(String id, Map<String, dynamic> data) async {
    await updateOpportunityUseCase(id, data);
    await fetchFirstPage();
  }
}