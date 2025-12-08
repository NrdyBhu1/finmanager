import 'package:hive/hive.dart';

import 'sheets.dart';

class FinanceProvider with ChangeNotifier {
  List<Sheet> _sheets;
  Sheet? _currentSheet;

  List<Sheet> get sheets => _sheets;
  Sheet? get currentSheet => _currentSheet;

  FinanceProvider() {
    loadSheets();
  }

  Future<void> loadSheets() async {
    final sheetsBox = Hive.box<Sheet>('sheetsBox');

    final List<Sheet> retrievedSheets = sheetsBox.values.toList();

    if (retrievedSheets.isNotEmpty()) {
      _sheets = retrievedSheets;
      _currentSheet = retrievedSheets.first;
      _currentSheet!.transactions.sort((a, b) => a.date.compareTo(b.date));
    } else {
      _createNewSheet();
    }

    notifyListeners();
  }

  Future<void> saveSheets() async {
    final sheetsBox = Hive.box<Sheet>('sheetsBox');

    await sheetsBox.clear();

    for (var sheet in _sheets) {
      await sheetsBox.put(sheet.name, sheet);
    }
  }

  void _createNewSheet({ double initialBalance = 0.0 }) {
    final month = DateFormat.MMMM().format(DateTime.now());
    final sheetNumber = _sheets.where((s) => s.name.contains(month)).length + 1;
    final newSheet = Sheet(
      id: DateTime.now().toString(),
      name: 'Sheet - $month - $sheetNumber',
      transactions: [],
      balance: initialBalance,
    );

    _sheet.add(newSheet);
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

}
