import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/auth/domain/entities/user_entity.dart';
import 'package:venue_connect/features/auth/domain/repositories/user_repository.dart';
import 'package:venue_connect/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements IUserRepository {}

void main() {
  late RegisterUsecase usecase;
  late IUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockAuthRepository();
    usecase = RegisterUsecase(userRepository: mockUserRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      UserEntity(fullName: "fallback fullName", email: "fallback email"),
    );
  });

  const tFullName = 'Test User';
  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tConfirmPassword = 'password123';

  group("Register Usecase", () {
    test("Should return true when registration is successful", () async {
      // Arrange
      when(
        () => mockUserRepository.register(any()),
      ).thenAnswer((_) async => Right(true));

      // Act
      final result = await usecase(
        RegisterUsecaseParams(
          fullName: tFullName,
          email: tEmail,
          password: tPassword,
          confirmPassword: tConfirmPassword,
        ),
      );

      // Assert
      expect(result, Right(true));

      // Verify
      verify(() => mockUserRepository.register(any())).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    });

    test('Should pass UserEntity with correct values to repository', () async {
      // Arrange
      UserEntity? capturedEntity;
      when(() => mockUserRepository.register(any())).thenAnswer((invocation) {
        capturedEntity = invocation.positionalArguments[0] as UserEntity;
        return Future.value(const Right(true));
      });

      // Act
      await usecase(
        const RegisterUsecaseParams(
          fullName: tFullName,
          email: tEmail,
          password: tPassword,
          confirmPassword: tConfirmPassword,
        ),
      );

      // Assert
      expect(capturedEntity?.fullName, tFullName);
      expect(capturedEntity?.email, tEmail);
      expect(capturedEntity?.password, tPassword);
      expect(capturedEntity?.confirmPassword, tConfirmPassword);
    });

    test('Should return failure when registration fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Email already exists');
      when(
        () => mockUserRepository.register(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const RegisterUsecaseParams(
          fullName: tFullName,
          email: tEmail,
          password: tPassword,
          confirmPassword: tConfirmPassword,
        ),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockUserRepository.register(any())).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    });
  });

  group('Register Usecase Params', () {
    test('Should have correct props with all values', () {
      // Arrange
      const params = RegisterUsecaseParams(
        fullName: tFullName,
        email: tEmail,
        password: tPassword,
        confirmPassword: tConfirmPassword,
      );

      // Assert
      expect(params.props, [tFullName, tEmail, tPassword, tConfirmPassword]);
    });

    test('Should have correct props with optional values as null', () {
      // Arrange
      const params = RegisterUsecaseParams(
        fullName: tFullName,
        email: tEmail,
        password: tPassword,
        confirmPassword: tConfirmPassword,
      );

      // Assert
      expect(params.props, [tFullName, tEmail, tPassword, tConfirmPassword]);
    });

    test('two params with same values should be equal', () {
      // Arrange
      const params1 = RegisterUsecaseParams(
        fullName: tFullName,
        email: tEmail,
        password: tPassword,
        confirmPassword: tConfirmPassword,
      );
      const params2 = RegisterUsecaseParams(
        fullName: tFullName,
        email: tEmail,
        password: tPassword,
        confirmPassword: tConfirmPassword,
      );

      // Assert
      expect(params1, params2);
    });
  });
}
