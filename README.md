# Productivity Tracking Analytics App

A machine learning powered productivity tracking application that transforms how you understand your work patterns. Built with Flutter and Firebase, this app goes beyond simple time logging by using K-Means clustering algorithms to automatically analyze your work sessions and provide intelligent insights about your productivity habits.

## What Makes This App Different

Most time tracking apps just record numbers. You log your hours, and you get a list of entries. That's it. Productivity Tracking Analytics App takes a completely different approach by applying machine learning to your work data.

The app uses unsupervised learning algorithms to automatically categorize your work sessions into three distinct patterns. Light sessions, moderate sessions, and deep work sessions. This happens without any manual tagging or configuration. You just log your time, and the machine learning engine figures out your work patterns.

Here's what makes this special. The K-Means clustering algorithm analyzes the duration of every work session you log. It identifies natural groupings in your data and tells you things like whether you're getting enough deep work time or if your day is too fragmented with short tasks. This is the kind of insight that normally requires a data analyst, but the app does it automatically every time you open the insights screen.

The machine learning component doesn't stop at clustering. The app also performs statistical analysis to identify your most productive day of the week, calculates your average hours per active day, tracks weekly trends, and shows you which projects consume the most time. All of this happens in real time as you use the app.

## Why This App Exists

This project was created to solve a real problem that knowledge workers face every day. You finish a week of work and wonder where all your time went. You know you were busy, but you can't pinpoint what actually got done or whether you're working efficiently.

Traditional time tracking tools give you raw data but no understanding. Spreadsheets full of numbers that you have to manually analyze. Project management tools that require entire teams to adopt them before they become useful. Timer apps that just count minutes without providing any context.

Productivity Tracking Analytics App bridges this gap by combining simple time logging with automated pattern recognition. You get the benefits of data analysis without needing to be a data scientist. The machine learning algorithms do the heavy lifting, and you get actionable insights that help you work smarter.

## Core Features

### Intelligent Session Clustering

This is the heart of the machine learning functionality. Every time you view the insights screen, the app runs a K-Means clustering algorithm on your work sessions. The algorithm groups sessions by duration into three clusters.

The clustering process works like this. The algorithm starts by identifying the shortest and longest sessions in your data. It places three initial cluster centers evenly spaced across this range. Then it iterates through your sessions, assigning each one to the nearest cluster center. After each iteration, it recalculates the cluster centers based on the sessions assigned to them. This process repeats until the assignments stabilize.

The result is three natural groupings. Short sessions typically under an hour become light work. Medium sessions between one and three hours become moderate work. Long sessions over three hours become deep work. These thresholds aren't hardcoded. They emerge naturally from your actual work patterns.

Why does this matter? Because it tells you whether you're structuring your day effectively. If all your sessions are light work, you might be context switching too much. If you have lots of deep work sessions, you're probably getting good focused time. The app visualizes this with color coded badges and shows you the total hours in each category.

### Predictive Analytics

Beyond clustering, the app performs statistical analysis to identify trends. It calculates your average hours per active day, which tells you if you're maintaining a consistent work schedule. It identifies your most productive day of the week by aggregating hours across all your logged sessions.

The app also tracks your activity over the last seven days and displays it as a line chart. This lets you spot patterns like whether you work more at the beginning or end of the week. You can see if your hours are increasing, decreasing, or staying stable.

The weekly summary shows your total hours for the current week compared to your overall average. This gives you immediate feedback about whether you're on track or falling behind.

### Smart Time Logging

You can log time in two ways, and both feed into the machine learning analysis. Manual logging is for work you've already completed. You enter the project, task, hours, and date. This takes about ten seconds and doesn't interrupt your workflow.

Scheduled sessions are for planning work in advance. You set a start time and end time, and the app sends notifications to remind you when to start and stop. When the session completes, it automatically appears in your time log with the exact duration calculated from the start and end times.

Both methods create the same data structure, so all your work history is unified. The machine learning algorithms don't care how the data was logged. They just analyze the patterns.

### Firebase Backend Integration

All your data lives in Firebase Cloud Firestore, which means it syncs across all your devices automatically. Log time on your phone during a commute, and the data appears on your desktop when you get home. The sync happens in real time, usually within a second or two.

Firebase Authentication handles user accounts with support for email/password sign in and Google Sign In. Your data is completely private and isolated from other users. The Firestore security rules ensure you can only access your own time entries, projects, and tasks.

