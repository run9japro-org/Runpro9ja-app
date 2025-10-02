import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth_state.dart';

class LoginNotifier extends StateNotifier<AuthState>{
  LoginNotifier():super(AuthState());

  void emailChange(String email){
    state = state.copyWith(email: email);
  }
  void passwordChange(String password){
    state = state.copyWith(password: password);
  }
}

var LoginNotifierProvider =
StateNotifierProvider<LoginNotifier, AuthState>(
      (ref) => LoginNotifier(),
);