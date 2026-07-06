import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/balance_provider.dart';
import 'friend_detail_screen.dart';
import '../models/friend.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Balance Manager'), centerTitle: true),
      body: Consumer<BalanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildSummaryCards(provider),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Divider(),
              ),
              Expanded(
                child: provider.friends.isEmpty
                    ? const Center(child: Text('No friends added yet.'))
                    : ListView.builder(
                        itemCount: provider.friends.length,
                        itemBuilder: (context, index) {
                          final friend = provider.friends[index];
                          return _buildFriendTile(context, friend);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFriendDialog(context),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildSummaryCards(BalanceProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildCard(
              'Owed to Me',
              provider.totalOwedToMe,
              Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: _buildCard('I Owe', provider.totalIOwe, Colors.red)),
        ],
      ),
    );
  }

  Widget _buildCard(String title, double amount, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              amount.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendTile(BuildContext context, Friend friend) {
    final balance = friend.totalBalance;
    final color = balance == 0
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : balance > 0
        ? Colors.green
        : Colors.red;
    final balanceText = balance == 0
        ? 'Settled up'
        : balance > 0
        ? 'Owes you: ${balance.abs().toStringAsFixed(2)}'
        : 'You owe: ${balance.abs().toStringAsFixed(2)}';

    return ListTile(
      leading: CircleAvatar(child: Text(friend.name[0].toUpperCase())),
      title: Text(friend.name),
      subtitle: Text(
        balanceText,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FriendDetailScreen(friend: friend),
          ),
        ).then((_) {
          if (context.mounted) {
            Provider.of<BalanceProvider>(context, listen: false).fetchFriends();
          }
        });
      },
      onLongPress: () {
        _showDeleteFriendDialog(context, friend);
      },
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Friend'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Friend Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await Provider.of<BalanceProvider>(
                  context,
                  listen: false,
                ).addFriend(name);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteFriendDialog(BuildContext context, Friend friend) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Friend'),
        content: Text(
          'Are you sure you want to delete ${friend.name}? All transaction history will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<BalanceProvider>(
                context,
                listen: false,
              ).deleteFriend(friend.id!);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
