import '../models/exercise.dart';

enum TrainingGoal {
  strength,
  muscle,
  fatLoss,
  maintain,
}

class EnumLabels {
  EnumLabels._();

  static String getBodyPartLabel(BodyPart value) {
    switch (value) {
      case BodyPart.chest:
        return '胸部';
      case BodyPart.back:
        return '背部';
      case BodyPart.legs:
        return '腿部';
      case BodyPart.shoulders:
        return '肩部';
      case BodyPart.arms:
        return '手臂';
      case BodyPart.core:
        return '核心';
      case BodyPart.cardio:
        return '有氧';
      case BodyPart.fullBody:
        return '全身';
    }
  }

  static String getEquipmentLabel(Equipment value) {
    switch (value) {
      case Equipment.barbell:
        return '杠铃';
      case Equipment.dumbbell:
        return '哑铃';
      case Equipment.kettlebell:
        return '壶铃';
      case Equipment.machine:
        return '器械';
      case Equipment.cable:
        return '绳索';
      case Equipment.bodyweight:
        return '自重';
      case Equipment.other:
        return '其他';
    }
  }

  static String getExerciseTypeLabel(ExerciseType value) {
    switch (value) {
      case ExerciseType.compound:
        return '复合';
      case ExerciseType.isolation:
        return '孤立';
    }
  }

  static String getTrainingGoalLabel(TrainingGoal value) {
    switch (value) {
      case TrainingGoal.strength:
        return '力量';
      case TrainingGoal.muscle:
        return '增肌';
      case TrainingGoal.fatLoss:
        return '减脂';
      case TrainingGoal.maintain:
        return '维持';
    }
  }
}
