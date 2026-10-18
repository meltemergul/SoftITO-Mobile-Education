import 'package:flutter/material.dart';
import '../models/budget_transaction.dart';
import '../models/category_model.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isIncome = false;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  List<CategoryModel> get _availableCategories => CategoryModel.categories
      .where(
        (category) => _isIncome
            ? category.name == 'Maaş' || category.name == 'Diğer'
            : category.name != 'Maaş',
      )
      .toList();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(
      _amountController.text.trim().replaceAll(',', '.'),
    );

    final transaction = BudgetTransaction(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      category: _selectedCategory!,
      amount: amount,
      date: _selectedDate,
      isIncome: _isIncome,
    );

    Navigator.pop(context, transaction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni İşlem')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text('Gelir'),
                    icon: Icon(Icons.trending_up),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('Gider'),
                    icon: Icon(Icons.trending_down),
                  ),
                ],
                selected: {_isIncome},
                onSelectionChanged: (selection) {
                  setState(() {
                    _isIncome = selection.first;
                    _selectedCategory = null;
                  });
                },
              ),
              const SizedBox(height: 24),
              const Text('İşlem adı'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Örn. Market alışverişi',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'İşlem adı zorunludur.'
                    : null,
              ),
              const SizedBox(height: 20),
              const Text('Tutar (₺)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: '0,00',
                  border: OutlineInputBorder(),
                  prefixText: '₺ ',
                ),
                validator: (value) {
                  final amount = double.tryParse(
                    (value ?? '').trim().replaceAll(',', '.'),
                  );

                  if (amount == null || !amount.isFinite || amount <= 0) {
                    return 'Pozitif ve geçerli bir tutar gir.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Kategori'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text('Kategori seç'),
                items: _availableCategories.map((category) {
                  return DropdownMenuItem(
                    value: category.name,
                    child: Row(
                      children: [
                        Icon(category.icon, color: category.color),
                        const SizedBox(width: 10),
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                validator: (value) =>
                    value == null ? 'Kategori seçmelisin.' : null,
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  'Tarih: ${_selectedDate.day}.'
                  '${_selectedDate.month}.'
                  '${_selectedDate.year}',
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  child: const Text('İşlemi Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
