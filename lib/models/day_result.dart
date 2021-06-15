class DayResultModel {
  double valueSum;
  DateTime createdAtDay;

  DayResultModel({
    required this.valueSum,
    required this.createdAtDay,
  });

  factory DayResultModel.fromJson(Map<String, dynamic> json) => DayResultModel(
        valueSum: json['value_sum'],
        createdAtDay: DateTime.fromMillisecondsSinceEpoch(
            json['created_at_day'] * 100000),
      );
}
