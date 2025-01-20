// import 'package:flutter/material.dart';
// import 'package:gtec/models/super_admin_model.dart';
// import 'package:gtec/services/webservice.dart';

// class CourseProvider with ChangeNotifier {
//   String? _token;
//   List<coursemodel> _course = [];
//   List<coursemodel> get course => _course;
//   String? get token => _token;

//   final SuperAdminAPI _apiService = SuperAdminAPI();

//   Map<int, List<Modulemodel>> _courseModules = {};
//   Map<int, List<Lessonmodel>> _moduleLessons = {};

//   List<Modulemodel> getModulesForCourse(int courseId) {
//     return _courseModules[courseId] ?? [];
//   }

//   List<Lessonmodel> getLessonsForModule(int moduleId) {
//     return _moduleLessons[moduleId] ?? [];
//   }

//   // Fetch courses from the API
//   Future<void> fetchCoursesprovider() async {
//     if (_token == null) throw Exception('Token is missing');
//     try {
//       _course = await _apiService.fetchCoursesAPI(_token!);
//       print('Fetched courses: $_course');
//       notifyListeners();
//     } catch (e) {
//       print('Error fetching courses: $e');
//     }
//   }

//   // Create a new course
//   Future<void> createCourseprovider(String title, String description) async {
//     if (_token == null) throw Exception('Token is missing');
//     try {
//       await _apiService.createCourseAPI(title, description, _token!);
//       await fetchCoursesprovider();
//     } catch (e) {
//       print('Error creating course: $e');
//       throw Exception('Failed to create course');
//     }
//   }

//   // Fetch modules for a course
//   Future<void> fetchModulesForCourseProvider(int courseId) async {
//     if (_token == null) throw Exception('Token is missing');
//     try {
//       final modules = await _apiService.fetchModulesForCourseAPI(_token!, courseId);
//       _courseModules[courseId] = modules;
//       notifyListeners();
//     } catch (e) {
//       print('Error fetching modules for course: $e');
//       throw Exception('Failed to fetch modules for course');
//     }
//   }

//   Future<void> createmoduleprovider(
//       String title, String content, int courseId) async {
//     if (_token == null) throw Exception('Token is missing');
//     try {
//       print('Creating module for courseId: $courseId');
//       await _apiService.createmoduleAPI(_token!, courseId, title, content);
//       print('Module creation successful. Fetching updated modules...');
//       await fetchModulesForCourseProvider(courseId);
//       print('Modules fetched successfully.');
//     } catch (e) {
//       print('Error creating module: $e');
//       throw Exception('Failed to create module');
//     }
//   }

//   Future<void> fetchLessonsForModuleProvider(int courseId, int moduleId) async {
//     if (_token == null) throw Exception('Token is missing');
//     try {
//       final lessons = await _apiService.fetchLessonsForModuleAPI(
//           _token!, courseId, moduleId);
//       _moduleLessons[moduleId] = lessons;
//       notifyListeners();
//     } catch (e) {
//       print('Error fetching lessons for module: $e');
//       rethrow;
//     }
//   }

//   Future<void> createlessonprovider(
//     int courseId,
//     int moduleId,
//     String content,
//     String title,
//     String videoLink,
//   ) async {
//     if (_token == null) throw Exception('Token is missing');
//     try {
//       print('Creating lesson for courseId: $courseId');
//       print('Creating lesson for moduleId: $moduleId');

//       await _apiService.createlessonseAPI(
//         _token!,
//         courseId,
//         moduleId,
//         content,
//         title,
//         videoLink,
//       );

//       print('Lesson creation successful. Fetching updated lessons...');
//       await fetchLessonsForModuleProvider(courseId, moduleId);
//       print('Lessons fetched successfully.');
//     } catch (e) {
//       print('Error creating lesson: $e');
//       throw Exception('Failed to create lesson: $e');
//     }
//   }
// }