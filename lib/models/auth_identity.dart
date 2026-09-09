/// Authentication identity only. Roles and active status come from the server.
class AuthIdentity {
  const AuthIdentity({required this.uid, this.phoneNumber});
  final String uid;
  final String? phoneNumber;
}

class AuthSessionResult {
  const AuthSessionResult(this.user);
  final AuthIdentity? user;
}