The app works offline by keeping a local copy of your data. When you log time without internet, the changes queue up and sync as soon as you reconnect. This makes the app reliable even with spotty connectivity.

### Cross Platform Support

The app runs on Android, iOS, web browsers, Windows, macOS, and Linux. The same codebase powers all platforms thanks to Flutter. The machine learning algorithms run directly on your device, so there's no server processing delay.

The user interface adapts to each platform while maintaining a consistent experience. Mobile versions use bottom navigation and floating action buttons. Desktop versions have more spacious layouts that take advantage of larger screens. Web versions work in any modern browser without requiring installation.

### Multi-Language Interface

The interface is available in English and French. All UI text, button labels, error messages, and notifications translate when you switch languages. The localization system uses Flutter's built-in tools with ARB files for translation strings.

User created content like project names and task names stays in whatever language you typed it. Only the interface elements translate. This means you can work in one language and switch the UI to another without losing any data.

### Adaptive Dark Mode

The dark theme uses carefully chosen colors that reduce eye strain during night work. The background is a deep purple instead of pure black, which looks better on OLED screens and provides better contrast for text.

The theme preference persists across app restarts and syncs across devices. If you enable dark mode on your phone, it automatically enables on your desktop the next time you open the app there.

## Machine Learning Technical Details

### K-Means Clustering Implementation

The clustering algorithm is implemented from scratch in Dart without external machine learning libraries. This keeps the app lightweight and ensures the algorithm runs efficiently on all platforms including web and mobile.

The implementation uses Lloyd's algorithm, which is the standard approach for K-Means clustering. The algorithm operates on one dimensional data, specifically the totalTime field from each work session.

Here's the step by step process. First, the algorithm extracts all session durations and finds the minimum and maximum values. It initializes three cluster centers evenly spaced across this range. For example, if your shortest session is 0.5 hours and your longest is 6 hours, the initial centers might be at 0.5, 3.25, and 6 hours.

Next comes the assignment step. The algorithm loops through every session and calculates the distance from that session's duration to each cluster center. It assigns the session to the nearest center. Distance is calculated as the absolute difference between the duration and the center value.

After all sessions are assigned, the update step recalculates each cluster center as the mean of all sessions assigned to it. If cluster one has sessions of 0.5, 0.75, and 1 hour, the new center becomes 0.75 hours.

The algorithm repeats the assignment and update steps until convergence. Convergence happens when no sessions change clusters between iterations. In practice, this usually takes 10 to 20 iterations for typical datasets.

The final step sorts the clusters by their center values and assigns labels. The cluster with the lowest center becomes light sessions, the middle becomes moderate sessions, and the highest becomes deep work sessions. This ensures consistent labeling regardless of how the initial centers were placed.

### Why K-Means for This Problem

K-Means was chosen because it's simple, fast, and interpretable. The algorithm runs in linear time relative to the number of sessions, which means it stays responsive even with thousands of logged entries.

The interpretability is crucial for a productivity app. Users can understand what the clusters mean without needing a machine learning background. Short sessions, medium sessions, and long sessions are intuitive categories.

K-Means also handles the variability in work patterns well. Some users might have sessions ranging from 15 minutes to 8 hours. Others might work in consistent 2 hour blocks. The algorithm adapts to whatever pattern exists in the data.

The unsupervised nature of K-Means is perfect for this use case. There's no training data required and no manual labeling. The algorithm discovers patterns automatically, which means the app works immediately after you log your first few sessions.

### Statistical Analysis

Beyond clustering, the app performs several statistical calculations. The average hours per active day is calculated by dividing total hours by the number of unique dates in your time log. This gives you a realistic average that accounts for days you didn't work.

The most productive day calculation aggregates hours by day of week. It builds a map where keys are day names like Monday, Tuesday, and values are total hours logged on that day across all weeks. The day with the highest total becomes your most productive day.

The weekly trend analysis filters your time entries to only include the last seven days. It builds a map where keys are dates and values are total hours for that date. This map feeds into the line chart on the insights screen.

Project distribution is calculated by grouping time entries by project name and summing the hours. The results are sorted by hours in descending order, so your top projects appear first.

## Project Structure

The Productivity Tracking Analytics App is organized into a clear and maintainable structure that separates concerns and makes the codebase easy to navigate.

