part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class SignInWithEmail extends AuthEvent {
  final String email;
  final String password;
  const SignInWithEmail(this.email, this.password);
  @override
  List<Object> get props => [email, password];
}

class SignInWithGoogle extends AuthEvent {}

class SignOut extends AuthEvent {}