import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_app/core/theme/themes.dart';
import 'package:inventory_app/core/widgets/primary_button.dart';
import 'package:inventory_app/core/widgets/primary_textfield.dart';
import 'package:inventory_app/data/models/stock_in_item.dart';
import 'package:inventory_app/data/models/employee.dart';
import 'package:inventory_app/features/stock_in/presentation/cubit/stock_in_form_cubit.dart';
import 'package:inventory_app/core/utils/number_to_words.dart';
import 'package:inventory_app/core/utils/currency_input_formatter.dart';
import 'package:intl/intl.dart';

class StockInFormScreen extends StatefulWidget {
  final String? receiptId;
  const StockInFormScreen({super.key, this.receiptId});

  @override
  State<StockInFormScreen> createState() => _StockInFormScreenState();
}

class _StockInFormScreenState extends State<StockInFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _receiptNumberController = TextEditingController();
  final _receiptDateController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _departmentNameController = TextEditingController();
  final _delivererNameController = TextEditingController();
  final _debtAccountController = TextEditingController();
  final _creditAccountController = TextEditingController();
  final _warehouseLocationController = TextEditingController();
  final _noteController = TextEditingController();
  final _itemScrollController = ScrollController();

  @override
  void dispose() {
    _receiptNumberController.dispose();
    _receiptDateController.dispose();
    _companyNameController.dispose();
    _departmentNameController.dispose();
    _delivererNameController.dispose();
    _debtAccountController.dispose();
    _creditAccountController.dispose();
    _warehouseLocationController.dispose();
    _noteController.dispose();
    _itemScrollController.dispose();
    super.dispose();
  }

  DateTime _selectedDate = DateTime.now();
  String? _selectedWarehouseId;
  String? _selectedReceiverId;
  String? _selectedCreatorId;
  String? _selectedKeeperId;
  String? _selectedAccountantId;

  List<StockInItem> _items = [];
  bool _isInitialized = false;
  bool _showItemsError = false;

  @override
  void initState() {
    super.initState();
    _receiptDateController.text = DateFormat(
      'dd/MM/yyyy',
    ).format(_selectedDate);
    context.read<StockInFormCubit>().init(widget.receiptId);
  }

  void _onStateSuccess(StockInFormSuccess state) {
    if (_isInitialized) return;
    if (state.receipt != null) {
      final r = state.receipt!;
      _receiptNumberController.text = r.receiptNumber;
      _selectedDate = r.receiptDate;
      _receiptDateController.text = DateFormat(
        'dd/MM/yyyy',
      ).format(_selectedDate);
      _companyNameController.text = r.companyName ?? '';
      _departmentNameController.text = r.departmentName ?? '';
      _delivererNameController.text = r.delivererName ?? '';
      _debtAccountController.text = r.debtAccount ?? '';
      _creditAccountController.text = r.creditAccount ?? '';
      _noteController.text = r.note ?? '';

      _selectedWarehouseId = r.warehouseId;
      if (_selectedWarehouseId != null) {
        final wList = state.warehouses.where(
          (w) => w.id == _selectedWarehouseId,
        );
        if (wList.isNotEmpty) {
          _warehouseLocationController.text = wList.first.location ?? '';
        }
      }

      _selectedReceiverId = r.receiverId;
      _selectedCreatorId = r.creatorId;
      _selectedKeeperId = r.warehouseKeeperId;
      _selectedAccountantId = r.chiefAccountantId;

      _items = List.from(r.items ?? []);
    } else {
      _receiptNumberController.text = 'PNK-';
    }
    _isInitialized = true;
  }

  double get _totalAmount =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StockInFormCubit, StockInFormState>(
      listener: (context, state) {
        if (state is StockInFormSuccess) {
          _onStateSuccess(state);
        } else if (state is StockInFormSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lưu phiếu nhập thành công')),
          );
          Navigator.of(context).pop(true);
        } else if (state is StockInFormFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.receiptId == null
                      ? 'Tạo phiếu nhập'
                      : 'Sửa phiếu nhập',
                ),
              ),
              body: state is StockInFormLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Thông tin chung'),
                                  _buildGeneralInfo(state),
                                  const SizedBox(height: 24),
                                  _buildSectionTitle('Thông tin kho & Kế toán'),
                                  _buildAccountInfo(state),
                                  const SizedBox(height: 24),
                                  _buildItemListHeader(),
                                  const SizedBox(height: 8),
                                  _buildItemsList(),
                                  const SizedBox(height: 24),
                                  _buildSectionTitle('Thông tin ký nhận'),
                                  _buildSignatureInfo(state),
                                  const SizedBox(height: 100),
                                ],
                              ),
                            ),
                          ),
                          _buildBottomBar(state),
                        ],
                      ),
                    ),
            ),
            if (state is StockInFormSubmitting)
              Container(
                color: Colors.black.withAlpha(80),
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Đang lưu dữ liệu...',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppStyles.s16W700.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _buildGeneralInfo(StockInFormState state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PrimaryTextField(
                controller: _receiptNumberController,
                label: 'Số phiếu *',
                hintText: 'PNK-xxxx',
                validator: (v) => v!.isEmpty ? '' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryTextField(
                controller: _receiptDateController,
                label: 'Ngày nhập *',
                hintText: 'dd/mm/yyyy',
                readOnly: true,
                onTap: _selectDate,
                suffixIcon: const Icon(Icons.calendar_today, size: 20),
                validator: (v) => v!.isEmpty ? '' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PrimaryTextField(
          controller: _companyNameController,
          label: 'Tên đơn vị',
          hintText: '',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PrimaryTextField(
                controller: _departmentNameController,
                label: 'Bộ phận',
                hintText: '',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryTextField(
                controller: _delivererNameController,
                label: 'Người giao hàng *',
                hintText: '',
                validator: (v) => v!.isEmpty ? '' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountInfo(StockInFormState state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PrimaryTextField(
                controller: _debtAccountController,
                label: 'Nợ',
                hintText: '',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryTextField(
                controller: _creditAccountController,
                label: 'Có',
                hintText: '',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildWarehouseDropdown(state)),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryTextField(
                controller: _warehouseLocationController,
                label: 'Địa điểm kho',
                hintText: '',
                readOnly: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildEmployeeDropdown(
          label: 'Người nhận hàng *',
          value: _selectedReceiverId,
          employees: state is StockInFormSuccess ? state.employees : [],
          onChanged: (v) => setState(() => _selectedReceiverId = v),
          validator: (v) => v == null ? '' : null,
        ),
      ],
    );
  }

  Widget _buildSignatureInfo(StockInFormState state) {
    final employees = state is StockInFormSuccess
        ? state.employees
        : <Employee>[];
    final accountants = employees
        .where((e) => e.department?.contains('Kế toán') ?? true)
        .toList();
    final keepers = employees
        .where((e) => e.department?.contains('Kho') ?? true)
        .toList();

    return Column(
      children: [
        _buildEmployeeDropdown(
          label: 'Người lập phiếu *',
          value: _selectedCreatorId,
          employees: employees,
          onChanged: (v) => setState(() => _selectedCreatorId = v),
          validator: (v) => v == null ? '' : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildEmployeeDropdown(
                label: 'Thủ kho *',
                value: _selectedKeeperId,
                employees: keepers.isEmpty ? employees : keepers,
                onChanged: (v) => setState(() => _selectedKeeperId = v),
                validator: (v) => v == null ? '' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildEmployeeDropdown(
                label: 'Kế toán trưởng *',
                value: _selectedAccountantId,
                employees: accountants.isEmpty ? employees : accountants,
                onChanged: (v) => setState(() => _selectedAccountantId = v),
                validator: (v) => v == null ? '' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PrimaryTextField(
          controller: _noteController,
          label: 'Ghi chú',
          hintText: '',
        ),
      ],
    );
  }

  Widget _buildWarehouseDropdown(StockInFormState state) {
    if (state is StockInFormSuccess) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kho nhập *', style: AppStyles.s14W600),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedWarehouseId,
            items: state.warehouses
                .map(
                  (w) => DropdownMenuItem(
                    value: w.id,
                    child: Text(w.name, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (v) {
              setState(() {
                _selectedWarehouseId = v;
                final warehouseList = state.warehouses.where((w) => w.id == v);
                if (warehouseList.isNotEmpty) {
                  _warehouseLocationController.text =
                      warehouseList.first.location ?? '';
                }
              });
            },
            decoration: _dropdownDecoration(),
            validator: (v) => v == null ? '' : null,
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildEmployeeDropdown({
    required String label,
    required String? value,
    required List<Employee> employees,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: AppStyles.s14W600),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          items: employees
              .map(
                (e) => DropdownMenuItem(
                  value: e.id,
                  child: Text(e.fullName, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: _dropdownDecoration(),
          validator: validator,
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration() {
    return const InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _buildItemListHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Danh sách mặt hàng',
            style: AppStyles.s16W700,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton.icon(
          onPressed: () => _openItemDialog(),
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Thêm dòng'),
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    if (_items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _showItemsError
              ? Colors.red.withAlpha(10)
              : Colors.grey.withAlpha(10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _showItemsError ? Colors.red : AppColors.border,
            width: _showItemsError ? 2 : 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: _showItemsError ? Colors.red : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              'Chưa có sản phẩm nào',
              style: TextStyle(
                color: _showItemsError ? Colors.red : Colors.grey,
                fontWeight: _showItemsError
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.of(context).size.height *
            0.4,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border.withAlpha(50)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Scrollbar(
        controller: _itemScrollController,
        thumbVisibility: true,
        child: ListView.separated(
          controller: _itemScrollController,
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          itemCount: _items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = _items[index];
            return GestureDetector(
              onTap: () => _openItemDialog(item: item, index: index),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.productName, style: AppStyles.s14W700),
                              if (item.productCode?.isNotEmpty ?? false)
                                Text(
                                  'Mã: ${item.productCode}',
                                  style: AppStyles.s12W400,
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _items.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildSmallInfo('ĐVT', item.unit ?? ''),
                        _buildSmallInfo(
                          'SL (TN)',
                          NumberFormat.decimalPattern(
                            'vi_VN',
                          ).format(item.quantityActual),
                        ),
                        _buildSmallInfo(
                          'Đơn giá',
                          NumberFormat.decimalPattern(
                            'vi_VN',
                          ).format(item.unitPrice),
                        ),
                        _buildSmallInfo(
                          'Thành tiền',
                          NumberFormat.decimalPattern(
                            'vi_VN',
                          ).format(item.totalPrice),
                          isBold: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSmallInfo(String label, String value, {bool isBold = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppStyles.s10W400.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: isBold ? AppStyles.s12W700 : AppStyles.s12W400,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(StockInFormState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng tiền:', style: AppStyles.s16W600),
              Text(
                NumberFormat.currency(
                  locale: 'vi_VN',
                  symbol: 'đ',
                ).format(_totalAmount),
                style: AppStyles.s18W700.copyWith(color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  'Bằng chữ: ${NumberToWords.convert(_totalAmount)}',
                  style: AppStyles.s12W400.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          context.basicButton(
            state is StockInFormSubmitting ? 'Đang lưu...' : 'Lưu phiếu nhập',
            isActive: state is! StockInFormSubmitting,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _receiptDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _openItemDialog({StockInItem? item, int? index}) {
    final GlobalKey<FormState> dialogFormKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        final codeCtrl = TextEditingController(text: item?.productCode ?? '');
        final nameCtrl = TextEditingController(text: item?.productName ?? '');
        final unitCtrl = TextEditingController(text: item?.unit ?? '');
        final qtyDocCtrl = TextEditingController(
          text: item != null
              ? NumberFormat.decimalPattern(
                  'vi_VN',
                ).format(item.quantityDocument)
              : '',
        );
        final qtyActCtrl = TextEditingController(
          text: item != null
              ? NumberFormat.decimalPattern('vi_VN').format(item.quantityActual)
              : '',
        );
        final priceCtrl = TextEditingController(
          text: item != null
              ? NumberFormat.decimalPattern('vi_VN').format(item.unitPrice)
              : '',
        );
        final size = MediaQuery.of(context).size;

        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Text(item == null ? 'Thêm mặt hàng' : 'Sửa mặt hàng'),
          content: Container(
            width: size.width * 0.85,
            constraints: BoxConstraints(maxHeight: size.height * 0.6),
            child: SingleChildScrollView(
              child: Form(
                key: dialogFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: codeCtrl,
                      decoration: const InputDecoration(labelText: 'Mã hàng'),
                      style: AppStyles.s14W400,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tên hàng *',
                      ),
                      style: AppStyles.s14W400,
                      validator: (v) => v!.isEmpty ? '' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: unitCtrl,
                            decoration: const InputDecoration(labelText: 'ĐVT'),
                            style: AppStyles.s14W400,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: qtyDocCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [CurrencyInputFormatter()],
                            decoration: const InputDecoration(
                              labelText: 'SL (Chứng từ)',
                            ),
                            style: AppStyles.s14W400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: qtyActCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [CurrencyInputFormatter()],
                            decoration: const InputDecoration(
                              labelText: 'SL (Thực nhập)',
                            ),
                            style: AppStyles.s14W400,
                            validator: (v) => v!.isEmpty ? '' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: priceCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [CurrencyInputFormatter()],
                            decoration: const InputDecoration(
                              labelText: 'Đơn giá',
                            ),
                            style: AppStyles.s14W400,
                            validator: (v) => v!.isEmpty ? '' : null,
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
            ElevatedButton(
              onPressed: () {
                if (dialogFormKey.currentState!.validate()) {
                  final String qDStr = qtyDocCtrl.text
                      .replaceAll('.', '')
                      .replaceAll(',', '');
                  final String qAStr = qtyActCtrl.text
                      .replaceAll('.', '')
                      .replaceAll(',', '');
                  final String priceStr = priceCtrl.text
                      .replaceAll('.', '')
                      .replaceAll(',', '');

                  final qD = double.tryParse(qDStr) ?? 0;
                  final qA = double.tryParse(qAStr) ?? 0;
                  final price = double.tryParse(priceStr) ?? 0;

                  final newItem = StockInItem(
                    id: item?.id,
                    productCode: codeCtrl.text,
                    productName: nameCtrl.text,
                    unit: unitCtrl.text,
                    quantityDocument: qD,
                    quantityActual: qA,
                    unitPrice: price,
                    totalPrice: qA * price,
                  );

                  setState(() {
                    if (index != null) {
                      _items[index] = newItem;
                    } else {
                      _items.add(newItem);
                    }
                    _showItemsError = false;
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng điền đủ thông tin')),
                  );
                }
              },
              child: Text(item == null ? 'Thêm' : 'Cập nhật'),
            ),
          ],
        );
      },
    );
  }

  void _save() {
    final bool isFormValid = _formKey.currentState!.validate();
    final bool isItemsValid = _items.isNotEmpty;

    setState(() {
      _showItemsError = !isItemsValid;
    });

    if (!isFormValid || !isItemsValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đủ thông tin')),
      );
      return;
    }

    final data = {
      'receiptNumber': _receiptNumberController.text,
      'receiptDate': _selectedDate.toIso8601String(),
      'companyName': _companyNameController.text,
      'departmentName': _departmentNameController.text,
      'debtAccount': _debtAccountController.text,
      'creditAccount': _creditAccountController.text,
      'delivererName': _delivererNameController.text,
      'warehouseId': _selectedWarehouseId,
      'receiverId': _selectedReceiverId,
      'creatorId': _selectedCreatorId,
      'warehouseKeeperId': _selectedKeeperId,
      'chiefAccountantId': _selectedAccountantId,
      'note': _noteController.text,
      'totalAmount': _totalAmount,
      'totalAmountInWords': NumberToWords.convert(_totalAmount),
      'items': _items
          .map(
            (e) => {
              'productCode': e.productCode ?? '',
              'productName': e.productName,
              'unit': e.unit ?? '',
              'quantityDocument': e.quantityDocument,
              'quantityActual': e.quantityActual,
              'unitPrice': e.unitPrice,
            },
          )
          .toList(),
    };
    context.read<StockInFormCubit>().save(data, id: widget.receiptId);
  }
}
