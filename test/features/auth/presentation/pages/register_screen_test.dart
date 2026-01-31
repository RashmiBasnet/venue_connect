import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/widgets/my_textform_field.dart';
import 'package:venue_connect/features/auth/presentation/pages/register_screen.dart';
import 'package:venue_connect/features/auth/presentation/pages/login_screen.dart';
import 'package:venue_connect/features/auth/presentation/state/user_state.dart';
import 'package:venue_connect/features/auth/presentation/view_model/user_viewmodel.dart';
import 'package:venue_connect/features/auth/domain/usecases/register_usecase.dart';
import 'package:venue_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:venue_connect/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:venue_connect/features/auth/domain/usecases/logout_usecase.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class FakeUserViewmodel extends UserViewmodel {
  @override
  UserState build() => const UserState();

  int registerCalled = 0;

  String? lastFullName;
  String? lastEmail;
  String? lastPassword;
  String? lastConfirmPassword;

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    registerCalled++;
    lastFullName = fullName;
    lastEmail = email;
    lastPassword = password;
    lastConfirmPassword = confirmPassword;
  }
}

void main() {
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;
  late MockLogoutUsecase mockLogoutUsecase;

  setUpAll(() {
    registerFallbackValue(
      const RegisterUsecaseParams(
        fullName: 'fallback',
        email: 'fallback@email.com',
        password: 'fallback',
        confirmPassword: 'fallback',
      ),
    );

    registerFallbackValue(
      const LoginUsecaseParams(
        email: 'fallback@email.com',
        password: 'fallback',
      ),
    );
  });

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
  });

  Future<void> pumpRegister(WidgetTester tester) async {
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
          registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
          loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
          getCurrentUserUsecaseProvider.overrideWithValue(
            mockGetCurrentUserUsecase,
          ),
          logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),

          userViewmodelProvider.overrideWith(FakeUserViewmodel.new),
        ],
        child: const MaterialApp(home: Scaffold(body: RegisterScreen())),
      ),
    );

    await tester.pumpAndSettle();
  }

  group('RegisterScreen UI Elements', () {
    testWidgets('should display Create Account button', (tester) async {
      await pumpRegister(tester);
      expect(
        find.widgetWithText(ElevatedButton, 'Create Account'),
        findsOneWidget,
      );
    });

    testWidgets('should display multiple input fields', (tester) async {
      await pumpRegister(tester);
      expect(find.byType(MyTextFormField), findsWidgets);
    });

    testWidgets('should display password visibility icons', (tester) async {
      await pumpRegister(tester);
      expect(find.byIcon(Icons.visibility_off), findsWidgets);
    });

    testWidgets('should display back button', (tester) async {
      await pumpRegister(tester);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should display Login text link', (tester) async {
      await pumpRegister(tester);
      expect(find.text('Login'), findsOneWidget);
    });
  });

  group('RegisterScreen Form Validation', () {
    testWidgets('should show error for empty full name', (tester) async {
      await pumpRegister(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your full name'), findsOneWidget);
    });

    testWidgets('should show error for empty email', (tester) async {
      await pumpRegister(tester);

      await tester.enterText(find.byType(MyTextFormField).at(0), 'John Doe');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('should show error for invalid email format', (tester) async {
      await pumpRegister(tester);

      await tester.enterText(find.byType(MyTextFormField).at(0), 'John Doe');
      await tester.enterText(
        find.byType(MyTextFormField).at(1),
        'invalid-email',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should show error for password < 6 chars', (tester) async {
      await pumpRegister(tester);

      await tester.enterText(find.byType(MyTextFormField).at(0), 'John Doe');
      await tester.enterText(
        find.byType(MyTextFormField).at(1),
        'john@email.com',
      );
      await tester.enterText(find.byType(MyTextFormField).at(2), '123');
      await tester.enterText(find.byType(MyTextFormField).at(3), '123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets('should show error when confirm password does not match', (
      tester,
    ) async {
      await pumpRegister(tester);

      await tester.enterText(find.byType(MyTextFormField).at(0), 'John Doe');
      await tester.enterText(
        find.byType(MyTextFormField).at(1),
        'john@email.com',
      );
      await tester.enterText(find.byType(MyTextFormField).at(2), '123456');
      await tester.enterText(find.byType(MyTextFormField).at(3), '654321');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Password do not match'), findsOneWidget);
    });

    testWidgets('should allow text entry in full name field', (tester) async {
      await pumpRegister(tester);

      await tester.enterText(find.byType(MyTextFormField).at(0), 'John Doe');
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('should call register on viewmodel when form is valid', (
      tester,
    ) async {
      await pumpRegister(tester);

      final fullNameField = find.byType(TextFormField).at(0);
      final emailField = find.byType(TextFormField).at(1);
      final passwordField = find.byType(TextFormField).at(2);
      final confirmPasswordField = find.byType(TextFormField).at(3);

      await tester.enterText(fullNameField, 'John Doe');
      await tester.enterText(emailField, 'john@email.com');
      await tester.enterText(passwordField, '123456');
      await tester.enterText(confirmPasswordField, '123456');

      final createBtn = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.ensureVisible(createBtn);

      await tester.tap(createBtn);
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(RegisterScreen)),
      );
      final vm =
          container.read(userViewmodelProvider.notifier) as FakeUserViewmodel;

      expect(vm.registerCalled, 1);
      expect(vm.lastFullName, 'John Doe');
      expect(vm.lastEmail, 'john@email.com');
      expect(vm.lastPassword, '123456');
      expect(vm.lastConfirmPassword, '123456');
    });
  });

  group('RegisterScreen Navigation', () {
    testWidgets('tapping Login navigates to LoginScreen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userViewmodelProvider.overrideWith(FakeUserViewmodel.new),
          ],
          child: const MaterialApp(home: RegisterScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
