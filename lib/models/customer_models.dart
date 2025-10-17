import 'package:flutter/material.dart';

// models/customer_model.dart
class CustomerProfile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profileImage'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class CustomerOrder {
  final String id;
  final String serviceCategory;
  final String description;
  final String location;
  final double price;
  final String status;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final String? assignedAgent;
  final Map<String, dynamic>? agent;
  final bool isPublic;
  final bool isDirectOffer;

  // NEW: Professional service fields
  final String? orderType;
  final String? quotationDetails;
  final double? quotationAmount;
  final DateTime? quotationProvidedAt;
  final List<dynamic>? recommendedAgents;
  final String? representative;
  final String? serviceCategoryId; // The actual MongoDB ID

  // NEW: Service Scale field
  final String? serviceScale;

  CustomerOrder({
    required this.id,
    required this.serviceCategory,
    required this.description,
    required this.location,
    required this.price,
    required this.status,
    required this.createdAt,
    this.scheduledDate,
    this.assignedAgent,
    this.agent,
    required this.isPublic,
    required this.isDirectOffer,

    // New professional fields
    this.orderType,
    this.quotationDetails,
    this.quotationAmount,
    this.quotationProvidedAt,
    this.recommendedAgents,
    this.representative,
    this.serviceCategoryId,

    // NEW: Service Scale
    this.serviceScale,
  });

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    print('🔄 Creating CustomerOrder from JSON...');
    print('📋 JSON keys: ${json.keys.toList()}');

    // Extract the actual order data - handle nested structure
    Map<String, dynamic> orderData = json;

    // If this is the top-level response with nested order
    if (json['order'] != null && json['order'] is Map) {
      orderData = json['order'] as Map<String, dynamic>;
      print('✅ Using nested order data');
    }

    // If this is a success response with data
    if (json['data'] != null && json['data'] is Map) {
      final data = json['data'] as Map;
      if (data['order'] != null && data['order'] is Map) {
        orderData = data['order'] as Map<String, dynamic>;
        print('✅ Using data.order nested data');
      }
    }

    print('🎯 Final order data keys: ${orderData.keys.toList()}');

    return CustomerOrder(
      id: orderData['_id'] ?? orderData['id'] ?? '',
      serviceCategory: _parseServiceCategory(orderData),
      description: orderData['details'] ?? orderData['description'] ?? '',
      location: orderData['location'] ?? '',
      price: _parsePrice(orderData),
      status: orderData['status'] ?? 'requested',
        createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      scheduledDate: _parseDateTime(orderData['scheduledDate']),
      assignedAgent: orderData['assignedAgent'],
      agent: orderData['agent'] is Map ? Map<String, dynamic>.from(orderData['agent']) : null,
      isPublic: orderData['isPublic'] ?? false,
      isDirectOffer: orderData['isDirectOffer'] ?? false,

      // New professional fields
      orderType: orderData['orderType'],
      quotationDetails: orderData['quotationDetails'],
      quotationAmount: (orderData['quotationAmount'] ?? 0).toDouble(),
      quotationProvidedAt: _parseDateTime(orderData['quotationProvidedAt']),
      recommendedAgents: orderData['recommendedAgents'],
      representative: orderData['representative'],
      serviceCategoryId: _parseServiceCategoryId(orderData),

      // Service Scale
      serviceScale: orderData['serviceScale'],
    );
  }

// Helper method to parse price from different possible fields
  static double _parsePrice(Map<String, dynamic> json) {
    if (json['price'] != null) return json['price'].toDouble();
    if (json['quotationAmount'] != null) return json['quotationAmount'].toDouble();
    if (json['totalAmount'] != null) return json['totalAmount'].toDouble();
    return 0.0;
  }

