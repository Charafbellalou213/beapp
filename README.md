# Beapp

App mobile Flutter per il turismo sostenibile a Padova — progetto universitario legato all'SDG 8 (Decent Work and Economic Growth), target 8.9.

## Tema

**Target 8.9 (UN SDG 8):** *"By 2030, devise and implement policies to promote sustainable tourism that creates jobs and promotes local culture and products."*
https://sdgs.un.org/goals/goal8

## Cosa fa l'app

Beapp aiuta turisti e cittadini a scoprire luoghi tipici, culturali e ristoranti/locali tipici di Padova attraverso percorsi a piedi. Ogni luogo visitato assegna punti; l'app stima le calorie bruciate camminando (anche con dati reali via API, quando disponibili) e suggerisce piatti tipici locali, collegando il percorso turistico al sostegno dell'economia locale.

## Tecnologie

- Flutter / Dart
- Google Maps (`google_maps_flutter`)
- State management: `provider` (ChangeNotifier)
- Persistenza locale: `shared_preferences`
- Dati locali: file JSON in `assets/data/`
- API dati attività (calorie/passi/distanza/esercizio), opzionale

## Setup rapido

```bash
flutter pub get
flutter run
```

Per la Google Maps API Key, vedi le istruzioni nella Fase 10 del progetto (la chiave reale non va mai committata su GitHub — vedi `.gitignore`).

## Struttura del progetto

```
lib/
  models/       # Place, Restaurant, MenuItem, Review, UserStats, Badge, ActivityData, DailyActivitySummary
  providers/    # AppState (ChangeNotifier)
  screens/      # Login, Home, Map, Places, PlaceDetail, Route, Restaurants, RestaurantDetail, Profile, SdgImpact
  widgets/      # componenti UI riutilizzabili
  services/     # caricamento dati locali, storage, posizione, percorso, API
  utils/        # calcolo calorie, distanze, date, costanti, config API
assets/
  data/         # places.json, restaurants.json
  images/
```

## Workflow Git

- `main`: branch stabile, pronta per demo/esame
- `develop`: branch di integrazione
- `feature/*`: una branch per funzionalità, poi Pull Request verso `develop`

## Gruppo

Progetto universitario — max 4 componenti.
