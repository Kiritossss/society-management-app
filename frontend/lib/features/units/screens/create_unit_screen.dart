import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/unit_provider.dart';

class CreateUnitScreen extends ConsumerStatefulWidget {
  const CreateUnitScreen({super.key});

  @override
  ConsumerState<CreateUnitScreen> createState() => _CreateUnitScreenState();
}

class _CreateUnitScreenState extends ConsumerState<CreateUnitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _unitNumberCtrl = TextEditingController();
  final _blockNameCtrl = TextEditingController();
  final _floorNumberCtrl = TextEditingController();
  final _areaSqftCtrl = TextEditingController();

  String? _selectedType;

  static const _unitTypes = ['1BHK', '2BHK', '3BHK', '4BHK', 'Studio', 'Shop', 'Office', 'Other'];

  @override
  void dispose() {
    _unitNumberCtrl.dispose();
    _blockNameCtrl.dispose();
    _floorNumberCtrl.dispose();
    _areaSqftCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(unitProvider).isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Unit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _unitNumberCtrl,
                decoration: const InputDecoration(
                  labelText: 'Unit / Flat Number *',
                  hintText: 'e.g. 301, A-101, House 5',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Unit number is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _blockNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Block / Tower / Wing (optional)',
                  hintText: 'e.g. Tower A, Block B',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _floorNumberCtrl,
                decoration: const InputDecoration(
                  labelText: 'Floor (optional)',
                  hintText: 'e.g. G, 1, 2, Mezzanine',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Unit Type (optional)'),
                items: _unitTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedType = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _areaSqftCtrl,
                decoration: const InputDecoration(
                  labelText: 'Area in sq.ft (optional)',
                  hintText: 'e.g. 1200',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty) {
                    final parsed = double.tryParse(v.trim());
                    if (parsed == null || parsed < 0) {
                      return 'Enter a valid positive number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: isSubmitting ? null : _submit,
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Unit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final areaText = _areaSqftCtrl.text.trim();
    final success = await ref.read(unitProvider.notifier).createUnit(
          unitNumber: _unitNumberCtrl.text.trim(),
          blockName: _blockNameCtrl.text.trim().isEmpty
              ? null
              : _blockNameCtrl.text.trim(),
          floorNumber: _floorNumberCtrl.text.trim().isEmpty
              ? null
              : _floorNumberCtrl.text.trim(),
          unitType: _selectedType,
          areaSqft: areaText.isNotEmpty ? double.tryParse(areaText) : null,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unit created successfully')),
      );
      context.pop();
    }
  }
}
