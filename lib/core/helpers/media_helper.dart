import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

const _maxMediaSize = 1024 * 1024 * 1024; // 1GB

enum MediaAttachmentType { image, video, audio, document }

class PickedMedia {
  final File file;
  final MediaAttachmentType type;

  PickedMedia({required this.file, required this.type});
}

class MediaHelper {
  const MediaHelper._();

  static Future<PickedMedia?> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) {
      return null;
    }

    // check if file size is over 10MB
    final file = File(pickedFile.path);
    if (await file.length() > _maxMediaSize) {
      throw Exception('File size is too large');
    }

    return PickedMedia(file: file, type: MediaAttachmentType.image);
  }

  static Future<PickedMedia?> pickVideoFromCamera({
    Duration? maxDuration,
  }) async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: maxDuration,
    );

    if (pickedFile == null) {
      return null;
    }

    // check if file size is over 10MB
    final file = File(pickedFile.path);
    if (await file.length() > _maxMediaSize) {
      throw Exception('File size is too large');
    }

    return PickedMedia(file: file, type: MediaAttachmentType.video);
  }

  static Future<PickedMedia?> pickMedia() async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickMedia();

    if (pickedFile == null) {
      return null;
    }

    final file = File(pickedFile.path);
    if (file.lengthSync() > _maxMediaSize) {}

    final mediaType = await _getMediaType(File(pickedFile.path));

    return PickedMedia(file: File(pickedFile.path), type: mediaType!);
  }

  static Future<PickedMedia?> pickMediaFromGallery() async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickMedia();

    if (pickedFile == null) {
      return null;
    }

    // check if file size is over 10MB
    // final file = File(pickedFile.path);
    // if (await file.length() > _maxMediaSize) {
    //   throw const ValidationException(ValidationExceptionKind.fileIsTooLarge);
    // }

    final mediaType = await _getMediaType(File(pickedFile.path));

    return PickedMedia(file: File(pickedFile.path), type: mediaType!);
  }

  static Future<PickedMedia?> takeImageFromCamera() async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile == null) {
      return null;
    }

    final mediaType = await _getMediaType(File(pickedFile.path));

    return PickedMedia(file: File(pickedFile.path), type: mediaType!);
  }

  static Future<MediaAttachmentType?> _getMediaType(File pickedFile) async {
    final mimeType = await getMimeType(pickedFile);

    if (mimeType == null) {
      throw Exception('Cannot get mime type of file');
    }

    if (mimeType.startsWith('image')) {
      return MediaAttachmentType.image;
    }

    if (mimeType.startsWith('video')) {
      return MediaAttachmentType.video;
    }

    if (mimeType.startsWith('audio')) {
      return MediaAttachmentType.audio;
    }

    return null;
  }

  static Future<String?> getMimeType(File file) async {
    return lookupMimeType(file.path);
  }

  static Future<PickedMedia?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
        'txt',
        'csv',
        'rtf',
        'zip',
        'rar',
        '7z',
        'tar',
        'apk',
      ],
    );

    if (result == null) {
      return null;
    }

    final file = File(result.files.single.path!);
    if (file.lengthSync() > _maxMediaSize) {
      throw Exception('File size is too large');
    }

    return PickedMedia(
      file: File(result.files.single.path!),
      type: MediaAttachmentType.document,
    );
  }

  static Future<List<PickedMedia>> pickMultipleMediaFromGallery() async {
    try {
      final List<PickedMedia> pickedMedia = [];
      final ImagePicker picker = ImagePicker();

      final List<XFile> pickedFiles = await picker.pickMultipleMedia();
      // Get.find<ChatInputController>().setIsLoadingMedia(true);
      if (pickedFiles.length > 100) {
        throw Exception('You can only upload 100 images/video');
      }

      for (final file in pickedFiles) {
        final File filePicked = File(file.path);

        final mediaType = await _getMediaType(filePicked);

        if (mediaType == null) {
          throw Exception('Cannot get media type');
        }

        if (mediaType == MediaAttachmentType.video) {
          // final bool isTimeValid =
          //     await MediaService().checkTimeVideo(filePicked);

          // if (!isTimeValid) {
          //   // throw Exception('Video is too long 2 minutes');
          //   throw Exception('Video is too long 2 minutes');
          // } else {
          //   // final File? fileCompress =
          //   //     await MediaService().compressVideo(filePicked);

          //   pickedMedia.add(PickedMedia(
          //     file: filePicked ?? filePicked,
          //     type: mediaType,
          //   ));
          // }
        } else if (mediaType == MediaAttachmentType.image) {
          // final File? fileCompress =
          //     await MediaService().compressImage(filePicked);

          pickedMedia.add(
            PickedMedia(file: filePicked ?? filePicked, type: mediaType),
          );
        }
      }

      return pickedMedia;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }
}
