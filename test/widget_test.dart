import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:beapp/app.dart';
import 'package:beapp/providers/app_state.dart';

/// Nota: ogni chiamata asincrona "vera" (asset JSON, shared_preferences)
/// dentro un testWidgets va avvolta in `tester.runAsync`, altrimenti il
/// secondo test del file può bloccarsi indefinitamente (limite noto della
/// zona FakeAsync usata da testWidgets).
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('utente non loggato vede la LoginScreen', (tester) async {
    final appState = AppState();
    await tester.runAsync(() => appState.bootstrap());

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const BeappApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Beapp'), findsWidgets);
    expect(find.byType(TextFormField), findsOneWidget);
  });

  testWidgets('utente loggato vede la bottom navigation con 5 tab', (tester) async {
    final appState = AppState();
    await tester.runAsync(() async {
      await appState.bootstrap();
      await appState.login('mario');
    });

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const BeappApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Mappa'));
    await tester.pump();
    expect(find.byType(GoogleMap), findsOneWidget);

    await tester.tap(find.text('Profilo'));
    await tester.pump();
  });
}
