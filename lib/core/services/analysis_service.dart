import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:gen_confi/core/config/api_config.dart';
import 'package:gen_confi/core/api/dio_client.dart';
import 'package:gen_confi/core/models/analysis_models.dart';

class AnalysisService {
  final DioClient _dioClient;

  AnalysisService(this._dioClient);

  /// Submit complete analysis with image and chat answers
  Future<AnalysisResponse> completeAnalysis({
    required String imagePath,
    required Map<String, dynamic> answers,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Create FormData for multipart request
      String fileName = imagePath.split('/').last;
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: fileName,
        ),
        'answers': jsonEncode(answers),
        'metadata': jsonEncode(metadata ?? {}),
      });

      final response = await _dioClient.post(
        ApiConfig.completeAnalysis,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final analysisResponse = AnalysisResponse.fromJson(response.data);

      print(
        '✅ Analysis submitted successfully: ID ${analysisResponse.id}',
      );
      return analysisResponse;
    } catch (e) {
      print('❌ Error submitting analysis: $e');
      rethrow;
    }
  }

  /// Get analysis by ID
  Future<AnalysisResponse> getAnalysis(int analysisId) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.getAnalysis(analysisId),
      );

      return AnalysisResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all analyses for current user
  Future<List<AnalysisResponse>> getUserAnalyses({
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.getUserAnalyses,
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      final List<dynamic> data = response.data;
      return data
          .map((json) => AnalysisResponse.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}

