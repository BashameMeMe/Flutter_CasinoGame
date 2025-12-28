class AppUser {
  final String uid;
  final String email;
  final String username;
  final int balance;

  AppUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.balance,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'],
      username: data['username'],
      balance: data['balance'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'balance': balance,
    };
  }
}
