import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../resources/styles/app_colors.dart';
import '../../../resources/styles/text_styles.dart';
import 'model/menu_item.dart';
import 'utilities/default_data.dart';

class AnimatedReactionsDialogWidget extends StatefulWidget {
  const AnimatedReactionsDialogWidget({
    required this.id,
    required this.messageWidget,
    required this.onReactionTap,
    required this.onContextMenuTap,
    required this.initialMenuItems,
    required this.position,
    required this.onSeeMorePressed,
    required this.onDeletePressed,
    required this.isMine,
    super.key,
    this.reactions = DefaultData.reactions,
    this.widgetAlignment = Alignment.centerRight,
    this.menuItemsWidth = 0.45,
  });

  // Id for the hero widget
  final String id;

  // The message widget to be displayed in the dialog
  final Widget messageWidget;

  // The callback function to be called when a reaction is tapped
  final Function(String) onReactionTap;

  // The callback function to be called when a context menu item is tapped
  final Function(MenuItem) onContextMenuTap;

  // The initial list of menu items to be displayed in the context menu
  final List<MenuItem> initialMenuItems;

  // The list of reactions to be displayed
  final List<String> reactions;

  // The alignment of the widget
  final Alignment widgetAlignment;

  // The width of the menu items
  final double menuItemsWidth;

  final String position;

  final bool isMine;

  // Callback to get new menu items when see more is pressed
  final Future<List<MenuItem>> Function() onSeeMorePressed;

  final Future<List<MenuItem>> Function() onDeletePressed;

  @override
  State<AnimatedReactionsDialogWidget> createState() =>
      _AnimatedReactionsDialogWidgetState();
}

