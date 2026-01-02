import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/features/auth/domain/usecases/login_usecase.dart';
import 'package:venue_connect/features/auth/domain/usecases/register_usecase.dart';
import 'package:venue_connect/features/auth/presentation/state/user_state.dart';

final userViewmodelProvider = NotifierProvider<UserViewmodel, UserState>(() => UserViewmodel());

class UserViewmodel extends Notifier<UserState>{
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  
  @override
  UserState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    return UserState();
  } 

  // Register
  Future<void> register({required String fullName, required String email, required String password}) async {
    state = state.copyWith(status: UserStatus.loading);
    final params = RegisterUsecaseParams(
      fullName: fullName,
      email: email,
      password: password,
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
        if(isRegistered){
          state = state.copyWith(status: UserStatus.registerd);
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
    final params = LoginUsecaseParams(
      email: email,
      password: password,
    );
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
}