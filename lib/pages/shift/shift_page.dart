import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/shift_model.dart';
import '../../models/position_model.dart';
import '../../services/shift_service.dart';
import '../../services/position_service.dart';
import '../../core/preferences/pref_helper.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/custom/report_widgets.dart';
import '../../widgets/custom/shift_card_widget.dart';
import 'position_management_page.dart';

class ShiftPage extends StatefulWidget {
  const ShiftPage({super.key});

  @override
  State<ShiftPage> createState() => _ShiftPageState();
}

class _ShiftPageState extends State<ShiftPage> {
  final ShiftService _shiftService = ShiftService();
  final PositionService _positionService = PositionService();
  final TextEditingController _searchController = TextEditingController();

  List<ShiftModel> _shifts = [];
  List<PositionModel> _positions = [];
  String _selectedFilter = 'Semua';
  bool _isLoading = true;

  final List<String> _filters = ['Semua', 'Hari Ini', 'Minggu Ini'];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadPositions();
    _loadShifts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final filter = await PrefHelper.getLastShiftFilter();
    if (mounted) {
      setState(() => _selectedFilter = filter);
    }
  }

  Future<void> _setFilter(String filter) async {
    setState(() => _selectedFilter = filter);
    await PrefHelper.saveLastShiftFilter(filter);
  }

  Future<void> _loadPositions() async {
    try {
      final positions = await _positionService.getAllPositions();
      if (mounted) {
        setState(() => _positions = positions);
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadShifts() async {
    setState(() => _isLoading = true);
    final data = await _shiftService.getAllShifts();
    if (!mounted) return;
    setState(() {
      _shifts = data;
      _isLoading = false;
    });
  }

  List<ShiftModel> get _filteredShifts {
    final keyword = _searchController.text.toLowerCase().trim();
    final now = DateTime.now();

    return _shifts.where((shift) {
      final shiftDate = DateTime.tryParse(shift.date);
      final matchKeyword =
          keyword.isEmpty ||
          shift.baristaName.toLowerCase().contains(keyword) ||
          shift.position.toLowerCase().contains(keyword);

      if (!matchKeyword) return false;
      if (_selectedFilter == 'Semua') return true;
      if (shiftDate == null) return false;

      if (_selectedFilter == 'Hari Ini') {
        return shiftDate.year == now.year &&
            shiftDate.month == now.month &&
            shiftDate.day == now.day;
      }

      if (_selectedFilter == 'Minggu Ini') {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        final start = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );
        final end = DateTime(
          endOfWeek.year,
          endOfWeek.month,
          endOfWeek.day,
          23,
          59,
          59,
        );
        return shiftDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
            shiftDate.isBefore(end.add(const Duration(seconds: 1)));
      }

      return true;
    }).toList();
  }

  int get _todayShiftCount {
    final now = DateTime.now();
    return _shifts.where((shift) {
      final shiftDate = DateTime.tryParse(shift.date);
      if (shiftDate == null) return false;
      return shiftDate.year == now.year &&
          shiftDate.month == now.month &&
          shiftDate.day == now.day;
    }).length;
  }

  String get _nearestShiftText {
    if (_shifts.isEmpty) return '-';

    final sorted = [..._shifts]..sort((a, b) => a.date.compareTo(b.date));
    return sorted.first.startTime;
  }

  Future<void> _deleteShift(ShiftModel shift) async {
    if (shift.id == null) return;
    await _shiftService.deleteShift(shift.id!);
    await _loadShifts();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Shift berhasil dihapus')));
  }

  Future<void> _openShiftForm({ShiftModel? shift}) async {
    final nameController = TextEditingController(
      text: shift?.baristaName ?? '',
    );
    String selectedDate =
        shift?.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    String startTime = shift?.startTime ?? '08:00';
    String endTime = shift?.endTime ?? '16:00';

    // Selalu load posisi terbaru dari database sebelum membuka form
    await _loadPositions();

    // Load last selected position from preferences
    final lastPosition = await PrefHelper.getLastShiftPosition();

    // Tentukan posisi awal: gunakan posisi shift yang sedang diedit,
    // atau posisi terakhir yang dipilih, atau posisi pertama dari daftar
    String selectedPosition;
    if (shift?.position != null &&
        _positions.any((p) => p.name == shift!.position)) {
      // Posisi shift yang ada masih valid di database
      selectedPosition = shift!.position;
    } else if (lastPosition != null &&
        _positions.any((p) => p.name == lastPosition)) {
      // Posisi terakhir yang dipilih masih ada
      selectedPosition = lastPosition;
    } else if (_positions.isNotEmpty) {
      // Gunakan posisi pertama yang tersedia
      selectedPosition = _positions.first.name;
    } else {
      // Fallback jika belum ada posisi sama sekali
      selectedPosition = 'Barista';
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickDate() async {
              final initialDate =
                  DateTime.tryParse(selectedDate) ?? DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setModalState(() {
                  selectedDate = DateFormat('yyyy-MM-dd').format(picked);
                });
              }
            }

            Future<void> pickTime(bool isStart) async {
              final initial = _stringToTime(isStart ? startTime : endTime);
              final picked = await showTimePicker(
                context: context,
                initialTime: initial,
              );
              if (picked != null) {
                final value = _timeToString(picked);
                setModalState(() {
                  if (isStart) {
                    startTime = value;
                  } else {
                    endTime = value;
                  }
                });
              }
            }

            Future<void> saveShift() async {
              try {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama barista tidak boleh kosong'),
                    ),
                  );
                  return;
                }

                final data = ShiftModel(
                  id: shift?.id,
                  baristaName: nameController.text.trim(),
                  date: selectedDate,
                  startTime: startTime,
                  endTime: endTime,
                  position: selectedPosition,
                );

                if (shift == null) {
                  await _shiftService.addShift(data);
                } else {
                  await _shiftService.updateShift(data);
                }

                // Save selected position to preferences
                await PrefHelper.saveLastShiftPosition(selectedPosition);

                if (!mounted) return;
                Navigator.pop(bottomSheetContext);
                await _loadShifts();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      shift == null
                          ? 'Shift berhasil ditambahkan'
                          : 'Shift berhasil diperbarui',
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menyimpan shift: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ReportColors.navy,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shift == null ? 'Tambah Shift' : 'Edit Shift',
                        style: const TextStyle(
                          color: ReportColors.cream,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _ShiftTextField(
                        controller: nameController,
                        label: 'Nama Barista',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 12),
                      _ShiftPickerTile(
                        icon: Icons.calendar_month_outlined,
                        label: 'Tanggal Shift',
                        value: selectedDate,
                        onTap: pickDate,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ShiftPickerTile(
                              icon: Icons.access_time_rounded,
                              label: 'Mulai',
                              value: startTime,
                              onTap: () => pickTime(true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ShiftPickerTile(
                              icon: Icons.access_time_filled_rounded,
                              label: 'Selesai',
                              value: endTime,
                              onTap: () => pickTime(false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedPosition,
                        dropdownColor: ReportColors.navy,
                        iconEnabledColor: ReportColors.muted,
                        style: const TextStyle(
                          color: ReportColors.cream,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: _inputDecoration(
                          label: 'Posisi',
                          icon: Icons.work_outline_rounded,
                        ),
                        items: _positions.isEmpty
                            ? [
                                const DropdownMenuItem(
                                  value: 'Barista',
                                  child: Text('Barista'),
                                ),
                                const DropdownMenuItem(
                                  value: 'Cashier',
                                  child: Text('Cashier'),
                                ),
                                const DropdownMenuItem(
                                  value: 'Kitchen',
                                  child: Text('Kitchen'),
                                ),
                              ]
                            : _positions
                                  .map(
                                    (position) => DropdownMenuItem(
                                      value: position.name,
                                      child: Text(position.name),
                                    ),
                                  )
                                  .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() => selectedPosition = value);
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ReportColors.brownLight,
                            foregroundColor: ReportColors.cream,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: saveShift,
                          child: Text(
                            shift == null ? 'Simpan Shift' : 'Perbarui Shift',
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
            );
          },
        );
      },
    );

    nameController.dispose();
  }

  TimeOfDay _stringToTime(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts.first) ?? 8;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _timeToString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredShifts;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: ReportColors.navyDark,
        bottomNavigationBar: const AppBottomNav(currentIndex: 1),
        floatingActionButton: FloatingActionButton(
          backgroundColor: ReportColors.brownLight,
          foregroundColor: ReportColors.cream,
          onPressed: () => _openShiftForm(),
          child: const Icon(Icons.add_rounded),
        ),
        body: ReportGradientBackground(
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadShifts,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 90),
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shifts',
                              style: TextStyle(
                                color: ReportColors.cream,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Kelola jadwal barista café',
                              style: TextStyle(
                                color: ReportColors.muted,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.09),
                          ),
                        ),
                        child: const Icon(
                          Icons.calendar_month_outlined,
                          color: ReportColors.muted,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          // Close shift form modal if open before navigating to position management
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }

                          if (!mounted) return;
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PositionManagementPage(),
                            ),
                          );

                          // Reload positions after returning from PositionManagementPage
                          if (mounted) {
                            await _loadPositions();
                          }
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.09),
                            ),
                          ),
                          child: const Icon(
                            Icons.work_outline,
                            color: ReportColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      ReportStatCard(
                        label: 'Total Shift',
                        value: _shifts.length.toString(),
                        trend: 'semua',
                        trendColor: ReportColors.green,
                      ),
                      const SizedBox(width: 12),
                      ReportStatCard(
                        label: 'Hari Ini',
                        value: _todayShiftCount.toString(),
                        trend: 'aktif',
                        trendColor: ReportColors.brownLight,
                      ),
                      const SizedBox(width: 12),
                      ReportStatCard(
                        label: 'Terdekat',
                        value: _nearestShiftText,
                        trend: 'jam',
                        trendColor: ReportColors.indigo,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _SearchBox(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final filter = _filters[index];
                        final selected = filter == _selectedFilter;

                        return ChoiceChip(
                          label: Text(filter),
                          selected: selected,
                          showCheckmark: false,
                          backgroundColor: Colors.white.withOpacity(0.05),
                          selectedColor: ReportColors.brown.withOpacity(0.5),
                          labelStyle: TextStyle(
                            color: selected
                                ? ReportColors.cream
                                : ReportColors.muted,
                            fontWeight: FontWeight.w800,
                          ),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.08),
                          ),
                          onSelected: (_) {
                            _setFilter(filter);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: ReportColors.brownLight,
                        ),
                      ),
                    )
                  else if (filtered.isEmpty)
                    const _EmptyShiftState()
                  else
                    ...filtered.map(
                      (shift) => Dismissible(
                        key: ValueKey(
                          'shift-${shift.id}-${shift.date}-${shift.startTime}',
                        ),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                          ),
                        ),
                        confirmDismiss: (_) async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Hapus shift?'),
                              content: Text(
                                'Shift ${shift.baristaName} akan dihapus.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );
                          return confirm ?? false;
                        },
                        onDismissed: (_) => _deleteShift(shift),
                        child: ShiftCardWidget(
                          shift: shift,
                          onEdit: () => _openShiftForm(shift: shift),
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
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBox({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        color: ReportColors.cream,
        fontWeight: FontWeight.w700,
      ),
      decoration: _inputDecoration(
        label: 'Cari nama barista atau posisi',
        icon: Icons.search_rounded,
      ),
    );
  }
}

class _ShiftTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _ShiftTextField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: ReportColors.cream,
        fontWeight: FontWeight.w700,
      ),
      decoration: _inputDecoration(label: label, icon: icon),
    );
  }
}

class _ShiftPickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ShiftPickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: InputDecorator(
        decoration: _inputDecoration(label: label, icon: icon),
        child: Text(
          value,
          style: const TextStyle(
            color: ReportColors.cream,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _EmptyShiftState extends StatelessWidget {
  const _EmptyShiftState();

  @override
  Widget build(BuildContext context) {
    return ReportGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              color: ReportColors.muted,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada data shift',
            style: TextStyle(
              color: ReportColors.cream,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tekan tombol + untuk menambahkan jadwal barista.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ReportColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration({
  required String label,
  required IconData icon,
}) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white.withOpacity(0.055),
    labelText: label,
    labelStyle: const TextStyle(
      color: ReportColors.muted,
      fontWeight: FontWeight.w700,
    ),
    prefixIcon: Icon(icon, color: ReportColors.muted),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: ReportColors.brownLight),
    ),
  );
}
