import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../resources/styles/app_colors.dart';
import '../../resources/styles/text_styles.dart';
import 'reaction_chat_widget/model/menu_item.dart';
import 'reaction_chat_widget/utilities/default_data.dart';
// Conditional import for web-specific functionality
import 'web_context_menu_web.dart'
    if (dart.library.io) 'web_context_menu_stub.dart'
    as web_helper;

class WebContextMenu extends StatefulWidget {
  const WebContextMenu({
    required this.child,
    required this.onReactionTap,
    required this.onMenuItemTap,
    required this.menuItems,
    super.key,
    this.reactions = DefaultData.reactions,
    this.enabled = true,
  });

  final Widget child;
  final Function(String) onReactionTap;
  final Function(MenuItem) onMenuItemTap;
  final List<MenuItem> menuItems;
  final List<String> reactions;
  final bool enabled;

  @override
  State<WebContextMenu> createState() => _WebContextMenuState();
}

class _WebContextMenuState extends State<WebContextMenu> {
  OverlayEntry? _overlayEntry;
  bool _isMenuVisible = false;

  @override
  void initState() {
    super.initState();
    // Disable browser's default context menu (web only)
    if (widget.enabled && kIsWeb) {
      web_helper.WebContextMenuHelper.addContextMenuListener(
        _preventDefaultContextMenu,
      );
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    if (kIsWeb) {
      web_helper.WebContextMenuHelper.removeContextMenuListener(
        _preventDefaultContextMenu,
      );
    }
    super.dispose();
  }

  void _preventDefaultContextMenu(dynamic event) {
    web_helper.WebContextMenuHelper.preventDefaultContextMenu(event);
  }

  void _showContextMenu(TapDownDetails details) {
    if (!widget.enabled || _isMenuVisible) return;

    _removeOverlay();

    final Size screenSize = MediaQuery.of(context).size;

    // Calculate positions for both menus
    final double reactionsWidth = 240.0;
    final double reactionsHeight = 40.0;
    final double menuWidth = 200.0;
    final double menuHeight = widget.menuItems.length * 48.0 + 16.0;
    final double spacing = 10.0; // Space between cursor and popups
    final double margin = 10.0; // Margin from screen edges

    final double cursorX = details.globalPosition.dx;
    final double cursorY = details.globalPosition.dy;

    // Calculate available space above and below cursor
    final double spaceAbove = cursorY - margin;
    final double spaceBelow = screenSize.height - cursorY - margin;

    // Always try to keep emoji above and menu below, but adjust positions as needed
    // Calculate ideal positions first
    double emojisTop = cursorY - reactionsHeight - spacing;
    double menuTop = cursorY + spacing;

    // If emoji would go above screen, move it down but keep it above menu
    if (emojisTop < margin) {
      emojisTop = margin;
      // If emoji is now too close to cursor, move menu further down
      if (emojisTop + reactionsHeight + spacing > cursorY) {
        menuTop = emojisTop + reactionsHeight + spacing;
      }
    }

    // If menu would go below screen, move it up but keep it below emoji
    if (menuTop + menuHeight > screenSize.height - margin) {
      menuTop = screenSize.height - menuHeight - margin;
      // If menu is now too close to cursor, move emoji further up
      if (menuTop - spacing < cursorY) {
        emojisTop = menuTop - reactionsHeight - spacing;
        // If emoji would now go above screen, compress the spacing
        if (emojisTop < margin) {
          emojisTop = margin;
          menuTop = emojisTop + reactionsHeight + 5; // Minimum 5px spacing
        }
      }
    }

    // Calculate horizontal positions
    double emojisLeft = cursorX - (reactionsWidth / 2);
    double menuLeft = cursorX - (menuWidth / 2);

    // Adjust horizontal positions to stay within screen bounds
    if (emojisLeft < margin) {
      emojisLeft = margin;
    } else if (emojisLeft + reactionsWidth > screenSize.width - margin) {
      emojisLeft = screenSize.width - reactionsWidth - margin;
    }

    if (menuLeft < margin) {
      menuLeft = margin;
    } else if (menuLeft + menuWidth > screenSize.width - margin) {
      menuLeft = screenSize.width - menuWidth - margin;
    }

    _overlayEntry = OverlayEntry(
      builder:
          (context) => _SplitContextMenuOverlay(
            cursorPosition: Offset(cursorX, cursorY),
            reactionsPosition: Offset(menuLeft, menuTop),
            menuPosition: Offset(emojisLeft, emojisTop),
            reactions: widget.reactions,
            menuItems: widget.menuItems,
            onReactionTap: (reaction) {
              _removeOverlay();
              widget.onReactionTap(reaction);
            },
            onMenuItemTap: (item) {
              _removeOverlay();
              widget.onMenuItemTap(item);
            },
            onDismiss: _removeOverlay,
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isMenuVisible = true;
    });

    // Add haptic feedback
    HapticFeedback.mediumImpact();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_isMenuVisible) {
      setState(() {
        _isMenuVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Enable context menu on web and desktop platforms
    if (widget.enabled && (kIsWeb || _isDesktopPlatform())) {
      return GestureDetector(
        onSecondaryTapDown: _showContextMenu,
        child: widget.child,
      );
    }

    // For mobile platforms, just return the child without context menu
    return widget.child;
  }

  bool _isDesktopPlatform() {
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }
}

class _SplitContextMenuOverlay extends StatefulWidget {
  const _SplitContextMenuOverlay({
    required this.cursorPosition,
    required this.reactionsPosition,
    required this.menuPosition,
    required this.reactions,
    required this.menuItems,
    required this.onReactionTap,
    required this.onMenuItemTap,
    required this.onDismiss,
  });

  final Offset cursorPosition;
  final Offset reactionsPosition;
  final Offset menuPosition;
  final List<String> reactions;
  final List<MenuItem> menuItems;
  final Function(String) onReactionTap;
  final Function(MenuItem) onMenuItemTap;
  final VoidCallback onDismiss;

  @override
  State<_SplitContextMenuOverlay> createState() =>
      _SplitContextMenuOverlayState();
}

class _SplitContextMenuOverlayState extends State<_SplitContextMenuOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.transparent,
        child: Stack(
          children: [
            // Cursor position indicator (for debugging)
            // Positioned(
            //   left: widget.cursorPosition.dx - 2,
            //   top: widget.cursorPosition.dy - 2,
            //   child: Container(
            //     width: 4,
            //     height: 4,
            //     decoration: BoxDecoration(
            //       color: Colors.red.withOpacity(0.7),
            //       shape: BoxShape.circle,
            //     ),
            //   ),
            // ),

            // Emoji reactions popup (above cursor)
            Positioned(
              left: widget.menuPosition.dx,
              top: widget.menuPosition.dy,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: _buildReactionsPopup(),
                    ),
                  );
                },
              ),
            ),

            // Menu actions popup (below cursor)
            Positioned(
              left: widget.reactionsPosition.dx,
              top: widget.reactionsPosition.dy,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: _buildMenuPopup(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionsPopup() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(25),
      color: Colors.white,
      shadowColor: Colors.black26,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children:
              widget.reactions.map((reaction) {
                final index = widget.reactions.indexOf(reaction);
                return _buildReactionButton(
                  reaction,
                  DefaultData.stringReactions[index],
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildMenuPopup() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      shadowColor: Colors.black26,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              widget.menuItems.map((item) {
                return _buildMenuItem(item);
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildReactionButton(String emoji, String reactionValue) {
    return InkWell(
      onTap: () => widget.onReactionTap(reactionValue),
      borderRadius: BorderRadius.circular(20),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 20),
      ).paddingOnly(right: 8),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return InkWell(
      onTap: () => widget.onMenuItemTap(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(
              item.icon as IconData,
              size: 18,
              color: item.isDestuctive ? Colors.red : AppColors.grey8,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: AppTextStyles.s14w700.copyWith(
                  fontSize: 13,
                  color: item.isDestuctive ? Colors.red : AppColors.text2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
