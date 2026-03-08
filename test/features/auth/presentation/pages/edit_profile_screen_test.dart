import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venue_connect/core/services/storage/user_session_storage.dart';
import 'package:venue_connect/features/auth/domain/entities/user_entity.dart';
import 'package:venue_connect/features/auth/presentation/pages/edit_profile_screen.dart';
import 'package:venue_connect/features/auth/presentation/state/user_state.dart';
import 'package:venue_connect/features/auth/presentation/view_model/user_viewmodel.dart';

class FakeUserViewmodel extends UserViewmodel {
  bool updateCalled = false;
  bool updateResult = true;
  String? lastFullName;
  String? lastEmail;

  @override
  UserState build() => const UserState();

  @override
  Future<bool> updateProfile({
    required String fullName,
    required String email,
  }) async {
    updateCalled = true;
    lastFullName = fullName;
    lastEmail = email;

    if (updateResult) {
      state = state.copyWith(
        status: UserStatus.loaded,
        userEntity: UserEntity(fullName: fullName, email: email),
      );
      return true;
    }

    state = state.copyWith(
      status: UserStatus.error,
      errorMessage: 'Profile update failed',
    );
    return false;
  }
}

void main() {
  late FakeUserViewmodel fakeUserVm;

  Future<void> pumpEditProfile(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_full_name', 'John Doe');
    await prefs.setString('user_email', 'john@email.com');

    fakeUserVm = FakeUserViewmodel();

    final view = tester.view;
    view.physicalSize = const Size(1200, 2400);
    view.devicePixelRatio = 1.0;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          userViewmodelProvider.overrideWith(() => fakeUserVm),
        ],
        child: const MaterialApp(home: EditProfileScreen()),
      ),
    );

    await tester.pumpAndSettle();
  }

  group('EditProfileScreen UI', () {
    testWidgets('should show title and prefilled fields', (tester) async {
      await pumpEditProfile(tester);

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@email.com'), findsOneWidget);
    });

    testWidgets('should show full name validation error when empty', (
      tester,
    ) async {
      await pumpEditProfile(tester);

      await tester.enterText(find.byType(TextFormField).at(0), '');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your full name'), findsOneWidget);
    });

    testWidgets('should show email validation error when invalid', (
      tester,
    ) async {
      await pumpEditProfile(tester);

      await tester.enterText(find.byType(TextFormField).at(1), 'invalid-email');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });
  });

  group('EditProfileScreen Submit', () {
    testWidgets('should call updateProfile when form is valid', (tester) async {
      await pumpEditProfile(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'Jane Doe');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'jane@email.com',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(fakeUserVm.updateCalled, isTrue);
      expect(fakeUserVm.lastFullName, 'Jane Doe');
      expect(fakeUserVm.lastEmail, 'jane@email.com');
    });

    testWidgets('should show error snackbar when update fails', (tester) async {
      await pumpEditProfile(tester);
      fakeUserVm.updateResult = false;

      await tester.enterText(find.byType(TextFormField).at(0), 'Jane Doe');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'jane@email.com',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Profile update failed'), findsOneWidget);
    });
  });
}
