// models/assistant_model.dart
class Assistant {
  final String id;
  final String name;
  final String image;
  final int age;
  final double distance;
  final double hourlyRate;
  final String timeAvailability;
  final double rating;
  final int reviewCount;
  final String description;
  final List<String> characteristics;
  final List<String> categories;
  final int yearsOfExperience;
  final int completedJobs;

  Assistant({
    required this.id,
    required this.name,
    required this.image,
    required this.age,
    required this.distance,
    required this.hourlyRate,
    required this.timeAvailability,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.characteristics,
    required this.categories,
    required this.yearsOfExperience,
    required this.completedJobs,
  });

  factory Assistant.fromJson(Map<String, dynamic> json) {
    return Assistant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      age: json['age'] ?? 0,
      distance: (json['distance'] ?? 0).toDouble(),
      hourlyRate: (json['hourlyRate'] ?? 0).toDouble(),
      timeAvailability: json['timeAvailability'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      description: json['description'] ?? '',
      characteristics: List<String>.from(json['characteristics'] ?? []),
      categories: List<String>.from(json['categories'] ?? []),
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      completedJobs: json['completedJobs'] ?? 0,
    );
  }

  String get reviews => '$reviewCount reviews';
  String get displayName => name;
  double get price => hourlyRate;
}

// models/booking_model.dart
class BookingRequest {
  final String assistantId;
  final String clientName;
  final String location;
  final String? organizationName;
  final String specificRole;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String address;
  final String category;
  final String? specialRequirements;

  BookingRequest({
    required this.assistantId,
    required this.clientName,
    required this.location,
    this.organizationName,
    required this.specificRole,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.address,
    required this.category,
    this.specialRequirements,
  });

  Map<String, dynamic> toJson() {
    return {
      'assistantId': assistantId,
      'clientName': clientName,
      'location': location,
      'organizationName': organizationName,
      'specificRole': specificRole,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'address': address,
      'category': category,
      'specialRequirements': specialRequirements,
    };
  }
}