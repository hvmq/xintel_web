import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xintel/presentation/widgets/app_check_box.dart';
import 'package:xintel/repositories/user_repository.dart';

import '../../../../core/utils/toast_util.dart';
import '../../../../models/user.dart';
import '../../../../resources/styles/app_colors.dart';
import '../../../../resources/styles/gaps.dart';
import '../../../../resources/styles/text_styles.dart';
import '../../../widgets/circle_avatar.dart';
import '../../../widgets/text_field.dart';
import '../chat_sidebar_controller.dart';

class ChatMemberView extends StatefulWidget {
  const ChatMemberView({super.key});

  @override
  State<ChatMemberView> createState() => _ChatMemberViewState();
}

class _ChatMemberViewState extends State<ChatMemberView> {
  final List<User> members = [];
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final List<User> filteredMembers = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getMembers();
  }

  Future<void> getMembers() async {
    final controller = Get.find<ChatSidebarController>();
    final response = await userRepository.getUsersByIds(
      controller
          .conversations[controller.currentConversationIndex.value]
          .memberIds,
    );
    members.clear();
    filteredMembers.clear();
    members.addAll(response);
    filteredMembers.addAll(members);
    setState(() {});
  }

  void search(String value) {
    filteredMembers.clear();
    filteredMembers.addAll(
      members
          .where(
            (element) =>
                element.fullName.toLowerCase().contains(value.toLowerCase()),
          )
          .toList(),
    );
    setState(() {});
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
                  final controller = Get.find<ChatSidebarController>();
                  controller.isShowChatMember.value = false;
                  controller.isShowChatProfile.value = false;
                },
              ),
              AppSpacing.gapW12,
              Text(
                'Thành viên',
                style: AppTextStyles.s16w700.copyWith(color: AppColors.text2),
              ),
            ],
          ),
        ),
        Divider(color: AppColors.greyBorder, height: 1, thickness: 0.5),
        AppSpacing.gapH16,
        AppTextField(
          // controller: controller.searchController,
          // focusNode: controller.searchFocusNode,
          hintStyle: AppTextStyles.s16w400.copyWith(color: AppColors.subText2),
          hintText: 'Tìm kiếm',
          onChanged: (value) {
            search(value);
          },
          onTap: () {},
          prefixIcon: Icon(Icons.search, color: AppColors.subText2),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          fillColor: AppColors.grey6,
          borderRadius: 100,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(100),
          ),
        ).paddingSymmetric(horizontal: 12),
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                itemCount: filteredMembers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      AppCircleAvatar(
                        url: filteredMembers[index].avatarPath ?? '',
                        size: 44,
                      ),
                      AppSpacing.gapW12,
                      Text(
                        filteredMembers[index].fullName,
                        style: AppTextStyles.s14w700.copyWith(
                          color: AppColors.text2,
                        ),
                      ),
                    ],
                  ).paddingOnly(left: 12, right: 12, top: 16);
                },
              ),
              Positioned(
                bottom: 30,
                right: 30,
                child: GestureDetector(
                  onTap: () => _showAddMemberDialog(context),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Icon(Icons.person_add, color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const AddMemberDialog(),
    ).then((value) {
      filteredMembers.addAll(value ?? []);
      members.addAll(value ?? []);
      setState(() {});
    });
  }
}

