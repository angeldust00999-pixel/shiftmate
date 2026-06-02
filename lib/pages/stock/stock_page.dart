import 'package:flutter/material.dart';
import '../../core/database/database_helper.dart';
import '../../core/preferences/pref_helper.dart';
import '../../models/stock_model.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/custom/stock_indicator_widget.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final _db = DatabaseHelper.instance;

  List<StockModel> _stocks = [];
  bool _isLoading = true;

  // SharedPreferences Orang 2 — KEY-12
  String _selectedFilter = 'Semua';

  final List<String> _filters = ['Semua', 'Hampir Habis', 'Habis'];
  final List<String> _units = ['kg', 'liter', 'pcs', 'gram', 'ml', 'pak'];

  static const int _maxQty = 100;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _loadStocks();
  }

  Future<void> _loadPrefs() async {
    final filter = await PrefHelper.getLastStockFilter(); // READ KEY-12
    if (mounted) setState(() => _selectedFilter = filter);
  }

  Future<void> _loadStocks() async {
    setState(() => _isLoading = true);
    try {
      final maps = await _db.getAll('stocks');
      setState(
          () => _stocks = maps.map((m) => StockModel.fromMap(m)).toList());
    } catch (e) {
      _snack('Gagal memuat stok: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<StockModel> get _filtered {
    switch (_selectedFilter) {
      case 'Hampir Habis':
        return _stocks
            .where((s) => s.quantity > 0 && s.quantity <= 20)
            .toList();
      case 'Habis':
        return _stocks.where((s) => s.quantity == 0).toList();
      default:
        return _stocks;
    }
  }

  Future<void> _setFilter(String f) async {
    setState(() => _selectedFilter = f);
    await PrefHelper.saveLastStockFilter(f); // WRITE KEY-12
  }

  // ── GESTURE drag slider → langsung UPDATE SQLite ─────────────────────
  Future<void> _updateQtySlider(StockModel stock, int newQty) async {
    final updated = StockModel(
      id: stock.id,
      itemName: stock.itemName,
      quantity: newQty,
      unit: stock.unit,
      updatedAt: DateTime.now().toIso8601String(),
    );
    await _db.update('stocks', updated.toMap(), stock.id!);
    await _loadStocks();
  }

  // ── CREATE / UPDATE ────────────────────────────────────────────────────
  Future<void> _showForm({StockModel? stock}) async {
    final nameCtrl = TextEditingController(text: stock?.itemName ?? '');
    final qtyCtrl = TextEditingController(
        text: stock != null ? stock.quantity.toString() : '');
    String unit = stock?.unit ?? 'kg';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2A4A),
              borderRadius: BorderRadius.circular(28),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock == null ? 'Tambah Stok' : 'Edit Stok',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _field(nameCtrl, 'Nama Bahan', Icons.inventory_2_outlined),
                  const SizedBox(height: 12),
                  _field(qtyCtrl, 'Jumlah', Icons.numbers_rounded,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: unit,
                    dropdownColor: const Color(0xFF1B2A4A),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                    decoration: _dec('Satuan', Icons.straighten_outlined),
                    items: _units
                        .map((u) =>
                            DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setSheet(() => unit = v);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5E3C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final qty =
                            int.tryParse(qtyCtrl.text.trim()) ?? 0;
                        if (name.isEmpty) {
                          _snack('Nama bahan tidak boleh kosong');
                          return;
                        }
                        final data = StockModel(
                          id: stock?.id,
                          itemName: name,
                          quantity: qty,
                          unit: unit,
                          updatedAt: DateTime.now().toIso8601String(),
                        );
                        if (stock == null) {
                          // CREATE SQLite
                          await _db.insert('stocks', data.toMap());
                          _snack('Stok ditambahkan!');
                        } else {
                          // UPDATE SQLite
                          await _db.update('stocks', data.toMap(), stock.id!);
                          _snack('Stok diperbarui!');
                        }
                        if (mounted) Navigator.pop(context);
                        await _loadStocks();
                      },
                      child: Text(
                        stock == null ? 'Simpan' : 'Perbarui',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    nameCtrl.dispose();
    qtyCtrl.dispose();
  }

  // ── DELETE SQLite ──────────────────────────────────────────────────────
  Future<void> _deleteStock(StockModel stock) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Stok?'),
        content: Text('"${stock.itemName}" akan dihapus.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await _db.delete('stocks', stock.id!);
      await _loadStocks();
      _snack('Stok dihapus.');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  TextField _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.w700),
      decoration: _dec(label, icon),
    );
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        labelText: label,
        labelStyle: const TextStyle(
            color: Colors.white54, fontWeight: FontWeight.w700),
        prefixIcon: Icon(icon, color: Colors.white38),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF8B5E3C)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final lowCount =
        _stocks.where((s) => s.quantity > 0 && s.quantity <= 20).length;
    final emptyCount = _stocks.where((s) => s.quantity == 0).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2E),
      bottomNavigationBar: const AppBottomNav(currentIndex: -1),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8B5E3C),
        foregroundColor: Colors.white,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Stok Bahan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      )),
                  const SizedBox(height: 6),
                  const Text('Geser slider untuk update stok cepat',
                      style:
                          TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _SummaryChip(
                          label: 'Total',
                          value: '${_stocks.length}',
                          color: Colors.blue),
                      const SizedBox(width: 10),
                      _SummaryChip(
                          label: 'Rendah',
                          value: '$lowCount',
                          color: Colors.orange),
                      const SizedBox(width: 10),
                      _SummaryChip(
                          label: 'Habis',
                          value: '$emptyCount',
                          color: Colors.red),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Filter bar — tersimpan di SharedPreferences KEY-12
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final f = _filters[i];
                  final sel = f == _selectedFilter;
                  return GestureDetector(
                    onTap: () => _setFilter(f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: sel
                            ? const Color(0xFF8B5E3C)
                            : Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Text(f,
                          style: TextStyle(
                            color: sel ? Colors.white : Colors.white54,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          )),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF8B5E3C)))
                  : filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.inventory_2_outlined,
                                  size: 64, color: Colors.white24),
                              const SizedBox(height: 12),
                              Text(
                                _stocks.isEmpty
                                    ? 'Belum ada data stok'
                                    : 'Tidak ada stok di filter ini',
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 15),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(18, 0, 18, 90),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final stock = filtered[i];
                            return _StockCard(
                              stock: stock,
                              maxQty: _maxQty,
                              onEdit: () => _showForm(stock: stock),
                              onDelete: () => _deleteStock(stock),
                              onSliderChanged: (newQty) =>
                                  _updateQtySlider(stock, newQty),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Card stok dengan DRAG SLIDER (Gesture Orang 2) ───────────────────────
class _StockCard extends StatelessWidget {
  final StockModel stock;
  final int maxQty;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<int> onSliderChanged;

  const _StockCard({
    required this.stock,
    required this.maxQty,
    required this.onEdit,
    required this.onDelete,
    required this.onSliderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5E3C).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: Color(0xFF8B5E3C), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stock.itemName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        )),
                    Text(
                        'Update: ${stock.updatedAt.length >= 10 ? stock.updatedAt.substring(0, 10) : stock.updatedAt}',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.edit_outlined,
                          color: Colors.white60, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_outline,
                          color: Colors.redAccent, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // StockIndicatorWidget — custom widget persentase stok
          StockIndicatorWidget(
            quantity: stock.quantity,
            maxQuantity: maxQty,
            unit: stock.unit,
          ),
          const SizedBox(height: 10),
          // GESTURE — drag slider stok langsung update SQLite
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 5,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 18),
              activeTrackColor: const Color(0xFF2ECC71),
              inactiveTrackColor: Colors.white12,
              thumbColor: Colors.white,
              overlayColor: Colors.white24,
            ),
            child: Slider(
              value: stock.quantity
                  .toDouble()
                  .clamp(0, maxQty.toDouble()),
              min: 0,
              max: maxQty.toDouble(),
              divisions: maxQty,
              onChanged: (val) => onSliderChanged(val.round()),
            ),
          ),
          const Center(
            child: Text('Geser untuk update stok',
                style: TextStyle(color: Colors.white24, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 15)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
