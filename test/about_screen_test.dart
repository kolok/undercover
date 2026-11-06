import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:undercover/l10n/l10n.dart';
import 'package:undercover/screens/about_screen.dart';
import 'package:undercover/theme.dart';

Future<void> pumpAboutScreen(WidgetTester tester) {
  return tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AboutScreen(),
    ),
  );
}

ScrollController aboutScrollController(WidgetTester tester) {
  return tester.widget<ListView>(find.byType(ListView)).controller!;
}

void main() {
  const rateLabel = 'Noter sur le Play Store';

  testWidgets('affiche le titre et le texte de présentation', (tester) async {
    await pumpAboutScreen(tester);

    expect(find.text('À PROPOS'), findsOneWidget);
    expect(find.textContaining('sans publicité'), findsOneWidget);
    expect(find.textContaining('bonne note'), findsOneWidget);
  });

  testWidgets('le contenu est dans une zone scrollable avec scrollbar', (
    tester,
  ) async {
    await pumpAboutScreen(tester);

    expect(find.byType(Scrollbar), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(aboutScrollController(tester), isNotNull);
  });

  testWidgets('on peut faire défiler le texte quand l\'écran est trop petit', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    tester.view.physicalSize = const Size(400, 420);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpAboutScreen(tester);
    await tester.pumpAndSettle();

    final controller = aboutScrollController(tester);
    expect(controller.position.maxScrollExtent, greaterThan(0));
    expect(find.text(rateLabel), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -120));
    await tester.pumpAndSettle();

    expect(controller.offset, greaterThan(0));
    expect(find.text(rateLabel), findsOneWidget);

    debugDefaultTargetPlatformOverride = null;
  });
}