class _AnimatedReactionsDialogWidgetState
    extends State<AnimatedReactionsDialogWidget>
    with TickerProviderStateMixin {
  // state variables for activating the animation
  bool reactionClicked = false;
  int? clickedReactionIndex;
  int? clickedContextMenuIndex;

  // Animation controllers for see more animation
  late AnimationController _shrinkController;
  late AnimationController _expandController;
  late Animation<double> _shrinkAnimation;
  late Animation<double> _expandAnimation;

  bool _isAnimating = false;
  bool _showNewMenu = false;
  bool _isFirstShow = true; // Track if this is the first time showing menu
  List<MenuItem> _currentMenuItems = [];

  @override
  void initState() {
    super.initState();
    _currentMenuItems = widget.initialMenuItems;

    // Initialize animation controllers
    _shrinkController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Shrink animation - scale down to 0 and move to top-right corner
    _shrinkAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _shrinkController, curve: Curves.easeInQuart),
    );

    // Expand animation - scale up from 0 to 1
    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeOutQuart),
    );

    // Start initial animation when widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInitialAnimation();
    });
  }

  @override
  void dispose() {
    _shrinkController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  // Function to handle see more animation
  Future<void> _handleAnimation({bool isSeeMore = false}) async {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    // Reset controllers to initial state
    _shrinkController.reset();
    _expandController.reset();

    // Reset showNewMenu flag
    _showNewMenu = false;

    // Start shrink animation
    await _shrinkController.forward();

    // Get new menu items
    final newMenuItems =
        isSeeMore
            ? await widget.onSeeMorePressed()
            : await widget.onDeletePressed();

    // Update menu items and show new menu
    setState(() {
      _currentMenuItems = newMenuItems;
      _showNewMenu = true;
    });

    // Small delay before expanding
    await Future.delayed(const Duration(milliseconds: 50));

    // Start expand animation
    await _expandController.forward();

    setState(() {
      _isAnimating = false;
    });
  }

  // Function to handle initial menu appearance animation
  Future<void> _startInitialAnimation() async {
    await _expandController.forward();
    setState(() {
      _isFirstShow = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
      child: SafeArea(
        child: Align(
          alignment:
              widget.position == 'top'
                  ? Alignment.topRight
                  : widget.position == 'center'
                  ? Alignment.centerRight
                  : Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(
              right: 20.0,
              left: 20.0,
              top: widget.position == 'top' ? 10 : 0,
              bottom: widget.position == 'bottom' ? 20 : 0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // reactions
                buildReactions(context),
                const SizedBox(height: 10),
                // message
                buildMessage().paddingOnly(
                  left: widget.isMine ? 60 : 0,
                  right: widget.isMine ? 0 : 60,
                ),
                const SizedBox(height: 10),
                // context menu with animation
                buildAnimatedMenuItems(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAnimatedMenuItems(BuildContext context) {
    // Xác định alignment dựa trên isMine
    final animationAlignment =
        widget.isMine ? Alignment.topRight : Alignment.topLeft;

    return AnimatedBuilder(
      animation: Listenable.merge([_shrinkController, _expandController]),
      builder: (context, child) {
        if (_showNewMenu && _expandController.value > 0) {
          // Show expanding new menu from corner tương ứng với isMine
          return Transform.scale(
            scale: _expandAnimation.value,
            alignment: animationAlignment,
            child: buildMenuItems(context, _currentMenuItems),
          );
        } else if (_isFirstShow) {
          // Show initial menu with expand animation
          return Transform.scale(
            scale: _expandAnimation.value,
            alignment: animationAlignment,
            child: buildMenuItems(context, widget.initialMenuItems),
          );
        } else {
          // Show shrinking old menu to corner tương ứng với isMine or normal menu
          return Transform.scale(
            scale: _isAnimating ? _shrinkAnimation.value : 1.0,
            alignment: animationAlignment,
            child: buildMenuItems(context, widget.initialMenuItems),
          );
        }
      },
    );
  }

  Widget buildMenuItems(BuildContext context, List<MenuItem> menuItems) {
    return Align(
      alignment: widget.widgetAlignment,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * widget.menuItemsWidth,
          decoration: BoxDecoration(
            color: const Color(0xfff6f6f6),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade500,
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var item in menuItems)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            clickedContextMenuIndex = menuItems.indexOf(item);
                          });
                          print('item.label: ${item.label}');
                          // Check if this is a "see more" item
                          if (item.label.toLowerCase().contains('see more') ||
                              item.label.toLowerCase().contains('xem thêm')) {
                            _handleAnimation(isSeeMore: true);
                          } else if (item.label.toLowerCase().contains('xóa')) {
                            _handleAnimation();
                          } else {
                            widget.onContextMenuTap(item);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.label,
                              style: AppTextStyles.s16w500.copyWith(
                                color:
                                    item.isDestuctive
                                        ? Colors.red
                                        : AppColors.text2,
                              ),
                            ),
                            Icon(
                              item.icon as IconData,
                              color:
                                  item.isDestuctive
                                      ? Colors.red
                                      : AppColors.grey8,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (menuItems.last != item)
                      Divider(
                        color: const Color(0xffa6a6a6).withOpacity(0.4),
                        thickness: 1,
                      ),
                  ],
                ),
            ],
          ).paddingSymmetric(vertical: 4),
        ),
      ),
    );
  }

  Widget buildMessage() {
    return Align(
      alignment: widget.widgetAlignment,
      child: Hero(tag: widget.id, child: widget.messageWidget),
    );
  }

  Widget buildReactions(BuildContext context) {
    return Align(
      alignment: widget.widgetAlignment,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: AppColors.grey7,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade500,
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var reaction in widget.reactions)
                FadeInLeft(
                  from:
                      0 + (widget.reactions.indexOf(reaction) * 20).toDouble(),
                  duration: const Duration(milliseconds: 200),
                  delay: const Duration(milliseconds: 100),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        reactionClicked = true;
                        clickedReactionIndex = widget.reactions.indexOf(
                          reaction,
                        );
                      });
                      Future.delayed(
                        const Duration(milliseconds: 300),
                      ).whenComplete(() {
                        Navigator.of(context).pop();
                        widget.onReactionTap(
                          DefaultData.stringReactions[widget.reactions.indexOf(
                            reaction,
                          )],
                        );
                      });
                    },
                    child: Pulse(
                      duration: const Duration(milliseconds: 500),
                      animate:
                          reactionClicked &&
                          clickedReactionIndex ==
                              widget.reactions.indexOf(reaction),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(6.0, 2.0, 6.0, 2),
                        child: Text(reaction, style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
