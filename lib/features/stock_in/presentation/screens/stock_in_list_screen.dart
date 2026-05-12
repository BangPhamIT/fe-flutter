import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_app/core/theme/themes.dart';
import 'package:inventory_app/features/stock_in/presentation/cubit/stock_in_cubit.dart';
import 'package:intl/intl.dart';
import 'stock_in_form_screen.dart';

class StockInListScreen extends StatefulWidget {
  const StockInListScreen({super.key});

  @override
  State<StockInListScreen> createState() => _StockInListScreenState();
}

class _StockInListScreenState extends State<StockInListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<StockInCubit>().fetchList();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Danh sách phiếu', style: AppStyles.s18W700),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<StockInCubit>().fetchList();
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // List section
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
