// utils/service_mapper.dart - FIXED VERSION
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
    'babysitting': {
      'name': 'Babysitting Services',
      'slug': 'babysitting-services',
      'categoryId': '68eab136001131897a342ded',
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
    return professionalServices[serviceType]?['categoryId'];
  }

  static String? getCategoryName(String serviceType) {
    return professionalServices[serviceType]?['name'];
  }

  static bool isProfessionalService(String serviceType) {
    return professionalServices.containsKey(serviceType);
  }

  static List<String> getProfessionalServiceTypes() {
    return professionalServices.keys.toList();
  }
}