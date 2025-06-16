import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xintel/core/extensions/widget_extensions.dart';

import '../../../../resources/styles/app_colors.dart';
import '../../../../resources/styles/gaps.dart';
import '../../../../resources/styles/text_styles.dart';
import '../../../widgets/circle_avatar.dart';
import '../../../widgets/network_image.dart';
import '../chat_sidebar_controller.dart';

part 'widgets/_group_tab_view.dart';
part 'widgets/_images_tab_view.dart';
part 'widgets/_link_tab_view.dart';
part 'widgets/_video_tab_view.dart';
part 'widgets/_voice_tab_view.dart';

class ChatResourceView extends StatefulWidget {
  const ChatResourceView({super.key});

  @override
  State<ChatResourceView> createState() => _ChatResourceViewState();
}

class _ChatResourceViewState extends State<ChatResourceView>
    with TickerProviderStateMixin {
  final ChatSidebarController controller = Get.find<ChatSidebarController>();
  TabController? tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: Row(
            children: [
              AppSpacing.gapW12,
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  controller.isShowChatResource.value = false;
                  controller.isShowChatProfile.value = false;
                },
              ),
              AppSpacing.gapW12,
              Text(
                'Tài nguyên chat',
                style: AppTextStyles.s16w700.copyWith(color: AppColors.text2),
              ),
            ],
          ),
        ),
        Divider(color: AppColors.greyBorder, height: 1, thickness: 0.5),
        Expanded(child: _buildPageContent()),
      ],
    );
  }

  Widget _buildPageContent() {
    return Column(
      children: [
        _buildTabBar(),
        AppSpacing.gapH8,
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              _ImageTabView(controller: controller),
              _VideoTabView(controller: controller),
              _VoiceTabView(controller: controller),
              _LinkTabView(controller: controller),
              _GroupTabView(controller: controller),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 36,
      child: TabBar(
        indicatorWeight: 1,
        labelStyle: AppTextStyles.s14w600,
        dividerColor: AppColors.subText1,
        dividerHeight: 0,

        controller: tabController,
        indicatorColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey5,
        indicatorSize: TabBarIndicatorSize.label,

        tabs: [
          const Tab(text: 'Media'),
          const Tab(text: 'Files'),
          const Tab(text: 'Voice'),
          const Tab(text: 'Links'),
          const Tab(text: 'Groups'),
        ],
      ),
    );
  }
}
