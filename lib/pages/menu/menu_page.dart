import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/database/database_helper.dart';
import '../../core/preferences/pref_helper.dart';
import '../../models/menu_model.dart';
import '../../widgets/common/app_bottom_nav.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final _db = DatabaseHelper.instance;
  final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  List<MenuModel> _menus = [];
  bool _isLoading = true;

  // SharedPreferences Orang 2 — KEY-11
  String _selectedCategory = 'Semua';

  final List<String> _categories = ['Semua', 'Minuman', 'Makanan', 'Snack'];
  final List<String> _statusOptions = ['Tersedia', 'Habis'];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _loadMenus();
  }

  Future<void> _loadPrefs() async {
    final cat = await PrefHelper.getLastMenuCategory(); // READ KEY-11
    if (mounted) setState(() => _selectedCategory = cat);
  }

  Future<void> _loadMenus() async {
    setState(() => _isLoading = true);
    try {
      final maps = await _db.getAll('menus');
      setState(() => _menus = maps.map((m) => MenuModel.fromMap(m)).toList());
    } catch (e) {
      _snack('Gagal memuat menu: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<MenuModel> get _filtered {
    if (_selectedCategory == 'Semua') return _menus;
    return _menus.where((m) => m.category == _selectedCategory).toList();
  }

  Future<void> _setCategory(String cat) async {
    setState(() => _selectedCategory = cat);
    await PrefHelper.saveLastMenuCategory(cat); // WRITE KEY-11
  }

  // ── CREATE / UPDATE ────────────────────────────────────────────────────
  Future<void> _showForm({MenuModel? menu}) async {
    final nameCtrl = TextEditingController(text: menu?.name ?? '');
    final priceCtrl = TextEditingController(
      text: menu != null ? menu.price.toString() : '',
    );
    final stockCtrl = TextEditingController(
      text: menu != null ? menu.stock.toString() : '',
    );
    String category = menu?.category ?? 'Minuman';
    String status = menu?.status ?? 'Tersedia';

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
                    menu == null ? 'Tambah Menu' : 'Edit Menu',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _field(nameCtrl, 'Nama Menu', Icons.coffee_outlined),
                  const SizedBox(height: 12),
                  _field(
                    priceCtrl,
                    'Harga (Rp)',
                    Icons.payments_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    stockCtrl,
                    'Stok',
                    Icons.inventory_2_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category,
                    dropdownColor: const Color(0xFF1B2A4A),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: _dec('Kategori', Icons.category_outlined),
                    items: _categories
                        .where((c) => c != 'Semua')
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setSheet(() => category = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    dropdownColor: const Color(0xFF1B2A4A),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: _dec('Status', Icons.toggle_on_outlined),
                    items: _statusOptions
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setSheet(() => status = v);
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
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          final name = nameCtrl.text.trim();
                          final price =
                              int.tryParse(priceCtrl.text.trim()) ?? 0;
                          final stock =
                              int.tryParse(stockCtrl.text.trim()) ?? 0;
                          if (name.isEmpty) {
                            _snack('Nama menu tidak boleh kosong');
                            return;
                          }
                          if (price == 0) {
                            _snack('Harga tidak boleh kosong atau 0');
                            return;
                          }
                          final data = MenuModel(
                            id: menu?.id,
                            name: name,
                            category: category,
                            price: price,
                            stock: stock,
                            status: status,
                          );
                          if (menu == null) {
                            // CREATE SQLite
                            await _db.insert('menus', data.toMap());
                            _snack('Menu ditambahkan!');
                          } else {
                            // UPDATE SQLite
                            await _db.update('menus', data.toMap(), menu.id!);
                            _snack('Menu diperbarui!');
                          }
                          if (mounted) Navigator.pop(context);
                          await _loadMenus();
                        } catch (e) {
                          _snack('Gagal menyimpan menu: $e');
                        }
                      },
                      child: Text(
                        menu == null ? 'Simpan Menu' : 'Perbarui Menu',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
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
    priceCtrl.dispose();
    stockCtrl.dispose();
  }

  // ── DELETE SQLite ──────────────────────────────────────────────────────
  Future<void> _deleteMenu(MenuModel menu) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Menu?'),
        content: Text('Menu "${menu.name}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _db.delete('menus', menu.id!);
      await _loadMenus();
      _snack('Menu dihapus.');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  TextField _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      decoration: _dec(label, icon),
    );
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    filled: true,
    fillColor: Colors.white.withOpacity(0.06),
    labelText: label,
    labelStyle: const TextStyle(
      color: Colors.white54,
      fontWeight: FontWeight.w700,
    ),
    prefixIcon: Icon(icon, color: Colors.white38),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF8B5E3C)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2E),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
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
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Menu Café',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Kelola daftar menu & harga',
                          style: TextStyle(color: Colors.white54, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${_menus.length} item',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Filter kategori — tersimpan di SharedPreferences KEY-11
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final sel = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => _setCategory(cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: sel
                            ? const Color(0xFF8B5E3C)
                            : Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: sel ? Colors.white : Colors.white54,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // List menu
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B5E3C),
                      ),
                    )
                  : filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.coffee_outlined,
                            size: 64,
                            color: Colors.white24,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _menus.isEmpty
                                ? 'Belum ada menu'
                                : 'Tidak ada menu di kategori ini',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 90),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final menu = filtered[i];
                        return Dismissible(
                          key: Key('menu_${menu.id}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                          ),
                          confirmDismiss: (_) async {
                            await _deleteMenu(menu);
                            return false;
                          },
                          child: _MenuCard(
                            menu: menu,
                            currency: _currency,
                            onEdit: () => _showForm(menu: menu),
                          ),
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

class _MenuCard extends StatelessWidget {
  final MenuModel menu;
  final NumberFormat currency;
  final VoidCallback onEdit;

  const _MenuCard({
    required this.menu,
    required this.currency,
    required this.onEdit,
  });

  Color get _statusColor =>
      menu.status == 'Tersedia' ? const Color(0xFF2ECC71) : Colors.red.shade400;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5E3C).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_cafe_rounded,
              color: Color(0xFF8B5E3C),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      menu.category,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        menu.status,
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currency.format(menu.price),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
