import 'package:get/get.dart';
import 'package:xintel/presentation/features/chat_sidebar/chat_hub/widgets/text_message_widget.dart';

import '../chat_sidebar/chat_sidebar_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ChatSidebarController>(ChatSidebarController());
    Get.put<TextMessageController>(TextMessageController());
  }
}
