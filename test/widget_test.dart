import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:beapp/app.dart';
import 'package:beapp/providers/app_state.dart';

void main() {
  testWidgets('utente non loggato vede la LoginScreen', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const BeappApp(),
      ),
    );

    expect(find.text('Login Screen'), findsOneWidget);
  });

  testWidgets('utente loggato vede la bottom navigation con 5 tab', (tester) async {
    final appState = AppState()..setUsername('mario');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const BeappApp(),
      ),
    );

    expect(find.text('Home Screen'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Mappa'));
    await tester.pumpAndSettle();
    expect(find.text('Map Screen'), findsOneWidget);

    await tester.tap(find.text('Profilo'));
    await tester.pumpAndSettle();
    expect(find.text('Profile Screen'), findsOneWidget);
  });
}