```
productivity-tracking-analytics-app/
├── android/                          # Android platform specific files
│   ├── app/
│   │   ├── src/
│   │   ├── build.gradle.kts
│   │   └── google-services.json      # Firebase configuration for Android
│   └── build.gradle.kts
├── ios/                              # iOS platform specific files
│   ├── Runner/
│   │   ├── Info.plist
│   │   └── GoogleService-Info.plist  # Firebase configuration for iOS
│   └── Runner.xcodeproj/
├── lib/                              # Main application code
│   ├── l10n/                         # Localization files
│   │   ├── app_en.arb                # English translations
│   │   ├── app_fr.arb                # French translations
│   │   ├── app_localizations.dart    # Generated localization class
│   │   ├── app_localizations_en.dart # Generated English class
│   │   └── app_localizations_fr.dart # Generated French class
│   ├── models/                       # Data models
│   │   ├── project.dart              # Project model with Firestore serialization
│   │   ├── task.dart                 # Task model with Firestore serialization
│   │   ├── time_entry.dart           # Time entry model with Firestore serialization
│   │   └── reminder.dart             # Reminder model with Firestore serialization
│   ├── providers/                    # State management providers
│   │   ├── app_auth_provider.dart    # Authentication state and operations
│   │   ├── insights_provider.dart    # Machine learning analytics provider
│   │   ├── locale_provider.dart      # Language preference management
│   │   ├── theme_provider.dart       # Theme preference management
│   │   └── time_tracker_provider.dart # Main productivity data repository
│   ├── screens/                      # UI screens
│   │   ├── add_entry_screen.dart     # Manual time entry form
│   │   ├── dashboard_screen.dart     # Main dashboard with overview
│   │   ├── home_screen.dart          # All time entries list view
│   │   ├── insights_screen.dart      # Machine learning insights display
│   │   ├── login_screen.dart         # Authentication screen
│   │   ├── ml_insights_screen.dart   # Detailed ML analytics
│   │   ├── project_detail_screen.dart # Individual project details
│   │   ├── project_management_screen.dart # Projects list and management
│   │   ├── sign_up_screen.dart       # New account creation
│   │   ├── splash_screen.dart        # App loading screen
│   │   ├── task_management_screen.dart # Tasks list and management
│   │   └── unified_schedule_screen.dart # Schedule work sessions
│   ├── services/                     # Business logic services
│   │   ├── ml_service.dart           # Machine learning algorithms
│   │   └── notification_service.dart # Cross-platform notifications
│   ├── widgets/                      # Reusable UI components
│   ├── firebase_options.dart         # Generated Firebase configuration
│   └── main.dart                     # Application entry point
├── web/                              # Web platform specific files
│   ├── icons/
│   ├── index.html                    # Web entry point with Firebase config
│   ├── manifest.json
│   └── favicon.png
├── test/                             # Unit and widget tests
│   └── widget_test.dart
├── .gitignore                        # Git ignore rules
├── analysis_options.yaml             # Dart analyzer configuration
├── firebase.json                     # Firebase hosting configuration
├── l10n.yaml                         # Localization configuration
├── pubspec.yaml                      # Project dependencies and metadata
├── README.md                         # This file
└── DOCUMENTATION.md                  # Detailed project documentation
```

### Key Directories Explained

