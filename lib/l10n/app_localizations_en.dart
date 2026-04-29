// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Time Tracker';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get allEntries => 'All Entries';

  @override
  String get projects => 'Projects';

  @override
  String get tasks => 'Tasks';

  @override
  String get localStorage => 'Local Storage';

  @override
  String get insights => 'Insights';

  @override
  String get logTimeEntry => 'Log Time Entry';

  @override
  String get hoursWorked => 'Hours Worked';

  @override
  String get project => 'Project';

  @override
  String get task => 'Task';

  @override
  String get notes => 'Notes';

  @override
  String get date => 'Date';

  @override
  String get saveTimeEntry => 'Save Time Entry';

  @override
  String get selectProject => 'Select a project';

  @override
  String get selectTask => 'Select a task';

  @override
  String get noProjectsAvailable => 'No projects available';

  @override
  String get noTasksAvailable => 'No tasks available';

  @override
  String get addProject => 'Add Project';

  @override
  String get addTask => 'Add Task';

  @override
  String get projectName => 'Project name';

  @override
  String get taskName => 'Task name';

  @override
  String get selectParentProject => 'Select parent project';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get deleteTimeEntry => 'Delete Time Entry';

  @override
  String get deleteTimeEntryConfirm =>
      'Are you sure you want to delete this time entry?';

  @override
  String get deleteTimeEntryPermanent => 'Delete this time entry permanently?';

  @override
  String get noTimeEntries => 'No time entries recorded yet';

  @override
  String get noTimeEntriesSubtitle =>
      'Tap the button below to log your first time entry';

  @override
  String get noProjectAnalytics => 'No project analytics available';

  @override
  String get noProjectAnalyticsSubtitle =>
      'Log time entries against projects to see analytics here';

  @override
  String get noProjectsYet => 'No projects yet';

  @override
  String get noProjectsYetSubtitle => 'Tap + to create your first project';

  @override
  String get noTasksYet => 'No tasks yet';

  @override
  String get noTasksYetSubtitle => 'Tap + to create your first task';

  @override
  String get timeEntries => 'Time Entries';

  @override
  String get storageOverview => 'Storage Overview';

  @override
  String get records => 'records';

  @override
  String get storageEmpty => 'Storage is empty';

  @override
  String get storageEmptySubtitle => 'No records have been persisted yet';

  @override
  String get sharedPreferencesKey => 'Firestore collection';

  @override
  String get listView => 'List View';

  @override
  String get groupByProject => 'Group by Project';

  @override
  String get projectManagement => 'Project Management';

  @override
  String get taskManagement => 'Task Management';

  @override
  String get localStorageInspector => 'Storage Inspector';

  @override
  String get name => 'Full Name';

  @override
  String get enterName => 'Enter your full name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get enterConfirmPassword => 'Re-enter your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get createAccount => 'Create your account';

  @override
  String get getStarted => 'Get Started';

  @override
  String get trackSmarter => 'Track smarter, work better';

  @override
  String get splashTagline => 'Log time. Gain insights. Stay productive.';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signOut => 'Sign Out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get enterHoursWorked => 'Enter hours worked';

  @override
  String get enterValidNumber => 'Enter a valid number';

  @override
  String get pleaseSelectProject => 'Please select a project';

  @override
  String get pleaseSelectTask => 'Please select a task';

  @override
  String get insightsTitle => 'Productivity Insights';

  @override
  String get mostProductiveDay => 'Most Productive Day';

  @override
  String get totalHours => 'Total Hours';

  @override
  String get avgHoursPerDay => 'Avg Hours / Day';

  @override
  String get topProject => 'Top Project';

  @override
  String get hoursThisWeek => 'Hours This Week';

  @override
  String get hoursPerProject => 'Hours per Project';

  @override
  String get dailyActivity => 'Daily Activity (Last 7 Days)';

  @override
  String get behaviorClusters => 'Behavior Clusters';

  @override
  String get clusterLight => 'Light Sessions';

  @override
  String get clusterModerate => 'Moderate Sessions';

  @override
  String get clusterDeep => 'Deep Work Sessions';

  @override
  String get notEnoughData => 'Not enough data yet';

  @override
  String get notEnoughDataSubtitle =>
      'Log at least 5 time entries to unlock insights';

  @override
  String get unknownProject => 'Unknown Project';

  @override
  String get addNotes => 'Add notes...';

  @override
  String get egHours => 'e.g. 2.5';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get language => 'Language';

  @override
  String get settings => 'Settings';

  @override
  String get scheduleSession => 'New Session';

  @override
  String get welcomeProductivityHub => 'Welcome to Your Productivity Hub!';

  @override
  String get startTrackingMessage =>
      'Start tracking your work sessions to unlock powerful ML-driven insights and analytics';

  @override
  String get scheduleFirstSession => 'Schedule Your First Session';

  @override
  String get createProjectFirst => 'Create a Project First';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get readyToBeProductive => 'Ready to be productive?';

  @override
  String get thisWeek => 'This Week';

  @override
  String get createFirstProject => 'Create your first project to get started';

  @override
  String get createProject => 'Create Project';

  @override
  String get topProjects => 'Top Projects';

  @override
  String get viewAll => 'View All →';

  @override
  String get mlInsightsLocked => 'ML Insights Locked';

  @override
  String get logMoreSessions => 'Log';

  @override
  String get sessionsToUnlock => 'more sessions to unlock AI-powered insights';

  @override
  String get learnMore => 'Learn More';

  @override
  String get mlInsights => 'ML Insights';

  @override
  String get noActivityYet => 'No Activity Yet';

  @override
  String get recentSessionsAppear =>
      'Your recent work sessions will appear here';

  @override
  String get logTime => 'Log Time';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get allTimeEntries => 'All Time Entries';

  @override
  String get scheduleNewSession => 'Schedule New Work Session';
}
