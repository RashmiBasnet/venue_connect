import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/auth/domain/repositories/user_repository.dart';
import 'package:venue_connect/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements IUserRepository {}

void main() {
  late LogoutUsecase usecase;
  late IUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockAuthRepository();
    usecase = LogoutUsecase(userRepository: mockUserRepository);
  });

  group('Logout Usecase', () {
    test('Should return true when logout is successful', () async {
      // Arrange
      when(
        () => mockUserRepository.logout(),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(true));
      verify(() => mockUserRepository.logout()).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    });

    test('Should return failure when logout fails', () async {
      // Arrange
      const failure = LocalDatabaseFailure(message: 'Logout failed');
      when(
        () => mockUserRepository.logout(),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(failure));
      verify(() => mockUserRepository.logout()).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    });
  });
}
