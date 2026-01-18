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

import 'package:lockin/core/models/goal_suggestion.dart';

const List<GoalSuggestion> goalSuggestionsDB = [
  // Finance
  GoalSuggestion(
    title: 'Build a 3–6 month emergency fund',
    category: 'Finance',
    description: 'Save a buffer to cover unexpected expenses without debt.',
  ),
  GoalSuggestion(
    title: 'Pay off high-interest credit card debt',
    category: 'Finance',
    description: 'Reduce interest costs and improve financial flexibility.',
  ),
  GoalSuggestion(
    title: 'Automate monthly savings contributions',
    category: 'Finance',
    description: 'Make saving effortless with recurring transfers.',
  ),
  GoalSuggestion(
    title: 'Create a 12-month budget and track it',
    category: 'Finance',
    description: 'Gain clarity on cashflow and identify opportunities to save.',
  ),
  GoalSuggestion(
    title: 'Start investing regularly (index funds)',
    category: 'Finance',
    description:
        'Build long-term wealth with low-cost, diversified investments.',
  ),

  // Career & Learning
  GoalSuggestion(
    title: 'Complete a professional certification',
    category: 'Career',
    description:
        'Acquire recognized credentials to boost career opportunities.',
  ),
  GoalSuggestion(
    title: 'Read 24 books this year (career & personal)',
    category: 'Learning',
    description:
        'Mix professional development and leisure reading to grow consistently.',
  ),
  GoalSuggestion(
    title: 'Create a portfolio of work projects',
    category: 'Career',
    description: 'Showcase your best work to potential employers or clients.',
  ),
  GoalSuggestion(
    title: 'Prepare and give a public talk or workshop',
    category: 'Career',
    description:
        'Sharpen communication skills and grow professional visibility.',
  ),

  // Health & Fitness
  GoalSuggestion(
    title: 'Run a 5K or half marathon',
    category: 'Fitness',
    description: 'Improve cardiovascular endurance with a measurable target.',
  ),
  GoalSuggestion(
    title: 'Lose 10% of body weight healthily',
    category: 'Health',
    description: 'Set a reasonable target with diet and exercise plans.',
  ),
  GoalSuggestion(
    title: 'Establish a 3x/week resistance training habit',
    category: 'Fitness',
    description: 'Build strength and improve metabolic health.',
  ),
  GoalSuggestion(
    title: 'Improve sleep to 7–8 hours nightly',
    category: 'Health',
    description: 'Optimize sleep hygiene to support recovery and cognition.',
  ),
  GoalSuggestion(
    title: 'Complete a 30-day flexibility program',
    category: 'Fitness',
    description:
        'Increase mobility and reduce injury risk with daily practice.',
  ),

  // Home & Lifestyle
  GoalSuggestion(
    title: 'Declutter and organize every room',
    category: 'Home',
    description: 'Create systems for storage and reduce household stressors.',
  ),
  GoalSuggestion(
    title: 'Complete a home improvement project',
    category: 'Home',
    description: 'Finish a repair or upgrade that improves comfort or value.',
  ),
  GoalSuggestion(
    title: 'Create a meal plan for the month',
    category: 'Nutrition',
    description: 'Save time and money while improving diet quality.',
  ),
  GoalSuggestion(
    title: 'Adopt a weekly cleaning schedule',
    category: 'Home',
    description:
        'Maintain a clean and functional living environment with minimal stress.',
  ),

  // Relationships & Social
  GoalSuggestion(
    title: 'Schedule monthly date nights or friend catch-ups',
    category: 'Social',
    description: 'Invest in relationships through regular shared time.',
  ),
  GoalSuggestion(
    title: 'Reconnect with three old friends this year',
    category: 'Social',
    description: 'Rebuild valuable social ties that may have lapsed.',
  ),

  // Personal Development
  GoalSuggestion(
    title: 'Develop a daily journaling habit (3 months)',
    category: 'Wellness',
    description: 'Increase self-awareness and track personal growth.',
  ),
  GoalSuggestion(
    title: 'Practice a creative skill weekly (art/music)',
    category: 'Personal',
    description:
        'Sustain and expand creative expression through regular practice.',
  ),
  GoalSuggestion(
    title: 'Complete a personal 30-day challenge',
    category: 'Personal',
    description: 'Commit to a focused habit challenge to build discipline.',
  ),

  // Finance & Career combo goals
  GoalSuggestion(
    title: 'Start a side income project and earn your first \$500',
    category: 'Finance',
    description: 'Validate a side gig and create a repeatable income flow.',
  ),
  GoalSuggestion(
    title: 'Negotiate a raise or promotion',
    category: 'Career',
    description: 'Prepare evidence of impact and ask for a compensation bump.',
  ),

  // Travel & Experience
  GoalSuggestion(
    title: 'Travel to three new cities or countries',
    category: 'Personal',
    description:
        'Broaden perspectives through diverse experiences and cultures.',
  ),
  GoalSuggestion(
    title: 'Plan and complete a multi-day outdoor trip',
    category: 'Lifestyle',
    description:
        'Improve wellbeing by spending time in nature and disconnecting.',
  ),

  // Learning & Mastery
  GoalSuggestion(
    title: 'Complete an online course with a capstone project',
    category: 'Learning',
    description: 'Apply new knowledge by building a portfolio-worthy project.',
  ),
  GoalSuggestion(
    title: 'Teach or mentor someone in your skill area',
    category: 'Career',
    description:
        'Solidify knowledge by helping others and practicing leadership.',
  ),

  // Health maintenance
  GoalSuggestion(
    title: 'Schedule all preventive health appointments this year',
    category: 'Health',
    description: 'Stay on top of screenings, dental and annual check-ups.',
  ),
  GoalSuggestion(
    title: 'Finish a structured nutrition plan for 12 weeks',
    category: 'Nutrition',
    description: 'Follow a sustainable nutrition plan to reach a health goal.',
  ),

  // Financial longer-term
  GoalSuggestion(
    title: 'Save for a down payment on a home',
    category: 'Finance',
    description: 'Plan and save progressively toward homeownership.',
  ),
  GoalSuggestion(
    title: 'Create an estate and emergency plan (documents)',
    category: 'Finance',
    description: 'Protect family and finances with basic legal documents.',
  ),

  // Habit & behavior change goals
  GoalSuggestion(
    title: 'Go 30 days without late-night snacking',
    category: 'Health',
    description: 'Improve sleep and digestion by removing late calories.',
  ),
  GoalSuggestion(
    title: 'Establish a weekly technology-free evening',
    category: 'Wellness',
    description: 'Improve presence and relationships by unplugging weekly.',
  ),

  // Professional visibility
  GoalSuggestion(
    title: 'Publish three articles or blog posts this year',
    category: 'Career',
    description: 'Share expertise and build your professional brand.',
  ),

  // Community & giving
  GoalSuggestion(
    title: 'Volunteer 20 hours this year',
    category: 'Social',
    description: 'Contribute meaningful time to causes you care about.',
  ),

  // Personal projects
  GoalSuggestion(
    title: 'Complete a small renovation or personal build',
    category: 'Home',
    description: 'Finish a tangible project that improves daily life.',
  ),
  GoalSuggestion(
    title: 'Publish a small ebook or guide',
    category: 'Personal',
    description: 'Package knowledge into a shareable resource.',
  ),

  // Social & family
  GoalSuggestion(
    title: 'Organize a family reunion or gathering',
    category: 'Social',
    description: 'Coordinate a meaningful event to strengthen family ties.',
  ),

  // Skills & hobbies
  GoalSuggestion(
    title: 'Learn to play an instrument to a basic level',
    category: 'Personal',
    description: 'Enjoy music and gain a rewarding lifelong skill.',
  ),
  GoalSuggestion(
    title: 'Complete a year-long creative project',
    category: 'Personal',
    description: 'Finish a significant portfolio piece or body of work.',
  ),

  // Wellbeing & lifestyle
  GoalSuggestion(
    title: 'Reduce screen time by 30% for 2 months',
    category: 'Wellness',
    description: 'Free up time for meaningful activities and improve sleep.',
  ),
  GoalSuggestion(
    title: 'Adopt and maintain a consistent daily routine',
    category: 'Productivity',
    description: 'Anchor your days with habits that support your goals.',
  ),

  // Long-term learning
  GoalSuggestion(
    title: 'Achieve intermediate fluency in a new language',
    category: 'Learning',
    description: 'Communicate comfortably in everyday situations.',
  ),
  GoalSuggestion(
    title: 'Finish a multi-month certification or degree course',
    category: 'Learning',
    description: 'Commit to finishing a major educational milestone.',
  ),
];
