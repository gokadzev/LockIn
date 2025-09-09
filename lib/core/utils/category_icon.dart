import 'package:flutter/material.dart';

/// Small helper to map category names to material icons.
IconData categoryToIcon(String? category) {
  if (category == null) return Icons.label_outline;
  switch (category.toLowerCase()) {
    case 'health':
      return Icons.favorite_border;
    case 'productivity':
      return Icons.work_outline;
    case 'learning':
      return Icons.school_outlined;
    case 'wellness':
      return Icons.spa_outlined;
    case 'fitness':
      return Icons.fitness_center_outlined;
    case 'mindfulness':
      return Icons.self_improvement_outlined;
    case 'finance':
      return Icons.account_balance_wallet_outlined;
    case 'planning':
      return Icons.event_note_outlined;
    case 'career':
      return Icons.trending_up_outlined;
    case 'social':
      return Icons.people_outline;
    case 'personal':
      return Icons.person_outline;
    default:
      return Icons.label_outline;
  }
}

/// Try to detect a category present in free text and return an icon.
IconData guessCategoryIcon(String? text) {
  if (text == null) return Icons.label_outline;
  final lower = text.toLowerCase();
  final candidates = [
    'health',
    'productivity',
    'learning',
    'wellness',
    'fitness',
    'mindfulness',
    'finance',
    'planning',
    'career',
    'social',
    'personal',
  ];
  for (final c in candidates) {
    if (lower.contains(c)) return categoryToIcon(c);
  }
  return Icons.label_outline;
}
