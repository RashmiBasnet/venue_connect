import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/auth/domain/entities/user_entity.dart';
import 'package:venue_connect/features/auth/domain/repositories/user_repository.dart';
import 'package:venue_connect/features/auth/domain/usecases/update_profile_usecase.dart';

class MockAuthRepository extends Mock implements IUserRepository {}

void main() {
  late UpdateProfileUsecase usecase;
  late IUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockAuthRepository();
    usecase = UpdateProfileUsecase(userRepository: mockUserRepository);
  });

  const tFullName = 'Updated User';
  const tEmail = 'updated@email.com';
  const tUser = UserEntity(fullName: tFullName, email: tEmail);

  group('UpdateProfile Usecase', () {
    test(
      'Should return UserEntity when profile update is successful',
      () async {
        // Arrange
        when(
          () => mockUserRepository.updateProfile(
            fullName: tFullName,
            email: tEmail,
          ),
        ).thenAnswer((_) async => const Right(tUser));

        // Act
        final result = await usecase(
          const UpdateProfileUsecaseParams(fullName: tFullName, email: tEmail),
        );

        // Assert
        expect(result, const Right(tUser));
        verify(
          () => mockUserRepository.updateProfile(
            fullName: tFullName,
            email: tEmail,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockUserRepository);
      },
    );

    test('Should return failure when profile update fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Profile update failed');
      when(
        () => mockUserRepository.updateProfile(
          fullName: tFullName,
          email: tEmail,
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const UpdateProfileUsecaseParams(fullName: tFullName, email: tEmail),
      );

      // Assert
      expect(result, const Left(failure));
      verify(
        () => mockUserRepository.updateProfile(
          fullName: tFullName,
          email: tEmail,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    });
  });

  group('UpdateProfile Usecase Params', () {
    test('Should have correct props', () {
      const params = UpdateProfileUsecaseParams(
        fullName: tFullName,
        email: tEmail,
      );
      expect(params.props, [tFullName, tEmail]);
    });

    test('Two params with same values should be equal', () {
      const params1 = UpdateProfileUsecaseParams(
        fullName: tFullName,
        email: tEmail,
      );
      const params2 = UpdateProfileUsecaseParams(
        fullName: tFullName,
        email: tEmail,
      );
      expect(params1, params2);
    });
  });
}
