/*
 *     Copyright (C) 2026 Valeri Gokadze
 *
 *     LockIn is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     LockIn is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

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
