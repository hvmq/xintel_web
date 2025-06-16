// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:get/get.dart';
import 'package:minio/io.dart';
import 'package:minio/minio.dart';
import 'package:minio/models.dart';

import '../core/configs/env_config.dart';
import '../core/mixins/log_mixin.dart';
import '../models/message.dart';

const CONVERSATION_BUCKET_NAME = 'conversation';
const USER_BUCKET_NAME = 'user';

class StorageRepository with LogMixin {
  bool isUseSsl = true;
  late Minio _minio;
  String _pathUrl = '';

  StorageRepository() {
    final envConfig = Get.find<EnvConfig>();

    _minio = Minio(
      endPoint: envConfig.minIoUrl,
      accessKey: envConfig.minIoAccessKey,
      secretKey: envConfig.minIoSecretKey,
      useSSL: isUseSsl,
    );

    _pathUrl = '${isUseSsl ? 'https://' : 'http://'}${envConfig.minIoUrl}';
  }

  Future<String> uploadUserAvatar({
    required File file,
    required int currentUserId,
  }) async {
    final String pathSaveToServer =
        '$currentUserId/${file.path.split('/').last}';

    return _uploadFile(
      file: file,
      bucketName: USER_BUCKET_NAME,
      path: pathSaveToServer,
    );
  }

  Future<String> uploadConversationMedia({
    required File file,
    required MessageType messageType,
    required String conversationId,
  }) async {
    final messageTypeFolder = _parseMessageTypeToSubFolder(messageType);

    final String path =
        '$conversationId/$messageTypeFolder/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

    return _uploadFile(
      file: file,
      bucketName: CONVERSATION_BUCKET_NAME,
      path: path,
    );
  }

  Future<String> uploadConversationAvatar({
    required File file,
    required String conversationId,
  }) async {
    final String path = '$conversationId/avatar.${file.path.split('.').last}';

    return _uploadFile(
      file: file,
      bucketName: CONVERSATION_BUCKET_NAME,
      path: path,
    );
  }

  Future<String> _uploadFile({
    required File file,
    required String bucketName,
    required String path,
  }) async {
    try {
      final String eTag = await _minio.fPutObject(bucketName, path, file.path);

      if (eTag.isNotEmpty) {
        return '$_pathUrl/$bucketName/$path';
      }

      return '';
    } catch (e) {
      logError(e);
      return '';
    }
  }

  String _parseMessageTypeToSubFolder(MessageType messageType) {
    return switch (messageType) {
      MessageType.image => 'image',
      MessageType.video => 'video',
      MessageType.audio => 'audio',
      MessageType.file => 'file',
      _ => throw Exception('Invalid message type'),
    };
  }

  Future<ListObjectsResult> _listAllObjects(
    String bucket, {
    String prefix = '',
    bool recursive = false,
  }) async {
    final chunks = _minio.listObjects(
      bucket,
      prefix: prefix,
      recursive: recursive,
    );
    final objects = <Object>[];
    final prefixes = <String>[];
    await for (final chunk in chunks) {
      objects.addAll(chunk.objects);
      prefixes.addAll(chunk.prefixes);
    }

    return ListObjectsResult(objects: objects, prefixes: prefixes);
  }

  Future<List<String>> getAllConversationMediaByType({
    required String conversationId,
    required MessageType messageType,
  }) async {
    final messageTypeFolder = _parseMessageTypeToSubFolder(messageType);

    final result = await _listAllObjects(
      CONVERSATION_BUCKET_NAME,
      prefix: '$conversationId/$messageTypeFolder/',
      recursive: true,
    );

    return result.objects
        .map((object) => '$_pathUrl/$CONVERSATION_BUCKET_NAME/${object.key}')
        .toList();
  }
}
