import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/map_screen.dart';
import 'screens/places_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/restaurants_screen.dart';

import 'services/storage_service.dart';
import 'widgets/rating_stars.dart';

class BeappApp extends StatelessWidget {
  const BeappApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeLocal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6B4A)),
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: Consumer<AppState>(
        builder: (context, appState, _) {
          if (appState.isBootstrapping) {
            return const _SplashScreen();
          }
          if (!appState.isLoggedIn) {
            return const LoginScreen();
          }
          return const MainNavigation();
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, size: 48),
            SizedBox(height: 16),
            Text(
              'BeLocal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final _storageService = StorageService();
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();
    _scheduleFeedbackPromptIfNeeded();
  }

  Future<void> _scheduleFeedbackPromptIfNeeded() async {
    final alreadyShown = await _storageService.hasShownFeedbackPrompt();
    if (alreadyShown || !mounted) return;

    _feedbackTimer = Timer(const Duration(minutes: 1), _showFeedbackDialog);
  }

  Future<void> _showFeedbackDialog() async {
    if (!mounted) return;

    double rating = 0;

    final liked = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Cosa ne pensi di BeLocal?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ti sta piacendo l\'app? La consiglieresti a un amico?',
              ),
              const SizedBox(height: 16),
              const Text('Quante stelle daresti?'),
              const SizedBox(height: 8),
              Center(
                child: RatingStars(
                  rating: rating,
                  size: 32,
                  onRatingUpdate: (value) =>
                      setDialogState(() => rating = value),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Sì, mi piace'),
            ),
          ],
        ),
      ),
    );

    if (liked != null) {
      await _storageService.saveFeedbackResponse(
        liked: liked,
        rating: rating > 0 ? rating.round() : null,
      );
    }
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    super.dispose();
  }

  static const _screens = [
    HomeScreen(),
    MapScreen(),
    PlacesScreen(),
    RestaurantsScreen(),
    ProfileScreen(),
  ];

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.map_outlined),
      selectedIcon: Icon(Icons.map),
      label: 'Mappa',
    ),
    NavigationDestination(
      icon: Icon(Icons.place_outlined),
      selectedIcon: Icon(Icons.place),
      label: 'Luoghi',
    ),
    NavigationDestination(
      icon: Icon(Icons.restaurant_outlined),
      selectedIcon: Icon(Icons.restaurant),
      label: 'Ristoranti',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profilo',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: _destinations,
      ),
    );
  }
}
