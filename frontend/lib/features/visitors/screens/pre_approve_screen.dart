import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/visitor_provider.dart';

const _purposes = ['guest', 'delivery', 'cab', 'service', 'other'];

class PreApproveScreen extends ConsumerStatefulWidget {
  const PreApproveScreen({super.key});

  @override
  ConsumerState<PreApproveScreen> createState() => _PreApproveScreenState();
}

class _PreApproveScreenState extends ConsumerState<PreApproveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _vehicleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _purpose = 'guest';
  int _count = 1;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _vehicleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(visitorProvider.notifier).preApprove(
          visitorName: _nameCtrl.text.trim(),
          visitorPhone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          visitorCount: _count,
          purpose: _purpose,
          vehicleNumber: _vehicleCtrl.text.trim().isEmpty ? null : _vehicleCtrl.text.trim(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visitor pre-approved'), backgroundColor: AppColors.success),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(visitorProvider).isSubmitting;

    return Scaffold(
      appBar: AppBar(title: const Text('Pre-approve Visitor')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Visitor Name', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'e.g. John Doe',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),

                const Text('Phone (optional)', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '+91 98765 43210',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Purpose', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _purpose,
                  items: _purposes
                      .map((p) => DropdownMenuItem(value: p, child: Text(p[0].toUpperCase() + p.substring(1))))
                      .toList(),
                  onChanged: (v) => setState(() => _purpose = v ?? 'guest'),
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined)),
                ),
                const SizedBox(height: 16),

                const Text('Number of Visitors', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: _count > 1 ? () => setState(() => _count--) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$_count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    IconButton(
                      onPressed: _count < 50 ? () => setState(() => _count++) : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text('Vehicle Number (optional)', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _vehicleCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'MH 01 AB 1234',
                    prefixIcon: Icon(Icons.directions_car_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Notes (optional)', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Any additional info',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  child: isSubmitting
                      ? const SizedBox(
                          height: 22, width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Pre-approve Visitor'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
