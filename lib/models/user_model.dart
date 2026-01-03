class UserModel {
  final String uid;
  final String email;
  final int point;

  UserModel({
    required this.uid,
    required this.email,
    required this.point,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      email: data['email'],
      point: data['point'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'point': point,
    };
  }
}
