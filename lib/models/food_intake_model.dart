class FoodIntakeModel {
  int? id;
  DateTime createdAt;
  DateTime? eatenAt;
  String? description;
  String? reasonComment;
  String? commentAfterIntake;
  String? emotionsAfterIntakeComment;
  int? satietyLevelBeforeIntake;
  int? satietyLevelAfterIntake;
  int profileId;
  int? wakingPeriodId;

  FoodIntakeModel({
    required this.id,
    required this.createdAt,
    required this.eatenAt,
    required this.description,
    required this.reasonComment,
    required this.commentAfterIntake,
    required this.emotionsAfterIntakeComment,
    required this.satietyLevelBeforeIntake,
    required this.satietyLevelAfterIntake,
    required this.profileId,
    required this.wakingPeriodId,
  })  : assert(satietyLevelBeforeIntake == null ||
            (satietyLevelBeforeIntake >= 0 && satietyLevelBeforeIntake <= 10)),
        assert(satietyLevelAfterIntake == null ||
            (satietyLevelAfterIntake >= 0 && satietyLevelAfterIntake <= 10));

  factory FoodIntakeModel.fromJson(Map<String, dynamic> json) =>
      FoodIntakeModel(
        id: json['id'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
        eatenAt: json['eaten_at'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(json['eaten_at']),
        description: json['description'],
        reasonComment: json['reason_comment'],
        commentAfterIntake: json['comment_after_intake'],
        emotionsAfterIntakeComment: json['emotions_after_intake_comment'],
        satietyLevelBeforeIntake: json['satiety_level_before_intake'],
        satietyLevelAfterIntake: json['satiety_level_after_intake'],
        profileId: json['profile_id'],
        wakingPeriodId: json['waking_period_id'],
      );
}
