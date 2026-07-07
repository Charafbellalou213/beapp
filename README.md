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

## Configurazione richiesta prima della demo

- **Google Maps API key (Android):** in `android/local.properties` sostituisci `MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY` con una chiave reale (Google Cloud Console → abilita "Maps SDK for Android"). Senza chiave valida la mappa resta grigia/vuota, il resto dell'app funziona comunque.
- **Google Maps API key (iOS):** in `ios/Runner/AppDelegate.swift` sostituisci `"YOUR_GOOGLE_MAPS_API_KEY"` (richiede macOS + Xcode + CocoaPods per buildare).
- **API dati attività:** `lib/utils/api_config.dart` contiene un `baseUrl` segnaposto non raggiungibile di proposito. Se il corso fornisce un endpoint reale, sostituiscilo lì. Senza endpoint reale l'app funziona comunque: la Profile screen userà sempre stime locali.
- **Web:** `google_maps_flutter` su web richiede un tag `<script>` con API key in `web/index.html` (non incluso: la app è pensata soprattutto per Android/iOS).

## Checklist pre-esame (Fase 17)

- [x] `flutter analyze` — nessun problema
- [x] `flutter test` — tutti i test passano (modelli, servizi, provider, navigazione)
- [x] `flutter build apk --debug` — build Android completa senza errori
- [x] `flutter run -d chrome` — avvio senza eccezioni runtime
- [ ] Sostituire le API key segnaposto (Maps + API attività) prima della presentazione
- [ ] Aggiungere gli altri luoghi/locali reali in `assets/data/places.json` e `restaurants.json`
- [ ] Provare il flusso completo su un device/emulatore Android reale (login → percorso → mappa → visita → recensione → profilo)

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
