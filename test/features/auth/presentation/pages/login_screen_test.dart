import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/auth/domain/entities/user_entity.dart';
import 'package:venue_connect/features/auth/domain/repositories/user_repository.dart';
import 'package:venue_connect/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements IUserRepository {}

void main() {
  late LoginUsecase usecase;
  late IUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockAuthRepository();
    usecase = LoginUsecase(userRepository: mockUserRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      LoginUsecaseParams(
        email: "fallback email",
        password: "fallback password",
      ),
    );
  });

  const tEmail = "test@email.com";
  const tPassword = "password123";

  const tUser = UserEntity(fullName: "Test User", email: tEmail);

  group('Login Usecase', () {
    test('Should return UserEntity when Login is successful', () async {
      // Arrange
      when(
        () => mockUserRepository.login(tEmail, tPassword),
      ).thenAnswer((_) async => const Right(tUser));

      // Act
      final result = await usecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Right(tUser));
      verify(() => mockUserRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    });

    test('Should return failure when Login fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Invalid credentials');
      when(
        () => mockUserRepository.login(tEmail, tPassword),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockUserRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    });

    test('Should pass correct email and password to repository', () async {
      // Arrange
      when(
        () => mockUserRepository.login(any(), any()),
      ).thenAnswer((_) async => const Right(tUser));

      // Act
      await usecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      // Assert
      verify(() => mockUserRepository.login(tEmail, tPassword)).called(1);
    });

    test(
      'Should succeed with correct credentials and fail with wrong credentials',
      () async {
        // Arrange
        const wrongEmail = 'wrong@example.com';
        const wrongPassword = 'wrongpassword';
        const failure = ApiFailure(message: 'Invalid credentials');

        // Mock: check credentials using if condition
        when(() => mockUserRepository.login(any(), any())).thenAnswer((
          invocation,
        ) async {
          final email = invocation.positionalArguments[0] as String;
          final password = invocation.positionalArguments[1] as String;

          // If email and password are correct, return success
          if (email == tEmail && password == tPassword) {
            return const Right(tUser);
          }
          // Otherwise return failure
          return const Left(failure);
        });

        // Act & Assert - Correct credentials should succeed
        final successResult = await usecase(
          const LoginUsecaseParams(email: tEmail, password: tPassword),
        );
        expect(successResult, const Right(tUser));

        // Act & Assert - Wrong email should fail
        final wrongEmailResult = await usecase(
          const LoginUsecaseParams(email: wrongEmail, password: tPassword),
        );
        expect(wrongEmailResult, const Left(failure));

        // Act & Assert - Wrong password should fail
        final wrongPasswordResult = await usecase(
          const LoginUsecaseParams(email: tEmail, password: wrongPassword),
        );
        expect(wrongPasswordResult, const Left(failure));
      },
    );
  });

  group('Login Usecase Params', () {
    test('Should have correct props', () {
      // Arrange
      const params = LoginUsecaseParams(email: tEmail, password: tPassword);

      // Assert
      expect(params.props, [tEmail, tPassword]);
    });

    test('Two params with same values should be equal', () {
      // Arrange
      const params1 = LoginUsecaseParams(email: tEmail, password: tPassword);
      const params2 = LoginUsecaseParams(email: tEmail, password: tPassword);

      // Assert
      expect(params1, params2);
    });

    test('Two params with different values should not be equal', () {
      // Arrange
      const params1 = LoginUsecaseParams(email: tEmail, password: tPassword);
      const params2 = LoginUsecaseParams(
        email: 'other@email.com',
        password: tPassword,
      );

      // Assert
      expect(params1, isNot(params2));
    });
  });
}
