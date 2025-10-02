import 'package:flutter/foundation.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final String? verificationId; // e.g., OTP session ID from backend

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.verificationId,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? verificationId,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      verificationId: verificationId ?? this.verificationId,
    );
  }
}
