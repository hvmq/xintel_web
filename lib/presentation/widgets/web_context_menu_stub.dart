class WebContextMenuHelper {
  static void preventDefaultContextMenu(dynamic event) {
    // No-op for non-web platforms
  }

  static void addContextMenuListener(Function(dynamic) callback) {
    // No-op for non-web platforms
  }

  static void removeContextMenuListener(Function(dynamic) callback) {
    // No-op for non-web platforms
  }

  static bool get isWebPlatform => false;
}
