import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ToastType { success, error, warning, info }

class ToastUtil {
  static OverlayEntry? _currentToast;
  static final List<_ToastData> _toastQueue = [];
  static bool _isShowing = false;

  /// Show a success toast
  static void showSuccess(
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? title,
  }) {
    _showToast(
      message: message,
      type: ToastType.success,
      duration: duration,
      title: title,
    );
  }

  /// Show an error toast
  static void showError(
    String message, {
    Duration duration = const Duration(seconds: 4),
    String? title,
  }) {
    _showToast(
      message: message,
      type: ToastType.error,
      duration: duration,
      title: title,
    );
  }

  /// Show a warning toast
  static void showWarning(
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? title,
  }) {
    _showToast(
      message: message,
      type: ToastType.warning,
      duration: duration,
      title: title,
    );
  }

  /// Show an info toast
  static void showInfo(
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? title,
  }) {
    _showToast(
      message: message,
      type: ToastType.info,
      duration: duration,
      title: title,
    );
  }

  /// Show a custom toast
  static void showCustom({
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 3),
    String? title,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
  }) {
    _showToast(
      message: message,
      type: type,
      duration: duration,
      title: title,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
    );
  }

  /// Internal method to show toast
  static void _showToast({
    required String message,
    required ToastType type,
    required Duration duration,
    String? title,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
  }) {
    print('🍞 ToastUtil: Attempting to show toast - $message');

    final toastData = _ToastData(
      message: message,
      type: type,
      duration: duration,
      title: title,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: icon,
    );

    _toastQueue.add(toastData);
    print('🍞 ToastUtil: Added to queue. Queue length: ${_toastQueue.length}');
    _processQueue();
  }

  /// Process the toast queue
  static void _processQueue() {
    print(
      '🍞 ToastUtil: Processing queue. IsShowing: $_isShowing, Queue length: ${_toastQueue.length}',
    );

    if (_isShowing || _toastQueue.isEmpty) return;

    _isShowing = true;
    final toastData = _toastQueue.removeAt(0);
    _displayToast(toastData);
  }

  /// Display the actual toast
  static void _displayToast(_ToastData toastData) {
    print('🍞 ToastUtil: Attempting to display toast');

    // Try multiple ways to get context with overlay
    BuildContext? context;
    OverlayState? overlay;

    // Method 1: Try Get.context
    context = Get.context;
    if (context != null) {
      try {
        overlay = Overlay.of(context);
        print('✅ ToastUtil: Found overlay using Get.context');
      } catch (e) {
        print('❌ ToastUtil: Get.context has no overlay: $e');
        context = null;
      }
    }

    // Method 2: Try Get.key.currentContext
    if (context == null) {
      context = Get.key.currentContext;
      if (context != null) {
        try {
          overlay = Overlay.of(context);
          print('✅ ToastUtil: Found overlay using Get.key.currentContext');
        } catch (e) {
          print('❌ ToastUtil: Get.key.currentContext has no overlay: $e');
          context = null;
        }
      }
    }

    // Method 3: Try to find overlay in widget tree
    if (context == null) {
      context = Get.key.currentState?.context;
      if (context != null) {
        try {
          overlay = Overlay.of(context);
          print(
            '✅ ToastUtil: Found overlay using Get.key.currentState.context',
          );
        } catch (e) {
          print('❌ ToastUtil: Get.key.currentState.context has no overlay: $e');
          context = null;
        }
      }
    }

    // If no overlay found, use fallback
    if (context == null || overlay == null) {
      print('❌ ToastUtil: No overlay context found, using fallback');
      showFallbackToast(
        toastData.message,
        toastData.type,
        title: toastData.title,
      );
      _isShowing = false;
      _processQueue();
      return;
    }

    print('✅ ToastUtil: Context and overlay found, creating toast');

    try {
      final toastConfig = _getToastConfig(toastData.type);

      _currentToast = OverlayEntry(
        builder:
            (context) => _ToastWidget(
              message: toastData.message,
              title: toastData.title,
              type: toastData.type,
              backgroundColor:
                  toastData.backgroundColor ?? toastConfig.backgroundColor,
              textColor: toastData.textColor ?? toastConfig.textColor,
              icon: toastData.icon ?? toastConfig.icon,
              onDismiss: _dismissCurrentToast,
            ),
      );

      overlay.insert(_currentToast!);
      print('✅ ToastUtil: Toast inserted into overlay');

      // Auto dismiss after duration
      Future.delayed(toastData.duration, () {
        _dismissCurrentToast();
      });
    } catch (e) {
      print('❌ ToastUtil: Error creating overlay entry: $e');
      showFallbackToast(
        toastData.message,
        toastData.type,
        title: toastData.title,
      );
      _isShowing = false;
      _processQueue();
    }
  }

  /// Dismiss current toast
  static void _dismissCurrentToast() {
    print('🍞 ToastUtil: Dismissing current toast');

    try {
      _currentToast?.remove();
      _currentToast = null;
    } catch (e) {
      print('❌ ToastUtil: Error removing toast: $e');
    }

    _isShowing = false;

    // Process next toast in queue
    Future.delayed(const Duration(milliseconds: 100), () {
      _processQueue();
    });
  }

  /// Clear all toasts
  static void clearAll() {
    print('🍞 ToastUtil: Clearing all toasts');
    _toastQueue.clear();
    _dismissCurrentToast();
  }

  /// Get toast configuration based on type
  static _ToastConfig _getToastConfig(ToastType type) {
    switch (type) {
      case ToastType.success:
        return _ToastConfig(
          backgroundColor: const Color(0xFF10B981),
          textColor: Colors.white,
          icon: Icons.check_circle,
        );
      case ToastType.error:
        return _ToastConfig(
          backgroundColor: const Color(0xFFEF4444),
          textColor: Colors.white,
          icon: Icons.error,
        );
      case ToastType.warning:
        return _ToastConfig(
          backgroundColor: const Color(0xFFF59E0B),
          textColor: Colors.white,
          icon: Icons.warning,
        );
      case ToastType.info:
        return _ToastConfig(
          backgroundColor: const Color(0xFF3B82F6),
          textColor: Colors.white,
          icon: Icons.info,
        );
    }
  }

  /// Alternative method using GetX snackbar as fallback
  static void showFallbackToast(
    String message,
    ToastType type, {
    String? title,
  }) {
    print('🍞 ToastUtil: Using fallback GetX snackbar');

    Color backgroundColor;
    Color textColor = Colors.white;
    IconData icon;

    switch (type) {
      case ToastType.success:
        backgroundColor = const Color(0xFF10B981);
        icon = Icons.check_circle;
        break;
      case ToastType.error:
        backgroundColor = const Color(0xFFEF4444);
        icon = Icons.error;
        break;
      case ToastType.warning:
        backgroundColor = const Color(0xFFF59E0B);
        icon = Icons.warning;
        break;
      case ToastType.info:
        backgroundColor = const Color(0xFF3B82F6);
        icon = Icons.info;
        break;
    }

    Get.snackbar(
      title ?? '',
      message,
      titleText:
          title != null
              ? Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
              : const SizedBox.shrink(),
      messageText: Text(
        message,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: title != null ? FontWeight.w400 : FontWeight.w500,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: backgroundColor,
      colorText: textColor,
      icon: Icon(icon, color: textColor, size: 20),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.only(top: 20, right: 20),
      borderRadius: 12,
      maxWidth: 300,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 300),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      padding: const EdgeInsets.all(12),
    );
  }
}

