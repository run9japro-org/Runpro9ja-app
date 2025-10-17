// models/agent_model.dart - FIXED FOR YOUR BACKEND DATA
class Agent {
  final String id;
  final String userId;
  final String serviceType;
  final String yearsOfExperience;
  final String availability;
  final String summary;
  final String servicesOffered;
  final String areasOfExpertise;
  final double rating;
  final int completedJobs;
  final bool isVerified;
  final String profileImage;
  final String bio;
  final String? certification;
  final String? subCategory;
  final double price;
  final String responseTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? location;
  final List<String>? vehicleTypes;
  final List<dynamic>? services;
  final int? v;

  // Add user data fields for populated user
  final String? fullName;
  final String? email;
  final String? phone;

  Agent({
    required this.id,
    required this.userId,
    required this.serviceType,
    required this.yearsOfExperience,
    required this.availability,
    required this.summary,
    required this.servicesOffered,
    required this.areasOfExpertise,
    required this.rating,
    required this.completedJobs,
    required this.isVerified,
    required this.profileImage,
    required this.bio,
    this.certification,
    this.subCategory,
    required this.price,
    required this.responseTime,
    required this.createdAt,
    required this.updatedAt,
    this.location,
    this.vehicleTypes,
    this.services,
    this.v,
    // New user fields
    this.fullName,
    this.email,
    this.phone,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    // Handle user data if populated
    String? fullName;
    String? email;
    String? phone;

    if (json['user'] is Map<String, dynamic>) {
      final userData = json['user'];
      fullName = userData['fullName']?.toString();
      email = userData['email']?.toString();
      phone = userData['phone']?.toString();
    }

    // Handle rating - it can be int or double
    double rating;
    if (json['rating'] is int) {
      rating = (json['rating'] as int).toDouble();
    } else {
      rating = (json['rating'] as double?) ?? 0.0;
    }

    // Handle completedJobs - it can be int or Map with $numberInt
    int completedJobs;
    if (json['completedJobs'] is int) {
      completedJobs = json['completedJobs'] as int;
    } else if (json['completedJobs'] is Map && json['completedJobs']['\$numberInt'] != null) {
      completedJobs = int.parse(json['completedJobs']['\$numberInt'].toString());
    } else {
      completedJobs = 0;
    }

    // Handle createdAt - it can be String or Map with $date
    DateTime createdAt;
    if (json['createdAt'] is String) {
      createdAt = DateTime.parse(json['createdAt']);
    } else if (json['createdAt'] is Map && json['createdAt']['\$date'] != null) {
      final dateMap = json['createdAt']['\$date'];
      if (dateMap is Map && dateMap['\$numberLong'] != null) {
        createdAt = DateTime.fromMillisecondsSinceEpoch(int.parse(dateMap['\$numberLong'].toString()));
      } else {
        createdAt = DateTime.now();
      }
    } else {
      createdAt = DateTime.now();
    }

    // Handle updatedAt - same logic as createdAt
    DateTime updatedAt;
    if (json['updatedAt'] is String) {
      updatedAt = DateTime.parse(json['updatedAt']);
    } else if (json['updatedAt'] is Map && json['updatedAt']['\$date'] != null) {
      final dateMap = json['updatedAt']['\$date'];
      if (dateMap is Map && dateMap['\$numberLong'] != null) {
        updatedAt = DateTime.fromMillisecondsSinceEpoch(int.parse(dateMap['\$numberLong'].toString()));
      } else {
        updatedAt = DateTime.now();
      }
    } else {
      updatedAt = DateTime.now();
    }

    // Calculate dynamic price based on service type and experience
    double calculatePrice() {
      final basePrice = _getBasePriceForService(json['serviceType']?.toString() ?? '');
      final experience = json['yearsOfExperience']?.toString();
      final multiplier = _getExperienceMultiplier(experience);
      return basePrice * multiplier;
    }

    return Agent(
      id: json['_id']?.toString() ?? '',
      userId: json['user'] is String ? json['user'] : json['user']?['_id']?.toString() ?? '',
      serviceType: json['serviceType']?.toString() ?? 'Professional Service',
      yearsOfExperience: json['yearsOfExperience']?.toString() ?? '0',
      availability: json['availability']?.toString() ?? 'Available',
      summary: json['summary']?.toString() ?? '',
      servicesOffered: json['servicesOffered']?.toString() ?? '',
      areasOfExpertise: json['areasOfExpertise']?.toString() ?? '',
      rating: rating,
      completedJobs: completedJobs,
      isVerified: json['isVerified'] ?? false,
      profileImage: json['profileImage']?.toString() ?? '',
      bio: json['bio']?.toString() ?? json['summary']?.toString() ?? 'Professional Service Provider',
      certification: json['certification']?.toString(),
      subCategory: json['subCategory']?.toString(),
      price: calculatePrice(), // Use calculated price instead of fixed price
      responseTime: json['responseTime']?.toString() ?? '30 mins',
      createdAt: createdAt,
      updatedAt: updatedAt,
      location: json['location'] is Map ? Map<String, dynamic>.from(json['location']) : null,
      vehicleTypes: json['vehicleTypes'] is List ? List<String>.from(json['vehicleTypes']) : null,
      services: json['services'] is List ? List<dynamic>.from(json['services']) : [],
      v: json['__v'] is int ? json['__v'] : null,
      // User data
      fullName: fullName,
      email: email,
      phone: phone,
    );
  }

  // FIX: Improved displayName to use actual user name if available
  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }
    if (bio.isNotEmpty) {
      final words = bio.split(' ');
      if (words.length >= 2) {
        return '${words[0]} ${words[1]}';
      }
      return bio;
    }
    return '${subCategory ?? serviceType} Expert';
  }

  // FIX: Improved displayLocation
  String get displayLocation {
    if (location != null && location!['address'] != null) {
      return location!['address'];
    }
    return availability.isNotEmpty ? availability : 'Location not specified';
  }

  double get distance {
    // You can implement actual distance calculation later
    return (1 + (DateTime.now().millisecond % 10)).toDouble(); // Random distance for demo
  }

  // Helper methods for pricing
  static double _getBasePriceForService(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'plumbing':
        return 5000.0;
      case 'electrical':
        return 4500.0;
      case 'carpentry':
        return 4000.0;
      case 'painting':
        return 3500.0;
      case 'cleaning':
        return 3000.0;
      case 'beauty':
        return 6000.0;
      case 'fashion':
        return 5500.0;
      case 'professional service':
        return 4000.0;
      default:
        return 4000.0;
    }
  }

  static double _getExperienceMultiplier(String? experience) {
    if (experience == null) return 1.0;

    final years = int.tryParse(experience) ?? 0;
    if (years >= 10) return 1.8;
    if (years >= 5) return 1.5;
    if (years >= 3) return 1.3;
    if (years >= 1) return 1.1;
    return 1.0;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'serviceType': serviceType,
      'yearsOfExperience': yearsOfExperience,
      'availability': availability,
      'summary': summary,
      'servicesOffered': servicesOffered,
      'areasOfExpertise': areasOfExpertise,
      'rating': rating,
      'completedJobs': completedJobs,
      'isVerified': isVerified,
      'profileImage': profileImage,
      'bio': bio,
      'certification': certification,
      'subCategory': subCategory,
      'price': price,
      'responseTime': responseTime,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'location': location,
      'vehicleTypes': vehicleTypes,
      'services': services,
      '__v': v,
    };
  }
}