// utils/service_mapper.dart - UPDATED VERSION WITH BABYSITTING SUBTYPES
class ServiceMapper {
  static const Map<String, Map<String, dynamic>> professionalServices = {
    // FIXED: Use the actual service type names that come from your app
    'plumbing': {
      'name': 'Professional Plumbing',
      'slug': 'professional-plumbing',
      'categoryId': '68eab131001131897a342d85',
    },
    'electrical': {
      'name': 'Electrical Services',
      'slug': 'electrical-services',
      'categoryId': '68eab131001131897a342d8f',
    },
    'mechanical': {
      'name': 'Mechanical Services',
      'slug': 'mechanical-services',
      'categoryId': '68eab132001131897a342d99',
    },
    'carpentry': {
      'name': 'Carpentry Services',
      'slug': 'carpentry-services',
      'categoryId': '68eab132001131897a342da2',
    },
    'painting': {
      'name': 'Painting Services',
      'slug': 'painting-services',
      'categoryId': '68eab133001131897a342dac',
    },
    'fashion': {
      'name': 'Fashion Services',
      'slug': 'fashion-services',
      'categoryId': '68eab133001131897a342db6',
    },
    'beauty': {
      'name': 'Beauty Services',
      'slug': 'beauty-services',
      'categoryId': '68eab134001131897a342dbf',
    },
    'errand': {
      'name': 'Errand Services',
      'slug': 'errand-services',
      'categoryId': '68eab134001131897a342dc9',
    },
    'delivery': {
      'name': 'Delivery Services',
      'slug': 'delivery-services',
      'categoryId': '68eab134001131897a342dd2',
    },
    'moving': {
      'name': 'Moving Services',
      'slug': 'moving-services',
      'categoryId': '68eab135001131897a342ddb',
    },
    'cleaning': {
      'name': 'Cleaning Services',
      'slug': 'cleaning-services',
      'categoryId': '68eab135001131897a342de4',
    },
    'laundry': { // ADDED: Map laundry to use cleaning category
      'name': 'Laundry Services',
      'slug': 'laundry-services',
      'categoryId': '68eab135001131897a342de4', // Same as cleaning
    },
    'babysitting': {
      'name': 'Babysitting Services',
      'slug': 'babysitting-services',
      'categoryId': '68eab136001131897a342ded',
    },
    'child_babysitting': { // ADDED: Child babysitting subtype
      'name': 'Child Babysitting',
      'slug': 'child-babysitting',
      'categoryId': '68eab136001131897a342ded', // Same as babysitting
    },
    'animal_babysitting': { // ADDED: Animal babysitting subtype
      'name': 'Pet Care Services',
      'slug': 'pet-care-services',
      'categoryId': '68eab136001131897a342ded', // Same as babysitting
    },
    'personal': {
      'name': 'Personal Assistance',
      'slug': 'personal-assistance',
      'categoryId': '68eab136001131897a342df5',
    },
    'grocery': {
      'name': 'Grocery Shopping',
      'slug': 'grocery-shopping',
      'categoryId': '68eab134001131897a342dc9', // Same as errand
    },
  };

  static String? getCategoryId(String serviceType) {
    // Handle case-insensitive matching and aliases
    final normalizedType = serviceType.toLowerCase();

    // First try exact match
    if (professionalServices.containsKey(normalizedType)) {
      return professionalServices[normalizedType]?['categoryId'];
    }

    // Handle common aliases
    final aliases = {
      'laundry': 'cleaning', // Map laundry to cleaning
      'wash': 'cleaning',
      'housekeeping': 'cleaning',
      'shopping': 'grocery',
      'movers': 'moving',
      'childcare': 'child_babysitting', // Map childcare to child_babysitting
      'child care': 'child_babysitting',
      'petcare': 'animal_babysitting', // Map petcare to animal_babysitting
      'pet care': 'animal_babysitting',
      'animal care': 'animal_babysitting',
    };

    if (aliases.containsKey(normalizedType)) {
      return professionalServices[aliases[normalizedType]!]?['categoryId'];
    }

    return null;
  }

  static String? getCategoryName(String serviceType) {
    final normalizedType = serviceType.toLowerCase();

    if (professionalServices.containsKey(normalizedType)) {
      return professionalServices[normalizedType]?['name'];
    }

    // Handle aliases for display names too
    final aliasNames = {
      'laundry': 'Laundry Services',
      'wash': 'Laundry Services',
      'housekeeping': 'Cleaning Services',
      'childcare': 'Child Babysitting',
      'child care': 'Child Babysitting',
      'petcare': 'Pet Care Services',
      'pet care': 'Pet Care Services',
      'animal care': 'Pet Care Services',
    };

    return aliasNames[normalizedType] ?? professionalServices[normalizedType]?['name'];
  }

  static bool isProfessionalService(String serviceType) {
    final normalizedType = serviceType.toLowerCase();
    return professionalServices.containsKey(normalizedType);
  }

  // NEW: Check if service is a babysitting subtype
  static bool isBabysittingService(String serviceType) {
    final normalizedType = serviceType.toLowerCase();
    return normalizedType == 'child_babysitting' ||
        normalizedType == 'animal_babysitting' ||
        normalizedType == 'babysitting';
  }

  // NEW: Get babysitting type for filtering
  static String? getBabysittingType(String serviceType) {
    final normalizedType = serviceType.toLowerCase();

    if (normalizedType == 'child_babysitting' ||
        normalizedType == 'childcare' ||
        normalizedType == 'child care') {
      return 'child';
    } else if (normalizedType == 'animal_babysitting' ||
        normalizedType == 'petcare' ||
        normalizedType == 'pet care' ||
        normalizedType == 'animal care') {
      return 'animal';
    }

    return null; // General babysitting
  }

  static List<String> getProfessionalServiceTypes() {
    return professionalServices.keys.toList();
  }
}