import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'transaction.dart';
import 'sheets.dart';
import 'config.dart';

class FinanceProvider with ChangeNotifier {
  List<Sheet> _sheets = [];
  Sheet? _currentSheet;

  List<Sheet> get sheets => _sheets;
  Sheet? get currentSheet => _currentSheet;

  FinanceProvider() {
    loadSheets();
    print(_currentSheet!.balance);
  }

  Future<void> loadSheets() async {
    final sheetsBox = Hive.box<Sheet>('sheetsBox');

    final List<Sheet> retrievedSheets = sheetsBox.values.toList();

    if (retrievedSheets.isNotEmpty) {
      _sheets = retrievedSheets;
      _currentSheet = retrievedSheets.first;
      _currentSheet?.transactions.sort((a, b) => a.date.compareTo(b.date));
    } else {
      createNewSheet();
    }

    notifyListeners();
  }

  Future<void> saveSheets() async {
    final sheetsBox = Hive.box<Sheet>('sheetsBox');

    for (var sheet in _sheets) {
      await sheetsBox.put(sheet.id, sheet);
    }
  }

  void switchSheets(Sheet sheet) {
    _currentSheet = sheet;
    _currentSheet?.transactions.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
  }

  void _createNewSheet({double initialBalance = 0.0}) {
    final month = DateFormat.MMMM().format(DateTime.now());
    final sheetNumber = _sheets.where((s) => s.name.contains(month)).length + 1;
    final newSheet = Sheet(
      id: uuid.v1(),
      name: 'Sheet - $month - $sheetNumber',
      transactions: [],
      balance: initialBalance,
    );

    _sheets.add(newSheet);
    _currentSheet = newSheet;
    saveSheets();
    notifyListeners();
  }

  void createNewSheet() {
    final previousBalance = _sheets.isEmpty ? 0.0 : _sheets.last.balance;
    _createNewSheet(initialBalance: previousBalance);
  }

  void switchSheet(Sheet sheet) {
    _currentSheet = sheet;
    _currentSheet!.transactions.sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
  }

  void addTransaction(Transaction transaction) {
    if (_currentSheet == null) {
      createNewSheet();
    }
    if (transaction.type == 'incoming') {
      _currentSheet!.balance += transaction.amount;
    } else {
      if (_currentSheet!.balance >= transaction.amount) {
        _currentSheet!.balance -= transaction.amount;
      } else {
        return;
      }
    }

    _currentSheet!.transactions.add(transaction);
    _currentSheet!.transactions.sort((a, b) => a.date.compareTo(b.date));
    saveSheets();
    notifyListeners();
  }

  void editTransaction(Transaction oldTransaction, Transaction newTransaction) {
    if (_currentSheet != null) {
      if (oldTransaction.type == 'incoming') {
        _currentSheet!.balance -= oldTransaction.amount;
      } else {
        _currentSheet!.balance += oldTransaction.amount;
      }

      if (newTransaction.type == 'incoming') {
        _currentSheet!.balance += newTransaction.amount;
      } else {
        if (_currentSheet!.balance >= newTransaction.amount) {
          _currentSheet!.balance -= newTransaction.amount;
        } else {
          if (oldTransaction.type == 'incoming') {
            _currentSheet!.balance += oldTransaction.amount;
          } else {
            _currentSheet!.balance -= oldTransaction.amount;
          }
        }
      }

      final index = _currentSheet!.transactions.indexWhere(
        (t) => t.id == oldTransaction.id,
      );
      if (index != -1) {
        _currentSheet!.transactions[index] = newTransaction;
      }

      _currentSheet!.transactions.sort((a, b) => a.date.compareTo(b.date));
      saveSheets();
      notifyListeners();
    }
  }

  void deleteTransaction(Transaction transaction) {
    if (_currentSheet != null) {
      if (transaction.type == 'incoming') {
        _currentSheet!.balance -= transaction.amount;
      } else {
        _currentSheet!.balance += transaction.amount;
      }

      _currentSheet!.transactions.removeWhere((t) => t.id == transaction.id);
      saveSheets();
      notifyListeners();
    }
  }
  
  Map<int, double> get monthlyDebitDataByDay {
    if (_currentSheet == null) {
      return {};
    }
    final debits = _currentSheet!.transactions.where((t) => t.type != 'incoming');
    
    final Map<int, double> dailyDebits = {};

    if (_currentSheet!.transactions.isNotEmpty) {
      final now = DateTime.now();
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;

      for (int day = 1; day <= lastDayOfMonth; day++) {
        dailyDebits[day] = 0.0;
      }
    }


    for (var transaction in debits) {
      final dayOfMonth = transaction.date.day;
      dailyDebits[dayOfMonth] = (dailyDebits[dayOfMonth] ?? 0.0) + transaction.amount;
    }

    return dailyDebits;
  }

  void deleteSheet(Sheet sheet) {
    if (_sheets.length > 1) {
      _sheets.remove(sheet);
      final sheetsBox = Hive.box<Sheet>('sheetsBox');
      sheetsBox.delete(sheet.id);
      _currentSheet = _sheets.first;
      saveSheets();
      notifyListeners();
    }
  }
}
