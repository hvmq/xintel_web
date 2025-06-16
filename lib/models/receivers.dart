import 'user.dart';

class Receivers {
  User user;

  Receivers({required this.user});

  factory Receivers.fromJson(Map<String, dynamic> json) {
    return Receivers(user: User.fromJson(json['user'] as Map<String, dynamic>));
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson()};
  }

  static List<Receivers> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => Receivers.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
