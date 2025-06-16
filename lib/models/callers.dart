import 'user.dart';

class Callers {
  User user;

  Callers({required this.user});

  factory Callers.fromJson(Map<String, dynamic> json) {
    return Callers(user: User.fromJson(json['user'] as Map<String, dynamic>));
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson()};
  }

  static List<Callers> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => Callers.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
