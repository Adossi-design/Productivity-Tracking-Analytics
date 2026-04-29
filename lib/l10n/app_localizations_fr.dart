// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Suivi du Temps';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get allEntries => 'Toutes les entrées';

  @override
  String get projects => 'Projets';

  @override
  String get tasks => 'Tâches';

  @override
  String get localStorage => 'Stockage';

  @override
  String get insights => 'Analyses';

  @override
  String get logTimeEntry => 'Enregistrer une entrée';

  @override
  String get hoursWorked => 'Heures travaillées';

  @override
  String get project => 'Projet';

  @override
  String get task => 'Tâche';

  @override
  String get notes => 'Notes';

  @override
  String get date => 'Date';

  @override
  String get saveTimeEntry => 'Enregistrer';

  @override
  String get selectProject => 'Sélectionner un projet';

  @override
  String get selectTask => 'Sélectionner une tâche';

  @override
  String get noProjectsAvailable => 'Aucun projet disponible';

  @override
  String get noTasksAvailable => 'Aucune tâche disponible';

  @override
  String get addProject => 'Ajouter un projet';

  @override
  String get addTask => 'Ajouter une tâche';

  @override
  String get projectName => 'Nom du projet';

  @override
  String get taskName => 'Nom de la tâche';

  @override
  String get selectParentProject => 'Sélectionner le projet parent';

  @override
  String get cancel => 'Annuler';

  @override
  String get add => 'Ajouter';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteTimeEntry => 'Supprimer l\'entrée';

  @override
  String get deleteTimeEntryConfirm =>
      'Voulez-vous vraiment supprimer cette entrée ?';

  @override
  String get deleteTimeEntryPermanent =>
      'Supprimer cette entrée définitivement ?';

  @override
  String get noTimeEntries => 'Aucune entrée enregistrée';

  @override
  String get noTimeEntriesSubtitle =>
      'Appuyez sur le bouton pour enregistrer votre première entrée';

  @override
  String get noProjectAnalytics => 'Aucune analyse disponible';

  @override
  String get noProjectAnalyticsSubtitle =>
      'Enregistrez des entrées pour voir les analyses ici';

  @override
  String get noProjectsYet => 'Aucun projet';

  @override
  String get noProjectsYetSubtitle =>
      'Appuyez sur + pour créer votre premier projet';

  @override
  String get noTasksYet => 'Aucune tâche';

  @override
  String get noTasksYetSubtitle =>
      'Appuyez sur + pour créer votre première tâche';

  @override
  String get timeEntries => 'Entrées de temps';

  @override
  String get storageOverview => 'Aperçu du stockage';

  @override
  String get records => 'enregistrements';

  @override
  String get storageEmpty => 'Stockage vide';

  @override
  String get storageEmptySubtitle => 'Aucun enregistrement persisté';

  @override
  String get sharedPreferencesKey => 'Collection Firestore';

  @override
  String get listView => 'Vue liste';

  @override
  String get groupByProject => 'Grouper par projet';

  @override
  String get projectManagement => 'Gestion des projets';

  @override
  String get taskManagement => 'Gestion des tâches';

  @override
  String get localStorageInspector => 'Inspecteur de stockage';

  @override
  String get name => 'Nom complet';

  @override
  String get enterName => 'Entrez votre nom complet';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get enterConfirmPassword => 'Ressaisissez votre mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get createAccount => 'Créer votre compte';

  @override
  String get getStarted => 'Commencer';

  @override
  String get trackSmarter => 'Travaillez mieux, suivez plus intelligemment';

  @override
  String get splashTagline => 'Enregistrez. Analysez. Restez productif.';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get noAccount => 'Pas de compte ?';

  @override
  String get alreadyHaveAccount => 'Déjà un compte ?';

  @override
  String get enterEmail => 'Entrez votre email';

  @override
  String get enterPassword => 'Entrez votre mot de passe';

  @override
  String get enterHoursWorked => 'Entrez les heures travaillées';

  @override
  String get enterValidNumber => 'Entrez un nombre valide';

  @override
  String get pleaseSelectProject => 'Veuillez sélectionner un projet';

  @override
  String get pleaseSelectTask => 'Veuillez sélectionner une tâche';

  @override
  String get insightsTitle => 'Analyses de productivité';

  @override
  String get mostProductiveDay => 'Jour le plus productif';

  @override
  String get totalHours => 'Total des heures';

  @override
  String get avgHoursPerDay => 'Moy. heures / jour';

  @override
  String get topProject => 'Projet principal';

  @override
  String get hoursThisWeek => 'Heures cette semaine';

  @override
  String get hoursPerProject => 'Heures par projet';

  @override
  String get dailyActivity => 'Activité quotidienne (7 derniers jours)';

  @override
  String get behaviorClusters => 'Clusters de comportement';

  @override
  String get clusterLight => 'Sessions légères';

  @override
  String get clusterModerate => 'Sessions modérées';

  @override
  String get clusterDeep => 'Sessions de travail intensif';

  @override
  String get notEnoughData => 'Pas assez de données';

  @override
  String get notEnoughDataSubtitle =>
      'Enregistrez au moins 5 entrées pour débloquer les analyses';

  @override
  String get unknownProject => 'Projet inconnu';

  @override
  String get addNotes => 'Ajouter des notes...';

  @override
  String get egHours => 'ex. 2.5';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get lightMode => 'Mode clair';

  @override
  String get language => 'Langue';

  @override
  String get settings => 'Paramètres';

  @override
  String get scheduleSession => 'Nouvelle session';

  @override
  String get welcomeProductivityHub =>
      'Bienvenue dans votre hub de productivité !';

  @override
  String get startTrackingMessage =>
      'Commencez à suivre vos sessions de travail pour débloquer des analyses puissantes basées sur l\'IA';

  @override
  String get scheduleFirstSession => 'Planifier votre première session';

  @override
  String get createProjectFirst => 'Créer d\'abord un projet';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get readyToBeProductive => 'Prêt à être productif ?';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get createFirstProject => 'Créez votre premier projet pour commencer';

  @override
  String get createProject => 'Créer un projet';

  @override
  String get topProjects => 'Meilleurs projets';

  @override
  String get viewAll => 'Voir tout →';

  @override
  String get mlInsightsLocked => 'Analyses IA verrouillées';

  @override
  String get logMoreSessions => 'Enregistrez';

  @override
  String get sessionsToUnlock =>
      'sessions supplémentaires pour débloquer les analyses IA';

  @override
  String get learnMore => 'En savoir plus';

  @override
  String get mlInsights => 'Analyses IA';

  @override
  String get noActivityYet => 'Aucune activité';

  @override
  String get recentSessionsAppear =>
      'Vos sessions de travail récentes apparaîtront ici';

  @override
  String get logTime => 'Enregistrer le temps';

  @override
  String get recentActivity => 'Activité récente';

  @override
  String get helpAndSupport => 'Aide et support';

  @override
  String get allTimeEntries => 'Toutes les entrées';

  @override
  String get scheduleNewSession => 'Planifier une nouvelle session de travail';
}
