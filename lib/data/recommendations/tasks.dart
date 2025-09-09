// ignore_for_file: avoid_redundant_argument_values

import 'package:lockin/core/models/task_suggestion.dart';

const List<TaskSuggestion> taskSuggestionsDB = [
  // Productivity / Planning
  TaskSuggestion(
    title: 'Organize your workspace',
    category: 'Productivity',
    description:
        'Clear clutter, sort papers and tidy digital files for a focused start.',
    priority: 2,
  ),
  TaskSuggestion(
    title: 'Plan tomorrow tonight',
    category: 'Planning',
    description: 'Write your top 3 MITs (Most Important Tasks) for tomorrow.',
    priority: 3,
  ),
  TaskSuggestion(
    title: 'Review weekly goals',
    category: 'Planning',
    description: 'Check progress and adjust next week’s priorities.',
    priority: 2,
  ),
  TaskSuggestion(
    title: 'Break a big task into subtasks',
    category: 'Productivity',
    description:
        'Split the project into small, actionable steps you can complete in one session.',
    priority: 3,
  ),
  TaskSuggestion(
    title: 'Batch similar small tasks',
    category: 'Productivity',
    description:
        'Group quick actions (emails, calls) and do them in one block to reduce context switching.',
    priority: 2,
  ),

  // Personal / Routines
  TaskSuggestion(
    title: 'Meal-prep for two days',
    category: 'Personal',
    description:
        'Cook and portion meals to save time and eat healthier during busy days.',
    priority: 2,
  ),
  TaskSuggestion(
    title: 'Set out clothes for tomorrow',
    category: 'Personal',
    description: 'Decide outfit and prep to reduce morning friction.',
    priority: 1,
  ),
  TaskSuggestion(
    title: 'Schedule medical check-up',
    category: 'Health',
    description:
        'Book a routine doctor or dental appointment you’ve been postponing.',
    priority: 2,
  ),
  TaskSuggestion(
    title: 'Declutter one drawer',
    category: 'Lifestyle',
    description: 'Pick a small zone and remove items you no longer need.',
    priority: 1,
  ),

  // Finance
  TaskSuggestion(
    title: 'Reconcile last month’s expenses',
    category: 'Finance',
    description:
        'Compare bank statements to your records and note irregularities.',
    priority: 2,
  ),
  TaskSuggestion(
    title: 'Set or review budget categories',
    category: 'Finance',
    description:
        'Adjust monthly limits for essentials, savings and discretionary spend.',
    priority: 2,
  ),
  TaskSuggestion(
    title: 'Automate a savings transfer',
    category: 'Finance',
    description:
        'Set up a recurring transfer to your emergency or investment account.',
    priority: 3,
  ),

  // Learning / Career
  TaskSuggestion(
    title: 'Read one chapter of a professional book',
    category: 'Learning',
    description:
        'Make progress on a book that builds your skills or domain knowledge.',
    priority: 2,
  ),
  TaskSuggestion(
    title: 'Draft a short LinkedIn update',
    category: 'Career',
    description:
        'Share a recent achievement or lesson to keep professional visibility active.',
    priority: 1,
  ),
  TaskSuggestion(
    title: 'Update your resume bullet points',
    category: 'Career',
    description: 'Add recent accomplishments with measurable outcomes.',
    priority: 2,
  ),

  // Home / Errands
  TaskSuggestion(
    title: 'Pay an outstanding bill',
    category: 'Finance',
    description:
        'Avoid late fees by catching up on any unpaid invoices or subscriptions.',
    priority: 3,
  ),
  TaskSuggestion(
    title: 'Schedule a deep-clean session',
    category: 'Home',
    description:
        'Pick one room and do a focused deep clean (floor-to-ceiling).',
    priority: 1,
  ),
  TaskSuggestion(
    title: 'Service your car or check tires',
    category: 'Lifestyle',
    description: 'Keep vehicle maintenance current for safety and longevity.',
    priority: 2,
  ),

  // Health / Fitness
  TaskSuggestion(
    title: 'Book a 30-minute walk',
    category: 'Health',
    description:
        'Take a brisk walk outdoors to boost circulation and clear your head.',
    priority: 1,
  ),
  TaskSuggestion(
    title: 'Try a 15-minute mobility routine',
    category: 'Fitness',
    description: 'Improve joint health with simple mobility drills.',
    priority: 1,
  ),
  TaskSuggestion(
    title: 'Prepare a healthy grocery list',
    category: 'Nutrition',
    description: 'Plan meals with lean protein, vegetables and whole grains.',
    priority: 2,
  ),

  // Social / Relationships
  TaskSuggestion(
    title: 'Call a friend or family member',
    category: 'Social',
    description: 'Reach out for a short catch-up to maintain connections.',
    priority: 1,
  ),
  TaskSuggestion(
    title: 'Plan a small outing with someone',
    category: 'Social',
    description: 'Arrange a coffee or walk — low-effort, high-bonding.',
    priority: 1,
  ),

  // Habits / Micro-actions
  TaskSuggestion(
    title: 'Set a 25-minute focus timer',
    category: 'Productivity',
    description: 'Work on a single task with no distractions (Pomodoro).',
    priority: 3,
  ),
  TaskSuggestion(
    title: 'Unsubscribe from 5 unwanted newsletters',
    category: 'Productivity',
    description: 'Clear inbox noise to reduce daily distraction.',
    priority: 1,
  ),

  // Development / Creativity
  TaskSuggestion(
    title: 'Sketch one new idea for your project',
    category: 'Personal',
    description: 'Spend 15–30 minutes brainstorming and sketching solutions.',
    priority: 2,
  ),
  TaskSuggestion(
    title: 'Practice 30 minutes of your hobby',
    category: 'Personal',
    description:
        'Keep progress steady by showing up for short practice sessions.',
    priority: 1,
  ),

  // Admin / Organization
  TaskSuggestion(
    title: 'Archive old digital files',
    category: 'Productivity',
    description:
        'Move stale files to an archive folder to keep active folders tidy.',
    priority: 1,
  ),
  TaskSuggestion(
    title: 'Review subscriptions and cancel unused ones',
    category: 'Finance',
    description: 'Save money by stopping services you no longer use.',
    priority: 2,
  ),

  // Mental Health / Wellness
  TaskSuggestion(
    title: 'Write a 5-minute journal entry',
    category: 'Wellness',
    description: 'Capture one win, one lesson, and one gratitude item.',
    priority: 1,
  ),
  TaskSuggestion(
    title: 'Do a 10-minute guided breathing session',
    category: 'Mindfulness',
    description: 'Lower stress with a short guided breathing or meditation.',
    priority: 1,
  ),

  // Learning small tasks
  TaskSuggestion(
    title: 'Watch a 10-minute tutorial on a skill',
    category: 'Learning',
    description: 'Consume a short focused lesson to build momentum.',
    priority: 1,
  ),
  TaskSuggestion(
    title: 'Summarize an article you read',
    category: 'Learning',
    description: 'Write 3 short takeaways to reinforce retention.',
    priority: 1,
  ),

  // Household
  TaskSuggestion(
    title: 'Pay utilities or schedule payment',
    category: 'Home',
    description: 'Ensure bills are handled on time to avoid late fees.',
    priority: 3,
  ),
  TaskSuggestion(
    title: 'Replace a household filter (air/water)',
    category: 'Home',
    description:
        'Improve air/water quality by staying on a maintenance schedule.',
    priority: 2,
  ),

  // Career growth
  TaskSuggestion(
    title: 'Ask for feedback on a recent deliverable',
    category: 'Career',
    description: 'Request short feedback to learn and iterate faster.',
    priority: 2,
  ),

  // Misc practical tasks
  TaskSuggestion(
    title: 'Back up important files to cloud',
    category: 'Productivity',
    description: 'Ensure critical documents are safely backed up.',
    priority: 2,
  ),
  TaskSuggestion(
    title: 'Clean out your wallet or keychain',
    category: 'Lifestyle',
    description: 'Remove old receipts and cards you no longer need.',
    priority: 1,
  ),

  // Preparation tasks
  TaskSuggestion(
    title: 'Prepare meeting notes and agenda',
    category: 'Productivity',
    description:
        'Outline goals and talking points before an important meeting.',
    priority: 3,
  ),
  TaskSuggestion(
    title: 'Pack a go-bag for travel',
    category: 'Lifestyle',
    description: 'Include essentials (chargers, documents, a spare outfit).',
    priority: 1,
  ),

  // End-of-day wind down
  TaskSuggestion(
    title: 'Tidy the main living area for 10 minutes',
    category: 'Lifestyle',
    description:
        'A quick tidy reduces morning friction and improves sleep quality.',
    priority: 1,
  ),
  TaskSuggestion(
    title: 'Reflect on one thing learned today',
    category: 'Wellness',
    description: 'Reinforce learning and close the day intentionally.',
    priority: 1,
  ),

  // Quick wins
  TaskSuggestion(
    title: 'Complete one lingering quick task',
    category: 'Productivity',
    description: 'Finish a small task you’ve been deferring to feel progress.',
    priority: 2,
  ),
  TaskSuggestion(
    title: 'Clear your downloads folder',
    category: 'Productivity',
    description: 'Free up space and improve file hygiene.',
    priority: 1,
  ),
];
