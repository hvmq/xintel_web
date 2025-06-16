import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Hồ sơ cá nhân',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue.shade600),
            onPressed: () {
              _showEditProfileDialog(context, authController);
            },
          ),
        ],
      ),
      body: Obx(() {
        final user = authController.currentUser.value;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child:
                          user.avatarPath != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  user.avatarPath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.blue.shade600,
                                    );
                                  },
                                ),
                              )
                              : Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.blue.shade600,
                              ),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    Text(
                      user.displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Email or Phone
                    Text(
                      user.email ?? user.phone ?? 'Chưa cập nhật',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            user.isActivated == true
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.isActivated == true
                            ? 'Đã kích hoạt'
                            : 'Chưa kích hoạt',
                        style: TextStyle(
                          color:
                              user.isActivated == true
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Profile Information
              _ProfileSection(
                title: 'Thông tin cá nhân',
                children: [
                  _ProfileItem(
                    icon: Icons.person_outline,
                    label: 'Họ và tên',
                    value: user.fullName,
                  ),
                  if (user.nickname?.isNotEmpty == true)
                    _ProfileItem(
                      icon: Icons.badge_outlined,
                      label: 'Biệt danh',
                      value: user.nickname!,
                    ),
                  if (user.email?.isNotEmpty == true)
                    _ProfileItem(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: user.email!,
                      showVerified: user.isActivated == true,
                    ),
                  if (user.phone?.isNotEmpty == true)
                    _ProfileItem(
                      icon: Icons.phone_outlined,
                      label: 'Số điện thoại',
                      value: user.phone!,
                      showVerified: user.isPhoneVerified == true,
                    ),
                  if (user.gender?.isNotEmpty == true)
                    _ProfileItem(
                      icon: Icons.wc_outlined,
                      label: 'Giới tính',
                      value: user.gender!,
                    ),
                  if (user.birthday?.isNotEmpty == true)
                    _ProfileItem(
                      icon: Icons.cake_outlined,
                      label: 'Ngày sinh',
                      value: user.birthday!,
                    ),
                  if (user.location?.isNotEmpty == true)
                    _ProfileItem(
                      icon: Icons.location_on_outlined,
                      label: 'Địa chỉ',
                      value: user.location!,
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Settings Section
              _ProfileSection(
                title: 'Cài đặt',
                children: [
                  _ProfileAction(
                    icon: Icons.language_outlined,
                    title: 'Ngôn ngữ',
                    subtitle: user.talkLanguage ?? 'Tiếng Việt',
                    onTap: () {
                      Get.snackbar(
                        'Thông báo',
                        'Tính năng thay đổi ngôn ngữ sẽ được cập nhật sớm',
                        snackPosition: SnackPosition.TOP,
                      );
                    },
                  ),
                  _ProfileAction(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Quyền riêng tư',
                    subtitle: 'Quản lý thông tin hiển thị',
                    onTap: () {
                      _showPrivacyDialog(context, user);
                    },
                  ),
                  _ProfileAction(
                    icon: Icons.refresh_outlined,
                    title: 'Làm mới thông tin',
                    subtitle: 'Cập nhật thông tin từ server',
                    onTap: () {
                      // authController.refreshUserProfile();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Logout Section
              _ProfileSection(
                title: 'Tài khoản',
                children: [
                  _ProfileAction(
                    icon: Icons.logout,
                    title: 'Đăng xuất',
                    subtitle: 'Đăng xuất khỏi ứng dụng',
                    onTap: () {
                      _showLogoutDialog(context, authController);
                    },
                    isDestructive: true,
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    AuthController authController,
  ) {
    final user = authController.currentUser.value;
    if (user == null) return;

    final firstNameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);
    final nicknameController = TextEditingController(text: user.nickname);
    final locationController = TextEditingController(text: user.location);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Chỉnh sửa thông tin'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Họ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nicknameController,
                    decoration: const InputDecoration(
                      labelText: 'Biệt danh',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('Hủy')),
              ElevatedButton(
                onPressed: () {
                  final updateData = {
                    'first_name': firstNameController.text.trim(),
                    'last_name': lastNameController.text.trim(),
                    'nickname': nicknameController.text.trim(),
                    'location': locationController.text.trim(),
                  };

                  // authController.updateProfile(updateData);
                  Get.back();
                },
                child: const Text('Lưu'),
              ),
            ],
          ),
    );
  }

  void _showPrivacyDialog(BuildContext context, user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Quyền riêng tư'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PrivacySwitch(
                  title: 'Hiển thị email',
                  value: user.isShowEmail == true,
                  onChanged: (value) {
                    // Update privacy settings
                  },
                ),
                _PrivacySwitch(
                  title: 'Hiển thị số điện thoại',
                  value: user.isShowPhone == true,
                  onChanged: (value) {
                    // Update privacy settings
                  },
                ),
                _PrivacySwitch(
                  title: 'Hiển thị giới tính',
                  value: user.isShowGender == true,
                  onChanged: (value) {
                    // Update privacy settings
                  },
                ),
                _PrivacySwitch(
                  title: 'Hiển thị ngày sinh',
                  value: user.isShowBirthday == true,
                  onChanged: (value) {
                    // Update privacy settings
                  },
                ),
                _PrivacySwitch(
                  title: 'Hiển thị địa chỉ',
                  value: user.isShowLocation == true,
                  onChanged: (value) {
                    // Update privacy settings
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Đăng xuất'),
            content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('Hủy')),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  // authController.logout();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Đăng xuất'),
              ),
            ],
          ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showVerified;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
    this.showVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (showVerified)
                      Icon(Icons.verified, color: Colors.green, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? Colors.red : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _PrivacySwitch extends StatefulWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrivacySwitch({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_PrivacySwitch> createState() => _PrivacySwitchState();
}

class _PrivacySwitchState extends State<_PrivacySwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.title),
        Switch(
          value: _value,
          onChanged: (value) {
            setState(() {
              _value = value;
            });
            widget.onChanged(value);
          },
        ),
      ],
    );
  }
}
