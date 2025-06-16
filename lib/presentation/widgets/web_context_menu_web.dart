import 'dart:html' as html;

class WebContextMenuHelper {
  static void preventDefaultContextMenu(dynamic event) {
    if (event is html.Event) {
      event.preventDefault();
    }
  }

  static void addContextMenuListener(Function(dynamic) callback) {
    html.document.addEventListener('contextmenu', callback);
  }

  static void removeContextMenuListener(Function(dynamic) callback) {
    html.document.removeEventListener('contextmenu', callback);
  }

  static bool get isWebPlatform => true;
}
