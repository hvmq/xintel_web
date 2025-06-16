class UserContact {
  final int? id;
  final String contactFirstName;
  final String contactLastName;
  final String contactPhoneNumber;
  final String? contactAvatarPath;
  final bool isExpanded;
  final int? userId;
  final int? contactId;
  final String? data;

  UserContact({
    required this.contactFirstName,
    required this.contactLastName,
    required this.contactPhoneNumber,
    this.id,
    this.contactAvatarPath,
    this.isExpanded = false,
    this.userId,
    this.contactId,
    this.data,
  });

  factory UserContact.fromJson(Map<String, dynamic> json) {
    return UserContact(
      id: json['id'] as int?,
      contactFirstName: json['contact_first_name'] as String? ?? '',
      contactLastName: json['contact_last_name'] as String? ?? '',
      contactPhoneNumber: json['contact_phone_number'] as String? ?? '',
      contactAvatarPath: json['contact_avatar_path'] as String?,
      isExpanded: json['is_expanded'] as bool? ?? false,
      userId: json['user_id'] as int?,
      contactId: json['contact_id'] as int?,
      data: json['data'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'contact_first_name': contactFirstName,
      'contact_last_name': contactLastName,
      'contact_phone_number': contactPhoneNumber,
      if (contactAvatarPath != null) 'contact_avatar_path': contactAvatarPath,
      'is_expanded': isExpanded,
      if (userId != null) 'user_id': userId,
      if (contactId != null) 'contact_id': contactId,
      if (data != null) 'data': data,
    };
  }

  Map<String, dynamic> toDtoJson() {
    return {
      'first_name': contactFirstName,
      'last_name': contactLastName,
      'phone_number': contactPhoneNumber,
      if (contactAvatarPath != null && contactAvatarPath!.isNotEmpty)
        'avatar_path': contactAvatarPath,
      if (data != null) 'data': data,
    };
  }

  UserContact copyWith({
    int? id,
    String? contactFirstName,
    String? contactLastName,
    String? contactPhoneNumber,
    String? contactAvatarPath,
    bool? isExpanded,
    int? userId,
    int? contactId,
    String? data,
  }) {
    return UserContact(
      id: id ?? this.id,
      contactFirstName: contactFirstName ?? this.contactFirstName,
      contactLastName: contactLastName ?? this.contactLastName,
      contactPhoneNumber: contactPhoneNumber ?? this.contactPhoneNumber,
      contactAvatarPath: contactAvatarPath ?? this.contactAvatarPath,
      isExpanded: isExpanded ?? this.isExpanded,
      userId: userId ?? this.userId,
      contactId: contactId ?? this.contactId,
      data: data ?? this.data,
    );
  }

  String get fullName => contactFirstName.isEmpty && contactLastName.isEmpty
      ? ''
      : '$contactFirstName $contactLastName';

  static List<UserContact> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => UserContact.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class ContactsResult {
  final List<UserContact> created;
  final NotCreatedContacts notCreated;

  ContactsResult({
    required this.notCreated,
    this.created = const [],
  });

  factory ContactsResult.fromJson(Map<String, dynamic> json) {
    return ContactsResult(
      created: json['created'] != null
          ? UserContact.fromJsonList(json['created'] as List<dynamic>)
          : [],
      notCreated: NotCreatedContacts.fromJson(json['not_created'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created': created.map((e) => e.toJson()).toList(),
      'not_created': notCreated.toJson(),
    };
  }

  ContactsResult copyWith({
    List<UserContact>? created,
    NotCreatedContacts? notCreated,
  }) {
    return ContactsResult(
      created: created ?? this.created,
      notCreated: notCreated ?? this.notCreated,
    );
  }
}

class NotCreatedContacts {
  final List<UserContact> existed;
  final List<String> notFounds;

  NotCreatedContacts({
    this.existed = const [],
    this.notFounds = const [],
  });

  factory NotCreatedContacts.fromJson(Map<String, dynamic> json) {
    return NotCreatedContacts(
      existed: json['existed'] != null
          ? UserContact.fromJsonList(json['existed'] as List<dynamic>)
          : [],
      notFounds: json['not_founds'] != null
          ? List<String>.from(json['not_founds'] as List<dynamic>)
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'existed': existed.map((e) => e.toJson()).toList(),
      'not_founds': notFounds,
    };
  }

  NotCreatedContacts copyWith({
    List<UserContact>? existed,
    List<String>? notFounds,
  }) {
    return NotCreatedContacts(
      existed: existed ?? this.existed,
      notFounds: notFounds ?? this.notFounds,
    );
  }
} 