import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xintel/core/extensions/widget_extensions.dart';

import '../../../resources/styles/app_colors.dart';
import '../../../resources/styles/gaps.dart';
import '../../../resources/styles/text_styles.dart';
import '../../widgets/circle_avatar.dart';
import '../chat_sidebar/chat_hub/chat_hub_view.dart';
import '../chat_sidebar/chat_hub/widgets/pin_message_widget.dart';
import '../chat_sidebar/chat_profile/chat_profile_view.dart';
import '../chat_sidebar/chat_sidebar_controller.dart';
import '../chat_sidebar/chat_sidebar_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _homeWidgetWidth = 300; // Initial width
  bool _isDragging = false;
  bool _isProfileResizing = false;
  bool _isProfileHovering = false;
  final double _minProfileWidth = 350.0;
  final double _maxProfileWidth = 600.0;
  final controller = Get.find<ChatSidebarController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(width: _homeWidgetWidth, child: const ChatSidebar()),
            MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                onHorizontalDragStart: (details) {
                  setState(() {
                    _isDragging = true;
                  });
                },
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _homeWidgetWidth += details.delta.dx;
                    // Add constraints to prevent the width from becoming too small or too large
                    _homeWidgetWidth = _homeWidgetWidth.clamp(200.0, 500.0);
                  });
                },
                onHorizontalDragEnd: (details) {
                  setState(() {
                    _isDragging = false;
                  });
                },
                child: Container(width: 2, color: AppColors.greyBorder),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Obx(() {
                    return !controller.isInitChat.value
                        ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          width: double.infinity,
                          color: Colors.white,
                          child: Row(
                            children: [
                              AppCircleAvatar(
                                url:
                                    controller
                                        .conversations[controller
                                            .currentConversationIndex
                                            .value]
                                        .avatarUrl() ??
                                    '',
                                size: 40,
                              ),
                              AppSpacing.gapW8,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller
                                        .conversations[controller
                                            .currentConversationIndex
                                            .value]
                                        .title(),
                                    style: AppTextStyles.s14w700.copyWith(
                                      color: AppColors.text2,
                                    ),
                                  ),
                                  Text(
                                    'Ngoai tuyen',
                                    style: AppTextStyles.s12w400.copyWith(
                                      color: AppColors.subText2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).clickable(() {
                          controller.isShowChatProfile.value =
                              !controller.isShowChatProfile.value;
                        })
                        : const SizedBox.shrink();
                  }),
                  Divider(
                    color: AppColors.greyBorder,
                    height: 1,
                    thickness: 0.5,
                  ),
                  PinMessageWidget(),
                  Divider(
                    color: AppColors.greyBorder,
                    height: 1,
                    thickness: 0.5,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 650,
                                minWidth: 350,
                              ),
                              child: ChatHubView(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Obx(() {
              return controller.isShowChatProfile.value
                  ? MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    onEnter: (_) {
                      setState(() {
                        _isProfileHovering = true;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        _isProfileHovering = false;
                      });
                    },
                    child: GestureDetector(
                      onPanStart: (details) {
                        setState(() {
                          _isProfileResizing = true;
                        });
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          // Calculate new width based on drag
                          final screenWidth = MediaQuery.of(context).size.width;
                          final newProfileWidth =
                              screenWidth - details.globalPosition.dx;

                          // Constrain within min/max bounds
                          final clampedWidth = newProfileWidth.clamp(
                            _minProfileWidth,
                            _maxProfileWidth,
                          );
                          controller.profileWidth.value = clampedWidth;
                        });
                      },
                      onPanEnd: (details) {
                        setState(() {
                          _isProfileResizing = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 8,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border(
                            left: BorderSide(
                              color: AppColors.greyBorder,
                              width:
                                  (_isProfileHovering || _isProfileResizing)
                                      ? 2
                                      : 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  : const SizedBox.shrink();
            }),
            Obx(() {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width:
                    controller.isShowChatProfile.value
                        ? controller.profileWidth.value
                        : 0,
                height: double.infinity,
                color: Colors.white,
                child: const ChatProfileView(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