// Helper method to parse DateTime safely
  static DateTime? _parseDateTime(dynamic dateString) {
    try {
      if (dateString == null) return null;
      if (dateString is DateTime) return dateString;
      if (dateString is String) return DateTime.parse(dateString);
      return null;
    } catch (e) {
      print('❌ Error parsing date: $dateString');
      return null;
    }
  }

  // Helper method to parse service category name
  static String _parseServiceCategory(Map<String, dynamic> json) {
    if (json['serviceCategory'] is String) {
      return json['serviceCategory'];
    } else if (json['serviceCategory'] is Map) {
      return json['serviceCategory']['name'] ?? 'Unknown Service';
    }
    return 'General Service';
  }
  static CustomerOrder? fromResponse(dynamic response) {
    try {
      if (response is Map) {
        print('🔍 Converting response to CustomerOrder...');
        print('📋 Response keys: ${response.keys.toList()}');

        // If the response has an 'order' field, use that
        if (response['order'] != null && response['order'] is Map) {
          print('✅ Found nested order field');
          final orderData = response['order'] as Map<String, dynamic>;
          print('📦 Order data keys: ${orderData.keys.toList()}');
          return CustomerOrder.fromJson(orderData);
        }

        // If the response has a 'data' field with 'order', use that
        if (response['data'] != null && response['data'] is Map) {
          final data = response['data'] as Map;
          if (data['order'] != null && data['order'] is Map) {
            print('✅ Found data.order field');
            return CustomerOrder.fromJson(data['order'] as Map<String, dynamic>);
          }
        }

        // Otherwise, try to use the response directly
        print('✅ Using response directly');
        return CustomerOrder.fromJson(response as Map<String, dynamic>);
      }

      print('❌ Response is not a Map: ${response.runtimeType}');
      return null;
    } catch (e) {
      print('❌ Error converting response to CustomerOrder: $e');
      print('📋 Response that failed: $response');
      return null;
    }
  }
  // Helper method to parse service category ID
  static String? _parseServiceCategoryId(Map<String, dynamic> json) {
    if (json['serviceCategory'] is String) {
      return json['serviceCategory']; // It's already the ID
    } else if (json['serviceCategory'] is Map) {
      return json['serviceCategory']['_id'] ?? json['serviceCategory']['id'];
    }
    return null;
  }

  // Getter to check if this is a minimum scale order
  bool get isMinimumScale {
    return serviceScale == 'minimum';
  }

  // Getter to check if this is a large scale order
  bool get isLargeScale {
    return serviceScale == 'large_scale';
  }

  // Getter for service scale display text
  String get serviceScaleText {
    switch (serviceScale) {
      case 'minimum':
        return 'Minimum Scale';
      case 'large_scale':
        return 'Large Scale';
      default:
        return 'Standard';
    }
  }

  // Getter for service scale description
  String get serviceScaleDescription {
    switch (serviceScale) {
      case 'minimum':
        return 'Small job, direct agent booking';
      case 'large_scale':
        return 'Major project, representative inspection';
      default:
        return 'Standard service';
    }
  }

  // Getter for service scale icon
  IconData get serviceScaleIcon {
    switch (serviceScale) {
      case 'minimum':
        return Icons.build_circle;
      case 'large_scale':
        return Icons.engineering;
      default:
        return Icons.build;
    }
  }

  String get formattedPrice {
    return '₦${price.toStringAsFixed(2)}';
  }

  String get statusText {
    switch (status) {
      case 'requested':
        return isLargeScale ? 'Awaiting Inspection' : 'Requested';
      case 'accepted': return 'Accepted';
      case 'in-progress': return 'In Progress';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      case 'quotation_provided': return 'Quotation Ready';
      case 'quotation_accepted': return 'Quotation Accepted';
      case 'agent_selected': return 'Agent Selected';
      case 'inspection_scheduled': return 'Inspection Scheduled';
      case 'inspection_completed': return 'Inspection Completed';
      default: return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'requested': return Colors.orange;
      case 'accepted': return Colors.green;
      case 'in-progress': return Colors.blue;
      case 'completed': return Colors.grey;
      case 'cancelled': return Colors.red;
      case 'quotation_provided': return Colors.purple;
      case 'quotation_accepted': return Colors.teal;
      case 'agent_selected': return Colors.indigo;
      case 'inspection_scheduled': return Colors.blue;
      case 'inspection_completed': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'requested':
        return isLargeScale ? Icons.engineering : Icons.access_time;
      case 'accepted': return Icons.check_circle;
      case 'in-progress': return Icons.directions_car;
      case 'completed': return Icons.verified;
      case 'cancelled': return Icons.cancel;
      case 'quotation_provided': return Icons.attach_money;
      case 'quotation_accepted': return Icons.thumb_up;
      case 'agent_selected': return Icons.person;
      case 'inspection_scheduled': return Icons.calendar_today;
      case 'inspection_completed': return Icons.task_alt;
      default: return Icons.help;
    }
  }

  // Getter for next action based on status and service scale
  String get nextAction {
    if (isLargeScale) {
      switch (status) {
        case 'requested':
          return 'Waiting for representative inspection';
        case 'inspection_scheduled':
          return 'Inspection scheduled';
        case 'inspection_completed':
          return 'Waiting for quotation';
        case 'quotation_provided':
          return 'Review and accept quotation';
        case 'quotation_accepted':
          return 'Select an agent';
        case 'agent_selected':
          return 'Proceed to payment';
        default:
          return 'Processing';
      }
    } else {
      // Minimum scale flow
      switch (status) {
        case 'requested':
          return 'Select an agent';
        case 'agent_selected':
          return 'Proceed to payment';
        case 'accepted':
          return 'Waiting for service';
        case 'in-progress':
          return 'Service in progress';
        default:
          return 'Processing';
      }
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceCategory': serviceCategory,
      'description': description,
      'location': location,
      'price': price,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'scheduledDate': scheduledDate?.toIso8601String(),
      'assignedAgent': assignedAgent,
      'agent': agent,
      'isPublic': isPublic,
      'isDirectOffer': isDirectOffer,
      'orderType': orderType,
      'quotationDetails': quotationDetails,
      'quotationAmount': quotationAmount,
      'recommendedAgents': recommendedAgents,
      'serviceScale': serviceScale, // ADD THIS
    };
  }

  // Method to create a copy with updated fields
  CustomerOrder copyWith({
    String? id,
    String? serviceCategory,
    String? description,
    String? location,
    double? price,
    String? status,
    DateTime? createdAt,
    DateTime? scheduledDate,
    String? assignedAgent,
    Map<String, dynamic>? agent,
    bool? isPublic,
    bool? isDirectOffer,
    String? orderType,
    String? quotationDetails,
    double? quotationAmount,
    DateTime? quotationProvidedAt,
    List<dynamic>? recommendedAgents,
    String? representative,
    String? serviceCategoryId,
    String? serviceScale, // ADD THIS
  }) {
    return CustomerOrder(
      id: id ?? this.id,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      description: description ?? this.description,
      location: location ?? this.location,
      price: price ?? this.price,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      assignedAgent: assignedAgent ?? this.assignedAgent,
      agent: agent ?? this.agent,
      isPublic: isPublic ?? this.isPublic,
      isDirectOffer: isDirectOffer ?? this.isDirectOffer,
      orderType: orderType ?? this.orderType,
      quotationDetails: quotationDetails ?? this.quotationDetails,
      quotationAmount: quotationAmount ?? this.quotationAmount,
      quotationProvidedAt: quotationProvidedAt ?? this.quotationProvidedAt,
      recommendedAgents: recommendedAgents ?? this.recommendedAgents,
      representative: representative ?? this.representative,
      serviceCategoryId: serviceCategoryId ?? this.serviceCategoryId,
      serviceScale: serviceScale ?? this.serviceScale, // ADD THIS
    );
  }

}