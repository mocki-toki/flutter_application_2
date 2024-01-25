import 'package:dio/dio.dart';
import 'image_entity.dart';

class ImageService {
  final Dio _dio = Dio();
  final String baseUrl =
      'https://ru.api.dev.photograf.io/v1/jobEvaluation/images';

  Future<(List<ImageEntity>, String?)> fetchImages({
    String? continuationToken,
  }) async {
    final url = continuationToken != null
        ? '$baseUrl?continuationToken=$continuationToken'
        : baseUrl;
    final response = await _dio.get(url);

    if (response.statusCode == 200) {
      final jsonList = response.data['result']['items'] as List;
      final continuationToken =
          response.data['result']["continuationToken"] as String?;

      final images =
          jsonList.map((json) => ImageEntity.fromJson(json)).toList();
      return (images, continuationToken);
    } else {
      throw Exception('Failed to load images');
    }
  }
}
