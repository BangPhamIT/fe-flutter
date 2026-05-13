import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_app/core/theme/themes.dart';
import 'package:inventory_app/features/stock_in/presentation/cubit/stock_in_cubit.dart';
import 'package:intl/intl.dart';
import 'package:inventory_app/data/models/stock_in_filter.dart';
import 'package:inventory_app/features/stock_in/presentation/widgets/stock_in_filter_dialog.dart';
import 'package:inventory_app/core/widgets/primary_textfield.dart';
import 'stock_in_form_screen.dart';

class StockInListScreen extends StatefulWidget {
  const StockInListScreen({super.key});

  @override
  State<StockInListScreen> createState() => _StockInListScreenState();
}

class _StockInListScreenState extends State<StockInListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<StockInCubit>().fetchList();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final currentState = context.read<StockInCubit>().state;
      if (currentState is StockInSuccess) {
        context.read<StockInCubit>().fetchList(
              filter: currentState.filter.copyWith(
                receiptNumber: _searchController.text,
              ),
            );
      } else {
        context.read<StockInCubit>().fetchList(
              filter: StockInFilter(receiptNumber: _searchController.text),
            );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Widget _buildItemInfo(String label, String value) {
    if (value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: AppStyles.s12W400.copyWith(color: AppColors.textPrimary),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<StockInCubit>().fetchMoreList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Nhập kho'),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: () => _navigateToForm(context),
            child: Container(
              margin: EdgeInsets.only(right: 16),
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: AppColors.mainColor,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(Icons.add, color: AppColors.white, size: 26),
            ),
          ),
        ],
      ),
      body: BlocBuilder<StockInCubit, StockInState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(state),
              if (state is StockInSuccess && state.isRefreshing)
                const LinearProgressIndicator(minHeight: 2),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text('Danh sách phiếu', style: AppStyles.s18W700),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    final cubit = context.read<StockInCubit>();
                    if (state is StockInSuccess) {
                      await cubit.fetchList(filter: (state as StockInSuccess).filter);
                    } else {
                      await cubit.fetchList();
                    }
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (state is StockInLoading)
                        const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (state is StockInFailure)
                        SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Lỗi: ${state.message}',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () =>
                                      context.read<StockInCubit>().fetchList(),
                                  child: const Text('Thử lại'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (state is StockInSuccess) ...[
                        if (state.receipts.isEmpty)
                          const SliverFillRemaining(
                            child: Center(child: Text('Chưa có dữ liệu')),
                          )
                        else ...[
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((context, index) {
                                final item = state.receipts[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    onTap: () => _navigateToForm(context, receiptId: item.id),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.receiptNumber,
                                                  style: AppStyles.s16W700.copyWith(
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                if (item.companyName?.isNotEmpty ?? false)
                                                  _buildItemInfo('Đơn vị', item.companyName!),
                                                _buildItemInfo('Người giao', item.delivererName ?? ''),
                                                _buildItemInfo('Người nhận', item.receiver?.fullName ?? ''),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                DateFormat('dd/MM/yyyy').format(item.receiptDate),
                                                style: AppStyles.s12W400.copyWith(
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                NumberFormat.currency(
                                                  locale: 'vi_VN',
                                                  symbol: 'đ',
                                                ).format(item.totalAmount),
                                                style: AppStyles.s14W700.copyWith(
                                                  color: Colors.red,
                                                ),
                                              ),
                                              if (item.warehouse != null) ...[
                                                const SizedBox(height: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.chipBg,
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(
                                                      color: AppColors.primary.withAlpha(50),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    item.warehouse?.name ?? '',
                                                    style: AppStyles.s10W600.copyWith(
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }, childCount: state.receipts.length),
                            ),
                          ),
                          if (state.hasMore)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              ),
                            ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(StockInState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: PrimaryTextField(
              controller: _searchController,
              hintText: 'Tìm kiếm theo số phiếu...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: IconButton(
              onPressed: () => _showFilterDialog(state),
              icon: Icon(
                Icons.filter_list,
                color: (state is StockInSuccess &&
                        ((state as StockInSuccess).filter.warehouseId != null ||
                            (state as StockInSuccess).filter.startDate != null ||
                            (state as StockInSuccess).filter.endDate != null))
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterDialog(StockInState state) async {
    if (state is! StockInSuccess) return;

    final filter = await showDialog<StockInFilter>(
      context: context,
      builder: (context) => StockInFilterDialog(
        initialFilter: (state as StockInSuccess).filter,
      ),
    );

    if (filter != null) {
      if (mounted) {
        _searchController.text = filter.receiptNumber ?? '';
        context.read<StockInCubit>().fetchList(filter: filter);
      }
    }
  }

  void _navigateToForm(BuildContext context, {String? receiptId}) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => StockInFormScreen(receiptId: receiptId),
          ),
        )
        .then((result) {
          if (result == true) {
            // ignore: use_build_context_synchronously
            context.read<StockInCubit>().fetchList();
          }
        });
  }
}
