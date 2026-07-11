import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:beapp/app.dart';
import 'package:beapp/providers/app_state.dart';
import 'package:beapp/services/storage_service.dart';
import 'package:beapp/widgets/rating_stars.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('dopo 1 minuto dall\'accesso appare il popup di feedback', (tester) async {
    final appState = AppState();
    await tester.runAsync(() async {
      await appState.bootstrap();
      await appState.login('mario');
    });

    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: appState, child: const BeappApp()),
    );
    await tester.pump();

    expect(find.text('Cosa ne pensi di BeLocal?'), findsNothing);

    await tester.pump(const Duration(minutes: 1));
    await tester.pump();

    expect(find.text('Cosa ne pensi di BeLocal?'), findsOneWidget);
    expect(find.text('Quante stelle daresti?'), findsOneWidget);
    expect(find.byType(RatingStars), findsOneWidget);
    expect(find.text('Sì, mi piace'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);

    await tester.tap(find.text('Sì, mi piace'));
    await tester.pump();

    expect(find.text('Cosa ne pensi di BeLocal?'), findsNothing);
    expect(await StorageService().hasShownFeedbackPrompt(), true);
  });
}