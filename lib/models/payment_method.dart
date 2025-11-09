// models/payment_method.dart
class PaymentMethod {
  final String id;
  final String type; // 'card', 'bank', 'wallet'
  final String displayName;
  final String iconName;
  final String colorHex;
  final String expiryDisplay;
  final String? lastFourDigits;
  final String? bankName;
  final DateTime? createdAt;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.displayName,
    required this.iconName,
    required this.colorHex,
    required this.expiryDisplay,
    this.lastFourDigits,
    this.bankName,
    this.createdAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['_id'] ?? json['id'] ?? '',
      type: json['type'] ?? 'card',
      displayName: json['displayName'] ?? json['name'] ?? 'Payment Method',
      iconName: json['iconName'] ?? 'payment',
      colorHex: json['colorHex'] ?? 'FF2E7D32',
      expiryDisplay: json['expiryDisplay'] ?? json['expiry'] ?? '',
      lastFourDigits: json['lastFourDigits'],
      bankName: json['bankName'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'displayName': displayName,
      'iconName': iconName,
      'colorHex': colorHex,
      'expiryDisplay': expiryDisplay,
      'lastFourDigits': lastFourDigits,
      'bankName': bankName,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  String get maskedNumber {
    if (lastFourDigits != null && lastFourDigits!.isNotEmpty) {
      return '**** **** **** $lastFourDigits';
    }
    return displayName;
  }

  bool get isExpired {
    if (expiryDisplay.isEmpty) return false;

    try {
      final parts = expiryDisplay.split('/');
      if (parts.length == 2) {
        final month = int.tryParse(parts[0]);
        final year = int.tryParse(parts[1]);

        if (month != null && year != null) {
          final now = DateTime.now();
          final expiryDate = DateTime(2000 + year, month + 1, 0);
          return expiryDate.isBefore(now);
        }
      }
    } catch (e) {
      print('Error checking expiry: $e');
    }

    return false;
  }
}