**lib/models/** contains the data structures that represent the core entities in the app. Each model knows how to serialize itself to and from Firestore documents. The models are simple data classes without business logic.

**lib/providers/** contains all the state management logic. The ProductivityRepository is the main provider that manages CRUD operations for all productivity data. The InsightsProvider runs the machine learning analysis. The auth, theme, and locale providers handle their respective concerns.

**lib/screens/** contains the full-page UI components. Each screen is a stateful or stateless widget that builds its own widget tree. Screens consume data from providers and display it to users.

**lib/services/** contains business logic that doesn't fit into providers. The MLService implements the K-Means clustering algorithm. The NotificationService handles cross-platform notification scheduling.

**lib/l10n/** contains all the localization files. The ARB files define translations for English and French. Flutter's code generation creates type-safe accessor classes from these files.

## Settings and Configuration

### Application Settings

The app provides several user-configurable settings accessible from the drawer menu.

**Theme Settings**
Users can toggle between light and dark mode. The theme preference is stored in SharedPreferences and syncs across devices. The dark theme uses a deep purple color scheme optimized for OLED displays.

**Language Settings**
Users can switch between English and French. The language preference is stored in SharedPreferences and persists across app restarts. All UI text updates immediately when the language changes.

**Account Settings**
Users can view their account information including display name and email address. The sign out option is available from the drawer menu.

### Firebase Configuration

The app requires Firebase configuration for each platform you want to support.

**Android Configuration**
Place the google-services.json file in the android/app directory. This file contains your Firebase project credentials and is generated from the Firebase Console.

**iOS Configuration**
Place the GoogleService-Info.plist file in the ios/Runner directory. This file contains your Firebase project credentials and is generated from the Firebase Console.

**Web Configuration**
Update the web/index.html file with your Firebase configuration object. This includes your API key, project ID, auth domain, and other settings.

### Environment Variables

The app does not use environment variables. All configuration is handled through Firebase configuration files and the pubspec.yaml file.

### Build Configuration

The app uses different build configurations for debug and release modes. Debug builds include additional logging and debugging tools. Release builds are optimized for performance and have smaller file sizes.

## Getting Started

### Prerequisites

You need Flutter SDK version 3.35.0 or higher and Dart SDK version 3.9.0 or higher. You can check your versions by running flutter doctor in your terminal.

You also need a Firebase project because the app uses Firebase for authentication and data storage. Go to console.firebase.google.com and create a new project if you don't have one already.

### Firebase Configuration

Create a new Firebase project and enable the following services.

In the Authentication section, enable Email/Password authentication and Google Sign In. These are the two authentication methods the app supports.

In the Firestore Database section, create a new database in production mode. The app will create the necessary collections automatically when users start logging time.

Add your app to the Firebase project for each platform you want to support. For Android, download the google-services.json file and place it in the android/app directory. For iOS, download the GoogleService-Info.plist file and place it in the ios/Runner directory.

For web, you need to copy the Firebase configuration object from the Firebase Console and update the web/index.html file. The configuration includes your API key, project ID, and other settings.

### Installation

Clone the repository to your local machine.

```bash
git clone https://github.com/yourusername/productivity-tracking-analytics-app.git
cd productivity-tracking-analytics-app
```

Install all the dependencies.

```bash
flutter pub get
```

Generate the localization files.

```bash
flutter gen-l10n
```

Run the app on your preferred platform.

```bash
flutter run
```

For specific platforms, use these commands.

```bash
flutter run -d chrome
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

For mobile devices, connect your phone via USB with USB debugging enabled, then run flutter run.

## How to Use the App

### First Time Setup

Open the app and you'll see the login screen. Create a new account with your email and password, or sign in with your Google account. After authentication, you'll land on the dashboard.

The dashboard shows your recent activity and quick stats. This is your home base for accessing all features.

### Logging Your First Session

Tap the floating action button at the bottom right to open the time logging form. Fill in the project name, task name, hours worked, and any notes. The date defaults to today but you can change it if you're logging work from a previous day.

Submit the form and your first time entry appears on the dashboard. You need at least five entries before the machine learning analysis kicks in, so log a few more sessions to see the insights.

### Viewing Machine Learning Insights

Once you have five or more logged sessions, tap ML Insights from the drawer menu. The app runs the K-Means clustering algorithm and displays your work patterns.

The top section shows key metrics like total hours, average hours per day, and most productive day. The middle section displays the session clusters with color coded badges showing how many hours you spent in each category. The bottom section has a line chart showing your activity over the last seven days.

The clustering updates automatically every time you view this screen, so the insights always reflect your latest work patterns.

### Scheduling Future Sessions

To plan work in advance, tap Schedule Session from the drawer menu. Pick a project, task, start time, and end time. The app schedules three notifications. One fires five minutes before the session starts, one fires when the session starts, and one fires when the session ends.

When the session completes, it automatically appears in your time log with the exact duration calculated from the start and end times. This feeds into the machine learning analysis just like manually logged sessions.

### Managing Projects and Tasks

The Projects screen shows all your projects with total hours logged for each one. Create new projects by tapping the floating action button. Delete projects by swiping left on any item.

The Tasks screen shows all your tasks across all projects. Create new tasks by tapping the floating action button and selecting a parent project. Delete tasks by swiping left on any item.

### Switching Languages and Themes

Open the drawer menu and tap the language toggle to switch between English and French. All UI text updates immediately.

Tap the theme toggle to switch between light and dark mode. The theme preference saves automatically and syncs across all your devices.

## Dependencies

The app uses several Flutter packages to provide its functionality.

**State Management**
Provider handles state management with a simple ChangeNotifier pattern. It's lightweight and doesn't require code generation.

**Backend Services**
Firebase Core, Firebase Auth, and Cloud Firestore provide the backend infrastructure. Firebase Auth handles user accounts and Google Sign In. Firestore stores all productivity data with real-time synchronization.

**Data Visualization**
FL Chart renders the activity charts on the insights screen with smooth animations and interactive tooltips.

**Notifications**
Flutter Local Notifications schedules reminder notifications on mobile platforms. The package supports Android and iOS with platform-specific implementations.

**Utilities**
Intl provides date formatting functions for displaying dates in different locales. Shared Preferences stores small pieces of data like theme preference and language choice. Timezone handles time zone conversions for scheduled notifications.

**Localization**
Flutter Localizations provides the framework for multi-language support. The app uses ARB files for translation strings.

## Future Enhancements

### Advanced Machine Learning Features

**Predictive Analytics**
The next phase will add predictive models that forecast future productivity based on historical patterns. The app will predict how many hours you're likely to log next week and suggest optimal times for deep work.

**Anomaly Detection**
The app will automatically identify unusual work patterns that might indicate burnout or data entry errors. For example, logging 12 hours in a single day when your typical day is 6 hours.

**Recommendation Engine**
Based on your work patterns, the app will suggest improvements like scheduling deep work during your most productive hours or breaking up long sessions with breaks.

**Multi-Dimensional Clustering**
Future versions will cluster sessions based on multiple features like duration, time of day, and day of week. This will provide richer insights about when different types of work happen.

### Enhanced User Experience

**Data Export**
Users will be able to export their data as CSV or JSON files. This makes it easy to import into other tools or create custom reports.

**Goal Setting**
Users will be able to set weekly or monthly hour targets for projects. The dashboard will show progress toward these goals with visual indicators.

**Pomodoro Timer**
A built-in timer for the Pomodoro Technique will let users start a 25-minute work session that automatically logs time when it completes.

**Custom Reports**
Users will be able to generate custom reports with date ranges, project filters, and different visualization types.

### Collaboration Features

**Team Workspaces**
Future versions may add the ability to share projects with other users. This would enable team time tracking while maintaining individual privacy.

**Project Sharing**
Users could share read-only views of their project statistics with managers or clients without exposing detailed time entries.

**Aggregate Analytics**
Team leaders could see aggregated statistics across team members without accessing individual time logs.

### Technical Improvements

**Offline Mode Enhancements**
Better visual indicators for pending syncs and improved conflict resolution when multiple devices make changes offline.

**Performance Optimization**
Pagination for large datasets to reduce memory usage. Currently all entries load at once, which works fine for typical usage but could be optimized for power users.

**Accessibility Improvements**
Enhanced screen reader support, keyboard navigation, and high contrast themes for users with visual impairments.

**Additional Platforms**
Support for smartwatches to quickly log time on the go. Integration with voice assistants for hands-free time logging.

## Troubleshooting

### Common Issues

**Provider Error**
If you see a Provider error, make sure you're accessing providers inside the MaterialApp widget tree. All provider access must happen in widgets that are descendants of the MultiProvider in main.dart.

**Firebase Connection Issues**
If Firebase isn't working, verify that you've added your app to the Firebase project and downloaded the correct configuration files. The package name in your Firebase project must match the package name in your Flutter app.

**Notification Problems**
If notifications aren't firing on Android, check that you've granted notification permissions. On Android 13 and higher, you need to request this permission at runtime.

**iOS Build Failures**
If the app won't build for iOS, open the ios folder in Xcode and verify the signing settings. You need a valid development team selected.

**Sync Issues**
If data isn't syncing across devices, check your internet connection and verify that you're signed in with the same account on all devices.

**Localization Not Working**
If translations aren't appearing, make sure you've run flutter gen-l10n after modifying the ARB files. The generated localization classes need to be rebuilt.

### Getting Help

If you encounter issues not covered here, please check the GitHub issues page or create a new issue with details about your problem. Include your Flutter version, platform, and any error messages you're seeing.

## Contributing

This project welcomes contributions and feedback. If you find a bug, please describe what you were doing when it happened and include any error messages.

If you want to contribute code, please fork the repository and submit a pull request. Make sure your code follows the existing style and includes appropriate comments.

## License

This project is open source and available under the MIT License. You're free to use, modify, and distribute the code as long as you include the original license.

## Contact

For questions about the app or discussions about machine learning in productivity tools, feel free to reach out through the GitHub repository or email.

## Acknowledgments

This project was built with Flutter and Firebase. Special thanks to the Flutter team for creating an excellent cross-platform framework and the Firebase team for providing robust backend services.

The K-Means clustering algorithm is based on Lloyd's algorithm, a classic approach in machine learning literature.
