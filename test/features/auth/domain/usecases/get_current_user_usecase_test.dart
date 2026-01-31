import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/auth/domain/entities/user_entity.dart';
import 'package:venue_connect/features/auth/domain/repositories/user_repository.dart';
import 'package:venue_connect/features/auth/domain/usecases/get_current_user_usecase.dart';

class MockUserRepository extends Mock implements IUserRepository {}

void main() {
  late GetCurrentUserUsecase usecase;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    usecase = GetCurrentUserUsecase(userRepository: mockUserRepository);
  });

  group('GetCurrentUserUsecase', () {
    test('should return Right(UserEntity) when repo returns user', () async {
      // arrange
      final user = UserEntity(
        userId: '1',
        fullName: 'Test User',
        email: 'test@mail.com',
        password: '123456',
      );

      when(
        () => mockUserRepository.getCurrentUser(),
      ).thenAnswer((_) async => Right(user));

      // act
      final result = await usecase();

      // assert
      expect(result, Right(user));
      verify(() => mockUserRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    });

    test('should return Left(Failure) when repo returns failure', () async {
      // arrange
      final failure = ApiFailure(message: 'User not found');

      when(
        () => mockUserRepository.getCurrentUser(),
      ).thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase();

      // assert
      expect(result, Left(failure));
      verify(() => mockUserRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    });
  });
}