class AddMemberDialog extends StatefulWidget {
  const AddMemberDialog({super.key});

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<User> _searchResults = [];
  final List<User> _selectedUsers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    try {
      final controller = Get.find<ChatSidebarController>();

      // Get current conversation members to exclude them
      final currentMembers =
          controller
              .conversations[controller.currentConversationIndex.value]
              .members;
      final currentMemberIds = currentMembers.map((m) => m.id).toSet();

      // Search users using the controller's search functionality
      final data = await userRepository.searchUserByTypes(
        query,
        SearchType.suggest,
      );

      // Filter out current members and current user
      final filteredResults =
          data.where((user) => !currentMemberIds.contains(user.id)).toList();

      if (_searchQuery == query) {
        // Check if this is still the current search
        setState(() {
          _searchResults.clear();
          _searchResults.addAll(filteredResults);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (_searchQuery == query) {
        setState(() {
          _isLoading = false;
        });
      }
      // Handle error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tìm kiếm: $e')));
    }
  }

  void _toggleUserSelection(User user) {
    setState(() {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  Future<void> _addSelectedMembers() async {
    if (_selectedUsers.isEmpty) return;

    try {
      setState(() => _isLoading = true);

      final controller = Get.find<ChatSidebarController>();
      final conversation =
          controller.conversations[controller.currentConversationIndex.value];

      // Add members to group using ChatRepository

      await controller.chatRepository.updateConversationMembers(
        conversationId: conversation.id,
        membersIds: [
          ...conversation.memberIds,
          ..._selectedUsers.map((user) => user.id),
        ],
        adminIds: conversation.adminIds,
      );

      // Update local conversation state
      final updatedMembers = [...conversation.members, ..._selectedUsers];
      final updatedConversation = conversation.copyWith(
        members: updatedMembers,
      );

      controller.conversations[controller.currentConversationIndex.value] =
          updatedConversation;

      Navigator.of(context).pop(_selectedUsers);

      ToastUtil.showSuccess('Đã thêm ${_selectedUsers.length} thành viên');

      // Refresh member view
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Thêm thành viên',
                  style: AppTextStyles.s16w700.copyWith(color: AppColors.text2),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            AppSpacing.gapH16,

            // Search field
            AppTextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              hintText: 'Tìm kiếm người dùng...',
              hintStyle: AppTextStyles.s16w400.copyWith(
                color: AppColors.subText2,
              ),
              onChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _searchUsers(value);
                  }
                });
              },
              prefixIcon: Icon(Icons.search, color: AppColors.subText2),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              fillColor: AppColors.grey6,
              borderRadius: 8,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            AppSpacing.gapH16,

            // Selected users chips
            if (_selectedUsers.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đã chọn (${_selectedUsers.length}):',
                      style: AppTextStyles.s14w600.copyWith(
                        color: AppColors.text2,
                      ),
                    ),
                    AppSpacing.gapH8,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _selectedUsers.map((user) {
                            return Chip(
                              avatar: AppCircleAvatar(
                                url: user.avatarPath ?? '',
                                size: 24,
                              ),
                              label: Text(
                                user.fullName,
                                style: AppTextStyles.s12w500,
                              ),
                              onDeleted: () => _toggleUserSelection(user),
                              deleteIcon: const Icon(Icons.close, size: 16),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapH16,
            ],

            // Search results
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _searchResults.isEmpty
                      ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'Nhập tên để tìm kiếm người dùng'
                              : 'Không tìm thấy kết quả',
                          style: AppTextStyles.s14w400.copyWith(
                            color: AppColors.subText2,
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          final isSelected = _selectedUsers.contains(user);

                          return ListTile(
                            leading: AppCircleAvatar(
                              url: user.avatarPath ?? '',
                              size: 40,
                            ),
                            title: Text(
                              user.fullName,
                              style: AppTextStyles.s14w600.copyWith(
                                color: AppColors.text2,
                              ),
                            ),
                            subtitle:
                                user.email?.isNotEmpty == true
                                    ? Text(
                                      user.email!,
                                      style: AppTextStyles.s12w400.copyWith(
                                        color: AppColors.subText2,
                                      ),
                                    )
                                    : null,
                            trailing: AppCheckBox(
                              value: isSelected,
                              onChanged: (_) => _toggleUserSelection(user),
                            ),
                            onTap: () => _toggleUserSelection(user),
                          );
                        },
                      ),
            ),

            // Add button
            if (_selectedUsers.isNotEmpty) ...[
              AppSpacing.gapH16,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addSelectedMembers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text(
                            'Thêm ${_selectedUsers.length} thành viên',
                            style: AppTextStyles.s16w600.copyWith(
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
