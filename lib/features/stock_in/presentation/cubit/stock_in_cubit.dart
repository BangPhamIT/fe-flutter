import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_app/data/models/stock_in_receipt.dart';
import 'package:inventory_app/data/models/stock_in_filter.dart';
import 'package:inventory_app/features/stock_in/data/repository/stock_in_repository.dart';

part 'stock_in_state.dart';

class StockInCubit extends Cubit<StockInState> {
  final StockInRepository repository;

  StockInCubit({required this.repository}) : super(StockInInitial());

  Future<void> fetchList({
    int limit = 10,
    StockInFilter filter = const StockInFilter(),
  }) async {
    final currentState = state;
    if (currentState is StockInSuccess) {
      emit(currentState.copyWith(isRefreshing: true, filter: filter));
    } else {
      emit(StockInLoading());
    }

    try {
      final result = await repository.getStockInList(
        page: 1,
        limit: limit,
        filter: filter.toJson(),
      );
      final listData = result['elements'] as List? ?? [];
      final list = listData
          .map((e) => StockInReceipt.fromJson(e as Map<String, dynamic>))
          .toList();

      final paginate = result['paginate'] as Map<String, dynamic>?;
      final total = paginate?['totalRecord'] as int? ?? 0;
      final hasMore = list.length < total;

      emit(
        StockInSuccess(
          receipts: list,
          total: total,
          page: 1,
          hasMore: hasMore,
          isRefreshing: false,
          filter: filter,
        ),
      );
    } catch (e) {
      if (state is StockInSuccess) {
        emit((state as StockInSuccess).copyWith(isRefreshing: false));
      } else {
        emit(StockInFailure(e.toString()));
      }
    }
  }

  Future<void> fetchMoreList({int limit = 10}) async {
    final currentState = state;
    if (currentState is! StockInSuccess ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));
    try {
      final nextPage = currentState.page + 1;
      final result = await repository.getStockInList(
        page: nextPage,
        limit: limit,
        filter: currentState.filter.toJson(),
      );
      final listData = result['elements'] as List? ?? [];
      final list = listData
          .map((e) => StockInReceipt.fromJson(e as Map<String, dynamic>))
          .toList();

      final updatedList = List<StockInReceipt>.from(currentState.receipts)
        ..addAll(list);
      final paginate = result['paginate'] as Map<String, dynamic>?;
      final total = paginate?['totalRecord'] as int? ?? 0;
      final hasMore = updatedList.length < total;

      emit(
        StockInSuccess(
          receipts: updatedList,
          total: total,
          page: nextPage,
          hasMore: hasMore,
          isLoadingMore: false,
          filter: currentState.filter,
        ),
      );
    } catch (e) {
      if (state is StockInSuccess) {
        emit((state as StockInSuccess).copyWith(isLoadingMore: false));
      } else {
        emit(StockInFailure(e.toString()));
      }
    }
  }

  Future<void> deleteReceipt(String id) async {
    final currentState = state;
    try {
      await repository.deleteStockIn(id);
      if (currentState is StockInSuccess) {
        fetchList(filter: currentState.filter);
      } else {
        fetchList();
      }
    } catch (e) {
      emit(StockInFailure(e.toString()));
    }
  }
}
