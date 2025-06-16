import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:xintel/core/extensions/widget_extensions.dart';

import '../../../../../../resources/styles/app_colors.dart';
import '../../../../../../resources/styles/gaps.dart';
import '../../../../../../resources/styles/text_styles.dart';
import '../../../../../core/helpers/media_helper.dart';
import '../../../../widgets/app_media_preview.dart';
import '../../../../widgets/text_field.dart';
import '../../../auth/auth_controller.dart';
import '../../chat_sidebar_controller.dart';
import 'reply_message_preview_widget.dart';

class ChatInput extends StatelessWidget {
  const ChatInput({super.key});

  void _onAttachmentButtonPressed() {
    final controller = Get.find<ChatSidebarController>();
    MediaHelper.pickMultipleMediaFromGallery()
        .then((media) {
          if (media.isNotEmpty) {
            controller.attachImage(media);
            log('media: ${media.first.file.path}');
            controller.pathLocal = media.first.file.path.substring(0, 10);
            // controller.pathLocal = media.first.file.path.substring(0, 24);
          }
        })
        .catchError((error) {
          log(error.toString());
        })
        .whenComplete(() {
          controller.focusNode.requestFocus();
        });
  }

  void _onDocumentButtonPressed() {
    final controller = Get.find<ChatSidebarController>();
    MediaHelper.pickDocument()
        .then((media) {
          if (media != null) {
            controller.attachImage([media]);
            log('document: ${media.file.path}');
          }
        })
        .catchError((error) {
          log(error.toString());
        })
        .whenComplete(() {
          controller.focusNode.requestFocus();
        });
  }

  void _onCameraButtonPressed() {
    // ViewUtil.hideKeyboard(Get.context!);
    // MediaHelper.takeImageFromCamera().then((media) {
    //   if (media != null) {
    //     controller.attachImages([media]);
    //     controller.pathLocal = media.file.path.substring(0, 24);
    //   }
    // });
  }

  void _onVideoButtonPressed() {
    final controller = Get.find<ChatSidebarController>();
    MediaHelper.pickMediaFromGallery()
        .then((media) {
          if (media != null && media.type == MediaAttachmentType.video) {
            controller.attachImage([media]);
            log('video: ${media.file.path}');
          }
        })
        .catchError((error) {
          log(error.toString());
        })
        .whenComplete(() {
          controller.focusNode.requestFocus();
        });
  }

