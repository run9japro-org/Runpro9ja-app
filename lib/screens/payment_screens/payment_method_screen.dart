// lib/screens/payment_methods_screen.dart
import 'package:flutter/material.dart';
import 'package:runpro_9ja/services/payment_service.dart';

import '../../auth/Auth_services/auth_service.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final PaymentService _paymentService = PaymentService(AuthService());
  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final methods = await _paymentService.getSavedPaymentMethods();

      setState(() {
        _paymentMethods = methods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load payment methods: $e');
    }
  }

  // ========== ICON AND COLOR MAPPING ==========

  IconData _getPaymentMethodIcon(String iconName) {
    switch (iconName) {
      case 'credit_card':
        return Icons.credit_card_outlined;
      case 'account_balance':
        return Icons.account_balance_outlined;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet_outlined;
      case 'payment':
        return Icons.payment_outlined;
      default:
        return Icons.payment_outlined;
    }
  }

  Color _getPaymentMethodColor(String colorHex) {
    try {
      // Remove the 'FF' prefix if present and parse the hex color
      final hexCode = colorHex.startsWith('FF') ? colorHex.substring(2) : colorHex;
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (e) {
      return const Color(0xFF2E7D32); // Default green
    }
  }

  // ========== PAYMENT METHOD OPERATIONS ==========

  Future<void> _setDefaultPayment(String methodId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _paymentService.setDefaultPaymentMethod(methodId);

      setState(() {
        for (var method in _paymentMethods) {
          method.isDefault = method.id == methodId;
        }
        _isLoading = false;
      });

      _showSuccess('Default payment method updated');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to update default payment method: $e');
    }
  }

  Future<void> _deletePaymentMethod(String methodId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _paymentService.deletePaymentMethod(methodId);

      setState(() {
        _paymentMethods.removeWhere((method) => method.id == methodId);
        _isLoading = false;
      });

      _showSuccess('Payment method deleted');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to delete payment method: $e');
    }
  }

  void _addNewPaymentMethod() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddPaymentMethodSheet(
        onPaymentMethodAdded: () {
          _loadPaymentMethods(); // Reload the list
        },
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewPaymentMethod,
            tooltip: 'Add Payment Method',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _paymentMethods.isEmpty
          ? _buildEmptyState()
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDefaultPaymentSection(),
          const SizedBox(height: 24),
          _buildOtherPaymentMethods(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Payment Methods',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your preferred payment methods for faster checkout',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addNewPaymentMethod,
            icon: const Icon(Icons.add),
            label: const Text('Add Payment Method'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultPaymentSection() {
    final defaultMethod = _paymentMethods.where((method) => method.isDefault).firstOrNull;

    if (defaultMethod == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Default Payment Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        _buildPaymentMethodCard(defaultMethod, isDefault: true),
      ],
    );
  }

  Widget _buildOtherPaymentMethods() {
    final otherMethods = _paymentMethods.where((method) => !method.isDefault).toList();

    if (otherMethods.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Other Payment Methods',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        ...otherMethods.map((method) =>
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPaymentMethodCard(method, isDefault: false),
            ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method, {required bool isDefault}) {
    final icon = _getPaymentMethodIcon(method.iconName);
    final color = _getPaymentMethodColor(method.colorHex);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDefault
            ? BorderSide(color: const Color(0xFF2E7D32).withOpacity(0.3), width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Row(
          children: [
            Text(
              method.displayName,
              style: TextStyle(
                fontWeight: isDefault ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: method.expiryDisplay.isNotEmpty
            ? Text('Expires ${method.expiryDisplay}')
            : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'set_default':
                if (!isDefault) {
                  _setDefaultPayment(method.id);
                }
                break;
              case 'delete':
                _deletePaymentMethod(method.id);
                break;
            }
          },
          itemBuilder: (context) => [
            if (!isDefault)
              const PopupMenuItem(
                value: 'set_default',
                child: Row(
                  children: [
                    Icon(Icons.star, size: 20),
                    SizedBox(width: 8),
                    Text('Set as Default'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddPaymentMethodSheet extends StatefulWidget {
  final Function() onPaymentMethodAdded;

  const AddPaymentMethodSheet({
    super.key,
    required this.onPaymentMethodAdded,
  });

  @override
  State<AddPaymentMethodSheet> createState() => _AddPaymentMethodSheetState();
}

class _AddPaymentMethodSheetState extends State<AddPaymentMethodSheet> {
  final PaymentService _paymentService = PaymentService(AuthService());
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'card';
  bool _isLoading = false;

  // Card fields
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  // Bank fields
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  Future<void> _savePaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> paymentData = {
        'type': _selectedType,
      };

      if (_selectedType == 'card') {
        paymentData.addAll({
          'cardNumber': _cardNumberController.text.replaceAll(' ', ''),
          'expiryMonth': _expiryMonthController.text,
          'expiryYear': _expiryYearController.text,
          'cvv': _cvvController.text,
          'cardHolder': _cardHolderController.text,
        });
      } else if (_selectedType == 'bank') {
        paymentData.addAll({
          'bankName': _bankNameController.text,
          'accountNumber': _accountNumberController.text,
          'accountName': _accountNameController.text,
        });
      }

      await _paymentService.savePaymentMethod(paymentData);

      widget.onPaymentMethodAdded();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment method saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save payment method: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildCardForm() {
    return Column(
      children: [
        TextFormField(
          controller: _cardNumberController,
          decoration: const InputDecoration(
            labelText: 'Card Number',
            hintText: '1234 5678 9012 3456',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card number';
            }
            if (value.replaceAll(' ', '').length != 16) {
              return 'Card number must be 16 digits';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryMonthController,
                decoration: const InputDecoration(
                  labelText: 'MM',
                  hintText: '12',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'MM';
                  }
                  final month = int.tryParse(value);
                  if (month == null || month < 1 || month > 12) {
                    return 'Invalid month';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _expiryYearController,
                decoration: const InputDecoration(
                  labelText: 'YY',
                  hintText: '25',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'YY';
                  }
                  final year = int.tryParse(value);
                  if (year == null || year < DateTime.now().year % 100) {
                    return 'Invalid year';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'CVV required';
                  }
                  if (value.length < 3) {
                    return 'Invalid CVV';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cardHolderController,
          decoration: const InputDecoration(
            labelText: 'Card Holder Name',
            hintText: 'John Doe',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card holder name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBankForm() {
    return Column(
      children: [
        TextFormField(
          controller: _bankNameController,
          decoration: const InputDecoration(
            labelText: 'Bank Name',
            hintText: 'GTBank, First Bank, etc.',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter bank name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _accountNumberController,
          decoration: const InputDecoration(
            labelText: 'Account Number',
            hintText: '0123456789',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter account number';
            }
            if (value.length != 10) {
              return 'Account number must be 10 digits';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _accountNameController,
          decoration: const InputDecoration(
            labelText: 'Account Name',
            hintText: 'John Doe',
            border: OutlineInputBorder(),
            enabled: false, // This would typically be auto-filled from bank verification
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Payment Type Selection
            const Text(
              'Payment Type',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTypeChip('card', 'Card', Icons.credit_card),
                const SizedBox(width: 8),
                _buildTypeChip('bank', 'Bank', Icons.account_balance),
              ],
            ),
            const SizedBox(height: 20),

            // Dynamic Form
            _selectedType == 'card' ? _buildCardForm() : _buildBankForm(),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _savePaymentMethod,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Save Payment Method'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2E7D32).withOpacity(0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF2E7D32) : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}