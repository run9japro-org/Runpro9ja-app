import 'dart:convert';

import 'package:flutter/material.dart';
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
    print('🔄 Parsing CustomerProfile from JSON: ${json.keys.toList()}');

    // Handle nested 'user' object or direct fields
    final data = json['user'] ?? json;

    return CustomerProfile(
      id: _parseString(data['_id']) ?? _parseString(data['id']) ?? '',
      fullName: _parseString(data['fullName']) ??
          _parseString(data['name']) ??
          'Customer',
      email: _parseString(data['email']) ?? 'No email',
      phone: _parseString(data['phone']) ?? 'No phone',
      profileImage: _parseString(data['profileImage']) ??
          _parseString(data['avatarUrl']),
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(data['updatedAt']) ?? DateTime.now(),
    );
  }

  // Helper method to safely parse strings
  static String? _parseString(dynamic value) {
    if (value == null) return null;
    final stringValue = value.toString().trim();
    return stringValue.isEmpty ? null : stringValue;
  }

  // Helper method to safely parse dates
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      print('❌ Error parsing date: $value, error: $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
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
  static double safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('❌ Error parsing string to double: $value');
        return 0.0;
      }
    }
    return 0.0;
  }
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

    // Parse price first to debug
    final parsedPrice = _parsePrice(orderData);
    print('💰 Parsed price: $parsedPrice');

    return CustomerOrder(
      id: orderData['_id'] ?? orderData['id'] ?? '',
      serviceCategory: _parseServiceCategory(orderData),
      description: orderData['details'] ?? orderData['description'] ?? '',
      location: orderData['location'] ?? '',
      price: parsedPrice, // Use the properly parsed price
      status: orderData['status'] ?? 'requested',
      createdAt: _parseDateTime(orderData['createdAt']) ?? DateTime.now(),
      scheduledDate: _parseDateTime(orderData['scheduledDate']),
      assignedAgent: orderData['assignedAgent'],
      agent: orderData['agent'] is Map ? Map<String, dynamic>.from(orderData['agent']) : null,
      isPublic: orderData['isPublic'] ?? false,
      isDirectOffer: orderData['isDirectOffer'] ?? false,
      orderType: orderData['orderType'],
      quotationDetails: orderData['quotationDetails'],
      quotationAmount: safeToDouble(orderData['quotationAmount']), // Use the same helper
      quotationProvidedAt: _parseDateTime(orderData['quotationProvidedAt']),
      recommendedAgents: orderData['recommendedAgents'],
      representative: orderData['representative'],
      serviceCategoryId: _parseServiceCategoryId(orderData),
      serviceScale: orderData['serviceScale'],
    );
  }
// FIXED: Enhanced price parsing method with proper type handling
  // FIXED: Enhanced price parsing method that checks details field properly
  // FIXED: Enhanced price parsing method that extracts price from text details
  static double _parsePrice(Map<String, dynamic> json) {
    print('💰 Parsing price from JSON keys: ${json.keys.toList()}');

    // Helper function to safely convert to double
    double safeToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          print('❌ Error parsing string to double: $value');
          return 0.0;
        }
      }
      return 0.0;
    }

    // Helper function to extract price from text using regex
    double extractPriceFromText(String text) {
      try {
        // Look for patterns like "₦2000", "Total Amount: ₦2000", "NGN 2000", etc.
        final regex = RegExp(r'(?:₦|NGN|Naira|Total.*?)(\d+(?:\.\d+)?)');
        final match = regex.firstMatch(text);

        if (match != null) {
          final priceString = match.group(1);
          final price = safeToDouble(priceString);
          print('✅ Extracted price from text: $price');
          return price;
        }

        // Alternative pattern for "2000" directly
        final simpleRegex = RegExp(r'\b(\d+(?:\.\d+)?)\s*(?:₦|NGN)?\b');
        final simpleMatch = simpleRegex.firstMatch(text);

        if (simpleMatch != null) {
          final priceString = simpleMatch.group(1);
          final price = safeToDouble(priceString);
          print('✅ Extracted price using simple pattern: $price');
          return price;
        }

        return 0.0;
      } catch (e) {
        print('❌ Error extracting price from text: $e');
        return 0.0;
      }
    }

    // First, check if details is a Map and contains price information
    if (json['details'] != null) {
      print('🔍 Checking details field: ${json['details']}');

      if (json['details'] is Map) {
        final details = json['details'] as Map<String, dynamic>;
        print('📋 Details keys: ${details.keys.toList()}');

        // Check for various price fields in details map
        if (details['totalAmount'] != null) {
          final total = safeToDouble(details['totalAmount']);
          print('✅ Using details.totalAmount field: $total');
          return total;
        }
        if (details['price'] != null) {
          final price = safeToDouble(details['price']);
          print('✅ Using details.price field: $price');
          return price;
        }
        if (details['amount'] != null) {
          final amount = safeToDouble(details['amount']);
          print('✅ Using details.amount field: $amount');
          return amount;
        }
        if (details['totalPrice'] != null) {
          final totalPrice = safeToDouble(details['totalPrice']);
          print('✅ Using details.totalPrice field: $totalPrice');
          return totalPrice;
        }
      } else if (json['details'] is String) {
        final detailsText = json['details'] as String;
        print('📝 Details is text, extracting price from: $detailsText');

        // Extract price from the text details
        final extractedPrice = extractPriceFromText(detailsText);
        if (extractedPrice > 0) {
          print('✅ Successfully extracted price from text: $extractedPrice');
          return extractedPrice;
        }
      }
    }

    // Check top-level price fields
    if (json['price'] != null) {
      final price = safeToDouble(json['price']);
      print('✅ Using top-level price field: $price');
      return price;
    }

    if (json['quotationAmount'] != null) {
      final amount = safeToDouble(json['quotationAmount']);
      print('✅ Using top-level quotationAmount field: $amount');
      return amount;
    }

    if (json['totalAmount'] != null) {
      final total = safeToDouble(json['totalAmount']);
      print('✅ Using top-level totalAmount field: $total');
      return total;
    }

    if (json['amount'] != null) {
      final amount = safeToDouble(json['amount']);
      print('✅ Using top-level amount field: $amount');
      return amount;
    }

    print('❌ No price field found in any location!');

    // Since we know the details contain "Total Amount: ₦2000", let's try one more extraction
    if (json['details'] is String) {
      final detailsText = json['details'] as String;
      print('🔄 Final attempt to extract from: $detailsText');

      // Direct search for the total amount line
      final lines = detailsText.split('\n');
      for (final line in lines) {
        if (line.contains('Total Amount') || line.contains('₦')) {
          final price = extractPriceFromText(line);
          if (price > 0) {
            print('✅ Extracted from specific line: $price');
            return price;
          }
        }
      }
    }

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
// Helper method to extract price from text details
  static double extractPriceFromDetails(String detailsText) {
    try {
      // Look for patterns like "₦2000", "Total Amount: ₦2000"
      final regex = RegExp(r'(?:₦|NGN|Total.*?)(\d+(?:\.\d+)?)');
      final match = regex.firstMatch(detailsText);

      if (match != null) {
        final priceString = match.group(1);
        return double.parse(priceString!);
      }

      return 0.0;
    } catch (e) {
      print('❌ Error extracting price from details: $e');
      return 0.0;
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