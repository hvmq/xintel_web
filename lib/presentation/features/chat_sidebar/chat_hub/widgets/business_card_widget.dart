import 'package:flutter/material.dart';

import '../../../../../resources/styles/app_colors.dart';
import '../../../../../resources/styles/text_styles.dart';
import '../../../../widgets/circle_avatar.dart';

class BusinessCardWidget extends StatelessWidget {
  final String phone;
  final String name;
  final String avatarUrl;
  final bool isMine;
  final String userId;
  final bool isBankInfo;

  const BusinessCardWidget({
    required this.phone,
    required this.name,
    required this.avatarUrl,
    required this.isMine,
    required this.userId,
    required this.isBankInfo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: isMine ? AppColors.primary : AppColors.grey7,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user avatar
          Row(
            children: [
              AppCircleAvatar(url: avatarUrl, size: 40),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.s14w600.copyWith(
                        color: isMine ? AppColors.white : AppColors.text1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      phone,
                      style: AppTextStyles.s12w400.copyWith(
                        color:
                            isMine
                                ? AppColors.white.withOpacity(0.8)
                                : AppColors.text2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Action button - only message button
          _buildActionButton(
            icon: Icons.message_rounded,
            label: isBankInfo ? 'Chuyển khoản' : 'Chat',
            onTap: () {
              if (isBankInfo) {
                _sendBankInfo(phone, name);
              } else {
                _sendMessage(phone, name);
              }
            },
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.white, size: 16),
            SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.s12w600.copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendBankInfo(String phone, String name) async {
    final idBank =
        phone == 'MBBANK'
            ? '970422'
            : phone == 'TPBANK'
            ? '970423'
            : '970436';
    final url = 'https://img.vietqr.io/image/$idBank-$name-print.png';
    // Find user by phone number
    // showCupertinoModalBottomSheet(
    //   context: Get.context!,
    //   builder: (context) => SizedBox(
    //     child: Image.network(
    //       url,
    //       fit: BoxFit.cover,
    //     ),
    //   ),
    // );
  }

  Future<void> _sendMessage(String phone, String name) async {
    // Find user by phone number
    // final userRepository = Get.find<UserRepository>();
    // final users = await userRepository.getUserById(int.parse(userId));

    // Navigate to private chat
    // final dashboardController = Get.find<ChatDashboardController>();
    // await dashboardController.goToPrivateChat(users);
  }
}
