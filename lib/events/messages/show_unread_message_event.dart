/// Event to notify that there are unread messages
/// This event can be used to update UI badges or indicators
class ShowUnreadMessageEvent {
  final int? unreadCount;
  final DateTime timestamp;

  ShowUnreadMessageEvent({this.unreadCount}) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'ShowUnreadMessageEvent(unreadCount: $unreadCount, timestamp: $timestamp)';
  }
}
