import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Tracker'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @allEntries.
  ///
  /// In en, this message translates to:
  /// **'All Entries'**
  String get allEntries;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @localStorage.
  ///
  /// In en, this message translates to:
  /// **'Local Storage'**
  String get localStorage;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @logTimeEntry.
  ///
  /// In en, this message translates to:
  /// **'Log Time Entry'**
  String get logTimeEntry;

  /// No description provided for @hoursWorked.
  ///
  /// In en, this message translates to:
  /// **'Hours Worked'**
  String get hoursWorked;

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// No description provided for @task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get task;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @saveTimeEntry.
  ///
  /// In en, this message translates to:
  /// **'Save Time Entry'**
  String get saveTimeEntry;

  /// No description provided for @selectProject.
  ///
  /// In en, this message translates to:
  /// **'Select a project'**
  String get selectProject;

  /// No description provided for @selectTask.
  ///
  /// In en, this message translates to:
  /// **'Select a task'**
  String get selectTask;

  /// No description provided for @noProjectsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No projects available'**
  String get noProjectsAvailable;

  /// No description provided for @noTasksAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tasks available'**
  String get noTasksAvailable;

  /// No description provided for @addProject.
  ///
  /// In en, this message translates to:
  /// **'Add Project'**
  String get addProject;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get projectName;

  /// No description provided for @taskName.
  ///
  /// In en, this message translates to:
  /// **'Task name'**
  String get taskName;

  /// No description provided for @selectParentProject.
  ///
  /// In en, this message translates to:
  /// **'Select parent project'**
  String get selectParentProject;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteTimeEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete Time Entry'**
  String get deleteTimeEntry;

  /// No description provided for @deleteTimeEntryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this time entry?'**
  String get deleteTimeEntryConfirm;

  /// No description provided for @deleteTimeEntryPermanent.
  ///
  /// In en, this message translates to:
  /// **'Delete this time entry permanently?'**
  String get deleteTimeEntryPermanent;

  /// No description provided for @noTimeEntries.
  ///
  /// In en, this message translates to:
  /// **'No time entries recorded yet'**
  String get noTimeEntries;

  /// No description provided for @noTimeEntriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to log your first time entry'**
  String get noTimeEntriesSubtitle;

  /// No description provided for @noProjectAnalytics.
  ///
  /// In en, this message translates to:
  /// **'No project analytics available'**
  String get noProjectAnalytics;

  /// No description provided for @noProjectAnalyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log time entries against projects to see analytics here'**
  String get noProjectAnalyticsSubtitle;

  /// No description provided for @noProjectsYet.
  ///
  /// In en, this message translates to:
  /// **'No projects yet'**
  String get noProjectsYet;

  /// No description provided for @noProjectsYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first project'**
  String get noProjectsYetSubtitle;

  /// No description provided for @noTasksYet.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get noTasksYet;

  /// No description provided for @noTasksYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first task'**
  String get noTasksYetSubtitle;

  /// No description provided for @timeEntries.
  ///
  /// In en, this message translates to:
  /// **'Time Entries'**
  String get timeEntries;

  /// No description provided for @storageOverview.
  ///
  /// In en, this message translates to:
  /// **'Storage Overview'**
  String get storageOverview;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'records'**
  String get records;

  /// No description provided for @storageEmpty.
  ///
  /// In en, this message translates to:
  /// **'Storage is empty'**
  String get storageEmpty;

  /// No description provided for @storageEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'No records have been persisted yet'**
  String get storageEmptySubtitle;

  /// No description provided for @sharedPreferencesKey.
  ///
  /// In en, this message translates to:
  /// **'Firestore collection'**
  String get sharedPreferencesKey;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get listView;

  /// No description provided for @groupByProject.
  ///
  /// In en, this message translates to:
  /// **'Group by Project'**
  String get groupByProject;

  /// No description provided for @projectManagement.
  ///
  /// In en, this message translates to:
  /// **'Project Management'**
  String get projectManagement;

  /// No description provided for @taskManagement.
  ///
  /// In en, this message translates to:
  /// **'Task Management'**
  String get taskManagement;

  /// No description provided for @localStorageInspector.
  ///
  /// In en, this message translates to:
  /// **'Storage Inspector'**
  String get localStorageInspector;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get name;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @enterConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get enterConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createAccount;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @trackSmarter.
  ///
  /// In en, this message translates to:
  /// **'Track smarter, work better'**
  String get trackSmarter;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Log time. Gain insights. Stay productive.'**
  String get splashTagline;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @enterHoursWorked.
  ///
  /// In en, this message translates to:
  /// **'Enter hours worked'**
  String get enterHoursWorked;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @pleaseSelectProject.
  ///
  /// In en, this message translates to:
  /// **'Please select a project'**
  String get pleaseSelectProject;

  /// No description provided for @pleaseSelectTask.
  ///
  /// In en, this message translates to:
  /// **'Please select a task'**
  String get pleaseSelectTask;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Productivity Insights'**
  String get insightsTitle;

  /// No description provided for @mostProductiveDay.
  ///
  /// In en, this message translates to:
  /// **'Most Productive Day'**
  String get mostProductiveDay;

  /// No description provided for @totalHours.
  ///
  /// In en, this message translates to:
  /// **'Total Hours'**
  String get totalHours;

  /// No description provided for @avgHoursPerDay.
  ///
  /// In en, this message translates to:
  /// **'Avg Hours / Day'**
  String get avgHoursPerDay;

  /// No description provided for @topProject.
  ///
  /// In en, this message translates to:
  /// **'Top Project'**
  String get topProject;

  /// No description provided for @hoursThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Hours This Week'**
  String get hoursThisWeek;

  /// No description provided for @hoursPerProject.
  ///
  /// In en, this message translates to:
  /// **'Hours per Project'**
  String get hoursPerProject;

  /// No description provided for @dailyActivity.
  ///
  /// In en, this message translates to:
  /// **'Daily Activity (Last 7 Days)'**
  String get dailyActivity;

  /// No description provided for @behaviorClusters.
  ///
  /// In en, this message translates to:
  /// **'Behavior Clusters'**
  String get behaviorClusters;

  /// No description provided for @clusterLight.
  ///
  /// In en, this message translates to:
  /// **'Light Sessions'**
  String get clusterLight;

  /// No description provided for @clusterModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate Sessions'**
  String get clusterModerate;

  /// No description provided for @clusterDeep.
  ///
  /// In en, this message translates to:
  /// **'Deep Work Sessions'**
  String get clusterDeep;

  /// No description provided for @notEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet'**
  String get notEnoughData;

  /// No description provided for @notEnoughDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log at least 5 time entries to unlock insights'**
  String get notEnoughDataSubtitle;

  /// No description provided for @unknownProject.
  ///
  /// In en, this message translates to:
  /// **'Unknown Project'**
  String get unknownProject;

  /// No description provided for @addNotes.
  ///
  /// In en, this message translates to:
  /// **'Add notes...'**
  String get addNotes;

  /// No description provided for @egHours.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2.5'**
  String get egHours;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @scheduleSession.
  ///
  /// In en, this message translates to:
  /// **'New Session'**
  String get scheduleSession;

  /// No description provided for @welcomeProductivityHub.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Your Productivity Hub!'**
  String get welcomeProductivityHub;

  /// No description provided for @startTrackingMessage.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your work sessions to unlock powerful ML-driven insights and analytics'**
  String get startTrackingMessage;

  /// No description provided for @scheduleFirstSession.
  ///
  /// In en, this message translates to:
  /// **'Schedule Your First Session'**
  String get scheduleFirstSession;

  /// No description provided for @createProjectFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a Project First'**
  String get createProjectFirst;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @readyToBeProductive.
  ///
  /// In en, this message translates to:
  /// **'Ready to be productive?'**
  String get readyToBeProductive;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @createFirstProject.
  ///
  /// In en, this message translates to:
  /// **'Create your first project to get started'**
  String get createFirstProject;

  /// No description provided for @createProject.
  ///
  /// In en, this message translates to:
  /// **'Create Project'**
  String get createProject;

  /// No description provided for @topProjects.
  ///
  /// In en, this message translates to:
  /// **'Top Projects'**
  String get topProjects;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All →'**
  String get viewAll;

  /// No description provided for @mlInsightsLocked.
  ///
  /// In en, this message translates to:
  /// **'ML Insights Locked'**
  String get mlInsightsLocked;

  /// No description provided for @logMoreSessions.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get logMoreSessions;

  /// No description provided for @sessionsToUnlock.
  ///
  /// In en, this message translates to:
  /// **'more sessions to unlock AI-powered insights'**
  String get sessionsToUnlock;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learnMore;

  /// No description provided for @mlInsights.
  ///
  /// In en, this message translates to:
  /// **'ML Insights'**
  String get mlInsights;

  /// No description provided for @noActivityYet.
  ///
  /// In en, this message translates to:
  /// **'No Activity Yet'**
  String get noActivityYet;

  /// No description provided for @recentSessionsAppear.
  ///
  /// In en, this message translates to:
  /// **'Your recent work sessions will appear here'**
  String get recentSessionsAppear;

  /// No description provided for @logTime.
  ///
  /// In en, this message translates to:
  /// **'Log Time'**
  String get logTime;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @allTimeEntries.
  ///
  /// In en, this message translates to:
  /// **'All Time Entries'**
  String get allTimeEntries;

  /// No description provided for @scheduleNewSession.
  ///
  /// In en, this message translates to:
  /// **'Schedule New Work Session'**
  String get scheduleNewSession;

  /// No description provided for @clusterQuality.
  ///
  /// In en, this message translates to:
  /// **'Cluster quality'**
  String get clusterQuality;

  /// No description provided for @mlNoData.
  ///
  /// In en, this message translates to:
  /// **'No data yet. Start logging time entries!'**
  String get mlNoData;

  /// No description provided for @productivityScore.
  ///
  /// In en, this message translates to:
  /// **'Productivity Score'**
  String get productivityScore;

  /// No description provided for @scoreVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get scoreVolume;

  /// No description provided for @scoreConsistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get scoreConsistency;

  /// No description provided for @scoreFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get scoreFocus;

  /// No description provided for @scoreBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get scoreBalance;

  /// No description provided for @scoreEfficiency.
  ///
  /// In en, this message translates to:
  /// **'Efficiency'**
  String get scoreEfficiency;

  /// No description provided for @scoreExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get scoreExcellent;

  /// No description provided for @scoreGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get scoreGood;

  /// No description provided for @scoreFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get scoreFair;

  /// No description provided for @scoreNeedsImprovement.
  ///
  /// In en, this message translates to:
  /// **'Needs Improvement'**
  String get scoreNeedsImprovement;

  /// No description provided for @anomalyDetection.
  ///
  /// In en, this message translates to:
  /// **'Anomaly Detection'**
  String get anomalyDetection;

  /// No description provided for @noAnomalies.
  ///
  /// In en, this message translates to:
  /// **'No anomalies detected - your work patterns are consistent!'**
  String get noAnomalies;

  /// No description provided for @patternRecognition.
  ///
  /// In en, this message translates to:
  /// **'Pattern Recognition'**
  String get patternRecognition;

  /// No description provided for @noPatterns.
  ///
  /// In en, this message translates to:
  /// **'Not enough data to detect patterns yet'**
  String get noPatterns;

  /// No description provided for @confidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidenceLabel;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @noRecommendations.
  ///
  /// In en, this message translates to:
  /// **'No recommendations at this time'**
  String get noRecommendations;

  /// No description provided for @scheduleWorkSession.
  ///
  /// In en, this message translates to:
  /// **'Schedule Work Session'**
  String get scheduleWorkSession;

  /// No description provided for @sectionProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get sectionProject;

  /// No description provided for @sectionTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get sectionTask;

  /// No description provided for @sectionSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get sectionSchedule;

  /// No description provided for @sectionReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get sectionReminder;

  /// No description provided for @sectionNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get sectionNotesOptional;

  /// No description provided for @scheduleSessionAction.
  ///
  /// In en, this message translates to:
  /// **'Schedule Session'**
  String get scheduleSessionAction;

  /// No description provided for @schedulingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Scheduling...'**
  String get schedulingInProgress;

  /// No description provided for @forecastTitle.
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get forecastTitle;

  /// No description provided for @forecastNextDay.
  ///
  /// In en, this message translates to:
  /// **'Predicted next day'**
  String get forecastNextDay;

  /// No description provided for @forecastNext7Days.
  ///
  /// In en, this message translates to:
  /// **'Next 7 days'**
  String get forecastNext7Days;

  /// No description provided for @modelAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Model accuracy (held-out test)'**
  String get modelAccuracy;

  /// No description provided for @trendIncreasing.
  ///
  /// In en, this message translates to:
  /// **'Increasing'**
  String get trendIncreasing;

  /// No description provided for @trendDecreasing.
  ///
  /// In en, this message translates to:
  /// **'Decreasing'**
  String get trendDecreasing;

  /// No description provided for @trendStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get trendStable;

  /// No description provided for @forecastInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Log a few more days to unlock forecasting'**
  String get forecastInsufficient;

  /// No description provided for @forecastValidation.
  ///
  /// In en, this message translates to:
  /// **'Trained on {train} days · validated on {test}'**
  String forecastValidation(int train, int test);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
