import 'package:aspire/models/goal.dart';
import 'package:aspire/models/goal_template.dart';

/// Sample goal templates for seeding Firestore
final sampleGoalTemplates = <Map<String, dynamic>>[
  // Travel
  {
    'title': 'Take my first solo trip',
    'description':
        'Experience the freedom and confidence of traveling alone for the first time.',
    'category': GoalCategory.travel.name,
    'suggestedActions': [
      'Choose a beginner-friendly destination',
      'Research safety tips for solo travelers',
      'Book accommodations with good reviews',
      'Plan a flexible daily itinerary',
      'Pack light with essentials only',
    ],
    'targetDateType': TargetDateType.sixMonths.name,
  },
  {
    'title': 'Visit my dream destination',
    'description':
        'Finally make it to that place I\'ve always dreamed about visiting.',
    'category': GoalCategory.travel.name,
    'suggestedActions': [
      'Research the best time to visit',
      'Set a travel budget and start saving',
      'Look for flight deals and set alerts',
      'Create a must-see list of attractions',
      'Learn basic phrases if needed',
    ],
    'targetDateType': TargetDateType.oneYear.name,
  },
  {
    'title': 'Travel to 3 new countries this year',
    'description': 'Expand my horizons and explore different cultures.',
    'category': GoalCategory.travel.name,
    'suggestedActions': [
      'List potential countries to visit',
      'Check passport validity and visa requirements',
      'Create a yearly travel budget',
      'Book the first trip',
      'Join travel communities for tips',
    ],
    'targetDateType': TargetDateType.endOfYear.name,
  },

  // Career
  {
    'title': 'Negotiate a raise or promotion',
    'description': 'Advocate for my worth and advance in my career.',
    'category': GoalCategory.career.name,
    'suggestedActions': [
      'Document my achievements and impact',
      'Research market salary for my role',
      'Practice negotiation talking points',
      'Schedule a meeting with my manager',
      'Follow up with a written summary',
    ],
    'targetDateType': TargetDateType.threeMonths.name,
  },
  {
    'title': 'Land my dream job',
    'description': 'Transition into a role that excites and fulfills me.',
    'category': GoalCategory.career.name,
    'suggestedActions': [
      'Define what my dream job looks like',
      'Update my resume and LinkedIn',
      'Reach out to people in the field',
      'Apply to 5 jobs this week',
      'Prepare for interviews',
    ],
    'targetDateType': TargetDateType.sixMonths.name,
  },
  {
    'title': 'Start a side business',
    'description': 'Turn my skills or passion into an additional income stream.',
    'category': GoalCategory.career.name,
    'suggestedActions': [
      'Identify my marketable skill or idea',
      'Research the target market',
      'Create a simple business plan',
      'Set up basic branding',
      'Get my first paying customer',
    ],
    'targetDateType': TargetDateType.sixMonths.name,
  },

  // Finance
  {
    'title': 'Build a 3-month emergency fund',
    'description': 'Create financial security with a safety net.',
    'category': GoalCategory.finance.name,
    'suggestedActions': [
      'Calculate 3 months of expenses',
      'Open a high-yield savings account',
      'Set up automatic transfers',
      'Cut one unnecessary expense',
      'Track progress monthly',
    ],
    'targetDateType': TargetDateType.sixMonths.name,
  },
  {
    'title': 'Pay off my credit card debt',
    'description': 'Achieve financial freedom by eliminating debt.',
    'category': GoalCategory.finance.name,
    'suggestedActions': [
      'List all debts with interest rates',
      'Choose a payoff strategy (avalanche or snowball)',
      'Create a realistic monthly budget',
      'Find ways to increase income',
      'Celebrate each card paid off',
    ],
    'targetDateType': TargetDateType.oneYear.name,
  },
  {
    'title': 'Start investing for the future',
    'description': 'Make my money work for me through smart investing.',
    'category': GoalCategory.finance.name,
    'suggestedActions': [
      'Learn investing basics',
      'Open a brokerage or retirement account',
      'Start with a small recurring investment',
      'Diversify across different assets',
      'Review and rebalance quarterly',
    ],
    'targetDateType': TargetDateType.threeMonths.name,
  },

  // Wellness
  {
    'title': 'Establish a morning routine',
    'description': 'Start each day with intention and energy.',
    'category': GoalCategory.wellness.name,
    'suggestedActions': [
      'Decide on my ideal wake-up time',
      'Plan 3-5 morning activities',
      'Prepare the night before',
      'Try the routine for 2 weeks',
      'Adjust based on what works',
    ],
    'targetDateType': TargetDateType.none.name,
  },
  {
    'title': 'Run my first 5K',
    'description': 'Build endurance and achieve a fitness milestone.',
    'category': GoalCategory.wellness.name,
    'suggestedActions': [
      'Get proper running shoes',
      'Follow a couch-to-5K program',
      'Run 3 times per week',
      'Sign up for a local 5K race',
      'Cross the finish line',
    ],
    'targetDateType': TargetDateType.threeMonths.name,
  },
  {
    'title': 'Practice daily mindfulness',
    'description': 'Reduce stress and increase presence through meditation.',
    'category': GoalCategory.wellness.name,
    'suggestedActions': [
      'Download a meditation app',
      'Start with 5 minutes daily',
      'Find a consistent time each day',
      'Try different meditation styles',
      'Increase duration gradually',
    ],
    'targetDateType': TargetDateType.none.name,
  },

  // Personal
  {
    'title': 'Learn a new language',
    'description': 'Open doors to new cultures and opportunities.',
    'category': GoalCategory.personal.name,
    'suggestedActions': [
      'Choose a language and reason why',
      'Set up a language learning app',
      'Practice 15 minutes daily',
      'Find a language exchange partner',
      'Watch shows in the target language',
    ],
    'targetDateType': TargetDateType.oneYear.name,
  },
  {
    'title': 'Read 12 books this year',
    'description': 'Expand my mind through consistent reading.',
    'category': GoalCategory.personal.name,
    'suggestedActions': [
      'Create a reading list',
      'Set aside 20 minutes daily',
      'Join a book club',
      'Mix fiction and non-fiction',
      'Track books completed',
    ],
    'targetDateType': TargetDateType.endOfYear.name,
  },
  {
    'title': 'Build my confidence speaking up',
    'description': 'Share my ideas and opinions without holding back.',
    'category': GoalCategory.personal.name,
    'suggestedActions': [
      'Speak up once in every meeting',
      'Practice with low-stakes situations',
      'Prepare talking points in advance',
      'Join a public speaking group',
      'Celebrate every time I speak up',
    ],
    'targetDateType': TargetDateType.threeMonths.name,
  },
];
