import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venue_connect/core/error/failures.dart';
import 'package:venue_connect/features/auth/domain/repositories/user_repository.dart';
import 'package:venue_connect/features/auth/domain/usecases/upload_profile_picture_usecase.dart';

class MockAuthRepository extends Mock implements IUserRepository {}

void main() {
  late UploadProfilePictureUsecase usecase;
  late IUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockAuthRepository();
    usecase = UploadProfilePictureUsecase(userRepository: mockUserRepository);
  });

  setUpAll(() {
    registerFallbackValue(File('fallback'));
  });

  final tFile = File('test/assets/profile.jpg');

  group('UploadProfilePicture Usecase', () {
    test('Should return filename when upload is successful', () async {
      // Arrange
      when(
        () => mockUserRepository.uploadProfilePicture(any()),
      ).thenAnswer((_) async => const Right('uploaded.jpg'));

      // Act
      final result = await usecase(UploadProfilePictureParams(image: tFile));

      // Assert
      expect(result, const Right('uploaded.jpg'));
      verify(() => mockUserRepository.uploadProfilePicture(tFile)).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    });

    test('Should return failure when upload fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Upload failed');
      when(
        () => mockUserRepository.uploadProfilePicture(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(UploadProfilePictureParams(image: tFile));

      // Assert
      expect(result, const Left(failure));
      verify(() => mockUserRepository.uploadProfilePicture(tFile)).called(1);
      verifyNoMoreInteractions(mockUserRepository);
    });

    test('Should pass correct File to repository', () async {
      // Arrange
      File? captured;
      when(() => mockUserRepository.uploadProfilePicture(any())).thenAnswer((
        invocation,
      ) async {
        captured = invocation.positionalArguments[0] as File;
        return const Right('uploaded.jpg');
      });

      // Act
      await usecase(UploadProfilePictureParams(image: tFile));

      // Assert
      expect(captured?.path, tFile.path);
    });
  });
}
