# Project & Task Time Tracking System

A Flutter application for logging and managing time entries across projects and tasks. All data is stored locally on-device using SharedPreferences — no backend, no account required.

---

## Features

- Log time entries with a project, task, hours worked, optional notes, and a date
- Create and delete projects
- Create and delete tasks, each scoped to a specific project
- View all time entries in a flat chronological list
- Toggle to a grouped-by-project view showing total hours per project
- Swipe-to-delete or tap the delete icon to remove entries, projects, or tasks
- Inspect the raw JSON stored in SharedPreferences via the Local Storage Inspector screen
- Data loads automatically on app start and persists across sessions

---

## Project Structure

```
lib/
├── main.dart                          # App entry point — bootstraps ProductivityTrackingApp via MultiProvider
├── models/
│   ├── project.dart                   # Project model (id, name)
│   ├── task.dart                      # Task model (id, name, projectId)
│   └── time_entry.dart                # TimeEntry model (id, projectName, taskName, notes, totalTime, date)
├── providers/
│   └── time_tracker_provider.dart     # ProductivityRepository — central state, persistence, and CRUD
└── screens/
    ├── home_screen.dart               # Dashboard with tab bar and navigation drawer
    ├── add_entry_screen.dart          # Form to log a new time entry
    ├── project_management_screen.dart # List, create, and delete projects
    ├── task_management_screen.dart    # List, create, and delete tasks
    └── local_storage_screen.dart      # Raw SharedPreferences inspector
```

---

## Screens

### Dashboard (Home)
The main screen. Contains a tab bar with two tabs:

- **All Entries** — flat list of every time entry, sorted newest first. Each card shows the task name, project name, hours logged, date, and optional notes. Swipe left or tap the delete icon to remove an entry (with a confirmation dialog).
- **Projects** — always shows time entries grouped by project, with a total hours badge per project header.

A toggle button in the app bar switches the "All Entries" tab between flat list and grouped-by-project view.

Navigation to other screens is via the side drawer (hamburger menu).

### Log Time Entry
A form screen reached via the floating action button on the Dashboard. Fields:

| Field | Type | Required |
|---|---|---|
| Hours Worked | Decimal number input | Yes |
| Project | Dropdown of existing projects | Yes |
| Task | Dropdown filtered to the selected project | Yes |
| Notes | Multi-line text input | No |
| Date | Date picker, defaults to today | No |

Submitting saves the entry and returns to the Dashboard.

### Project Management
Lists all projects. Each item shows the project name and how many time entries reference it. Create a project via the FAB (dialog with a name field). Delete by swiping left or tapping the delete icon.

### Task Management
Lists all tasks across all projects. Each item shows the task name and its parent project. Create a task via the FAB (dialog with a name field and a parent project dropdown). Delete by swiping left or tapping the delete icon.

### Local Storage Inspector
A debug/inspection screen. Shows a storage overview card with record counts for time entries, projects, and tasks. Below that, each SharedPreferences key (`time_entries`, `projects`, `tasks`) is shown as an expandable card that reveals the raw JSON when tapped.

---

## State Management & Data Flow

All state lives in `ProductivityRepository`, a `ChangeNotifier` registered at the root via `MultiProvider`.

- On construction, `_loadPersistedRecords()` reads all three SharedPreferences keys and deserializes them into `List<TimeEntry>`, `List<Project>`, and `List<Task>`.
- Every mutation method (`addEntry`, `deleteEntry`, `addProject`, `deleteProject`, `addTask`, `deleteTask`) updates the in-memory list, persists the change via `_persistTimeEntries()` / `_persistProjects()` / `_persistTasks()`, and calls `notifyListeners()`.
- `timeEntriesGroupedByProject` is a computed getter that returns a `Map<String, List<TimeEntry>>` keyed by project name.
- `toggleGroupByProject()` flips a boolean flag used by the Dashboard to switch list modes.
- `fetchRawStorageSnapshot()` returns the raw JSON strings for the Local Storage Inspector screen.

---

## Data Models

### Project
```dart
Project({ required String id, required String name })
```
Serialized to/from JSON. `id` is set to `DateTime.now().millisecondsSinceEpoch.toString()` on creation.

### Task
```dart
Task({ required String id, required String name, required String projectId })
```
`projectId` references a `Project.id`. Tasks are filtered by `projectId` when populating the task dropdown on the Log Time Entry screen.

### TimeEntry
```dart
TimeEntry({
  required String id,
  required String projectName,
  required String taskName,
  required String notes,
  required double totalTime,
  required DateTime date,
})
```
Stores project and task by name (denormalized), not by ID. `date` is serialized as ISO 8601.

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| [provider](https://pub.dev/packages/provider) | ^6.0.0 | `ChangeNotifier`-based state management |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | ^2.2.0 | On-device key-value persistence (resolved: 2.5.4) |
| [intl](https://pub.dev/packages/intl) | ^0.19.0 | Date formatting (`MMM d`, `MMMM d, yyyy`) |
| flutter_lints | ^3.0.0 | Lint rules (dev) |

Supports: Android, iOS, Web, Windows, macOS, Linux.

---

## Getting Started

```bash
flutter pub get
flutter run
```

**Requirements:**
- Flutter SDK `>=3.35.0`
- Dart SDK `>=3.9.0 <4.0.0`

No environment variables, API keys, or backend configuration needed.
