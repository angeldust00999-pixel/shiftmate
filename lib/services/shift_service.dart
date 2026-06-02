import '../core/database/database_helper.dart';
import '../models/shift_model.dart';

class ShiftService {
  static const String _tableName = 'shifts';

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<ShiftModel>> getAllShifts() async {
    final result = await _dbHelper.getAll(_tableName);
    return result.map((map) => ShiftModel.fromMap(map)).toList();
  }

  Future<int> addShift(ShiftModel shift) async {
    return await _dbHelper.insert(_tableName, shift.toMap());
  }

  Future<int> updateShift(ShiftModel shift) async {
    if (shift.id == null) {
      throw Exception('ID shift tidak ditemukan');
    }

    return await _dbHelper.update(_tableName, shift.toMap(), shift.id!);
  }

  Future<int> deleteShift(int id) async {
    return await _dbHelper.delete(_tableName, id);
  }
}
