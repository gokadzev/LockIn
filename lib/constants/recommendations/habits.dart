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

// ignore_for_file: avoid_redundant_argument_values

import 'package:lockin/core/models/habit_suggestion.dart';

const List<HabitSuggestion> habitSuggestionsDB = [
  HabitSuggestion(
    title: 'Make your bed every morning',
    category: 'Productivity',
    description: 'Start the day with a small, repeatable win.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: '5-minute morning meditation',
    category: 'Mindfulness',
    description: 'Reduce stress and improve focus with a short practice.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Read 20 minutes',
    category: 'Learning',
    description: 'Progress on a book or professional material each day.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Drink a glass of water on wake',
    category: 'Health',
    description: 'Rehydrate after sleep and support digestion.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'List 3 gratitudes',
    category: 'Wellness',
    description: 'Boost mood by noting three things you appreciate.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: '10-minute evening review',
    category: 'Productivity',
    description: 'Quickly reflect on accomplishments and plan tomorrow.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Walk 30 minutes',
    category: 'Fitness',
    description: 'Regular low-impact cardio to support health.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Stretch for 10 minutes',
    category: 'Fitness',
    description: 'Improve mobility and reduce stiffness.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'No screens 1 hour before sleep',
    category: 'Health',
    description: 'Improve sleep quality by reducing blue light exposure.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Prepare next-day outfit',
    category: 'Lifestyle',
    description: 'Reduce morning decision fatigue.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Pack a healthy lunch',
    category: 'Nutrition',
    description: 'Control portions and ingredients by preparing lunch ahead.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Practice 10 push-ups',
    category: 'Fitness',
    description: 'Keep strength up with a short bodyweight set.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Floss once a day',
    category: 'Health',
    description: 'Protect dental health with a consistent routine.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Read or listen to a short lesson',
    category: 'Learning',
    description: 'Consume micro-learning to build skills gradually.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Track one expense',
    category: 'Finance',
    description: 'Log small purchases to stay aware of spending habits.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Tidy for 10 minutes',
    category: 'Home',
    description: 'A short, consistent tidying habit keeps spaces manageable.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Practice mindful breathing (2 min)',
    category: 'Mindfulness',
    description: 'Quick reset to reduce stress and improve clarity.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Limit sugar intake for the day',
    category: 'Nutrition',
    description: 'Make a conscious choice to reduce added sugars.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Spend 15 minutes on a hobby',
    category: 'Personal',
    description:
        'Small creative or skill-building sessions compound over time.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Review a weekly priority list',
    category: 'Productivity',
    description: 'Keep important outcomes in focus for the week.',
    frequency: 'weekly',
  ),
  HabitSuggestion(
    title: 'Plan meals for the week',
    category: 'Nutrition',
    description: 'Reduces food waste and supports healthier choices.',
    frequency: 'weekly',
  ),
  HabitSuggestion(
    title: 'Grocery shop with a list',
    category: 'Home',
    description: 'Stick to planned items to save money and time.',
    frequency: 'weekly',
  ),
  HabitSuggestion(
    title: 'Clear email inbox to zero',
    category: 'Productivity',
    description: 'Process and archive messages to maintain focus.',
    frequency: 'weekly',
  ),
  HabitSuggestion(
    title: 'Reflect on a personal win',
    category: 'Wellness',
    description: 'Recognize progress to build motivation.',
    frequency: 'weekly',
  ),
  HabitSuggestion(
    title: 'Call or message a loved one',
    category: 'Social',
    description: 'Maintain connections with regular, small check-ins.',
    frequency: 'weekly',
  ),
  HabitSuggestion(
    title: 'Practice a 20-minute workout',
    category: 'Fitness',
    description: 'Short, focused sessions to improve strength and endurance.',
    frequency: 'weekly',
  ),
  HabitSuggestion(
    title: 'Review finances and bills',
    category: 'Finance',
    description: 'Weekly checks prevent surprises and missed payments.',
    frequency: 'weekly',
  ),
  HabitSuggestion(
    title: 'Complete a focused study session',
    category: 'Learning',
    description: 'Deep work blocks reinforce skill acquisition.',
    frequency: 'weekly',
  ),
  HabitSuggestion(
    title: 'Practice a skill drill (30 min)',
    category: 'Personal',
    description: 'Deliberate practice for a craft or hobby.',
    frequency: 'weekly',
  ),
  HabitSuggestion(
    title: 'Plan one social activity',
    category: 'Social',
    description: 'Schedule time to maintain relationships and community.',
    frequency: 'weekly',
  ),
  HabitSuggestion(
    title: 'Digital detox afternoon',
    category: 'Wellness',
    description: 'Unplug for a few hours to recharge.',
    frequency: 'weekly',
  ),
  HabitSuggestion(
    title: 'Practice sleeping by a consistent time',
    category: 'Health',
    description: 'Stabilize sleep patterns by keeping a routine.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Limit caffeine after 2pm',
    category: 'Health',
    description: 'Protect sleep quality by reducing late-day stimulants.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Take short standing breaks at work',
    category: 'Health',
    description: 'Stand and move briefly every hour to reduce sedentary time.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Practice a gratitude or affirmation',
    category: 'Wellness',
    description: 'Start the day with a positive mindset.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Do a 5-minute brain dump',
    category: 'Productivity',
    description: 'Clear your mind by writing down open tasks and ideas.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Limit social media to 20 minutes',
    category: 'Lifestyle',
    description: 'Set boundaries to prevent time drain and distraction.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Practice pen-to-paper notes once a day',
    category: 'Learning',
    description: 'Writing helps memory and comprehension.',
    frequency: 'daily',
  ),
  HabitSuggestion(
    title: 'Do a monthly budget review',
    category: 'Finance',
    description: 'Adjust allocations and check progress toward savings goals.',
    frequency: 'monthly',
  ),
  HabitSuggestion(
    title: 'Declutter one small area monthly',
    category: 'Home',
    description: 'Keep your living space manageable by small regular actions.',
    frequency: 'monthly',
  ),
  HabitSuggestion(
    title: 'Schedule preventive appointments',
    category: 'Health',
    description: 'Book dentist, doctor, or vision check-ups proactively.',
    frequency: 'monthly',
  ),
  HabitSuggestion(
    title: 'Review long-term goals and progress',
    category: 'Personal',
    description: 'Ensure weekly habits align with bigger objectives.',
    frequency: 'monthly',
  ),
  HabitSuggestion(
    title: 'Try a new recipe',
    category: 'Nutrition',
    description: 'Expand your cooking skills and dietary variety.',
    frequency: 'monthly',
  ),
  HabitSuggestion(
    title: 'Practice a monthly creative challenge',
    category: 'Personal',
    description: 'Keep creative muscles active with small projects.',
    frequency: 'monthly',
  ),
  HabitSuggestion(
    title: 'Review and update passwords',
    category: 'Security',
    description:
        'Improve digital safety by rotating or strengthening passwords.',
    frequency: 'monthly',
  ),
  HabitSuggestion(
    title: 'Volunteer or donate time',
    category: 'Social',
    description: 'Contribute to your community to build meaning and purpose.',
    frequency: 'monthly',
  ),
  HabitSuggestion(
    title: 'Reflect on personal values and alignment',
    category: 'Wellness',
    description: 'Check that daily actions match your priorities.',
    frequency: 'monthly',
  ),
  HabitSuggestion(
    title: 'Practice a monthly financial housecleaning',
    category: 'Finance',
    description: 'Cancel unused subscriptions and reconcile accounts.',
    frequency: 'monthly',
  ),
  HabitSuggestion(
    title: 'Try a quarterly digital declutter',
    category: 'Productivity',
    description: 'Archive or delete old files and apps you no longer use.',
    frequency: 'quarterly',
  ),
  HabitSuggestion(
    title: 'Review career development plan',
    category: 'Career',
    description:
        'Make sure your skills and actions are aligned with desired growth.',
    frequency: 'quarterly',
  ),
  HabitSuggestion(
    title: 'Plan a weekend mini-retreat',
    category: 'Wellness',
    description: 'Take intentional time to recharge and reassess.',
    frequency: 'quarterly',
  ),
  HabitSuggestion(
    title: 'Replace smoke/carbon detector batteries',
    category: 'Home',
    description: 'Maintain household safety with periodic checks.',
    frequency: 'yearly',
  ),
  HabitSuggestion(
    title: 'Annual health screening',
    category: 'Health',
    description: 'Book a yearly check to catch issues early.',
    frequency: 'yearly',
  ),
];
