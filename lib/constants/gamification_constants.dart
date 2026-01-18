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

/// Constants related to gamification, levels, and achievements
class GamificationConstants {
  GamificationConstants._();

  // Level thresholds
  static const int legendaryLevel = 15;
  static const int incredibleLevel = 12;
  static const int masterLevel = 10;
  static const int advancedLevel = 8;
  static const int intermediateLevel = 5;
  static const int beginnerLevel = 1;

  // Streak milestones
  static const int longStreakDays = 30;
  static const int mediumStreakDays = 14;
  static const int shortStreakDays = 7;

  // Achievement thresholds
  static const int tasksCompletedMilestone = 100;
  static const int habitsCompletedMilestone = 50;
}
