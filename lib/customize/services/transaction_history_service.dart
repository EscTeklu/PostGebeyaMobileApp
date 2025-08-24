import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionHistoryService {
  static const _key = 'ethswitch_transactions';

  Future<void> saveTransaction(Map<String, dynamic> transaction) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(jsonEncode(transaction));
    await prefs.setStringList(_key, list);
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }
}
