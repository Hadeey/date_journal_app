# Date Journal App - Project Context

## 📱 Présentation Générale
**Date Journal App** ("Une app pour noter et analyser ses dates") est une application mobile développée en Flutter. Elle a pour but de permettre aux utilisateurs de consigner, suivre et analyser leurs rendez-vous romantiques. L'application agit comme un journal intime sécurisé et analytique, offrant des statistiques détaillées sur les rencontres passées.

## 🛠 Stack Technique
- **Frontend** : Flutter (Dart)
- **Backend & Base de données** : Supabase (Authentification + Database relationnelle)
- **State Management** : Riverpod (`flutter_riverpod`)
- **Navigation** : GoRouter (`go_router`)
- **Sécurité** : Authentification biométrique locale (`local_auth`)
- **Visualisation de données** : `fl_chart` (pour les statistiques)
- **Stockage Local** : `shared_preferences`
- **UI / Animations** : `flutter_animate`, `google_fonts`, `cupertino_icons`

## 📂 Architecture du Projet
L'application adopte une structure **Feature-First** (modulaire par fonctionnalité) pour garantir une meilleure scalabilité :

- **`lib/features/`** : Contient le cœur métier de l'application, divisé par domaines :
  - **`auth/`** : Gestion de l'authentification (Onboarding, Login, Signup).
  - **`dates/`** : Fonctionnalités liées aux rendez-vous (Timeline, Détails d'un date, Ajout d'un nouveau date).
  - **`persons/`** : Liste et gestion des personnes rencontrées.
  - **`profile/`** : Paramètres utilisateurs et gestion du profil.
  - **`statistics/`** : Écran d'analyse et graphiques des dates passés.

- **`lib/core/`** : Logique transversale de l'application :
  - **`routes/`** : Configuration `GoRouter` et protection des routes.
  - **`theme/`**, **`config/`**, **`constants/`**, **`utils/`** : Éléments globaux.

- **`lib/shared/`** : Éléments réutilisables à travers toute l'app :
  - **`widgets/`** : Composants UI globaux (ex: `MainScaffoldShell` pour la navigation persistante).
  - **`models/`** et **`extensions/`**.

## 🧬 Modèles de Données Principaux

### 1. DateEntry (`date_entry.dart`)
L'entité centrale qui enregistre chaque rendez-vous. Elle contient des données très complètes :
- **Relations** : `userId`, `personId`
- **Contexte** : `dateTime`, `location`, `dateType`, `manStyle`
- **Notes quantitatives (ratings)** : Alchimie (`ratingChemistry`), Conversation, Ponctualité, Apparence, et Note Globale (`ratingOverall`).
- **Notes qualitatives** : Ce qu'on a fait (`whatWeDid`), son comportement (`hisBehavior`), moments gênants (`awkwardMoments`), moments drôles, `greenFlags`, `redFlags`, notes personnelles, humeur, etc.
- **Faits marquants** : `spentNightTogether` (booléen).

### 2. Person (`person.dart`)
Représente une personne avec qui l'utilisateur a eu un ou plusieurs rendez-vous :
- **Propriétés** : `name`, `age`, `howKnown` (comment on s'est rencontré).
- **Données agrégées** : `dateCount` (nombre de dates avec cette personne, récupéré dynamiquement via une jointure Supabase).

## 🧭 Navigation & Routes Principales (GoRouter)
L'application utilise une `ShellRoute` pour garder une barre de navigation persistante sur les écrans principaux :
- `/` : La **Timeline** (Historique des dates).
- `/persons` : La liste des personnes rencontrées.
- `/stats` : L'écran de statistiques (`fl_chart`).
- `/profile` : Les paramètres.

Des routes plein écran sont prévues pour :
- **L'authentification** (`/onboarding`, `/login`, `/signup`).
- **L'édition/création d'un date** (`/date/new`, `/date/:id`, `/date/:id/edit`). L'accès est protégé, redirigeant les utilisateurs non connectés vers l'onboarding.

## 🚀 État actuel et prochaines étapes
- L'architecture de base, le routing protégé et les modèles de données connectés à **Supabase** sont en place.
- La sérialisation JSON (`fromJson`/`toJson`) pour le backend est prête.
- **Extensions futures prévues** : L'ajout de photos aux dates (`image_picker` est en commentaire dans le `pubspec.yaml`).
