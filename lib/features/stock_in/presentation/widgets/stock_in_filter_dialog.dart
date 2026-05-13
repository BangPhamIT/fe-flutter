import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_app/core/theme/app_colors.dart';
import 'package:inventory_app/core/widgets/primary_textfield.dart';
import 'package:inventory_app/data/models/stock_in_filter.dart';
import 'package:inventory_app/data/models/warehouse.dart';
import 'package:inventory_app/features/stock_in/presentation/cubit/stock_in_cubit.dart';
import 'package:intl/intl.dart';

class StockInFilterDialog extends StatefulWidget {
  final StockInFilter initialFilter;
  const StockInFilterDialog({super.key, required this.initialFilter});

  @override
  State<StockInFilterDialog> createState() => _StockInFilterDialogState();
}

class _StockInFilterDialogState extends State<StockInFilterDialog> {
  late TextEditingController _receiptNumberController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  String? _selectedWarehouseId;
  DateTime? _startDate;
  DateTime? _endDate;
  List<Warehouse> _warehouses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _receiptNumberController = TextEditingController(
      text: widget.initialFilter.receiptNumber,
    );
    _startDate = widget.initialFilter.startDate;
    _endDate = widget.initialFilter.endDate;
    _selectedWarehouseId = widget.initialFilter.warehouseId;

    _startDateController = TextEditingController(
      text: _startDate != null
          ? DateFormat('dd/MM/yyyy').format(_startDate!)
          : '',
    );
    _endDateController = TextEditingController(
      text: _endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : '',
    );

    _fetchWarehouses();
  }

  Future<void> _fetchWarehouses() async {
    try {
      final repository = context.read<StockInCubit>().repository;
      final warehouses = await repository.getWarehouses();
      if (mounted) {
        setState(() {
          _warehouses = warehouses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _receiptNumberController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      title: const Text('Bộ lọc nâng cao'),
      content: SizedBox(
        width: size.width * 0.8,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: InputDecorationTheme(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.textPrimary.withAlpha(50),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.textPrimary.withAlpha(50),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.textPrimary.withAlpha(50),
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PrimaryTextField(
                        controller: _receiptNumberController,
                        label: 'Số phiếu',
                        hintText: '--',
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Kho nhập',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedWarehouseId,
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Tất cả kho'),
                          ),
                          ..._warehouses.map(
                            (w) => DropdownMenuItem(
                              value: w.id,
                              child: Text(
                                w.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedWarehouseId = v),
                        decoration: const InputDecoration(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryTextField(
                              controller: _startDateController,
                              label: 'Từ ngày',
                              hintText: '--',
                              readOnly: true,
                              onTap: () => _selectDate(true),
                              suffixIcon: const Icon(
                                Icons.calendar_today,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PrimaryTextField(
                              controller: _endDateController,
                              label: 'Đến ngày',
                              hintText: '--',
                              readOnly: true,
                              onTap: () => _selectDate(false),
                              suffixIcon: const Icon(
                                Icons.calendar_today,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _receiptNumberController.clear();
              _startDate = null;
              _endDate = null;
              _selectedWarehouseId = null;
              _startDateController.clear();
              _endDateController.clear();
            });
          },
          child: const Text('Đặt lại'),
        ),
        ElevatedButton(
          onPressed: () {
            final filter = StockInFilter(
              receiptNumber: _receiptNumberController.text,
              warehouseId: _selectedWarehouseId,
              startDate: _startDate,
              endDate: _endDate,
            );
            Navigator.pop(context, filter);
          },
          child: const Text('Áp dụng'),
        ),
      ],
    );
  }
}
