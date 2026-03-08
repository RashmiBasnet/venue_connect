import 'dart:io';

import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/core/services/sensors/biometric_service.dart';
import 'package:venue_connect/core/services/storage/biometric_shared_prefs.dart';
import 'package:venue_connect/core/services/storage/token_service.dart';
import 'package:venue_connect/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:venue_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:venue_connect/features/auth/domain/usecases/logout_usecase.dart';
import 'package:venue_connect/features/auth/domain/usecases/register_usecase.dart';
import 'package:venue_connect/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:venue_connect/features/auth/domain/usecases/upload_profile_picture_usecase.dart';
import 'package:venue_connect/features/auth/presentation/state/user_state.dart';

final userViewmodelProvider = NotifierProvider<UserViewmodel, UserState>(
  () => UserViewmodel(),
);

class UserViewmodel extends Notifier<UserState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  late final UpdateProfileUsecase _updateProfileUsecase;
  late final UploadProfilePictureUsecase _uploadProfilePictureUsecase;
  late final BiometricService _biometricService;
  late final BiometricPrefService _biometricPrefService;
  late final TokenService _tokenService;

  @override
  UserState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _updateProfileUsecase = ref.read(updateProfileUsecaseProvider);
    _uploadProfilePictureUsecase = ref.read(
      uploadProfilePictureUsecaseProvider,
    );
    _biometricService = ref.read(biometricServiceProvider);
    _biometricPrefService = ref.read(biometricPrefServiceProvider);
    _tokenService = ref.read(tokenServiceProvider);
    Future.microtask(_initBiometrics);
    return UserState();
  }

  Future<void> _initBiometrics() async {
    try {
      final available = await _biometricService.canCheck();
      final enabled = _biometricPrefService.isEnabled();
      state = state.copyWith(
        biometricAvailable: available,
        biometricEnabled: enabled && available,
      );
    } catch (_) {
      state = state.copyWith(
        biometricAvailable: false,
        biometricEnabled: false,
      );
    }
  }

  // Register
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: UserStatus.loading);
    final params = RegisterUsecaseParams(
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    final result = await _registerUsecase(params);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: UserStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered) {
        if (isRegistered) {
          state = state.copyWith(status: UserStatus.registered);
        } else {
          state = state.copyWith(
            status: UserStatus.error,
            errorMessage: "Registration failed",
          );
        }
      },
    );
  }

  // Login
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: UserStatus.loading);
    final params = LoginUsecaseParams(email: email, password: password);
    final result = await _loginUsecase(params);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: UserStatus.error,
          errorMessage: failure.message,
        );
      },
      (userEntity) {
        state = state.copyWith(
          status: UserStatus.authenticated,
          userEntity: userEntity,
        );
      },
    );
  }

  // Logout
  Future<void> logout() async {
    final result = await _logoutUsecase();
    result.fold(
      (failure) => state = state.copyWith(
        status: UserStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: UserStatus.unauthenticated,
        userEntity: null,
      ),
    );
  }

  // Upload Profile Picture
  Future<void> uploadProfilePicture(File image) async {
    state = state.copyWith(status: UserStatus.loading);
    final result = await _uploadProfilePictureUsecase(
      UploadProfilePictureParams(image: image),
    );
    result.fold(
      (failure) {
        state = state.copyWith(
          status: UserStatus.error,
          errorMessage: failure.message,
        );
      },
      (imageName) {
        state = state.copyWith(
          status: UserStatus.loaded,
          profilePictureName: imageName,
        );
      },
    );
  }

  // Get Current User
  Future<void> getCurrentUser() async {
    state = state.copyWith(status: UserStatus.loading);
    final result = await _getCurrentUserUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: UserStatus.error,
          errorMessage: failure.message,
        );
      },
      (entity) {
        state = state.copyWith(status: UserStatus.loaded, userEntity: entity);
      },
    );
  }

  Future<bool> updateProfile({
    required String fullName,
    required String email,
  }) async {
    state = state.copyWith(status: UserStatus.loading, clearError: true);
    final result = await _updateProfileUsecase(
      UpdateProfileUsecaseParams(fullName: fullName, email: email),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: UserStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (entity) {
        state = state.copyWith(status: UserStatus.loaded, userEntity: entity);
        return true;
      },
    );
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final available = await _biometricService.canCheck();

    // If device can't do biometrics, don't allow enabling.
    if (enabled && !available) {
      await _biometricPrefService.setEnabled(false);
      state = state.copyWith(
        biometricAvailable: false,
        biometricEnabled: false,
        status: UserStatus.error,
        errorMessage:
            "Biometrics not ready. Enable fingerprint/face lock in phone settings and try again.",
      );
      return;
    }

    // Do not require biometric prompt here; authenticate during login flow.
    await _biometricPrefService.setEnabled(enabled);
    state = state.copyWith(
      biometricAvailable: available,
      biometricEnabled: enabled,
      clearError: true,
    );
  }

  Future<bool> loginWithBiometrics() async {
    state = state.copyWith(biometricLoading: true, clearError: true);

    if (!state.biometricAvailable) {
      state = state.copyWith(
        biometricLoading: false,
        status: UserStatus.error,
        errorMessage:
            "Biometrics not ready. Enable fingerprint/face lock in phone settings and try again.",
      );
      return false;
    }

    if (!state.biometricEnabled) {
      state = state.copyWith(
        biometricLoading: false,
        status: UserStatus.error,
        errorMessage: "Enable biometric login in Profile settings first",
      );
      return false;
    }

    final ok = await _biometricService.authenticate();
    if (!ok) {
      final code = _biometricService.lastExceptionCode;
      final available = await _biometricService.canCheck();
      if (!available) {
        await _biometricPrefService.setEnabled(false);
      }
      state = state.copyWith(
        biometricAvailable: available,
        biometricEnabled: available ? state.biometricEnabled : false,
        biometricLoading: false,
        status: UserStatus.error,
        errorMessage: !available
            ? "Biometrics are currently unavailable on this device"
            : code == LocalAuthExceptionCode.uiUnavailable
            ? "Biometric prompt unavailable right now. Try again in a moment."
            : "Fingerprint authentication failed",
      );
      return false;
    }

    // Require previously saved token from password login.
    final token = _tokenService.getToken();
    if (token == null || token.trim().isEmpty) {
      state = state.copyWith(
        biometricLoading: false,
        status: UserStatus.error,
        errorMessage: "No saved session. Please login with password once.",
      );
      return false;
    }

    // Validate token + fetch latest user profile.
    final result = await _getCurrentUserUsecase();
    return result.fold(
      (failure) {
        state = state.copyWith(
          biometricLoading: false,
          status: UserStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (entity) {
        state = state.copyWith(
          biometricLoading: false,
          status: UserStatus.authenticated,
          userEntity: entity,
        );
        return true;
      },
    );
  }
}
