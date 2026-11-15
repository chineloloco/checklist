sealed class AppFailure implements Exception {
  const AppFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

final class ConfigurationFailure extends AppFailure {
  const ConfigurationFailure(super.message);
}

final class AuthenticationFailure extends AppFailure {
  const AuthenticationFailure(super.message);
}

final class SessionExpiredFailure extends AppFailure {
  const SessionExpiredFailure()
      : super('Sua sessão expirou. Entre novamente para sincronizar.');
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message);
}

final class CursorExpiredFailure extends AppFailure {
  const CursorExpiredFailure()
      : super('O cursor expirou; é necessário baixar um novo manifesto.');
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message, {this.fields = const {}});
  final Map<String, String> fields;
}

final class ConflictFailure extends AppFailure {
  const ConflictFailure(super.message, {this.conflictId});
  final String? conflictId;
}
