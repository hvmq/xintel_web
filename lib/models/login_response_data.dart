import 'user.dart';

class LoginResponseData {
  final String token;
  final User user;
  final String otp;

  LoginResponseData({
    required this.token,
    required this.user,
    required this.otp,
  });

  factory LoginResponseData.fromJson(Map<String, dynamic> json) {
    return LoginResponseData(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      otp: json['otp'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'user': user.toJson(), 'otp': otp};
  }

  LoginResponseData copyWith({String? token, User? user, String? otp}) {
    return LoginResponseData(
      token: token ?? this.token,
      user: user ?? this.user,
      otp: otp ?? this.otp,
    );
  }
}
