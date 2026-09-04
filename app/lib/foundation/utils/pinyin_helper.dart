import 'package:pinyin/pinyin.dart';

bool matchPinyin(String input, String chinese) {
  if (input.isEmpty) return true;
  final lowerInput = input.toLowerCase();

  if (chinese.contains(input)) {
    return true;
  }

  final fullPinyin = PinyinHelper.getPinyin(chinese, separator: '').toLowerCase();
  if (fullPinyin.contains(lowerInput)) {
    return true;
  }

  final firstLetter = PinyinHelper.getShortPinyin(chinese).toLowerCase();
  if (firstLetter.contains(lowerInput)) {
    return true;
  }

  return false;
}
