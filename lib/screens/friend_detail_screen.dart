import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/friend.dart';
import '../models/transaction.dart';
import '../providers/balance_provider.dart';

class FriendDetailScreen extends StatefulWidget {
  final Friend friend;

  const FriendDetailScreen({super.key, required this.friend});

  @override
  State<FriendDetailScreen> createState() => _FriendDetailScreenState();
}

class _FriendDetailScreenState extends State<FriendDetailScreen> {
  late Future<List<FriendTransaction>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    _transactionsFuture = Provider.of<BalanceProvider>(
      context,
      listen: false,
    ).getTransactions(widget.friend.id!);
  }

  Future<void> _refreshTransactions() async {
    setState(_loadTransactions);
    await Provider.of<BalanceProvider>(context, listen: false).fetchFriends();
  }

  @override
  Widget build(BuildContext context) {
    final currentFriend = context.select<BalanceProvider, Friend>(
      (provider) => provider.friends.firstWhere(
        (friend) => friend.id == widget.friend.id,
        orElse: () => widget.friend,
      ),
    );
    final balance = currentFriend.totalBalance;
    final balanceColor = balance == 0
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : balance > 0
        ? Colors.green
        : Colors.red;
    final balanceLabel = balance == 0
        ? 'Settled up'
        : balance > 0
        ? '${widget.friend.name} owes you'
        : 'You owe ${widget.friend.name}';

    return Scaffold(
      appBar: AppBar(title: Text(widget.friend.name)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: balanceColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        balanceLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      balance.abs().toStringAsFixed(2),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: balanceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<FriendTransaction>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final transactions = snapshot.data ?? [];

                if (transactions.isEmpty) {
                  return const Center(child: Text('No transactions yet.'));
                }

                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return _buildTransactionTile(context, tx);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, FriendTransaction tx) {
    final isGiven = tx.type == TransactionType.given;
    final color = isGiven ? Colors.green : Colors.red;
    final prefix = isGiven ? '+' : '-';
    final direction = isGiven ? 'Money given' : 'Money received';
    final dateStr = DateFormat('MMM dd, yyyy').format(tx.date);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(
          isGiven ? Icons.arrow_upward : Icons.arrow_downward,
          color: color,
        ),
      ),
      title: Text(
        tx.description.isEmpty
            ? (isGiven ? 'Given' : 'Received')
            : tx.description,
      ),
      subtitle: Text('$direction - $dateStr'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$prefix${tx.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () => _showDeleteTransactionDialog(context, tx),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    final amountController = TextEditingController();
    final descController = TextEditingController();
    TransactionType selectedType = TransactionType.given;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Add Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ChoiceChip(
                    label: const Text('Given'),
                    selected: selectedType == TransactionType.given,
                    selectedColor: Colors.green.withValues(alpha: 0.3),
                    onSelected: (selected) {
                      if (selected) {
                        setDialogState(
                          () => selectedType = TransactionType.given,
                        );
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Received'),
                    selected: selectedType == TransactionType.received,
                    selectedColor: Colors.red.withValues(alpha: 0.3),
                    onSelected: (selected) {
                      if (selected) {
                        setDialogState(
                          () => selectedType = TransactionType.received,
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  final navigator = Navigator.of(dialogContext);
                  final provider = Provider.of<BalanceProvider>(
                    dialogContext,
                    listen: false,
                  );
                  final tx = FriendTransaction(
                    friendId: widget.friend.id!,
                    amount: amount,
                    description: descController.text,
                    date: DateTime.now(),
                    type: selectedType,
                  );
                  await provider.addTransaction(tx);
                  if (mounted && dialogContext.mounted) {
                    await _refreshTransactions();
                    navigator.pop();
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteTransactionDialog(
    BuildContext context,
    FriendTransaction tx,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              final provider = Provider.of<BalanceProvider>(
                dialogContext,
                listen: false,
              );
              await provider.deleteTransaction(tx.id!, tx.friendId);
              if (mounted && dialogContext.mounted) {
                await _refreshTransactions();
                navigator.pop();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
