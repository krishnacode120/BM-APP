enum UserRole { user, admin }

class AppUser {
  const AppUser(
      {required this.id, required this.phoneNumber, required this.role});
  final String id;
  final String phoneNumber;
  final UserRole role;
}
