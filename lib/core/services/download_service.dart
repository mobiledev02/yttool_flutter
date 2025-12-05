import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadService {
  final Dio _dio = Dio();

  Future<bool> downloadAndSaveImage(String url, String fileName) async {
    try {
      // Request permissions
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        status = await Permission.photos.request();
        if (!status.isGranted) {
          return false;
        }
      }

      // Download image
      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      // Save to gallery
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: fileName,
      );

      return result['isSuccess'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
