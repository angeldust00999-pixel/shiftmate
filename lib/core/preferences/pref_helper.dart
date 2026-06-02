import 'package:shared_preferences/shared_preferences.dart';

class PrefHelper {
  // ── Kunci milik Orang 4 (Login & Dashboard) ───────────────────────────
  static const String isLogin = 'isLogin';
  static const String username = 'username';
  static const String role = 'role';
  static const String themeMode = 'themeMode';
  static const String outletName = 'outletName';
  static const String lastReportFilter = 'lastReportFilter';
  static const String language = 'language';
  static const String dashboardViewMode = 'dashboardViewMode';

  // ── Kunci milik Orang 3 (Modul Transaksi) ─────────────────────────────
  static const String lastMenuId = 'lastMenuId'; // KEY-9
  static const String transactionFilter = 'transactionFilter'; // KEY-10

  // ── Kunci milik Orang 2 (Modul Menu & Stok) ───────────────────────────
  static const String lastMenuCategory = 'lastMenuCategory'; // KEY-11
  static const String lastStockFilter = 'lastStockFilter'; // KEY-12

  // ── Kunci milik Orang 1 (Modul Shift) ──────────────────────────────────
  static const String lastShiftFilter = 'lastShiftFilter'; // KEY-13 (Orang 1)
  static const String lastShiftPosition =
      'lastShiftPosition'; // KEY-14 (Orang 1)

  // ═══════════════════════════════════════════════════════════════════════
  // Methods Orang 4
  // ═══════════════════════════════════════════════════════════════════════

  static Future<void> saveLoginSession(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLogin, true);
    await prefs.setString(username, name);
    await prefs.setString(role, 'Admin');
    await prefs.setBool(themeMode, false);
    await prefs.setString(outletName, 'ShiftMate Café');
    await prefs.setString(lastReportFilter, 'Hari Ini');
    await prefs.setString(language, 'id');
    await prefs.setString(dashboardViewMode, 'chart');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Methods Orang 3 — READ kunci existing
  // ═══════════════════════════════════════════════════════════════════════

  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(username) ?? 'Kasir';
  }

  static Future<String> getOutletName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(outletName) ?? 'ShiftMate Café';
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Methods Orang 3 — READ + WRITE kunci baru
  // ═══════════════════════════════════════════════════════════════════════

  static Future<void> saveLastMenuId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(lastMenuId, id);
  }

  static Future<int> getLastMenuId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(lastMenuId) ?? -1;
  }

  static Future<void> saveTransactionFilter(String filter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(transactionFilter, filter);
  }

  static Future<String> getTransactionFilter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(transactionFilter) ?? 'Semua';
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Methods Orang 2 — READ + WRITE kunci baru
  // ═══════════════════════════════════════════════════════════════════════

  static Future<void> saveLastMenuCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lastMenuCategory, category);
  }

  static Future<String> getLastMenuCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(lastMenuCategory) ?? 'Semua';
  }

  static Future<void> saveLastStockFilter(String filter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lastStockFilter, filter);
  }

  static Future<String> getLastStockFilter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(lastStockFilter) ?? 'Semua';
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Methods Orang 1 — READ + WRITE kunci baru (Modul Shift)
  // ═══════════════════════════════════════════════════════════════════════

  static Future<void> saveLastShiftFilter(String filter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lastShiftFilter, filter);
  }

  static Future<String> getLastShiftFilter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(lastShiftFilter) ?? 'Semua';
  }

  static Future<void> saveLastShiftPosition(String position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lastShiftPosition, position);
  }

  static Future<String> getLastShiftPosition() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(lastShiftPosition) ?? 'Barista';
  }
}
