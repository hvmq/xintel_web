import 'user.dart';

class AddOrRemoveUserBySocket {
  final String? roomId;
  final User? user;
  final bool? isAdd;

  AddOrRemoveUserBySocket({this.roomId, this.user, this.isAdd});

  factory AddOrRemoveUserBySocket.fromJson(Map<String, dynamic> json) {
    return AddOrRemoveUserBySocket(
      roomId: json['roomId'] as String?,
      user:
          json['user'] != null
              ? User.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      isAdd: json['isAdd'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'roomId': roomId, 'user': user?.toJson(), 'isAdd': isAdd};
  }

  @override
  String toString() {
    return 'AddOrRemoveUserBySocket(roomId: $roomId, user: $user, isAdd: $isAdd)';
  }
}