  @override
  Widget build(BuildContext context) {
    final child = Column(
      children: [
        // _buildSearchMentionedUsers(),
        Padding(
          padding: AppSpacing.edgeInsetsH8.copyWith(
            bottom: AppSpacing.bottomPaddingValue(context, additional: 0),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child:
            // controller.isRecording.value
            //     ? _buildRecordingAudio()
            //     :
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToReplyMessagePreview(),
                Row(
                  children: [
                    AppSpacing.gapW8,
                    // this.controller.chatHubController.isBot == false
                    //     ? _buildStickerButton()
                    //     : const SizedBox(),
                    // this.controller.chatHubController.isBot == true
                    //     ? _buildButtonMenuCommandBot(context)
                    //     : const SizedBox(),
                    Expanded(child: _buildTextField(context)),

                    // _buildShowMoreButton(),
                    // _buildRecordButton(),
                    _buildSendOrRecordButton(context),
                    // AppSpacing.gapW4,
                    // _buildSendButton(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey11,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.text2.withOpacity(0.3),
            blurRadius: 2,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Obx(() {
          //   if (controller.isShowMenuCommandBot.value) {
          //     return _buildMenuCommandBot(context);
          //   }
          //   return const SizedBox();
          // }),
          child,
        ],
      ),
    );
  }

  // Widget _buildSendButton(BuildContext context) {
  //   return Obx(() {
  //     if (!controller.isInputEmpty) {
  //       return AppIcon(
  //         icon: AppIcons.send,
  //         color: AppColors.white,
  //         isCircle: true,
  //         backgroundColor: AppColors.primary,
  //         padding: const EdgeInsets.all(5),
  //         onTap: controller.sendMessage,
  //       );
  //     }
  //     return AppIcon(
  //       icon: AppIcons.send,
  //       color: AppColors.text4,
  //       padding: AppSpacing.edgeInsetsAll12.copyWith(left: 8),
  //       onTap: controller.sendMessage,
  //     );
  //   });
  // }

  Widget _buildTextField(BuildContext context) {
    final controller = Get.find<ChatSidebarController>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToSendMediasPreview(),
        // _buildToSendMediaPreviewLoading(),
        Theme(
          data: Theme.of(context).copyWith(hoverColor: Colors.transparent),
          child: Focus(
            onKeyEvent: (FocusNode node, KeyEvent event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.enter) {
                // Check if Shift is pressed
                final isShiftPressed =
                    HardwareKeyboard.instance.logicalKeysPressed.contains(
                      LogicalKeyboardKey.shiftLeft,
                    ) ||
                    HardwareKeyboard.instance.logicalKeysPressed.contains(
                      LogicalKeyboardKey.shiftRight,
                    );

                if (!isShiftPressed) {
                  // Just Enter pressed, send message
                  controller.sendMessage();
                  return KeyEventResult.handled; // Prevent default behavior
                }
                // Shift+Enter pressed, allow new line
                return KeyEventResult.ignored;
              }
              return KeyEventResult.ignored;
            },
            child: AppTextField(
              fillColor: Colors.transparent,
              border: InputBorder.none,
              hintStyle: AppTextStyles.s16w400.copyWith(color: AppColors.grey8),
              controller: controller.textEditingController,
              focusNode: controller.focusNode,
              borderRadius: Sizes.s32,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Sizes.s12,
                vertical: Sizes.s12,
              ),
              maxLines: 5,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              hintText: 'Nhập tin nhắn',
              textInputAction: TextInputAction.newline,
              onChanged: (value) {
                controller.textFieldMessage.value = value;
              },
              // Don't use onFieldSubmitted to avoid conflicts
              // Custom context menu with paste image option
              contextMenuBuilder: (context, editableTextState) {
                final List<ContextMenuButtonItem> buttonItems = [];

                // Add default context menu items
                final defaultItems = editableTextState.contextMenuButtonItems;
                buttonItems.addAll(defaultItems);

                return AdaptiveTextSelectionToolbar.buttonItems(
                  anchors: editableTextState.contextMenuAnchors,
                  buttonItems: buttonItems,
                );
              },
              // suffixIcon: _buildStickerButton(),
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildToSendMediaPreviewLoading() {
  //   return Obx(
  //     () => controller.isLoadingMedia.value
  //         ? SizedBox(
  //             height: 60,
  //             child: const Row(
  //               children: [
  //                 SizedBox(
  //                   width: 20,
  //                   height: 20,
  //                   child: CircularProgressIndicator(
  //                     color: AppColors.primary,
  //                     strokeWidth: 3,
  //                   ),
  //                 ),
  //                 // const SizedBox(width: 12),
  //                 // Text('${controller.loadMediaPersent.value}%',
  //                 //     style: AppTextStyles.s12Base.text2Color),
  //               ],
  //             ).marginOnly(left: 8),
  //           )
  //         : const SizedBox(),
  //   );
  // }

  Widget _buildToSendMediasPreview() {
    final controller = Get.find<ChatSidebarController>();
    return Obx(
      () => Column(
        children: [
          if (controller.toSendImages.isNotEmpty)
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: controller.toSendImages.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = controller.toSendImages[index];

                  return AppMediaPreview(
                    height: 70,
                    width: 68,
                    media: item,
                    onRemove: () {
                      controller.removeItemInMedias(item);
                    },
                  ).marginOnly(left: 8);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToReplyMessagePreview() {
    final controller = Get.find<ChatSidebarController>();
    return Obx(
      () =>
          controller.replyFromMessage != null
              ? Padding(
                padding: AppSpacing.edgeInsetsV8,
                child: ReplyMessagePreviewWidget(
                  message: controller.replyFromMessage!,
                  onCloseMessage: controller.removeReplyMessage,
                  isMine:
                      controller.replyFromMessage?.isMine(
                        myId: Get.find<AuthController>().currentUser.value!.id,
                      ) ??
                      true,
                  members:
                      controller
                          .conversations[controller
                              .currentConversationIndex
                              .value]
                          .members,
                  onMentionPressed:
                      (String? text, Map<String, int> mentions) {},
                ),
              )
              : AppSpacing.emptyBox,
    );
  }

  Widget _buildSendOrRecordButton(BuildContext context) {
    final controller = Get.find<ChatSidebarController>();
    return Obx(() {
      if (controller.textFieldMessage.value.isEmpty &&
          controller.toSendImages.isEmpty) {
        return Row(
          children: [
            // _buildShowMoreButton(),
            // _buildRecordButton(),
            _buildGallery(context),
          ],
        );
      }

      return Icon(Icons.send, color: AppColors.primary, size: 24).clickable(() {
        controller.sendMessage();
      });
    });
  }

  // Widget _buildAttachButtons() {
  //   return Obx(
  //     () => controller.isInputEmpty
  //         ? AppSpacing.emptyBox
  //         : Row(
  //             children: [
  //               _buildCameraButton(),
  //               _buildGalleryButton(),
  //               _buildSendDocumentButton(),
  //               _buildRecordButton(),
  //             ],
  //           ),
  //   );
  // }

  Widget _buildRecordButton() {
    return Container();
    // return GetBuilder<RecordController>(
    //   init: RecordController(), // INIT IT ONLY THE FIRST TIME
    //   builder: (controller) {
    //     return AppIcon(
    //       icon: AppIcons.microphone,
    //       padding: AppSpacing.edgeInsetsAll8,
    //       color: AppColors.text2,
    //     ).clickable(() {
    //       controller.startRecording();
    //     });
    //   },
    // );
  }

  Widget _buildGallery(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppColors.white,
      icon: Icon(Icons.photo_library, color: AppColors.text2),
      position: PopupMenuPosition.under,
      offset: Offset(0, -160),
      onSelected: (String value) {
        switch (value) {
          case 'image':
            _onAttachmentButtonPressed();
            break;
          case 'video':
            _onVideoButtonPressed();
            break;
          case 'file':
            _onDocumentButtonPressed();
            break;
        }
      },
      itemBuilder:
          (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'file',
              height: 36,
              child: Row(
                children: [
                  Icon(
                    Icons.insert_drive_file,
                    color: AppColors.text2,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text('Tệp tin', style: AppTextStyles.s14w400),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'video',
              height: 36,
              child: Row(
                children: [
                  Icon(Icons.videocam, color: AppColors.text2, size: 20),
                  SizedBox(width: 12),
                  Text('Video', style: AppTextStyles.s14w400),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'image',
              height: 36,
              child: Row(
                children: [
                  Icon(Icons.image, color: AppColors.text2, size: 20),
                  SizedBox(width: 12),
                  Text('Hình ảnh', style: AppTextStyles.s14w400),
                ],
              ),
            ),
          ],
    );
  }

  // Widget _buildRecordingAudio() {
  //   return GetBuilder<RecordController>(
  //     init: RecordController(),
  //     builder: (controller) {
  //       return Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           AppSpacing.gapW8,
  //           _buildDeleteAudioButton(controller),
  //           Container(
  //             padding: EdgeInsets.all(6.w),
  //             decoration: BoxDecoration(
  //               color: const Color(0xffFFE69D).withOpacity(0.58),
  //               borderRadius: BorderRadius.circular(40),
  //             ),
  //             child: Row(
  //               children: [
  //                 controller.isRecordingCompleted.value
  //                     ? Row(
  //                         children: [
  //                           _buildPlayAudio(controller),
  //                           AudioFileWaveforms(
  //                             size: Size(0.5.sw, 30),
  //                             playerController: controller.playController,
  //                             padding: EdgeInsets.only(left: 6.w, right: 6.w),
  //                             decoration: const BoxDecoration(),
  //                             playerWaveStyle: const PlayerWaveStyle(
  //                               fixedWaveColor: AppColors.primary,
  //                               liveWaveColor: AppColors.primary,
  //                               seekLineColor: AppColors.primary,
  //                             ),
  //                           ),
  //                           // controller.isPlaying.value
  //                           //     ?
  //                           StreamBuilder<Duration>(
  //                             stream:
  //                                 controller.onPlayingCurrentDurationChanged,
  //                             builder: (context, snapshot) {
  //                               if (snapshot.hasData) {
  //                                 return Text(
  //                                   '${snapshot.data!.inMinutes.toString().padLeft(2, '0')}:${(snapshot.data!.inSeconds % 60).toString().padLeft(2, '0')}',
  //                                   style: AppTextStyles.s12w400
  //                                       .copyWith(color: AppColors.zambezi),
  //                                 );
  //                               }

  //                               return const SizedBox.shrink();
  //                             },
  //                           ),
  //                           // : Text(
  //                           //     controller.maxDuration.value,
  //                           //     style: AppTextStyles.s12w400,
  //                           //   ),
  //                         ],
  //                       )
  //                     : Row(
  //                         children: [
  //                           _buildPauseRecording(controller),
  //                           AudioWaveforms(
  //                             enableGesture: true,
  //                             size: Size(0.5.sw, 30),
  //                             recorderController: controller.recorderController,
  //                             waveStyle: const WaveStyle(
  //                               waveColor: AppColors.primary,
  //                               extendWaveform: true,
  //                               showMiddleLine: false,
  //                               spacing: 5,
  //                             ),
  //                             padding: EdgeInsets.only(
  //                               left: 8.w,
  //                               right: 8.w,
  //                             ),
  //                           ),
  //                           StreamBuilder<Duration>(
  //                             stream: controller
  //                                 .recorderController.onCurrentDuration,
  //                             builder: (context, snapshot) {
  //                               if (snapshot.hasData) {
  //                                 return Text(
  //                                   controller.formatDuration(snapshot.data!),
  //                                   style: AppTextStyles.s12w400
  //                                       .copyWith(color: AppColors.zambezi),
  //                                 );
  //                               }

  //                               return const SizedBox.shrink();
  //                             },
  //                           ),
  //                         ],
  //                       ),
  //               ],
  //             ),
  //           ),
  //           _buildSendAudioButton(controller),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Widget _buildSendAudioButton(RecordController controller) {
  //   return AppIcon(
  //     icon: Assets.icons.send,
  //     color: AppColors.primary,
  //     padding: AppSpacing.edgeInsetsAll12,
  //     onTap: () {
  //       controller.onSendAudio();
  //     },
  //   );
  // }

  // Widget _buildDeleteAudioButton(RecordController controller) {
  //   return AppIcon(
  //     icon: AppIcons.deleteAudio,
  //     color: AppColors.zambezi,
  //     onTap: () {
  //       controller.deleteRecord();
  //     },
  //   );
  // }

  // Widget _buildPauseRecording(RecordController controller) {
  //   return Container(
  //     width: Sizes.s28,
  //     height: Sizes.s28,
  //     decoration: const BoxDecoration(
  //       shape: BoxShape.circle,
  //       color: AppColors.primary,
  //       // gradient: LinearGradient(
  //       //   colors: AppColors.button2,
  //       // ),
  //     ),
  //     child: GetBuilder<RecordController>(
  //       init: RecordController(),
  //       builder: (controller) {
  //         return AppIcon(
  //           icon: AppIcons.pauseAudio,
  //           padding: const EdgeInsets.all(4),
  //           onTap: () {
  //             controller.stopRecording();
  //           },
  //         );
  //       },
  //     ),
  //   );
  // }

  // Widget _buildPlayAudio(RecordController controller) {
  //   return Container(
  //     width: Sizes.s28,
  //     height: Sizes.s28,
  //     decoration: const BoxDecoration(
  //       shape: BoxShape.circle,
  //       color: AppColors.primary,
  //       // gradient: LinearGradient(
  //       //   colors: AppColors.button2,
  //       // ),
  //     ),
  //     child: GetBuilder<RecordController>(
  //       init: RecordController(),
  //       builder: (controller) {
  //         return AppIcon(
  //           icon: AppIcons.playAudio,
  //           color: AppColors.text1,
  //           padding: const EdgeInsets.all(4),
  //           onTap: () {
  //             controller.playAudio();
  //           },
  //         );
  //       },
  //     ),
  //   );
  // }

  // Widget _buildSearchMentionedUsers() {
  //   return Obx(
  //     () {
  //       if (controller.mentionedUsersInSearch.isEmpty) {
  //         return AppSpacing.emptyBox;
  //       }

  //       if (!controller.chatHubController.conversation.isGroup) {
  //         return AppSpacing.emptyBox;
  //       }

  //       return ConstrainedBox(
  //         constraints: BoxConstraints(
  //           maxHeight: 0.3.sh,
  //         ),
  //         child: Container(
  //           decoration: BoxDecoration(
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.2),
  //                 blurRadius: 2,
  //                 offset: const Offset(0, 1),
  //               ),
  //             ],
  //             color: Colors.white,
  //           ),
  //           child: ListView.builder(
  //             padding: EdgeInsets.zero,
  //             shrinkWrap: true,
  //             itemCount: controller.mentionedUsersInSearch.length,
  //             itemBuilder: (context, index) {
  //               final user = controller.mentionedUsersInSearch[index];

  //               return Row(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   AppCircleAvatar(
  //                     url: user.avatarPath ?? '',
  //                     size: Sizes.s32,
  //                   ),
  //                   AppSpacing.gapW16,
  //                   Expanded(
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           user.fullName,
  //                           style: AppTextStyles.s14w600.text2Color,
  //                         ),
  //                         AppSpacing.gapH12,
  //                         const Divider(
  //                           color: AppColors.grey6,
  //                           height: 1,
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ).paddingOnly(top: 12, left: 12, right: 12).clickable(() {
  //                 controller.onMentionedUserSelected(user);
  //               });
  //             },
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildShowMoreButton() {
    return Icon(
      Icons.more_vert,
      size: 6,
      color: AppColors.text2,
      // onTap: () {
      //   ViewUtil.showBottomSheet(
      //     child: Container(
      //       color: Colors.white,
      //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      //       child: GridView(
      //         shrinkWrap: true,
      //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      //           crossAxisCount: 4,
      //           crossAxisSpacing: Sizes.s16,
      //         ),
      //         children: [
      //           _buildCameraButton(),
      //           _buildGalleryButton(),
      //           _buildSendDocumentButton(),
      //           _buildPasteImageButton(),
      //           _buildLocationButton(),
      //           // _buildScheduleReminder(),
      //         ],
      //       ),
      //     ),
      //   );
      // },
    );
  }

  // Widget _buildCameraButton() {
  //   return _buildOptionItem(
  //     context: Get.context!,
  //     icon: AppIcon(
  //       icon: AppIcons.camera,
  //       isCircle: true,
  //       backgroundColor: AppColors.primary,
  //       padding: const EdgeInsets.all(7),
  //     ),
  //     title: Get.context!.l10n.chat_hub__camera_label,
  //     onTap: _onCameraButtonPressed,
  //   );
  // }

  // Widget _buildGalleryButton() {
  //   return _buildOptionItem(
  //     context: Get.context!,
  //     icon: AppIcon(
  //       icon: AppIcons.gallery,
  //       isCircle: true,
  //       backgroundColor: AppColors.primary,
  //       padding: const EdgeInsets.all(7),
  //     ),
  //     title: Get.context!.l10n.chat_hub__gallery_label,
  //     onTap: _onAttachmentButtonPressed,
  //   );
  // }

  // Widget _buildSendDocumentButton() {
  //   return _buildOptionItem(
  //     context: Get.context!,
  //     icon: AppIcon(
  //       icon: AppIcons.document,
  //       isCircle: true,
  //       backgroundColor: AppColors.primary,
  //       padding: const EdgeInsets.all(7),
  //     ),
  //     title: Get.context!.l10n.chat_hub__document_label,
  //     onTap: _onDocumentButtonPressed,
  //   );
  // }

  // Widget _buildPasteImageButton() {
  //   return _buildOptionItem(
  //     context: Get.context!,
  //     icon: const AppIcon(
  //       icon: Icons.content_paste,
  //       isCircle: true,
  //       backgroundColor: AppColors.primary,
  //       padding: EdgeInsets.all(7),
  //     ),
  //     title: 'Dán ảnh',
  //     onTap: () {
  //       controller.pasteImageFromClipboard();
  //     },
  //   );
  // }

  // Widget _buildLocationButton() {
  //   return _buildOptionItem(
  //     context: Get.context!,
  //     icon: const AppIcon(
  //       icon: Icons.location_on,
  //       isCircle: true,
  //       backgroundColor: AppColors.primary,
  //       padding: EdgeInsets.all(7),
  //     ),
  //     title: 'Vị trí',
  //     onTap: _onLocationButtonPressed,
  //   );
  // }

  // Widget _buildOptionItem({
  //   required BuildContext context,
  //   required Widget icon,
  //   required String title,
  //   required VoidCallback onTap,
  // }) {
  //   return Column(
  //     children: [
  //       icon,
  //       AppSpacing.gapH4,
  //       Text(
  //         title,
  //         style: AppTextStyles.s12w600.copyWith(
  //           color: AppColors.zambezi,
  //         ),
  //       ),
  //     ],
  //   ).clickable(() {
  //     Get.back();
  //     onTap();
  //   });
  // }

  // Widget _buildButtonMenuCommandBot(BuildContext context) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: AppColors.primary,
  //       borderRadius: BorderRadius.circular(16),
  //     ),
  //     child: const Center(
  //       child: Row(
  //         children: [
  //           AppIcon(
  //             icon: Icons.menu,
  //             color: AppColors.white,
  //           ),
  //           AppSpacing.gapW4,
  //           Text(
  //             'Menu',
  //             style: TextStyle(
  //               color: AppColors.white,
  //               fontSize: 16,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   ).clickable(() {
  //     controller.isShowMenuCommandBot.value =
  //         !controller.isShowMenuCommandBot.value;
  //   });
  // }

  // Widget _buildItemMenuCommandBot(BuildContext context, String name,
  //     String description, VoidCallback onTap) {
  //   return Wrap(children: [
  //     Row(
  //       children: [
  //         Container(
  //           width: 32,
  //           height: 32,
  //           decoration: const BoxDecoration(
  //             color: AppColors.primary,
  //             shape: BoxShape.circle,
  //           ),
  //           child: Center(
  //               child: Text('XIN', style: AppTextStyles.s14w700.text1Color)),
  //         ),
  //         AppSpacing.gapW8,
  //         Text('/$name', style: AppTextStyles.s14w700.text2Color),
  //         AppSpacing.gapW8,
  //         Flexible(
  //           child: Text(
  //             description,
  //             style: AppTextStyles.s14Base.text4Color,
  //           ),
  //         ),
  //       ],
  //     ).paddingOnly(left: 8, right: 12, top: 8, bottom: 8),
  //   ]).clickable(onTap);
  // }

  // Widget _buildItemMenuShimmer(BuildContext context) {
  //   return Row(
  //     children: [
  //       Container(
  //         width: 32,
  //         height: 32,
  //         decoration: const BoxDecoration(
  //           color: AppColors.primary,
  //           shape: BoxShape.circle,
  //         ),
  //         child: Center(
  //             child: Text('XIN', style: AppTextStyles.s14w700.text1Color)),
  //       ),
  //       AppSpacing.gapW8,
  //       Shimmer.fromColors(
  //         baseColor: Colors.grey.withOpacity(0.2),
  //         highlightColor: ColorRes.colorLight.withOpacity(0.2),
  //         child: Container(
  //           width: 100,
  //           height: 20,
  //           color: Colors.grey,
  //         ),
  //       ),
  //       AppSpacing.gapW8,
  //       Shimmer.fromColors(
  //         baseColor: Colors.grey.withOpacity(0.2),
  //         highlightColor: ColorRes.colorLight.withOpacity(0.2),
  //         child: Container(
  //           width: 100,
  //           height: 20,
  //           color: Colors.grey,
  //         ),
  //       ),
  //     ],
  //   ).paddingOnly(left: 8, right: 12, top: 8, bottom: 8);
  // }
}
