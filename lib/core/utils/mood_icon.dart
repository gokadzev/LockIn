import 'package:flutter/material.dart';

IconData moodIcon(int? mood) {
  if (mood == null) return Icons.sentiment_neutral;
  if (mood >= 8) return Icons.sentiment_very_satisfied;
  if (mood >= 6) return Icons.sentiment_satisfied;
  if (mood >= 4) return Icons.sentiment_neutral;
  return Icons.sentiment_very_dissatisfied;
}
