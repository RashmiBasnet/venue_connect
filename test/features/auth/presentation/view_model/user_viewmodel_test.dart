import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/core/services/sensors/biometric_service.dart';
import 'package:venue_connect/core/services/storage/biometric_shared_prefs.dart';
import 'package:venue_connect/core/services/storage/token_service.dart';
import 'package:venue_connect/features/auth/domain/entities/user_entity.dart';
import 'package:venue_connect/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:venue_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:venue_connect/features/auth/domain/usecases/logout_usecase.dart';
import 'package:venue_connect/features/auth/domain/usecases/register_usecase.dart';
import 'package:venue_connect/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:venue_connect/features/auth/domain/usecases/upload_profile_picture_usecase.dart';
import 'package:venue_connect/features/auth/presentation/state/user_state.dart';
import 'package:venue_connect/features/auth/presentation/view_model/user_viewmodel.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

class MockUpdateProfileUsecase extends Mock implements UpdateProfileUsecase {}

class MockUploadProfilePictureUsecase extends Mock
    implements UploadProfilePictureUsecase {}

class MockBiometricService extends Mock implements BiometricService {}

class MockBiometricPrefService extends Mock implements BiometricPrefService {}

class MockTokenService extends Mock implements TokenService {}

void main() {
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;
  late MockUpdateProfileUsecase mockUpdateProfileUsecase;
  late MockUploadProfilePictureUsecase mockUploadProfilePictureUsecase;
  late MockBiometricService mockBiometricService;
  late MockBiometricPrefService mockBiometricPrefService;
  late MockTokenService mockTokenService;

  setUpAll(() {
    registerFallbackValue(
      const RegisterUsecaseParams(
        fullName: 'fallback',
        email: 'fallback@email.com',
        password: 'password',
        confirmPassword: 'password',
      ),
    );
    registerFallbackValue(
      const LoginUsecaseParams(
        email: 'fallback@email.com',
        password: 'password',
      ),
    );
    registerFallbackValue(
      const UpdateProfileUsecaseParams(
        fullName: 'fallback',
        email: 'fallback@email.com',
      ),
    );
  });

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
    mockUpdateProfileUsecase = MockUpdateProfileUsecase();
    mockUploadProfilePictureUsecase = MockUploadProfilePictureUsecase();
    mockBiometricService = MockBiometricService();
    mockBiometricPrefService = MockBiometricPrefService();
    mockTokenService = MockTokenService();

    when(() => mockBiometricService.canCheck()).thenAnswer((_) async => false);
    when(() => mockBiometricPrefService.isEnabled()).thenReturn(false);
    when(
      () => mockBiometricPrefService.setEnabled(any()),
    ).thenAnswer((_) async {});
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
        getCurrentUserUsecaseProvider.overrideWithValue(
          mockGetCurrentUserUsecase,
        ),
        updateProfileUsecaseProvider.overrideWithValue(
          mockUpdateProfileUsecase,
        ),
        uploadProfilePictureUsecaseProvider.overrideWithValue(
          mockUploadProfilePictureUsecase,
        ),
        biometricServiceProvider.overrideWithValue(mockBiometricService),
        biometricPrefServiceProvider.overrideWithValue(
          mockBiometricPrefService,
        ),
        tokenServiceProvider.overrideWithValue(mockTokenService),
      ],
    );
  }

  const tUser = UserEntity(fullName: 'Test User', email: 'test@email.com');

  group('UserViewmodel', () {
    test('login should set authenticated state on success', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Right(tUser));

      await container
          .read(userViewmodelProvider.notifier)
          .login(email: tUser.email, password: 'password');

      final state = container.read(userViewmodelProvider);
      expect(state.status, UserStatus.authenticated);
      expect(state.userEntity, tUser);
    });

    test('logout should set unauthenticated state on success', () async {
      final container = createContainer();
      addTearDown(container.dispose);
      when(
        () => mockLogoutUsecase(),
      ).thenAnswer((_) async => const Right(true));

      await container.read(userViewmodelProvider.notifier).logout();

      final state = container.read(userViewmodelProvider);
      expect(state.status, UserStatus.unauthenticated);
      expect(state.userEntity, isNull);
    });

    test(
      'updateProfile should return true and set loaded state on success',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);
        const updatedUser = UserEntity(
          fullName: 'Updated User',
          email: 'updated@email.com',
        );
        when(
          () => mockUpdateProfileUsecase(any()),
        ).thenAnswer((_) async => const Right(updatedUser));

        final result = await container
            .read(userViewmodelProvider.notifier)
            .updateProfile(
              fullName: updatedUser.fullName,
              email: updatedUser.email,
            );

        final state = container.read(userViewmodelProvider);
        expect(result, isTrue);
        expect(state.status, UserStatus.loaded);
        expect(state.userEntity, updatedUser);
      },
    );

    test(
      'updateProfile should return false and set error state on failure',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);
        const failure = ApiFailure(message: 'Profile update failed');
        when(
          () => mockUpdateProfileUsecase(any()),
        ).thenAnswer((_) async => const Left(failure));

        final result = await container
            .read(userViewmodelProvider.notifier)
            .updateProfile(
              fullName: 'Updated User',
              email: 'updated@email.com',
            );

        final state = container.read(userViewmodelProvider);
        expect(result, isFalse);
        expect(state.status, UserStatus.error);
        expect(state.errorMessage, failure.message);
      },
    );

    test(
      'setBiometricEnabled should set error when enabling on unavailable device',
      () async {
        final container = createContainer();
        addTearDown(container.dispose);
        when(
          () => mockBiometricService.canCheck(),
        ).thenAnswer((_) async => false);

        await container
            .read(userViewmodelProvider.notifier)
            .setBiometricEnabled(true);

        final state = container.read(userViewmodelProvider);
        expect(state.status, UserStatus.error);
        expect(state.biometricEnabled, isFalse);
        verify(() => mockBiometricPrefService.setEnabled(false)).called(1);
      },
    );
  });
}
