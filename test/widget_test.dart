// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fit_tracker_app/main.dart';
import 'package:fit_tracker_app/core/bindings/core_binding.dart';
import 'package:fit_tracker_app/features/auth/bindings/auth_binding.dart';
import 'package:fit_tracker_app/features/metrics/bindings/metrics_binding.dart';
import 'package:fit_tracker_app/features/workout/bindings/workout_binding.dart';
import 'package:fit_tracker_app/features/stats/bindings/stats_binding.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ...CoreBinding.providers,
          ...AuthBinding.providers,
          ...MetricsBinding.providers,
          ...WorkoutBinding.providers,
          ...StatsBinding.providers,
        ],
        child: const FitTrackerApp(),
      ),
    );

    // Verify that the app renders without throwing.
    await tester.pump();
    expect(find.byType(FitTrackerApp), findsOneWidget);
  });
}
