import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/dates.dart';
import '../../core/money/money.dart';
import '../../core/widgets/state_views.dart';
import '../../data/database.dart';
import '../../data/transactions_repository.dart';
import '../../sync/sync_controller.dart';
import 'delete_with_undo.dart';
import 'transactions_providers.dart';

/// New transaction, or edit of [clientId]. Saves locally; sync uploads it.
class TransactionFormScreen extends ConsumerWidget {
  const TransactionFormScreen({this.clientId, super.key});
  final String? clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = clientId;
    if (id == null) return const _TransactionForm();
    return ref.watch(transactionProvider(id)).when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const Scaffold(
            body: ErrorView(message: 'Couldn’t load this transaction.'),
          ),
          data: (t) => t == null
              ? Scaffold(
                  appBar: AppBar(),
                  body: const EmptyView(
                    message: 'This transaction was deleted.',
                  ),
                )
              : _TransactionForm(existing: t),
        );
  }
}

class _TransactionForm extends ConsumerStatefulWidget {
  const _TransactionForm({this.existing});
  final Transaction? existing;

  @override
  ConsumerState<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<_TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _description;
  late final TextEditingController _notes;
  late String _kind;
  late DateTime _occurredOn;
  int? _accountId;
  int? _categoryId;
  bool _saving = false;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    _amount = TextEditingController(
      text: t == null ? '' : _plainAmount(t.amountCents),
    );
    _description = TextEditingController(text: t?.description ?? '');
    _notes = TextEditingController(text: t?.notes ?? '');
    _kind = t?.kind ?? 'expense';
    _occurredOn = t?.occurredOn ?? Dates.dateOnly(DateTime.now());
    _accountId = t?.accountId;
    _categoryId = t?.categoryId;
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    _notes.dispose();
    super.dispose();
  }

  static String _plainAmount(int cents) {
    final fraction = cents % 100;
    return fraction == 0
        ? '${cents ~/ 100}'
        : '${cents ~/ 100}.${fraction.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _occurredOn,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 366)),
    );
    if (picked != null) setState(() => _occurredOn = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final notes = _notes.text.trim();
    final draft = TransactionDraft(
      accountId: _accountId!,
      categoryId: _categoryId,
      kind: _kind,
      amountCents: Money.parse(_amount.text)!,
      occurredOn: _occurredOn,
      description: _description.text,
      notes: notes.isEmpty ? null : notes,
      tags: widget.existing?.tags ?? '',
    );
    final repo = ref.read(transactionsRepositoryProvider);
    final existing = widget.existing;
    if (existing == null) {
      await repo.create(draft);
    } else {
      await repo.update(existing.clientId, draft);
    }
    ref.read(syncControllerProvider.notifier).sync().ignore();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsListProvider).valueOrNull ?? const [];
    final categories =
        (ref.watch(categoriesListProvider).valueOrNull ?? const <Category>[])
            .where((c) => c.kind == _kind)
            .toList();
    // Default to the first account once accounts have loaded.
    _accountId ??= accounts.isEmpty ? null : accounts.first.id;
    if (_categoryId != null && !categories.any((c) => c.id == _categoryId)) {
      _categoryId = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit transaction' : 'New transaction'),
        actions: [
          if (widget.existing case final existing?)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                final messenger = ScaffoldMessenger.of(context);
                context.pop();
                deleteWithUndo(messenger, ref, existing.clientId);
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'expense', label: Text('Expense')),
                  ButtonSegment(value: 'income', label: Text('Income')),
                ],
                selected: {_kind},
                onSelectionChanged: (s) => setState(() => _kind = s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amount,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: '1,250.00',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final cents = Money.parse(value ?? '');
                  if (cents == null) return 'Enter an amount like 1,250.50';
                  if (cents == 0) return 'Amount must be more than zero';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 120,
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Add a short description'
                    : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _accountId,
                decoration: const InputDecoration(labelText: 'Account'),
                items: [
                  for (final a in accounts)
                    DropdownMenuItem(value: a.id, child: Text(a.name)),
                ],
                onChanged: (id) => setState(() => _accountId = id),
                validator: (id) => id == null
                    ? 'Add an account on the web first, then sync'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int?>(
                value: _categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  const DropdownMenuItem(child: Text('Uncategorised')),
                  for (final c in categories)
                    DropdownMenuItem(value: c.id, child: Text(c.name)),
                ],
                onChanged: (id) => setState(() => _categoryId = id),
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Date'),
                child: InkWell(
                  onTap: _pickDate,
                  child: Text(Dates.day(_occurredOn)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notes,
                decoration:
                    const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_editing ? 'Save changes' : 'Add transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
