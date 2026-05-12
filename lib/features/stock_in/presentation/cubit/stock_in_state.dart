part of 'stock_in_cubit.dart';

abstract class StockInState extends Equatable {
  const StockInState();

  @override
  List<Object?> get props => [];
}

class StockInInitial extends StockInState {}

class StockInLoading extends StockInState {}

class StockInSuccess extends StockInState {
  final List<StockInReceipt> receipts;
  final int total;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  const StockInSuccess({
    required this.receipts,
    required this.total,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  StockInSuccess copyWith({
    List<StockInReceipt>? receipts,
    int? total,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return StockInSuccess(
      receipts: receipts ?? this.receipts,
      total: total ?? this.total,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [receipts, total, page, hasMore, isLoadingMore];
}

class StockInFailure extends StockInState {
  final String message;

  const StockInFailure(this.message);

  @override
  List<Object> get props => [message];
}