/// Toast data model
class _ToastData {
  final String message;
  final ToastType type;
  final Duration duration;
  final String? title;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  _ToastData({
    required this.message,
    required this.type,
    required this.duration,
    this.title,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });
}

/// Toast configuration model
class _ToastConfig {
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  _ToastConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });
}

/// Toast widget
class _ToastWidget extends StatefulWidget {
  final String message;
  final String? title;
  final ToastType type;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.onDismiss,
    this.title,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    print('🍞 ToastWidget: Initializing animations');

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    print('✅ ToastWidget: Animation started');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    print('🍞 ToastWidget: Dismissing with animation');
    await _animationController.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    print('🍞 ToastWidget: Building toast widget');

    return Positioned(
      top: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 200, // Fixed width
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: _dismiss,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(widget.icon, color: widget.textColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.title != null) ...[
                                  Text(
                                    widget.title!,
                                    style: TextStyle(
                                      color: widget.textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                ],
                                Text(
                                  widget.message,
                                  style: TextStyle(
                                    color: widget.textColor,
                                    fontSize: 12,
                                    fontWeight:
                                        widget.title != null
                                            ? FontWeight.w400
                                            : FontWeight.w500,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: _dismiss,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                Icons.close,
                                color: widget.textColor.withOpacity(0.8),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
