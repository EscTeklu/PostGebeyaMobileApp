import 'package:flutter/material.dart';
import 'package:nopcommerce_mobile/customize/services/transaction_history_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final list = await TransactionHistoryService().getTransactions();
    setState(() => transactions = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: transactions.isEmpty
          ? const Center(child: Text('No transactions yet'))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (_, i) {
                final tx = transactions[i];
                return ListTile(
                  title: Text('Order ${tx['orderId']} - ${tx['status']}'),
                  subtitle: Text(tx['timestamp'] ?? ''),
                  trailing: Text(tx['amount']?.toString() ?? ''),
                );
              },
            ),
    );
  }
}
