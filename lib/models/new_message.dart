import 'message.dart';

class NewMessage {
  final Message? message;
  final bool? receiverMutedRoom;

  NewMessage({this.message, this.receiverMutedRoom});

  factory NewMessage.fromJson(Map<String, dynamic> json) {
    return NewMessage(
      message:
          json['message'] != null
              ? Message.fromJson(json['message'] as Map<String, dynamic>)
              : null,
      receiverMutedRoom: json['receiverMutedRoom'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message?.toJson(),
      'receiverMutedRoom': receiverMutedRoom,
    };
  }

  @override
  String toString() {
    return 'NewMessage(message: $message, receiverMutedRoom: $receiverMutedRoom)';
  }
}
