import 'user_contact.dart';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? avatarPath;
  final String? nickname;
  final String? loginLocal;
  final DateTime? fetchTime;
  final UserContact? contact;
  final bool? isActivated;
  final String? webUserId;
  final String? talkLanguage;
  final String? zoomId;
  final String? gender;
  final String? birthday;
  final String? location;
  final bool? isSearchGlobal;
  final bool? isShowEmail;
  final bool? isShowPhone;
  final bool? isShowGender;
  final bool? isShowBirthday;
  final bool? isShowLocation;
  final bool? isShowNft;
  final String? nftNumber;
  final bool? isPhoneVerified;
  final bool? isBot;
  final String? authenKey;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.avatarPath,
    this.nickname,
    this.loginLocal,
    this.fetchTime,
    this.contact,
    this.isActivated,
    this.webUserId,
    this.talkLanguage,
    this.zoomId,
    this.gender,
    this.birthday,
    this.location,
    this.isSearchGlobal,
    this.isShowEmail,
    this.isShowPhone,
    this.isShowGender,
    this.isShowBirthday,
    this.isShowLocation,
    this.isShowNft,
    this.nftNumber,
    this.isPhoneVerified,
    this.isBot,
    this.authenKey,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarPath: json['avatar_path'] as String?,
      nickname: json['nickname'] as String?,
      loginLocal: json['login_local'] as String?,
      fetchTime:
          json['fetch_time'] != null
              ? DateTime.parse(json['fetch_time'] as String)
              : null,
      contact:
          json['contact'] != null
              ? UserContact.fromJson(json['contact'] as Map<String, dynamic>)
              : null,
      isActivated: json['is_activated'] as bool?,
      webUserId: json['web_user_id'] as String?,
      talkLanguage: json['talk_language'] as String?,
      zoomId: json['zoom_id'] as String?,
      gender: json['gender'] as String?,
      birthday: json['birthday'] as String?,
      location: json['location'] as String?,
      isSearchGlobal: json['is_search_global'] as bool?,
      isShowEmail: json['is_show_email'] as bool?,
      isShowPhone: json['is_show_phone'] as bool?,
      isShowGender: json['is_show_gender'] as bool?,
      isShowBirthday: json['is_show_birthday'] as bool?,
      isShowLocation: json['is_show_location'] as bool?,
      isShowNft: json['is_show_nft'] as bool?,
      nftNumber: json['nft_number'] as String?,
      isPhoneVerified: json['is_phone_verified'] as bool?,
      isBot: json['is_bot'] as bool?,
      authenKey: json['authen_key'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (nickname != null) 'nickname': nickname,
      if (loginLocal != null) 'login_local': loginLocal,
      if (fetchTime != null) 'fetch_time': fetchTime!.toIso8601String(),
      if (contact != null) 'contact': contact!.toJson(),
      if (isActivated != null) 'is_activated': isActivated,
      if (webUserId != null) 'web_user_id': webUserId,
      if (talkLanguage != null) 'talk_language': talkLanguage,
      if (zoomId != null) 'zoom_id': zoomId,
      if (gender != null) 'gender': gender,
      if (birthday != null) 'birthday': birthday,
      if (location != null) 'location': location,
      if (isSearchGlobal != null) 'is_search_global': isSearchGlobal,
      if (isShowEmail != null) 'is_show_email': isShowEmail,
      if (isShowPhone != null) 'is_show_phone': isShowPhone,
      if (isShowGender != null) 'is_show_gender': isShowGender,
      if (isShowBirthday != null) 'is_show_birthday': isShowBirthday,
      if (isShowLocation != null) 'is_show_location': isShowLocation,
      if (isShowNft != null) 'is_show_nft': isShowNft,
      if (nftNumber != null) 'nft_number': nftNumber,
      if (isPhoneVerified != null) 'is_phone_verified': isPhoneVerified,
      if (isBot != null) 'is_bot': isBot,
      if (authenKey != null) 'authen_key': authenKey,
    };
  }

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? avatarPath,
    String? nickname,
    String? loginLocal,
    DateTime? fetchTime,
    UserContact? contact,
    bool? isActivated,
    String? webUserId,
    String? talkLanguage,
    String? zoomId,
    String? gender,
    String? birthday,
    String? location,
    bool? isSearchGlobal,
    bool? isShowEmail,
    bool? isShowPhone,
    bool? isShowGender,
    bool? isShowBirthday,
    bool? isShowLocation,
    bool? isShowNft,
    String? nftNumber,
    bool? isPhoneVerified,
    bool? isBot,
    String? authenKey,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarPath: avatarPath ?? this.avatarPath,
      nickname: nickname ?? this.nickname,
      loginLocal: loginLocal ?? this.loginLocal,
      fetchTime: fetchTime ?? this.fetchTime,
      contact: contact ?? this.contact,
      isActivated: isActivated ?? this.isActivated,
      webUserId: webUserId ?? this.webUserId,
      talkLanguage: talkLanguage ?? this.talkLanguage,
      zoomId: zoomId ?? this.zoomId,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      location: location ?? this.location,
      isSearchGlobal: isSearchGlobal ?? this.isSearchGlobal,
      isShowEmail: isShowEmail ?? this.isShowEmail,
      isShowPhone: isShowPhone ?? this.isShowPhone,
      isShowGender: isShowGender ?? this.isShowGender,
      isShowBirthday: isShowBirthday ?? this.isShowBirthday,
      isShowLocation: isShowLocation ?? this.isShowLocation,
      isShowNft: isShowNft ?? this.isShowNft,
      nftNumber: nftNumber ?? this.nftNumber,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isBot: isBot ?? this.isBot,
      authenKey: authenKey ?? this.authenKey,
    );
  }

  // Utility methods
  String get fullName => '$firstName $lastName';

  String get displayName =>
      (nickname ?? '').trim().isNotEmpty ? nickname ?? '' : fullName;

  String get contactName => contact?.fullName ?? fullName;

  factory User.deactivated([int? id]) => User(
    id: id ?? DateTime.now().millisecondsSinceEpoch,
    firstName: 'Deactivated',
    lastName: 'User',
  );

  bool isDeactivated() => id > 0 && firstName == 'Deactivated';

  static List<User> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
