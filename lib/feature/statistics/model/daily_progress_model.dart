class DailyProgressModel {
  final String date;
  final double accuracy;

  DailyProgressModel({required this.date, required this.accuracy});

  factory DailyProgressModel.fromMap(Map<String, dynamic> map) {
    return DailyProgressModel(
      date: (map['date'] ?? '') as String,
      accuracy: (map['accuracy'] ?? 0.0) is double 
          ? (map['accuracy'] ?? 0.0) as double
          : (map['accuracy'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'date': date, 'accuracy': accuracy};
  }

  @override
  String toString() {
    return 'DailyProgressModel(date: $date, accuracy: $accuracy)';
  }
}
