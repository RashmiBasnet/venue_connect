import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venue_connect/core/services/storage/user_session_storage.dart';
import 'package:venue_connect/features/auth/presentation/pages/login_screen.dart';
import 'package:venue_connect/features/auth/presentation/view_model/user_viewmodel.dart';
import 'package:venue_connect/features/dashboard/presentation/pages/bottom_screen/profile_screen.dart';

class FakeUserViewmodel extends UserViewmodel {
  bool logoutCalled = false;

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override
  build() => super.build();
}

void main() {
  late FakeUserViewmodel fakeUserVm;

  Future<void> pumpProfile(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_full_name', 'John Doe');
    await prefs.setString('user_email', 'john@email.com');
    await prefs.setString('user_profile_picture', '');

    fakeUserVm = FakeUserViewmodel();

    final view = tester.view;
    view.physicalSize = const Size(1200, 2400);
    view.devicePixelRatio = 1.0;

    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    final oldOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final msg = details.exceptionAsString();
      if (msg.contains('A RenderFlex overflowed by') ||
          (msg.contains('RenderFlex') && msg.contains('OVERFLOWING'))) {
        return;
      }
      oldOnError?.call(details);
    };

    addTearDown(() {
      FlutterError.onError = oldOnError;
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),

          userViewmodelProvider.overrideWith(() => fakeUserVm),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.pumpAndSettle();
  }

  Future<void> scrollToLogoutButton(WidgetTester tester) async {
    final logoutButton = find.widgetWithText(ElevatedButton, 'Logout');

    await tester.scrollUntilVisible(
      logoutButton,
      300,
      scrollable: find.byType(Scrollable),
    );

    await tester.pumpAndSettle();
  }

  group('ProfileScreen UI', () {
    testWidgets('should show user name, email and logout button', (
      tester,
    ) async {
      await pumpProfile(tester);

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.textContaining('john@email.com'), findsOneWidget);

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);

      await scrollToLogoutButton(tester);
      expect(find.widgetWithText(ElevatedButton, 'Logout'), findsOneWidget);
    });
  });

  group('ProfileScreen Logout dialog', () {
    testWidgets('should open logout confirmation dialog', (tester) async {
      await pumpProfile(tester);

      await scrollToLogoutButton(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
      await tester.pumpAndSettle();

      expect(find.text('Logout'), findsWidgets); // title + button text
      expect(find.text('Are you sure you want to logout?'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Logout'), findsWidgets);
    });

    testWidgets('should close dialog when pressing Cancel', (tester) async {
      await pumpProfile(tester);

      await scrollToLogoutButton(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to logout?'), findsNothing);
    });

    testWidgets('should call logout when pressing Logout in dialog', (
      tester,
    ) async {
      await pumpProfile(tester);

      await scrollToLogoutButton(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Logout'));
      await tester.pumpAndSettle();

      expect(fakeUserVm.logoutCalled, isTrue);
    });

    testWidgets('should navigate to LoginScreen after logout', (tester) async {
      await pumpProfile(tester);

      await scrollToLogoutButton(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Logout'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
