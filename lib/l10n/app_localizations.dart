import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Localized strings accessor for the app
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Localization delegate for MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Default localization delegates including Material, Cupertino, and Widgets
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// Supported locales for this app
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  String get appTitle;
  String get dashboard;
  String get allEntries;
  String get projects;
  String get tasks;
  String get localStorage;
  String get insights;
  String get logTimeEntry;
  String get hoursWorked;
  String get project;
  String get task;
  String get notes;
  String get date;
  String get saveTimeEntry;
  String get selectProject;
  String get selectTask;
  String get noProjectsAvailable;
  String get noTasksAvailable;
  String get addProject;
  String get addTask;
  String get projectName;
  String get taskName;
  String get selectParentProject;
  String get cancel;
  String get add;
  String get delete;
  String get deleteTimeEntry;
  String get deleteTimeEntryConfirm;
  String get deleteTimeEntryPermanent;
  String get noTimeEntries;
  String get noTimeEntriesSubtitle;
  String get noProjectAnalytics;
  String get noProjectAnalyticsSubtitle;
  String get noProjectsYet;
  String get noProjectsYetSubtitle;
  String get noTasksYet;
  String get noTasksYetSubtitle;
  String get timeEntries;
  String get storageOverview;
  String get records;
  String get storageEmpty;
  String get storageEmptySubtitle;
  String get sharedPreferencesKey;
  String get listView;
  String get groupByProject;
  String get projectManagement;
  String get taskManagement;
  String get localStorageInspector;
  String get name;
  String get enterName;
  String get confirmPassword;
  String get enterConfirmPassword;
  String get passwordsDoNotMatch;
  String get welcomeBack;
  String get createAccount;
  String get getStarted;
  String get trackSmarter;
  String get splashTagline;
  String get signIn;
  String get signUp;
  String get signOut;
  String get email;
  String get password;
  String get continueWithGoogle;
  String get noAccount;
  String get alreadyHaveAccount;
  String get enterEmail;
  String get enterPassword;
  String get enterHoursWorked;
  String get enterValidNumber;
  String get pleaseSelectProject;
  String get pleaseSelectTask;
  String get insightsTitle;
  String get mostProductiveDay;
  String get totalHours;
  String get avgHoursPerDay;
  String get topProject;
  String get hoursThisWeek;
  String get hoursPerProject;
  String get dailyActivity;
  String get behaviorClusters;
  String get clusterLight;
  String get clusterModerate;
  String get clusterDeep;
  String get notEnoughData;
  String get notEnoughDataSubtitle;
  String get unknownProject;
  String get addNotes;
  String get egHours;
  String get darkMode;
  String get lightMode;
  String get language;
  String get settings;
  String get scheduleSession;
  String get welcomeProductivityHub;
  String get startTrackingMessage;
  String get scheduleFirstSession;
  String get createProjectFirst;
  String get goodMorning;
  String get goodAfternoon;
  String get goodEvening;
  String get readyToBeProductive;
  String get thisWeek;
  String get createFirstProject;
  String get createProject;
  String get topProjects;
  String get viewAll;
  String get mlInsightsLocked;
  String get logMoreSessions;
  String get sessionsToUnlock;
  String get learnMore;
  String get mlInsights;
  String get noActivityYet;
  String get recentSessionsAppear;
  String get logTime;
  String get recentActivity;
  String get helpAndSupport;
  String get allTimeEntries;
  String get scheduleNewSession;
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

/// Lookup the correct localization class based on locale
AppLocalizations lookupAppLocalizations(Locale locale) {
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
