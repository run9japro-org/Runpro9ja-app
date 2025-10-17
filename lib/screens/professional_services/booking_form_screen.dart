// professional_booking_form.dart - UPDATED WITH MECHANIC ADDED TO LARGE SCALE
import 'package:flutter/material.dart';
import 'package:runpro_9ja/screens/professional_services/waiting_quotation_screen.dart';
import 'package:runpro_9ja/services/customer_services.dart';
import '../../auth/Auth_services/auth_service.dart';
import '../../models/agent_model.dart';
import '../../models/customer_models.dart';
import '../../utils/service_mapper.dart';
import '../agents_screen/available_agent_screen.dart';
import 'minimum_scale_agent_selection.dart';
import 'professional_service_type_selection.dart';

enum ServiceScale {
  minimum('Minimum Scale', 'Small jobs, direct agent booking', Icons.build_circle),
  largeScale('Large Scale', 'Major projects, representative inspection', Icons.engineering);

  final String title;
  final String description;
  final IconData icon;

  const ServiceScale(this.title, this.description, this.icon);
}

class ProfessionalBookingForm extends StatefulWidget {
  final String serviceType;
  final String serviceName;
  final String serviceCategoryId;
  final String subCategory;

  const ProfessionalBookingForm({
    super.key,
    required this.serviceType,
    required this.serviceName,
    required this.serviceCategoryId,
    required this.subCategory,
  });

  @override
  State<ProfessionalBookingForm> createState() => _ProfessionalBookingFormState();
}

