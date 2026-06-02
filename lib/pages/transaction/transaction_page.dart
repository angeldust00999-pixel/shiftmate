import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/database/database_helper.dart';
import '../../core/preferences/pref_helper.dart';
import '../../models/transaction_model.dart';
import '../../models/menu_model.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/custom/counter_button_widget.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final _db = DatabaseHelper.instance;

  List<TransactionModel> _transactions = [];
  List<MenuModel> _menus = [];
  bool _isLoading = true;

  // ── SharedPreferences state ────────────────────────────────────────────
  String _kasirName = 'Kasir'; // READ: key 'username'
  String _outletName = 'Café'; // READ: key 'outletName'
  String _filter = 'Semua'; // READ+WRITE: key 'transactionFilter'
  int _lastMenuId = -1; // READ+WRITE: key 'lastMenuId'

  late NumberFormat _currency;
  late DateFormat _dateFormat;

  static const List<String> _filters = ['Semua', 'Hari Ini', 'Minggu Ini'];

  // ────────────────────────────────────────────────────────────────────────
  // INIT
  // ────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // initializeDateFormatting sudah dipanggil di main(), langsung pakai
    _currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    _dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    // Prefs & data jalan BERSAMAAN, tidak sequential
    Future.wait([
      _loadPrefs(),
      _loadData(),
    ]).catchError((e) => debugPrint('Init error: $e'));
  }

  /// Baca SEMUA kunci SharedPreferences yang dipakai Orang 3
  Future<void> _loadPrefs() async {
    final name = await PrefHelper.getUsername(); // READ key 'username'
    final outlet = await PrefHelper.getOutletName(); // READ key 'outletName'
    final filter =
        await PrefHelper.getTransactionFilter(); // READ key 'transactionFilter'
    final menuId = await PrefHelper.getLastMenuId(); // READ key 'lastMenuId'
    setState(() {
      _kasirName = name;
      _outletName = outlet;
      _filter = filter;
      _lastMenuId = menuId;
    });
  }

  // ────────────────────────────────────────────────────────────────────────
  // DATABASE — READ
  // ────────────────────────────────────────────────────────────────────────

  // FIX: tambah try/catch + finally agar _isLoading SELALU di-set false,
  // bahkan ketika DatabaseHelper melempar exception (itulah penyebab loading terus)
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final txMaps = await _db.getAll('transactions');
      final menuMaps = await _db.getAll('menus');
      setState(() {
        _transactions = txMaps.map((m) => TransactionModel.fromMap(m)).toList();
        _menus = menuMaps.map((m) => MenuModel.fromMap(m)).toList();
      });
    } catch (e) {
      debugPrint('Error _loadData: $e');
      _snack('Gagal memuat data.');
    } finally {
      // Selalu jalan meski ada exception → loading tidak stuck selamanya
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // FILTER LOGIC (pakai SharedPreferences key 'transactionFilter')
  // ────────────────────────────────────────────────────────────────────────

  List<TransactionModel> get _filteredTransactions {
    if (_filter == 'Semua') return _transactions;
    final now = DateTime.now();
    return _transactions.where((t) {
      try {
        final d = DateTime.parse(t.date);
        if (_filter == 'Hari Ini') {
          return d.year == now.year && d.month == now.month && d.day == now.day;
        }
        if (_filter == 'Minggu Ini') {
          return d.isAfter(now.subtract(const Duration(days: 7)));
        }
      } catch (_) {}
      return false;
    }).toList();
  }

  Future<void> _setFilter(String f) async {
    setState(() => _filter = f);
    await PrefHelper.saveTransactionFilter(f); // WRITE key 'transactionFilter'
  }

  // ────────────────────────────────────────────────────────────────────────
  // DATABASE — CREATE
  // ────────────────────────────────────────────────────────────────────────

  Future<void> _showAddSheet() async {
    if (_menus.isEmpty) {
      _snack('Belum ada menu. Tambah menu terlebih dahulu.');
      return;
    }

    // Pre-select menu terakhir dari SharedPreferences (key 'lastMenuId')
    MenuModel initial = _menus.first;
    if (_lastMenuId != -1) {
      try {
        initial = _menus.firstWhere((m) => m.id == _lastMenuId);
      } catch (_) {}
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TransactionFormSheet(
        title: 'Tambah Transaksi',
        menus: _menus,
        initialMenu: initial,
        initialQty: 1,
        currency: _currency,
        onSave: (menu, qty) async {
          // DATABASE CREATE
          final tx = TransactionModel(
            menuId: menu.id!,
            quantity: qty,
            totalPrice: menu.price * qty,
            date: DateTime.now().toIso8601String(),
          );
          await _db.insert('transactions', tx.toMap());

          // WRITE SharedPreferences key 'lastMenuId'
          await PrefHelper.saveLastMenuId(menu.id!);
          setState(() => _lastMenuId = menu.id!);

          await _loadData();
          _snack('Transaksi berhasil ditambahkan!');
        },
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // DATABASE — UPDATE
  // ────────────────────────────────────────────────────────────────────────

  Future<void> _showEditSheet(TransactionModel tx) async {
    MenuModel? cur;
    try {
      cur = _menus.firstWhere((m) => m.id == tx.menuId);
    } catch (_) {}
    cur ??= _menus.isNotEmpty ? _menus.first : null;
    if (cur == null) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TransactionFormSheet(
        title: 'Edit Transaksi',
        menus: _menus,
        initialMenu: cur!,
        initialQty: tx.quantity,
        currency: _currency,
        onSave: (menu, qty) async {
          final updated = TransactionModel(
            id: tx.id,
            menuId: menu.id!,
            quantity: qty,
            totalPrice: menu.price * qty,
            date: tx.date,
          );
          await _db.update('transactions', updated.toMap(), tx.id!);

          // Perbarui lastMenuId juga
          await PrefHelper.saveLastMenuId(menu.id!);
          setState(() => _lastMenuId = menu.id!);

          await _loadData();
          _snack('Transaksi diperbarui!');
        },
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // DATABASE — DELETE
  // ────────────────────────────────────────────────────────────────────────

  Future<bool> _confirmDelete(BuildContext ctx) async {
    final res = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Transaksi'),
        content: const Text('Yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return res ?? false;
  }

  Future<void> _doDelete(int id) async {
    await _db.delete('transactions', id);
    await _loadData();
    _snack('Transaksi dihapus.');
  }

  // ────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────────────────────────────────

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  MenuModel? _menuById(int id) {
    try {
      return _menus.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  String _fmtDate(String raw) {
    try {
      return _dateFormat.format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final shown = _filteredTransactions;
    final totalPendapatan = shown.fold<int>(0, (s, t) => s + t.totalPrice);

    return Scaffold(
      // Nama outlet dari SharedPreferences (key 'outletName')
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Transaksi'),
            Text(
              _outletName,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: -1),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        tooltip: 'Tambah Transaksi',
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary — tampilkan nama kasir dari SharedPreferences
                _SummaryCard(
                  kasirName: _kasirName, // dari key 'username'
                  totalTx: shown.length,
                  totalPendapatan: totalPendapatan,
                  currency: _currency,
                ),

                // Filter chips — nilai & perubahan disimpan ke SharedPreferences
                _FilterBar(
                  selected: _filter,
                  filters: _filters,
                  onSelect: _setFilter,
                ),

                Expanded(child: _buildList(shown)),
              ],
            ),
    );
  }

  Widget _buildList(List<TransactionModel> shown) {
    if (shown.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              _transactions.isEmpty
                  ? 'Belum ada transaksi'
                  : 'Tidak ada transaksi untuk "$_filter"',
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ketuk + untuk menambah',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: shown.length,
      itemBuilder: (ctx, i) {
        final tx = shown[i];
        final menu = _menuById(tx.menuId);
        return Dismissible(
          key: Key('tx_${tx.id}'),
          direction: DismissDirection.endToStart,
          background: _dismissBg(),
          confirmDismiss: (_) => _confirmDelete(ctx),
          onDismissed: (_) => _doDelete(tx.id!),
          child: _TransactionCard(
            tx: tx,
            menuName: menu?.name ?? 'Menu #${tx.menuId}',
            formattedDate: _fmtDate(tx.date),
            formattedTotal: _currency.format(tx.totalPrice),
            onEdit: () => _showEditSheet(tx),
          ),
        );
      },
    );
  }

  Widget _dismissBg() => Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 24),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.red.shade400,
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.delete_outline, color: Colors.white, size: 28),
        SizedBox(height: 4),
        Text(
          'Hapus',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// REUSABLE WIDGETS
// ════════════════════════════════════════════════════════════════════════════

/// Kartu ringkasan — menampilkan kasirName (dari SharedPreferences 'username')
class _SummaryCard extends StatelessWidget {
  final String kasirName;
  final int totalTx;
  final int totalPendapatan;
  final NumberFormat currency;

  const _SummaryCard({
    required this.kasirName,
    required this.totalTx,
    required this.totalPendapatan,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2A4A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B2A4A).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris nama kasir
          Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.white54, size: 14),
              const SizedBox(width: 4),
              Text(
                'Kasir: $kasirName',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Item(
                label: 'Total Transaksi',
                value: '$totalTx transaksi',
                valueColor: Colors.white,
              ),
              Container(width: 1, height: 36, color: Colors.white24),
              _Item(
                label: 'Total Pendapatan',
                value: currency.format(totalPendapatan),
                valueColor: const Color(0xFF2ECC71),
                alignEnd: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool alignEnd;
  const _Item({
    required this.label,
    required this.value,
    required this.valueColor,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          color: valueColor,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

/// Filter chips — pilihan tersimpan ke SharedPreferences 'transactionFilter'
class _FilterBar extends StatelessWidget {
  final String selected;
  final List<String> filters;
  final ValueChanged<String> onSelect;

  const _FilterBar({
    required this.selected,
    required this.filters,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: filters.map((f) {
          final isActive = f == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF1B2A4A) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF1B2A4A).withOpacity(0.25),
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : const Color(0xFF1B2A4A),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Kartu satu baris transaksi
class _TransactionCard extends StatelessWidget {
  final TransactionModel tx;
  final String menuName;
  final String formattedDate;
  final String formattedTotal;
  final VoidCallback onEdit;

  const _TransactionCard({
    required this.tx,
    required this.menuName,
    required this.formattedDate,
    required this.formattedTotal,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1B2A4A).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.receipt,
                color: Color(0xFF1B2A4A),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${tx.quantity}x  •  $formattedDate',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedTotal,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1B2A4A),
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2A4A).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF1B2A4A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet form Create & Update
class _TransactionFormSheet extends StatefulWidget {
  final String title;
  final List<MenuModel> menus;
  final MenuModel initialMenu;
  final int initialQty;
  final NumberFormat currency;
  final Future<void> Function(MenuModel menu, int qty) onSave;

  const _TransactionFormSheet({
    required this.title,
    required this.menus,
    required this.initialMenu,
    required this.initialQty,
    required this.currency,
    required this.onSave,
  });

  @override
  State<_TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<_TransactionFormSheet> {
  late MenuModel _selected;
  late int _qty;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialMenu;
    _qty = widget.initialQty;
  }

  @override
  Widget build(BuildContext context) {
    final total = _selected.price * _qty;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8F6F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            widget.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),

          const Text(
            'Pilih Menu',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<MenuModel>(
            value: _selected,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            items: widget.menus
                .map(
                  (m) => DropdownMenuItem(
                    value: m,
                    child: Text(
                      '${m.name}  —  ${widget.currency.format(m.price)}',
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selected = val);
            },
          ),
          const SizedBox(height: 18),

          const Text(
            'Jumlah',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          // CounterButtonWidget — tap & hold gesture
          CounterButtonWidget(
            value: _qty,
            onChanged: (val) => setState(() => _qty = val),
          ),
          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2A4A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Bayar',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  widget.currency.format(total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B2A4A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _saving
                  ? null
                  : () async {
                      setState(() => _saving = true);
                      await widget.onSave(_selected, _qty);
                      if (mounted) Navigator.pop(context);
                    },
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Simpan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
