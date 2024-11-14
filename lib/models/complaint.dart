class Complaint {
  final String id;
  final String userId;
  final String rollNo;
  final String title;
  final String description;
  final String status;
  final List<String> photos;
  final double latitude;
  final double longitude;
  final String? building;
  final DateTime createdAt;
  final DateTime updatedAt;

  Complaint({
    required this.id,
    required this.userId,
    required this.rollNo,
    required this.title,
    required this.description,
    required this.status,
    required this.photos,
    required this.latitude,
    required this.longitude,
    this.building,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Complaint.fromMap(Map<String, dynamic> map) {
    return Complaint(
      id: map['\$id'] ?? '',
      userId: map['userId'] ?? '',
      rollNo: map['rollNo'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      photos: List<String>.from(map['photos'] ?? []),
      latitude: map['latitude'] ?? '',
      longitude: map['longitude'] ?? '',
      building: map['building'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'rollNo': rollNo,
      'title': title,
      'description': description,
      'status': status,
      'photos': photos,
      'latitude': latitude,
      'longitude': longitude,
      'building': building,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Location {
  final double latitude;
  final double longitude;
  final String building;

  Location({
    required this.latitude,
    required this.longitude,
    required this.building,
  });

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      building: map['building'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'building': building,
    };
  }
}
