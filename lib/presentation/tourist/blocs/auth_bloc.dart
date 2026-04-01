import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/auth_repository.dart';

// ─────────────────────────────────────────────
// Events
// ─────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginWithEmail extends AuthEvent {
  final String email;
  final String password;
  const LoginWithEmail(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class LoginWithGoogle extends AuthEvent {}

/// Full sign-up with profile information
class SignUpWithProfile extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String phone;
  final String dateOfBirth;
  final String accountType; // 'tourist' | 'provider'

  const SignUpWithProfile({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
    required this.dateOfBirth,
    required this.accountType,
  });

  @override
  List<Object?> get props =>
      [email, password, fullName, phone, dateOfBirth, accountType];
}

class Logout extends AuthEvent {}

class SendPasswordReset extends AuthEvent {
  final String email;
  const SendPasswordReset(this.email);
  @override
  List<Object?> get props => [email];
}

// ─────────────────────────────────────────────
// States
// ─────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final String accountType;
  const AuthAuthenticated(this.user, {this.accountType = 'tourist'});
  @override
  List<Object?> get props => [user, accountType];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}


class PasswordResetSent extends AuthState {
  final String email;
  const PasswordResetSent(this.email);
  @override
  List<Object?> get props => [email];
}

class EmailVerificationSent extends AuthState {
  final String email;
  const EmailVerificationSent(this.email);
  @override
  List<Object?> get props => [email];
}

// ─────────────────────────────────────────────
// BLoC
// ─────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc({required AuthRepository authRepository})
      : _repo = authRepository,
        super(AuthInitial()) {
    on<LoginWithEmail>(_onLoginWithEmail);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<SignUpWithProfile>(_onSignUpWithProfile);
    on<Logout>(_onLogout);
    on<SendPasswordReset>(_onSendPasswordReset);
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user =
          await _repo.signInWithEmail(event.email, event.password);
      if (user != null) {
        // Automatically block login if email is not verified
        if (!user.emailVerified) {
          await _repo.signOut();
          emit(const AuthError(
            'Email not verified. Please check your inbox for verification link.'
            ));
          return;
        }

        final profile = await _repo.getUserProfile(user.uid);
        final accountType =(profile?['accountType'] as String?) ?? 'tourist';
        emit(AuthAuthenticated(user, accountType: accountType));
      } else {
        emit(const AuthError('Login failed. Please try again.'));
      }
    } catch (e) {
      emit(AuthError(_clean(e)));
    }
  }
 


  Future<void> _onLoginWithGoogle(
    LoginWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _repo.signInWithGoogle();
      if (user != null) {
        final profile = await _repo.getUserProfile(user.uid);
        final accountType =
            (profile?['accountType'] as String?) ?? 'tourist';
        emit(AuthAuthenticated(user, accountType: accountType));
      } else {
        emit(const AuthError('Google Sign-In was cancelled.'));
      }
    } catch (e) {
      emit(AuthError(_clean(e)));
    }
  }

  Future<void> _onSignUpWithProfile(
    SignUpWithProfile event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _repo.signUpWithProfile(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        phone: event.phone,
        dateOfBirth: event.dateOfBirth,
        accountType: event.accountType,
      );
      if (user != null) {
        await user.sendEmailVerification();
        await _repo.signOut();
        emit(EmailVerificationSent(event.email));
      } else {
        emit(const AuthError('Account creation failed. Please try again.'));
      }
    } catch (e) {
      emit(AuthError(_clean(e)));
    }
  }

  Future<void> _onLogout(Logout event, Emitter<AuthState> emit) async {
    await _repo.signOut();
    emit(AuthInitial());
  }

  Future<void> _onSendPasswordReset(
    SendPasswordReset event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _repo.sendPasswordReset(event.email);
      emit(PasswordResetSent(event.email));
    } catch (e) {
      emit(AuthError(_clean(e)));
    }
  }

  /// Strip the "Exception: " prefix Flutter adds when converting to string.
  String _clean(Object e) =>
      e.toString().replaceFirst('Exception: ', '');
}
