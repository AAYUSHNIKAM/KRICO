import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/utils/date_parser.dart';

class JobPostModel {
  final String id;
  final String academyId;
  final String academyName;
  final String title;
  final String sport;
  final String description;
  final String salaryRange;
  final String location;
  final int openings;
  final bool isActive;
  final DateTime? createdAt;

  const JobPostModel({
    required this.id,
    required this.academyId,
    required this.academyName,
    required this.title,
    required this.sport,
    required this.description,
    required this.salaryRange,
    required this.location,
    this.openings = 1,
    this.isActive = true,
    this.createdAt,
  });

  factory JobPostModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return JobPostModel(
      id: doc.id,
      academyId: data['academyId'] as String? ?? '',
      academyName: data['academyName'] as String? ?? 'Sports Academy',
      title: data['title'] as String? ?? 'Head Coach',
      sport: data['sport'] as String? ?? 'General',
      description: data['description'] as String? ?? '',
      salaryRange: data['salaryRange'] as String? ?? 'Negotiable',
      location: data['location'] as String? ?? 'All Locations',
      openings: (data['openings'] as num?)?.toInt() ?? 1,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: parseTimestamp(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'academyId': academyId,
    'academyName': academyName,
    'title': title,
    'sport': sport,
    'description': description,
    'salaryRange': salaryRange,
    'location': location,
    'openings': openings,
    'isActive': isActive,
    'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
  };
}

class JobApplicationModel {
  final String id;
  final String jobId;
  final String coachId;
  final String coachName;
  final String status;
  final DateTime appliedAt;
  final DateTime? interviewDate;
  final String? offerSalary;
  final String? offerNotes;

  const JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.coachId,
    required this.coachName,
    this.status = 'applied',
    required this.appliedAt,
    this.interviewDate,
    this.offerSalary,
    this.offerNotes,
  });

  factory JobApplicationModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return JobApplicationModel(
      id: doc.id,
      jobId: data['jobId'] as String? ?? '',
      coachId: data['coachId'] as String? ?? '',
      coachName: data['coachName'] as String? ?? 'Coach',
      status: data['status'] as String? ?? 'applied',
      appliedAt: parseTimestamp(data['appliedAt']) ?? DateTime.now(),
      interviewDate: parseTimestamp(data['interviewDate']),
      offerSalary: data['offerSalary'] as String?,
      offerNotes: data['offerNotes'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'jobId': jobId,
    'coachId': coachId,
    'coachName': coachName,
    'status': status,
    'appliedAt': Timestamp.fromDate(appliedAt),
    if (interviewDate != null) 'interviewDate': Timestamp.fromDate(interviewDate!),
    if (offerSalary != null) 'offerSalary': offerSalary,
    if (offerNotes != null) 'offerNotes': offerNotes,
  };

  JobApplicationModel copyWith({
    String? status,
    DateTime? interviewDate,
    String? offerSalary,
    String? offerNotes,
  }) {
    return JobApplicationModel(
      id: id,
      jobId: jobId,
      coachId: coachId,
      coachName: coachName,
      status: status ?? this.status,
      appliedAt: appliedAt,
      interviewDate: interviewDate ?? this.interviewDate,
      offerSalary: offerSalary ?? this.offerSalary,
      offerNotes: offerNotes ?? this.offerNotes,
    );
  }
}

typedef JobModel = JobPostModel;
