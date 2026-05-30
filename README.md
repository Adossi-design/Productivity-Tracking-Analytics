# Productivity Tracking & Analytics App

A cross-platform Flutter + Firebase time-tracking app that turns raw work logs into
insight. Instead of just listing hours, it runs three on-device analytics engines over
your sessions: an unsupervised **K-Means clustering** model that groups sessions by
depth (with a silhouette quality score), a **supervised linear-regression forecaster**
that predicts upcoming hours and reports its own held-out accuracy, and a **heuristic
analytics engine** that detects anomalies, recognises patterns, and scores productivity
across five dimensions.

Everything runs locally on the device — there is no analytics server and no per-request
latency. Data lives in your own Firebase project, syncs in real time across devices via
Firestore streams, and is isolated per user by security rules.

---

## Table of contents

- [Features](#features)
- [How the analytics work](#how-the-analytics-work)
- [Architecture](#architecture)
- [Project structure](#project-structure)
- [Getting started](#getting-started)
- [Security](#security)
- [Testing & CI](#testing--ci)
- [Known limitations & roadmap](#known-limitations--roadmap)

---

## Features

- **Session clustering (K-Means).** Groups logged sessions into *Light*, *Moderate*,
  and *Deep Work* tiers by duration, and reports a **silhouette score** so you can see
  how well-separated (i.e. how trustworthy) the grouping actually is.
- **Hours forecasting (regression).** Predicts next-day and next-7-day hours from your
  history and shows the model's **held-out accuracy** (MAE / RMSE / R²) so the prediction
  is accountable rather than a black box.
- **Anomaly detection.** Flags unusually long days, late-night work, long gaps without
  logging, and weekend-heavy weeks — each with a severity level.
- **Pattern recognition.** Surfaces task sequences, peak/low days of the week,
  long-session-without-breaks tendencies, high task-switching, and time-of-day habits.
- **Productivity score.** A 0–100 score across Volume, Consistency, Focus, Balance, and
  Efficiency, with plain-language insights on what to improve.
- **Time logging & scheduling.** Log completed work or schedule future sessions with
  start/end times. Scheduled sessions fire local notifications (start, 5-min-before-end,
  and end) on mobile; on web they surface as in-app alerts while the tab is open.
- **Projects, tasks & reminders.** Organise work into projects and tasks; set per-project
  reminders with selectable notification sounds.
- **Firebase backend.** Email/password and Google sign-in; Cloud Firestore storage scoped
  per user. Offline persistence works out of the box on mobile.
- **Localised UI (EN / FR)** and **light/dark themes**, both persisted across launches.
- **Six platforms** from one codebase: Android, iOS, web, Windows, macOS, Linux.

---

## How the analytics work

The app deliberately ships **three complementary engines**, surfaced across two screens.

### 1. K-Means session clustering — `InsightsScreen`

Implemented from scratch (Lloyd's algorithm) in
[`lib/providers/insights_provider.dart`](lib/providers/insights_provider.dart) over a
single feature: session duration.

1. Initialise *k = 3* centroids evenly across the min/max duration range.
2. **Assign** each session to the nearest centroid (absolute distance).
3. **Update** each centroid to the mean of its members.
4. Repeat until assignments stop changing (or the iteration cap is hit).
5. Sort clusters by centroid and label them Light / Moderate / Deep Work.

**Quality is measured, not assumed.** After clustering, a mean **silhouette
coefficient** (range −1…1) is computed and shown in the UI as a quality label
(*Strong / Reasonable / Weak / Poor*). This is the kind of validation metric that
separates "we drew three buckets" from "these buckets are statistically meaningful."

### 2. Hours forecasting — supervised regression

Implemented in [`lib/services/forecast_service.dart`](lib/services/forecast_service.dart).
This is genuine supervised learning: it builds a continuous daily-hours time series,
**fits an ordinary least-squares regression**, and — crucially — evaluates honestly:

1. Split the series chronologically into **training** and **held-out validation** sets.
2. Fit `hours = slope·day + intercept` on the training set only.
3. Score the model on the unseen validation tail, reporting **MAE**, **RMSE**, and
   **R²** (all shown in the UI).
4. Refit on the full history to produce the actual next-day / next-7-day forecast and a
   trend label.

Reporting error on data the model never saw is what makes the forecast trustworthy
rather than a number pulled from thin air.

### 3. Heuristic analytics engine — `MLInsightsScreen`

Implemented in [`lib/services/ml_service.dart`](lib/services/ml_service.dart): a set of
pure, testable functions for anomaly detection, pattern recognition, recommendations,
and the productivity score. Every threshold (minimum data sizes, severity multipliers,
weekly-hours target, etc.) is centralised and documented in
[`lib/config/ml_config.dart`](lib/config/ml_config.dart) so the model is reviewable and
tunable in one place rather than scattered as magic numbers.

> **Honest framing:** clustering is unsupervised ML with a validation metric, and the
> forecaster is supervised regression with a held-out evaluation. The third engine is
> deliberately rule-based/statistical (no training data needed) — labelled as such rather
> than dressed up as a model. All three are clearly separated and individually testable.

---

## Architecture

State management is **Provider** (`ChangeNotifier`). Five providers are composed in
[`lib/main.dart`](lib/main.dart):

| Provider | Responsibility |
| --- | --- |
| `ProductivityRepository` | Firestore CRUD for entries/projects/tasks/reminders over **real-time `snapshots()` listeners** — changes propagate live and offline writes reconcile on reconnect. Persistence only; it never schedules notifications behind a caller's back. |
| `InsightsProvider` | K-Means clustering + silhouette score + summary stats. Memoised so repeated calls with unchanged data are no-ops. |
| `AppAuthProvider` | Firebase Auth (email/password + Google). |
| `ThemeProvider` / `LocaleProvider` | Dark mode & EN/FR, persisted via `SharedPreferences`. |

**Data flow:** auth state → `ProductivityRepository.setUser(uid)` attaches live listeners
to the user's Firestore subcollections → snapshots notify → screens rebuild.

---

## Project structure

```
lib/
├── config/
│   └── ml_config.dart            # All ML/analytics thresholds in one place
├── l10n/                         # ARB translation sources + generated classes
├── models/                       # Project, Task, TimeEntry, Reminder (defensive parsing)
├── providers/                    # State management (see table above)
├── screens/                      # UI screens
│   ├── dashboard_screen.dart
│   ├── insights_screen.dart      # K-Means clusters + charts + silhouette quality
│   ├── ml_insights_screen.dart   # Anomalies / patterns / recommendations / score
│   ├── unified_schedule_screen.dart
│   └── ...
├── services/
│   ├── ml_service.dart           # Heuristic analytics (pure functions)
│   ├── forecast_service.dart     # Supervised regression forecaster + evaluation
│   └── notification_service.dart # Cross-platform notifications (mobile + web fallback)
├── theme/
│   └── app_colors.dart           # Central brand palette
├── widgets/
│   └── drawer_item.dart          # Shared navigation widget
└── main.dart
firestore.rules                   # Per-user access rules
.github/workflows/ci.yml          # format + analyze + test on every push/PR
test/                             # Unit tests (ML + clustering) and a widget smoke test
```

---

## Getting started

### Prerequisites

- Flutter SDK **3.35+** / Dart **3.9+** (`flutter doctor`)
- A Firebase project with **Authentication** (Email/Password + Google) and **Cloud
  Firestore** enabled.

### Firebase configuration

Firebase config files are **not committed** (they are environment-specific). Generate
your own with the FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This regenerates `lib/firebase_options.dart`, `android/app/google-services.json`, and
`ios/Runner/GoogleService-Info.plist` — all already in `.gitignore`.

Then deploy the included security rules:

```bash
firebase deploy --only firestore:rules
```

### Run

```bash
flutter pub get
flutter gen-l10n
flutter run                 # or: -d chrome | -d windows | -d macos | -d linux
```

---

## Security

- **No secrets in source control.** `firebase_options.dart`, `google-services.json`, and
  `GoogleService-Info.plist` are git-ignored and untracked. (Note: these were committed in
  early history; if you forked from that point, rotate the affected keys in the Firebase
  console and scrub history with `git filter-repo`.)
- **Per-user isolation.** [`firestore.rules`](firestore.rules) restricts every document
  under `users/{uid}/**` to the authenticated owner and denies everything else by default.
- **Android permissions.** The manifest declares `INTERNET`, `POST_NOTIFICATIONS`,
  `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM`, and `RECEIVE_BOOT_COMPLETED`, plus the
  `flutter_local_notifications` receivers required for scheduled alarms to fire and survive
  reboot.

---

## Testing & CI

```bash
flutter analyze     # static analysis — clean
flutter test        # unit + widget tests
dart format .       # formatting
```

The test suite covers the analytics layer directly:

- `test/ml_service_test.dart` — score bounds, minimum-data guards, anomaly detection
  (including the "longest gap" labelling), and recommendation triggers.
- `test/insights_provider_test.dart` — K-Means cluster ordering/labelling, silhouette
  score on well-separated data, summary stats, and compute memoisation.
- `test/forecast_service_test.dart` — regression fit on clean linear/flat/declining
  series, held-out error metrics, trend detection, and the insufficient-data guard.
- `test/widget_test.dart` — a self-contained screen smoke test.

[`.github/workflows/ci.yml`](.github/workflows/ci.yml) runs **format → analyze → test**
on every push and pull request to `main`.

---

## Known limitations & roadmap

These are deliberately called out rather than glossed over:

- **No pagination.** All entries load at once — fine for typical use, not for power users
  with thousands of records. Streamed queries make windowed pagination a natural next step.
- **The forecaster is intentionally simple.** Linear regression on a single feature is a
  transparent, honest baseline. Richer models (seasonality/day-of-week features, or
  multi-feature clustering on duration × time-of-day × weekday) are the next iteration.
- **Web notifications require an open tab.** Browsers can't fire background notifications;
  the web path surfaces in-app alerts instead.

Further ideas: CSV/JSON export, goal setting with progress tracking, and a built-in
Pomodoro timer that auto-logs sessions.

---

## License

MIT.
