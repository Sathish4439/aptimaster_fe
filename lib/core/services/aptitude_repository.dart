import 'package:aptimaster/feature/questions/model/qustion_model.dart';
import 'package:aptimaster/core/models/workspace_models.dart';
import 'package:aptimaster/core/models/report_models.dart';
import 'package:aptimaster/core/models/discussion_models.dart';
import 'dart:io';

import '../models/api_models.dart';
import 'api_service.dart';
import 'api_endpoints.dart';
import '../../feature/home/model/aptitude_model.dart';

class AptitudeRepository {
  final ApiService _apiService = ApiService();

  // Categories API calls
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await _apiService.get(ApiEndpoints.categories);
      print(response.data);
      final List<dynamic> data = response.data;
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<CategoryModel> getCategoryById(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.categoryById(id));
      return CategoryModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch category: $e');
    }
  }

  Future<List<SubcategoryModel>> getSubcategories(String categoryId) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.categorySubcategories(categoryId),
      );
      final List<dynamic> data = response.data;
      return data.map((json) => SubcategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch subcategories: $e');
    }
  }

  // QuestionModels API calls
  Future<List<QuestionModel>> getAllQuestionModels({
    String? categoryId,
    String? difficulty,
    int? limit,
  }) async {
    try {
      final endpoint = ApiEndpoints.questionsWithFilters(
        categoryId: categoryId,
        difficulty: difficulty,
        limit: limit,
      );
      final response = await _apiService.get(endpoint);
      final List<dynamic> data = response.data;
      return data.map((json) => QuestionModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch questions: $e');
    }
  }

  Future<QuestionModel> getQuestionModelById(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.questionById(id));
      return QuestionModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch question: $e');
    }
  }

  Future<List<QuestionModel>> getQuestionModelsByCategory(
    String categoryId, {
    String? difficulty,
    int? limit,
  }) async {
    try {
      print('🔍 Fetching questions for category: $categoryId');
      print('🔍 Difficulty filter: $difficulty');
      print('🔍 Limit: $limit');

      final Map<String, dynamic> queryParams = {};
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      if (limit != null) queryParams['limit'] = limit;

      final endpoint = ApiEndpoints.questionsByCategory(categoryId);
      print('🔍 API Endpoint: $endpoint');
      print('🔍 Query Parameters: $queryParams');

      final response = await _apiService.get(
        endpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('🔍 Response status: ${response.statusCode}');
      print('🔍 Response data length: ${response.data?.length ?? 0}');

      final List<dynamic> data = response.data;
      final questions = data
          .map((json) => QuestionModel.fromJson(json))
          .toList();

      print('🔍 Parsed questions count: ${questions.length}');

      return questions;
    } catch (e) {
      print('❌ Error fetching questions by category: $e');
      throw Exception('Failed to fetch questions by category: $e');
    }
  }

  // Create category
  Future<CategoryModel> createCategory({
    required String name,
    String? description,
    required String slug,
    String? imageUrl,
    String? parentId,
  }) async {
    try {
      final data = {
        'name': name,
        'description': description,
        'slug': slug,
        'imageUrl': imageUrl,
        'parentId': parentId,
      };

      final response = await _apiService.post(
        ApiEndpoints.categories,
        data: data,
      );
      return CategoryModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  // Create question
  Future<QuestionModel> createQuestionModel({
    required String title,
    required String content,
    required String difficulty,
    required int points,
    int? timeLimit,
    String? explanation,
    required String categoryId,
    required List<Map<String, dynamic>> options,
  }) async {
    try {
      final data = {
        'title': title,
        'content': content,
        'difficulty': difficulty,
        'points': points,
        'timeLimit': timeLimit,
        'explanation': explanation,
        'categoryId': categoryId,
        'options': options,
      };

      final response = await _apiService.post(
        ApiEndpoints.questions,
        data: data,
      );
      return QuestionModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create question: $e');
    }
  }

  // Workspace API calls
  Future<List<WorkspaceDataModel>> getWorkspaceData(
    String questionId, {
    String? userId,
    bool includePublic = true,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (userId != null) queryParams['userId'] = userId;
      queryParams['includePublic'] = includePublic.toString();

      final response = await _apiService.get(
        '/workspace/question/$questionId',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => WorkspaceDataModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch workspace data: $e');
    }
  }

  Future<WorkspaceDataModel> createWorkspaceData({
    required String questionId,
    required String userId,
    required String title,
    required String content,
    required DataType dataType,
    bool isPublic = false,
    File? imageFile,
  }) async {
    try {
      // If image file is provided, use upload endpoint
      if (imageFile != null) {
        final data = {
          'questionId': questionId,
          'userId': userId,
          'title': title,
          'content': content,
          'dataType': dataType.name,
          'isPublic': isPublic.toString(),
        };

        final response = await _apiService.post(
          '/workspace/upload',
          data: data,
          files: {'workspaceMedia': imageFile},
        );

        return WorkspaceDataModel.fromJson(
          response.data['data'] ?? response.data,
        );
      } else {
        // Regular text/note creation
        final data = {
          'questionId': questionId,
          'userId': userId,
          'title': title,
          'content': content,
          'dataType': dataType.name,
          'isPublic': isPublic.toString(),
        };

        final response = await _apiService.post('/workspace', data: data);

        return WorkspaceDataModel.fromJson(
          response.data['data'] ?? response.data,
        );
      }
    } catch (e) {
      throw Exception('Failed to create workspace data: $e');
    }
  }

  Future<WorkspaceDataModel> updateWorkspaceData({
    required String id,
    String? title,
    String? content,
    DataType? dataType,
    bool? isPublic,
    File? imageFile,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (content != null) data['content'] = content;
      if (dataType != null) data['dataType'] = dataType.name;
      if (isPublic != null) data['isPublic'] = isPublic.toString();

      final response = await _apiService.put(
        '/workspace/$id',
        data: data,
        files: imageFile != null ? {'workspaceMedia': imageFile} : null,
      );

      return WorkspaceDataModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update workspace data: $e');
    }
  }

  Future<void> deleteWorkspaceData(String id, {String? userId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (userId != null) queryParams['userId'] = userId;

      await _apiService.delete('/workspace/$id', queryParameters: queryParams);
    } catch (e) {
      throw Exception('Failed to delete workspace data: $e');
    }
  }

  // Reports API calls
  Future<List<QuestionReportModel>> getQuestionReports(
    String questionId,
  ) async {
    try {
      final response = await _apiService.get('/reports/question/$questionId');

      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => QuestionReportModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch question reports: $e');
    }
  }

  Future<QuestionReportModel> submitReport({
    required String questionId,
    required String userId,
    required String reason,
    String? description,
  }) async {
    try {
      final data = {
        'questionId': questionId,
        'userId': userId,
        'reason': reason,
        'description': description,
      };

      final response = await _apiService.post('/reports', data: data);
      return QuestionReportModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to submit report: $e');
    }
  }

  Future<QuestionReportModel> updateReportStatus({
    required String reportId,
    required ReportStatus status,
  }) async {
    try {
      final data = {'status': status.name};

      final response = await _apiService.put(
        '/reports/$reportId/status',
        data: data,
      );
      return QuestionReportModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update report status: $e');
    }
  }

  // Discussions API calls
  Future<List<DiscussionModel>> getQuestionDiscussions(
    String questionId,
  ) async {
    try {
      final response = await _apiService.get(
        '/discussions/question/$questionId',
      );

      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => DiscussionModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch question discussions: $e');
    }
  }

  Future<DiscussionModel> createDiscussion({
    required String questionId,
    required String userId,
    required String content,
  }) async {
    try {
      final data = {
        'questionId': questionId,
        'userId': userId,
        'content': content,
      };

      final response = await _apiService.post('/discussions', data: data);
      return DiscussionModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create discussion: $e');
    }
  }

  Future<DiscussionModel> likeDiscussion({
    required String discussionId,
    required String userId,
  }) async {
    try {
      final data = {'discussionId': discussionId, 'userId': userId};

      final response = await _apiService.post('/discussions/like', data: data);
      return DiscussionModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to like discussion: $e');
    }
  }

  Future<DiscussionModel> unlikeDiscussion({
    required String discussionId,
    required String userId,
  }) async {
    try {
      final data = {'discussionId': discussionId, 'userId': userId};

      final response = await _apiService.post(
        '/discussions/unlike',
        data: data,
      );
      return DiscussionModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to unlike discussion: $e');
    }
  }
}
