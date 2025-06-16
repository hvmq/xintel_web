import 'package:flutter/material.dart';

import '../../../../../models/call.dart';
import '../../../../../models/call_history.dart';
import '../../../../../models/message.dart';
import '../../../../../resources/styles/app_colors.dart';
import '../../../../../resources/styles/gaps.dart';
import '../../../../../resources/styles/text_styles.dart';

class CallMessageBody extends StatelessWidget {
  final Message message;
  final bool isMine;
  final int currentUserId;

  const CallMessageBody({
    required this.message,
    required this.isMine,
    required this.currentUserId,
    super.key,
  });

  CallHistory? getCallHistory(List<CallHistory> callHistories, int senderId) {
    final index = callHistories.indexWhere(
      (element) => element.userId == senderId,
    );
    if (index != -1) {
      return callHistories[index];
    }

    return null;
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(Get.context!)!;
    final Call? call = Call.callFromStringJson(message.content);

    // if (message.isCallJitsi) {
    //   String? groupName;
    //   String? joinUrl;
    //   if (Get.isRegistered<ChatHubController>()) {
    //     final chatHubController = Get.find<ChatHubController>();

    //     groupName = chatHubController.conversation.name;
    //     joinUrl =
    //         '${Get.find<EnvConfig>().jitsiUrl}/${chatHubController.conversation.id}';
    //   }

    //   return AppBlurryContainer(
    //     blur: isMine ? 5 : 0,
    //     borderRadius: Sizes.s12,
    //     color: AppColors.grey7,
    //     padding: const EdgeInsets.only(
    //       top: Sizes.s8,
    //       bottom: Sizes.s8,
    //       left: Sizes.s24,
    //       right: Sizes.s8,
    //     ),
    //     child: buildItemCallGroup(
    //       Icons.video_call,
    //       l10n.call__call_meeting(groupName ?? ''),
    //       AppColors.text2,
    //       joinUrl ?? '',
    //       AppColors.text1,
    //     ),
    //   );
    // }
    if (call == null) {
      return Container();
    }
    final callHistory = getCallHistory(call.callHistories ?? [], currentUserId);
    // if (callHistory == null) {
    //   return Container();
    // }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.yellow1,
        borderRadius: BorderRadius.circular(Sizes.s12),
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.s24,
        vertical: Sizes.s8,
      ),
      child: _buildStatusCall(
        callHistory?.status ?? '',
        _formatDuration(callHistory?.duration ?? 0),
        call.isVideo ?? false,
      ),
    );
  }

  Widget _buildStatusCall(String status, String time, bool isVideoCall) {
    // final l10n = AppLocalizations.of(Get.context!)!;
    Widget result = const SizedBox();
    switch (status) {
      case 'outgoing':
        result = buildItemStatusCall(
          Icons.phone_outlined,
          isVideoCall ? 'Video Outgoing' : 'Outgoing',
          AppColors.text2,
          time,
        );
        break;
      case 'incoming':
        result = buildItemStatusCall(
          Icons.phone_in_talk,
          isVideoCall ? 'Video Incoming' : 'Incoming',
          AppColors.text2,
          time,
        );
        break;
      case 'missed':
        result = buildItemStatusCall(
          Icons.phone_missed,
          isVideoCall ? 'Video Missed' : 'Missed',
          AppColors.text2,
          time,
        );
        break;
      case 'canceled':
        result = buildItemStatusCall(
          Icons.phone_outlined,
          isVideoCall ? 'Video Canceled' : 'Canceled',
          AppColors.text2,
          time,
        );
      case 'declined':
        result = buildItemStatusCall(
          Icons.phone_missed,
          isVideoCall ? 'Video Declined' : 'Declined',
          AppColors.negative,
          time,
        );
        break;
    }

    return result;
  }

  Widget buildItemStatusCall(
    IconData icon,
    String title,
    Color color,
    String time,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: Sizes.s28, color: AppColors.text2),
        AppSpacing.gapW12,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.s14w700.copyWith(color: AppColors.text2),
            ),
            Text(
              time,
              style: AppTextStyles.s12w500.copyWith(color: AppColors.grey8),
            ),
          ],
        ),
      ],
    );
  }

  // Widget buildItemCallGroup(
  //   Object icon,
  //   String title,
  //   Color color,
  //   String time,
  //   Color? iconColor,
  // ) {
  //   return Row(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       AppIcon(
  //         icon: icon,
  //         size: Sizes.s28,
  //         color: iconColor ?? color,
  //         isCircle: true,
  //         backgroundColor: AppColors.grey9,
  //       ),
  //       AppSpacing.gapW12,
  //       Flexible(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               title,
  //               style: AppTextStyles.s14w700.copyWith(color: color),
  //               maxLines: 2,
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //             const SizedBox(
  //               width: Sizes.s4,
  //             ),
  //             Text(
  //               time,
  //               style: AppTextStyles.s14w400.copyWith(
  //                 color: AppColors.text2,
  //                 decoration: TextDecoration.underline,
  //                 decorationColor: AppColors.text2,
  //               ),
  //               maxLines: 2,
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
