final class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    this.refreshToken,
    this.idToken,
    this.subject,
    this.displayName,
  });

  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String? refreshToken;
  final String? idToken;
  final String? subject;
  final String? displayName;

  bool get isExpired => accessTokenExpiresAt.isBefore(
        DateTime.now().toUtc().add(const Duration(minutes: 1)),
      );
}

abstract interface class AuthSessionRepository {
  Future<AuthSession?> restore();
  Future<AuthSession> signIn({required String email, required String password});
  Future<String> validAccessToken({bool forceRefresh = false});
  Future<void> signOut();
}
