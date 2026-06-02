import '../core/database/database_helper.dart';
import '../models/position_model.dart';

class PositionService {
  static const String _tableName = 'positions';

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<PositionModel>> getAllPositions() async {
    final result = await _dbHelper.getAll(_tableName);
    return result.map((map) => PositionModel.fromMap(map)).toList();
  }

  Future<int> addPosition(PositionModel position) async {
    return await _dbHelper.insert(_tableName, position.toMap());
  }

  Future<int> updatePosition(PositionModel position) async {
    if (position.id == null) {
      throw Exception('ID posisi tidak ditemukan');
    }

    return await _dbHelper.update(_tableName, position.toMap(), position.id!);
  }

  Future<int> deletePosition(int id) async {
    return await _dbHelper.delete(_tableName, id);
  }
}