class _ProfessionalBookingFormState extends State<ProfessionalBookingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late final CustomerService customerService;
  String _selectedUrgency = 'standard';
  bool _isSubmitting = false;
  ServiceScale _selectedScale = ServiceScale.minimum;

  // Services that automatically use minimum scale
  final List<String> _autoMinimumServices = ['fashion', 'beauty'];

  // Services that automatically use large scale (plumber, electrician, furniture building, painter, mechanic)
  final List<String> _autoLargeScaleServices = ['plumbing', 'electrical', 'carpentry', 'painting', 'mechanical'];

  final List<Map<String, dynamic>> _urgencyOptions = [
    {'value': 'standard', 'label': 'Standard (Within 48 hours)', 'priceMultiplier': 1.0},
    {'value': 'urgent', 'label': 'Urgent (Within 24 hours)', 'priceMultiplier': 1.5},
  ];

  @override
  void initState() {
    super.initState();
    customerService = CustomerService(AuthService());

    // Auto-set scale based on service type
    if (_autoMinimumServices.contains(widget.serviceType)) {
      _selectedScale = ServiceScale.minimum;
    } else if (_autoLargeScaleServices.contains(widget.serviceType)) {
      _selectedScale = ServiceScale.largeScale;
    }
  }

  bool get _shouldHideScaleSelection {
    return _autoMinimumServices.contains(widget.serviceType) ||
        _autoLargeScaleServices.contains(widget.serviceType);
  }

  String get _autoScaleDescription {
    if (_autoMinimumServices.contains(widget.serviceType)) {
      return 'Direct Professional Booking';
    } else if (_autoLargeScaleServices.contains(widget.serviceType)) {
      return 'Large Scale Project - Representative Inspection Required';
    }
    return '';
  }

  Color get _autoScaleColor {
    if (_autoMinimumServices.contains(widget.serviceType)) {
      return Colors.green[700]!;
    } else if (_autoLargeScaleServices.contains(widget.serviceType)) {
      return Colors.orange[700]!;
    }
    return Colors.green[700]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book ${widget.serviceName}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green[50]!,
                    Colors.blue[50]!,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getServiceIcon(widget.serviceType),
                      color: Colors.green[700],
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.serviceName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subCategory,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_shouldHideScaleSelection) ...[
                          const SizedBox(height: 4),
                          Text(
                            _autoScaleDescription,
                            style: TextStyle(
                              fontSize: 12,
                              color: _autoScaleColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_shouldHideScaleSelection) ...[
                        _buildSectionHeader('Service Scale'),
                        const SizedBox(height: 12),
                        _buildServiceScaleSelector(),
                        const SizedBox(height: 24),
                      ],

                      _buildSectionHeader('Booking Information'),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        hintText: 'Enter your full address where service is needed',
                        icon: Icons.location_on_outlined,
                        isRequired: true,
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Service Details',
                        hintText: 'Describe the service you need in detail...',
                        icon: Icons.description_outlined,
                        maxLines: 4,
                        isRequired: true,
                      ),
                      const SizedBox(height: 24),

                      _buildSectionHeader('Urgency Level'),
                      const SizedBox(height: 12),
                      _buildUrgencySelector(),
                      const SizedBox(height: 24),

                      _buildSectionHeader('Schedule'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _dateController,
                              label: 'Preferred Date',
                              hintText: 'Select date',
                              icon: Icons.calendar_today_outlined,
                              isRequired: true,
                              readOnly: true,
                              onTap: () => _selectDate(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _timeController,
                              label: 'Preferred Time',
                              hintText: 'Select time',
                              icon: Icons.access_time_outlined,
                              isRequired: true,
                              readOnly: true,
                              onTap: () => _selectTime(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _buildSubmitButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceScaleSelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: ServiceScale.values.map((scale) {
          final bool isSelected = _selectedScale == scale;
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: scale == ServiceScale.values.last
                    ? BorderSide.none
                    : BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: RadioListTile<ServiceScale>(
              value: scale,
              groupValue: _selectedScale,
              onChanged: (value) {
                setState(() {
                  _selectedScale = value!;
                });
              },
              title: Row(
                children: [
                  Icon(scale.icon, color: isSelected ? Colors.green[700] : Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scale.title,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.green[700] : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          scale.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              activeColor: Colors.green,
              tileColor: isSelected ? Colors.green[50] : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isRequired)
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            readOnly: readOnly,
            keyboardType: keyboardType,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.green,
                  width: 2,
                ),
              ),
              prefixIcon: Icon(
                icon,
                color: Colors.grey[600],
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: isRequired
                ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildUrgencySelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: _urgencyOptions.map((option) {
          final bool isSelected = _selectedUrgency == option['value'];
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: _urgencyOptions.last == option
                    ? BorderSide.none
                    : BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: RadioListTile<String>(
              value: option['value'],
              groupValue: _selectedUrgency,
              onChanged: (value) {
                setState(() {
                  _selectedUrgency = value!;
                });
              },
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      option['label'],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.green[700] : Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${option['priceMultiplier']}x',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.green[700] : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              secondary: Icon(
                _getUrgencyIcon(option['value']),
                color: isSelected ? Colors.green[700] : Colors.grey[500],
              ),
              activeColor: Colors.green,
              tileColor: isSelected ? Colors.green[50] : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _findProfessionals,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          shadowColor: Colors.green.withOpacity(0.3),
        ),
        child: _isSubmitting
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                _getSubmitButtonIcon(),
                size: 20
            ),
            const SizedBox(width: 8),
            Text(
              _getSubmitButtonText(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSubmitButtonIcon() {
    if (_autoMinimumServices.contains(widget.serviceType)) {
      return Icons.search;
    } else if (_autoLargeScaleServices.contains(widget.serviceType)) {
      return Icons.engineering;
    } else {
      return _selectedScale == ServiceScale.minimum ? Icons.search : Icons.engineering;
    }
  }

  String _getSubmitButtonText() {
    if (_autoMinimumServices.contains(widget.serviceType)) {
      return 'Find Available Professionals';
    } else if (_autoLargeScaleServices.contains(widget.serviceType)) {
      return 'Request Representative Inspection';
    } else {
      return _selectedScale == ServiceScale.minimum
          ? 'Find Available Professionals'
          : 'Request Representative Inspection';
    }
  }

  Future<void> _findProfessionals() async {
    if (!_formKey.currentState!.validate()) return;

    final categoryId = ServiceMapper.getCategoryId(widget.serviceType);
    if (categoryId == null || categoryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Service category not found for ${widget.serviceType}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Determine which flow to use based on service type
    if (_autoMinimumServices.contains(widget.serviceType)) {
      await _handleMinimumScaleBooking(categoryId);
    } else if (_autoLargeScaleServices.contains(widget.serviceType)) {
      await _handleLargeScaleBooking(categoryId);
    } else {
      // Manual selection for other services
      if (_selectedScale == ServiceScale.minimum) {
        await _handleMinimumScaleBooking(categoryId);
      } else {
        await _handleLargeScaleBooking(categoryId);
      }
    }
  }

  Future<void> _handleMinimumScaleBooking(String categoryId) async {
    bool proceed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.orange),
            SizedBox(width: 8),
            Text('Important Notice'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For your safety and secure transactions:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('• All payments must be made through the official platform'),
            SizedBox(height: 8),
            Text('• Offline transactions are strictly prohibited'),
            SizedBox(height: 8),
            Text('• Report any suspicious payment requests to support'),
            SizedBox(height: 12),
            Text(
              '⚠️ The company is not liable for any transactions conducted outside the platform.',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Agree & Continue', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (!proceed) return;

    setState(() => _isSubmitting = true);

    try {
      final scheduledDate = _parseDisplayedDate(_dateController.text);
      final formattedDate = scheduledDate != null ? _formatDateForAPI(scheduledDate) : null;

      print('📝 Creating minimum scale order with data:');
      print('Category: $categoryId');
      print('Date: $formattedDate');
      print('Time: ${_timeController.text}');

      final order = await customerService.createProfessionalOrder(
        serviceCategory: categoryId,
        details: _descriptionController.text,
        location: _addressController.text,
        scheduledDate: formattedDate,
        scheduledTime: _timeController.text.isNotEmpty ? _timeController.text : null,
        urgency: _selectedUrgency,
        serviceScale: 'minimum',
      );

      print('✅ Order response received: $order');
      print('📦 Order type: ${order.runtimeType}');
      print('🔍 Order keys: ${order is Map ? order.keys.toList() : 'Not a Map'}');

      if (!mounted) return;

      String? orderId;

      if (order == null) {
        throw Exception('Order creation failed: Server returned null response');
      }

      if (order is Map) {
        print('🔍 Searching for order ID in response map...');

        if (order['_id'] != null) {
          orderId = order['_id'].toString();
          print('✓ Found order ID in "_id" field: $orderId');
        } else if (order['id'] != null) {
          orderId = order['id'].toString();
          print('✓ Found order ID in "id" field: $orderId');
        } else if (order['orderId'] != null) {
          orderId = order['orderId'].toString();
          print('✓ Found order ID in "orderId" field: $orderId');
        } else if (order['order_id'] != null) {
          orderId = order['order_id'].toString();
          print('✓ Found order ID in "order_id" field: $orderId');
        } else if (order['data'] != null && order['data'] is Map) {
          final data = order['data'] as Map;
          if (data['_id'] != null) {
            orderId = data['_id'].toString();
            print('✓ Found order ID in "data._id" field: $orderId');
          } else if (data['id'] != null) {
            orderId = data['id'].toString();
            print('✓ Found order ID in "data.id" field: $orderId');
          }
        } else if (order['order'] != null && order['order'] is Map) {
          final orderData = order['order'] as Map;
          if (orderData['_id'] != null) {
            orderId = orderData['_id'].toString();
            print('✓ Found order ID in "order._id" field: $orderId');
          }
        }
      } else {
        print('⚠️ Order response is not a Map, trying to handle as string or other type');
        orderId = order.toString();
      }

      if (orderId == null || orderId.isEmpty || orderId == 'null') {
        print('❌ FAILED TO EXTRACT ORDER ID FROM RESPONSE');
        print('📋 Full order response structure:');
        print('Type: ${order.runtimeType}');
        print('Value: $order');

        if (order is String && order.isNotEmpty && order != 'null') {
          orderId = order;
          print('✓ Using entire response as order ID: $orderId');
        } else {
          throw Exception('''
Invalid order response: Could not find order ID. 

Server Response: $order

Please check:
1. Backend is returning the order with _id field
2. Response structure matches expected format
3. Order creation was successful on server
''');
        }
      }

      print('✅ SUCCESS - Order ID extracted: $orderId');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MinimumScaleAgentSelection(
            serviceType: widget.serviceType,
            orderData: {
              'orderId': orderId!,
              'serviceType': widget.serviceType,
              'serviceName': widget.serviceName,
              'description': _descriptionController.text,
              'address': _addressController.text,
              'scheduledDate': _dateController.text,
              'scheduledTime': _timeController.text,
              'urgency': _selectedUrgency,
              'serviceScale': 'minimum',
            },
            orderAmount: _calculateEstimatedAmount(),
            onAgentSelected: (agent, orderData) {
              _handleAgentSelection(agent, orderData);
            },
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('❌ Error in _handleMinimumScaleBooking: $e');
      print('📚 Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit booking: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Details',
              textColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error Details'),
                    content: SingleChildScrollView(
                      child: Text(e.toString()),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleLargeScaleBooking(String categoryId) async {
    bool proceed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Large Scale Service Request'),
        content: const Text(
          'For this major project, we will send a representative to inspect and provide an accurate quotation before you proceed. Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Proceed'),
          ),
        ],
      ),
    ) ?? false;

    if (!proceed) return;

    setState(() => _isSubmitting = true);

    try {
      final scheduledDate = _parseDisplayedDate(_dateController.text);
      final formattedDate = scheduledDate != null ? _formatDateForAPI(scheduledDate) : null;

      print('📝 Creating large scale order with data:');
      print('Category: $categoryId');
      print('Date: $formattedDate');
      print('Time: ${_timeController.text}');

      final order = await customerService.createProfessionalOrder(
        serviceCategory: categoryId,
        details: _descriptionController.text,
        location: _addressController.text,
        scheduledDate: formattedDate,
        scheduledTime: _timeController.text.isNotEmpty ? _timeController.text : null,
        urgency: _selectedUrgency,
        serviceScale: 'large_scale',
      );

      print('✅ Order response received: $order');
      print('📦 Order type: ${order.runtimeType}');
      print('🔍 Order keys: ${order is Map ? order.keys.toList() : 'Not a Map'}');

      if (!mounted) return;

      String? orderId;

      if (order == null) {
        throw Exception('Order creation failed: Server returned null response');
      }

      if (order is Map) {
        print('🔍 Searching for order ID in response map...');

        if (order['_id'] != null) {
          orderId = order['_id'].toString();
          print('✓ Found order ID in "_id" field: $orderId');
        } else if (order['id'] != null) {
          orderId = order['id'].toString();
          print('✓ Found order ID in "id" field: $orderId');
        } else if (order['orderId'] != null) {
          orderId = order['orderId'].toString();
          print('✓ Found order ID in "orderId" field: $orderId');
        } else if (order['order_id'] != null) {
          orderId = order['order_id'].toString();
          print('✓ Found order ID in "order_id" field: $orderId');
        } else if (order['data'] != null && order['data'] is Map) {
          final data = order['data'] as Map;
          if (data['_id'] != null) {
            orderId = data['_id'].toString();
            print('✓ Found order ID in "data._id" field: $orderId');
          } else if (data['id'] != null) {
            orderId = data['id'].toString();
            print('✓ Found order ID in "data.id" field: $orderId');
          }
        } else if (order['order'] != null && order['order'] is Map) {
          final orderData = order['order'] as Map;
          if (orderData['_id'] != null) {
            orderId = orderData['_id'].toString();
            print('✓ Found order ID in "order._id" field: $orderId');
          }
        }
      } else {
        print('⚠️ Order response is not a Map, trying to handle as string or other type');
        orderId = order.toString();
      }

      if (orderId == null || orderId.isEmpty || orderId == 'null') {
        print('❌ FAILED TO EXTRACT ORDER ID FROM RESPONSE');
        print('📋 Full order response structure:');
        print('Type: ${order.runtimeType}');
        print('Value: $order');

        if (order is String && order.isNotEmpty && order != 'null') {
          orderId = order;
          print('✓ Using entire response as order ID: $orderId');
        } else {
          throw Exception('''
Invalid order response: Could not find order ID. 

Server Response: $order

Please check:
1. Backend is returning the order with _id field
2. Response structure matches expected format
3. Order creation was successful on server
''');
        }
      }

      print('✅ SUCCESS - Order ID extracted: $orderId');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WaitingQuotationScreen(
            orderId: orderId!,
            serviceType: widget.serviceType,
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('❌ Error in _handleLargeScaleBooking: $e');
      print('📚 Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit booking: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Details',
              textColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Error Details'),
                    content: SingleChildScrollView(
                      child: Text(e.toString()),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _handleAgentSelection(Agent agent, Map<String, dynamic> orderData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfessionalServiceTypeSelection(
          selectedAgent: agent,
          orderData: orderData,
          serviceType: widget.serviceType,
        ),
      ),
    );
  }

  IconData _getUrgencyIcon(String urgency) {
    switch (urgency) {
      case 'standard':
        return Icons.schedule_outlined;
      case 'urgent':
        return Icons.warning_amber_outlined;
      default:
        return Icons.schedule_outlined;
    }
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType) {
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'mechanical':
        return Icons.settings;
      case 'carpentry':
        return Icons.chair_alt;
      case 'painting':
        return Icons.format_paint;
      case 'fashion':
        return Icons.checkroom;
      case 'beauty':
        return Icons.spa;
      case 'mechanic':
        return Icons.build;
      default:
        return Icons.build;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  String _formatDateForAPI(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  DateTime? _parseDisplayedDate(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return null;
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  double _calculateEstimatedAmount() {
    double basePrice;
    switch (widget.serviceType) {
      case 'plumbing':
        basePrice = 5000.0;
        break;
      case 'electrical':
        basePrice = 4500.0;
        break;
      case 'mechanical':
        basePrice = 6000.0;
        break;
      case 'carpentry':
        basePrice = 4000.0;
        break;
      case 'painting':
        basePrice = 3500.0;
        break;
      case 'fashion':
        basePrice = 7000.0;
        break;
      case 'beauty':
        basePrice = 3000.0;
        break;
      case 'mechanic':
        basePrice = 5500.0;
        break;
      default:
        basePrice = 4000.0;
    }

    final urgencyMultiplier = _urgencyOptions
        .firstWhere((option) => option['value'] == _selectedUrgency)['priceMultiplier'];

    return basePrice * urgencyMultiplier;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}