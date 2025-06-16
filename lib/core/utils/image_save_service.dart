import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

import '../../resources/styles/app_colors.dart';
import 'toast_util.dart';

class ImageSaveService {
  static const String _defaultFileName = 'image';
  static const String _defaultExtension = '.jpg';

  /// Save image from URL to device
  /// Returns true if successful, false otherwise
  static Future<bool> saveImageFromUrl(
    String imageUrl, {
    String? fileName,
    String? customPath,
    bool showSuccessMessage = true,
    bool showErrorMessage = true,
  }) async {
    try {
      // Download image data
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        if (showErrorMessage) {
          ToastUtil.showError('Không thể tải ảnh từ server', title: 'Lỗi');
        }
        return false;
      }

      final Uint8List imageBytes = response.bodyBytes;
      final String finalFileName = _generateFileName(fileName, imageUrl);

      return await saveImageBytes(
        imageBytes,
        fileName: finalFileName,
        customPath: customPath,
        showSuccessMessage: showSuccessMessage,
        showErrorMessage: showErrorMessage,
      );
    } catch (e) {
      debugPrint('Error saving image from URL: $e');
      if (showErrorMessage) {
        ToastUtil.showError('Không thể lưu ảnh: ${e.toString()}', title: 'Lỗi');
      }
      return false;
    }
  }

  /// Save image bytes to device
  /// Returns true if successful, false otherwise
  static Future<bool> saveImageBytes(
    Uint8List imageBytes, {
    String? fileName,
    String? customPath,
    bool showSuccessMessage = true,
    bool showErrorMessage = true,
  }) async {
    try {
      final String finalFileName = fileName ?? _generateFileName(null, null);

      if (kIsWeb) {
        return await _saveImageWeb(
          imageBytes,
          finalFileName,
          showSuccessMessage: showSuccessMessage,
          showErrorMessage: showErrorMessage,
        );
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        return await _saveImageDesktop(
          imageBytes,
          finalFileName,
          customPath: customPath,
          showSuccessMessage: showSuccessMessage,
          showErrorMessage: showErrorMessage,
        );
      } else {
        // Mobile platforms (Android/iOS)
        return await _saveImageMobile(
          imageBytes,
          finalFileName,
          customPath: customPath,
          showSuccessMessage: showSuccessMessage,
          showErrorMessage: showErrorMessage,
        );
      }
    } catch (e) {
      debugPrint('Error saving image bytes: $e');
      if (showErrorMessage) {
        ToastUtil.showError('Không thể lưu ảnh: ${e.toString()}', title: 'Lỗi');
      }
      return false;
    }
  }

  /// Save image on web platform using download
  static Future<bool> _saveImageWeb(
    Uint8List imageBytes,
    String fileName, {
    bool showSuccessMessage = true,
    bool showErrorMessage = true,
  }) async {
    try {
      // Create blob and download link
      final blob = html.Blob([imageBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor =
          html.AnchorElement(href: url)
            ..target = 'blank'
            ..download = fileName;

      // Trigger download
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      if (showSuccessMessage) {
        ToastUtil.showSuccess('Ảnh đã được tải xuống!');
      }

      return true;
    } catch (e) {
      debugPrint('Error saving image on web: $e');
      if (showErrorMessage) {
        ToastUtil.showError('Không thể tải xuống ảnh trên web', title: 'Lỗi');
      }
      return false;
    }
  }

  /// Save image on desktop platforms (macOS, Windows, Linux)
  static Future<bool> _saveImageDesktop(
    Uint8List imageBytes,
    String fileName, {
    String? customPath,
    bool showSuccessMessage = true,
    bool showErrorMessage = true,
  }) async {
    try {
      String? outputPath;

      if (customPath != null) {
        // Use custom path if provided
        outputPath = customPath;
      } else {
        // Let user choose save location
        try {
          outputPath = await FilePicker.platform.saveFile(
            dialogTitle: 'Lưu ảnh',
            fileName: fileName,
            type: FileType.any,
          );
        } catch (e) {
          debugPrint('FilePicker error: $e');
          // Show user-friendly error and use fallback
          if (showErrorMessage) {
            ToastUtil.showError(
              'Không thể mở dialog lưu file. Sẽ lưu vào thư mục Documents.',
              title: 'Thông báo',
            );
          }

          // Fallback to accessible directory
          if (Platform.isMacOS || Platform.isLinux) {
            // Use Documents directory which is accessible
            final documentsDir = await getApplicationDocumentsDirectory();
            outputPath = '${documentsDir.path}/$fileName';
          } else if (Platform.isWindows) {
            try {
              // Try Documents folder first
              final documentsDir = await getApplicationDocumentsDirectory();
              outputPath = '${documentsDir.path}\\$fileName';
            } catch (_) {
              // Fallback to temp directory
              final tempDir = await getTemporaryDirectory();
              outputPath = '${tempDir.path}\\$fileName';
            }
          }
        }
      }

      if (outputPath == null) {
        // User cancelled the save dialog
        return false;
      }

      // Ensure file has extension
      if (!outputPath.contains('.')) {
        outputPath += _defaultExtension;
      }

      try {
        // Create directory if it doesn't exist
        final file = File(outputPath);
        final directory = file.parent;
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        // Write file
        await file.writeAsBytes(imageBytes);

        if (showSuccessMessage) {
          ToastUtil.showSuccess('Ảnh đã được lưu!');
        }

        return true;
      } catch (permissionError) {
        debugPrint('Permission error: $permissionError');

        // Try fallback to Documents directory
        try {
          final documentsDir = await getApplicationDocumentsDirectory();
          final fallbackPath = '${documentsDir.path}/$fileName';
          final fallbackFile = File(fallbackPath);

          await fallbackFile.writeAsBytes(imageBytes);

          if (showSuccessMessage) {
            ToastUtil.showSuccess('Ảnh đã được lưu!');
          }

          return true;
        } catch (fallbackError) {
          debugPrint('Fallback error: $fallbackError');

          // Last resort: temp directory
          try {
            final tempDir = await getTemporaryDirectory();
            final tempPath = '${tempDir.path}/$fileName';
            final tempFile = File(tempPath);

            await tempFile.writeAsBytes(imageBytes);

            if (showSuccessMessage) {
              ToastUtil.showSuccess('Ảnh đã được lưu!');
            }

            return true;
          } catch (finalError) {
            debugPrint('Final error: $finalError');
            rethrow;
          }
        }
      }
    } catch (e) {
      debugPrint('Error saving image on desktop: $e');
      if (showErrorMessage) {
        ToastUtil.showError(
          'Không thể lưu ảnh. Lỗi: ${e.toString()}',
          title: 'Lỗi',
        );
      }
      return false;
    }
  }

  /// Save image on mobile platforms (Android, iOS)
  static Future<bool> _saveImageMobile(
    Uint8List imageBytes,
    String fileName, {
    String? customPath,
    bool showSuccessMessage = true,
    bool showErrorMessage = true,
  }) async {
    try {
      Directory directory;

      if (customPath != null) {
        directory = Directory(customPath);
      } else {
        // Get default downloads directory
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory =
                await getExternalStorageDirectory() ??
                await getApplicationDocumentsDirectory();
          }
        } else {
          // iOS
          directory = await getApplicationDocumentsDirectory();
        }
      }

      // Create directory if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Create file path
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Write file
      await file.writeAsBytes(imageBytes);

      if (showSuccessMessage) {
        Get.snackbar(
          'Thành công',
          'Ảnh đã được lưu: ${file.path}',
          backgroundColor: AppColors.positive,
          colorText: AppColors.white,
          duration: const Duration(seconds: 3),
        );
      }

      return true;
    } catch (e) {
      debugPrint('Error saving image on mobile: $e');
      if (showErrorMessage) {
        Get.snackbar(
          'Lỗi',
          'Không thể lưu ảnh trên mobile: ${e.toString()}',
          backgroundColor: AppColors.negative,
          colorText: AppColors.white,
          duration: const Duration(seconds: 3),
        );
      }
      return false;
    }
  }

  /// Generate a unique filename
  static String _generateFileName(String? fileName, String? url) {
    if (fileName != null && fileName.isNotEmpty) {
      return fileName.contains('.') ? fileName : '$fileName$_defaultExtension';
    }

    // Try to extract filename from URL
    if (url != null && url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          final lastSegment = pathSegments.last;
          if (lastSegment.contains('.')) {
            return lastSegment;
          }
        }
      } catch (e) {
        debugPrint('Error parsing URL for filename: $e');
      }
    }

    // Generate default filename with timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${_defaultFileName}_$timestamp$_defaultExtension';
  }

  /// Get platform-specific default save directory
  static Future<String?> getDefaultSaveDirectory() async {
    try {
      if (kIsWeb) {
        return null; // Web doesn't have file system access
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        // Desktop platforms - let user choose
        return null;
      } else if (Platform.isAndroid) {
        // Android - try Downloads folder first
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (await downloadDir.exists()) {
          return downloadDir.path;
        }
        // Fallback to external storage
        final externalDir = await getExternalStorageDirectory();
        return externalDir?.path;
      } else if (Platform.isIOS) {
        // iOS - Documents directory
        final docsDir = await getApplicationDocumentsDirectory();
        return docsDir.path;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting default save directory: $e');
      return null;
    }
  }

  /// Check if platform supports file saving
  static bool get canSaveFiles {
    return kIsWeb ||
        Platform.isMacOS ||
        Platform.isWindows ||
        Platform.isLinux ||
        Platform.isAndroid ||
        Platform.isIOS;
  }

  /// Get platform name for display
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    return 'Unknown';
  }

  /// Check if a directory is writable
  static Future<bool> isDirectoryWritable(String path) async {
    try {
      final directory = Directory(path);
      if (!await directory.exists()) {
        return false;
      }

      // Try to create a test file
      final testFile = File(
        '$path/.write_test_${DateTime.now().millisecondsSinceEpoch}',
      );
      await testFile.writeAsString('test');
      await testFile.delete();
      return true;
    } catch (e) {
      debugPrint('Directory not writable: $path, error: $e');
      return false;
    }
  }

  /// Get list of accessible directories for saving files
  static Future<List<String>> getAccessibleDirectories() async {
    final List<String> directories = [];

    try {
      if (kIsWeb) {
        return ['Browser Downloads']; // Web doesn't have file system access
      }

      // Always accessible directories
      final documentsDir = await getApplicationDocumentsDirectory();
      directories.add(documentsDir.path);

      final tempDir = await getTemporaryDirectory();
      directories.add(tempDir.path);

      if (Platform.isAndroid || Platform.isIOS) {
        // Mobile specific directories
        if (Platform.isAndroid) {
          try {
            final externalDir = await getExternalStorageDirectory();
            if (externalDir != null) {
              directories.add(externalDir.path);
            }
          } catch (e) {
            debugPrint('External storage not available: $e');
          }
        }
      } else {
        // Desktop specific directories
        final List<String> commonPaths = [];

        if (Platform.isMacOS) {
          final user = Platform.environment['USER'] ?? '';
          commonPaths.addAll([
            '/Users/$user/Desktop',
            '/Users/$user/Documents',
            '/Users/$user/Pictures',
          ]);
        } else if (Platform.isWindows) {
          final userProfile = Platform.environment['USERPROFILE'] ?? '';
          commonPaths.addAll([
            '$userProfile\\Desktop',
            '$userProfile\\Documents',
            '$userProfile\\Pictures',
          ]);
        } else if (Platform.isLinux) {
          final home = Platform.environment['HOME'] ?? '';
          commonPaths.addAll([
            '$home/Desktop',
            '$home/Documents',
            '$home/Pictures',
          ]);
        }

        // Check which directories are accessible
        for (final path in commonPaths) {
          if (await isDirectoryWritable(path)) {
            directories.add(path);
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting accessible directories: $e');
    }

    return directories;
  }

  /// Show info about file save locations
  static Future<void> showSaveLocationInfo() async {
    final accessibleDirs = await getAccessibleDirectories();

    String message = 'Vị trí có thể lưu file:\n';
    for (int i = 0; i < accessibleDirs.length && i < 3; i++) {
      message += '• ${accessibleDirs[i]}\n';
    }

    if (Platform.isMacOS) {
      message +=
          '\nLưu ý: Trên macOS, app cần quyền truy cập để lưu vào Downloads. Hãy chọn thư mục khác hoặc cấp quyền trong System Preferences.';
    }

    Get.snackbar(
      'Thông tin lưu file',
      message,
      backgroundColor: AppColors.blue1,
      colorText: AppColors.text2,
      duration: const Duration(seconds: 5),
      maxWidth: 400,
    );
  }
}
