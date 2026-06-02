class ShiftModel {
  final int? id;
  final String baristaName;
  final String date;
  final String startTime;
  final String endTime;
  final String position;

  ShiftModel({
    this.id,
    required this.baristaName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.position,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barista_name': baristaName,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'position': position,
    };
  }

  factory ShiftModel.fromMap(Map<String, dynamic> map) {
    return ShiftModel(
      id: map['id'],
      baristaName: map['barista_name'],
      date: map['date'],
      startTime: map['start_time'],
      endTime: map['end_time'],
      position: map['position'],
    );
  }
}
