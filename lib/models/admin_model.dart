class Admincoursemodel {
  final int courseId;
  final String name;
  final String description;

  Admincoursemodel({
    required this.courseId,
    required this.name,
    required this.description,
  });

  factory Admincoursemodel.fromJson(Map<String, dynamic> json) {
    return Admincoursemodel(
      courseId: json['courseId'], // Matches the field in the API response
      name: json['name'],
      description: json['description'],
    );
  }
}

class AdminModulemodel {
  final int batchId;
  final int moduleId;
  final String title;
  final String content;

  AdminModulemodel({
    required this.batchId,
    required this.moduleId,
    required this.title,
    required this.content,
  });

  // Factory constructor to create a Course instance from JSON
  factory AdminModulemodel.fromJson(Map<String, dynamic> json) {
    return AdminModulemodel(
      batchId: json['batchId'],
      moduleId: json['moduleId'],
      content: json['content'],
      title: json['title'],
    );
  }
}

class AdminLessonmodel {
  final int lessonId;
  final int moduleId;
  final int courseId;
  final int batchId;
  final String title;
  final String content;
  final String videoLink;
  final String? pdfPath; // Nullable
  final String status;

  AdminLessonmodel({
    required this.lessonId,
    required this.moduleId,
    required this.courseId,
    required this.batchId,
    required this.title,
    required this.content,
    required this.videoLink,
    this.pdfPath, // Nullable
    required this.status,
  });

  factory AdminLessonmodel.fromJson(Map<String, dynamic> json) {
    return AdminLessonmodel(
      lessonId: int.parse(json['lessonId']?.toString() ?? '0'),
      moduleId: int.parse(json['moduleId']?.toString() ?? '0'),
      courseId: int.parse(json['courseId']?.toString() ?? '0'),
      batchId: int.parse(json['batchId']?.toString() ?? '0'),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      videoLink: json['videoLink'] ?? '',
      pdfPath: json['pdfPath'],
      status: json['status'] ?? '',
    );
  }
}

class AdminCourseBatch {
  final int batchId;
  final String batchName;

  AdminCourseBatch({
    required this.batchId,
    required this.batchName,
  });

  factory AdminCourseBatch.fromJson(Map<String, dynamic> json) {
    return AdminCourseBatch(
      batchId: json['batchId'],
      batchName: json['batchName'],
    );
  }
}

class AdminAllusersmodel {
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final int userId;

  AdminAllusersmodel({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.userId,
  });

  factory AdminAllusersmodel.fromJson(Map<String, dynamic> json) {
    return AdminAllusersmodel(
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      userId: json['userId'],
    );
  }
}

class AdminLiveLinkResponse {
  final String message;
  final String liveLink;
  final DateTime liveStartTime;

  AdminLiveLinkResponse({
    required this.message,
    required this.liveLink,
    required this.liveStartTime,
  });

  factory AdminLiveLinkResponse.fromJson(Map<String, dynamic> json) {
    return AdminLiveLinkResponse(
      message: json['message'] as String,
      liveLink: json['liveLink'] as String,
      liveStartTime: DateTime.parse(json['liveStartTime'] as String),
    );
  }
}

class Quizmodel {
  final int id;
  final String name;
  final String description;
  final List<QuestionModel> questions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Quizmodel({
    required this.id,
    required this.name,
    required this.description,
    required this.questions,
    this.createdAt,
    this.updatedAt,
  });

  factory Quizmodel.fromJson(Map<String, dynamic> json) {
    return Quizmodel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      questions: (json['questions'] as List?)
              ?.map((q) => QuestionModel.fromJson(q))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}

class QuestionModel {
  final String text;
  final List<AnswerModel> answers;

  QuestionModel({
    required this.text,
    required this.answers,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      text: json['text'],
      answers: (json['answers'] as List)
          .map((a) => AnswerModel.fromJson(a))
          .toList(),
    );
  }
}

class AnswerModel {
  final String text;
  final bool isCorrect;

  AnswerModel({
    required this.text,
    required this.isCorrect,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      text: json['text'],
      isCorrect: json['isCorrect'],
    );
  }
}

class AssignmentModel {
  final int assignmentId;
  final int courseId;
  final int moduleId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String submissionLink;

  AssignmentModel({
    required this.assignmentId,
    required this.courseId,
    required this.moduleId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.submissionLink,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      assignmentId: json['assignmentId'] ?? 0,
      courseId: json['courseId'] ?? 0,
      moduleId: json['moduleId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : DateTime.now(),
      submissionLink: json['submissionLink'] ?? '',
    );
  }
}

class BatchStudentModel {
  final String message;
  final int courseId;
  final String courseName;
  final int batchId;
  final String batchName;
  final List<Student> students;

  BatchStudentModel({
    required this.message,
    required this.courseId,
    required this.courseName,
    required this.batchId,
    required this.batchName,
    required this.students,
  });

  factory BatchStudentModel.fromJson(Map<String, dynamic> json) {
    return BatchStudentModel(
      message: json['message'] as String,
      courseId: json['courseId'] as int,
      courseName: json['courseName'] as String,
      batchId: json['batchId'] as int,
      batchName: json['batchName'] as String,
      students: (json['students'] as List<dynamic>)
          .map((student) => Student.fromJson(student as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Student {
  final int studentId;
  final String name;
  final String email;

  Student({
    required this.studentId,
    required this.name,
    required this.email,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'name': name,
      'email': email,
    };
  }
}

class UnapprovedUser {
  final int userId;
  final String name;
  final String email;
  final String role;
  final String? phoneNumber; // Added optional phone number field

  UnapprovedUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber, // Optional field
  });

  factory UnapprovedUser.fromJson(Map<String, dynamic> json) {
    return UnapprovedUser(
      userId: json['userId'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      phoneNumber: json['phoneNumber'], // Parse phone number from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
    };
  }
}


