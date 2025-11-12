// screens/agent_selection_screen.dart - COMPLETE WITH RECOVERY
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../auth/Auth_services/auth_service.dart';
import '../../models/agent_model.dart';
import '../../models/customer_models.dart';
import '../../services/customer_services.dart';
import '../../services/order_recovery_service.dart';
import '../../utils/service_mapper.dart';
import '../babysitting_services/babysitting_service.dart';
import '../errand_services/movers_screen.dart';
import '../errand_services/order_confirmation_screen.dart';
import '../laundry_services/laundry_waiting_screen.dart';

const kGreen = Color(0xFF2E7D32);

class AgentSelectionScreen extends StatefulWidget {
  final String serviceType;
  final Map<String, dynamic> orderData;
  final double orderAmount;
  final Widget? nextScreen;
  final Function(Agent, Map<String, dynamic>)? onAgentSelected;
  final bool fromRecovery;

  const AgentSelectionScreen({
    super.key,
    required this.serviceType,
    required this.orderData,
    required this.orderAmount,
    this.nextScreen,
    this.onAgentSelected,
    this.fromRecovery = false,
  });

  @override
  State<AgentSelectionScreen> createState() => _AgentSelectionScreenState();
}

class _AgentSelectionScreenState extends State<AgentSelectionScreen> {
  final AuthService _authService = AuthService();
  late final CustomerService _customerService;
  List<Agent> _agents = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String _errorMessage = '';
  Agent? _selectedAgent;
  bool _isRecoveredSession = false;

  @override
  void initState() {
    super.initState();
    _customerService = CustomerService(_authService);
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    if (widget.fromRecovery) {
      _isRecoveredSession = true;
    }
    await _saveCurrentProgress();
    _fetchAgents();
  }

  Future<void> _saveCurrentProgress() async {
    try {
      await OrderRecoveryService.saveAgentSelectionProgress(
        serviceType: widget.serviceType,
        orderData: widget.orderData,
        orderAmount: widget.orderAmount,
        selectedAgent: _selectedAgent?.toJson(),
      );
    } catch (e) {
      print('❌ Error saving agent selection progress: $e');
    }
  }

  Future<void> _fetchAgents() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      print('🔄 Fetching agents for service: ${widget.serviceType}');

      final allAgents = await _authService.getAvailableAgents(
        serviceType: ServiceMapper.isBabysittingService(widget.serviceType)
            ? 'babysitting'
            : widget.serviceType,
      );

      print('✅ Loaded ${allAgents.length} total agents');

      List<Agent> filteredAgents = allAgents;

      if (ServiceMapper.isBabysittingService(widget.serviceType)) {
        final babysittingType = ServiceMapper.getBabysittingType(widget.serviceType);

        if (babysittingType == 'child') {
          filteredAgents = allAgents.where((agent) {
            return agent.subCategory?.toLowerCase().contains('child') == true ||
                agent.servicesOffered.toLowerCase().contains('child') ||
                agent.bio.toLowerCase().contains('child') ||
                agent.displayName.toLowerCase().contains('child') ||
                (agent.subCategory == null && agent.servicesOffered.isEmpty);
          }).toList();
          print('👶 Found ${filteredAgents.length} child babysitters');

        } else if (babysittingType == 'animal') {
          filteredAgents = allAgents.where((agent) {
            return agent.subCategory?.toLowerCase().contains('pet') == true ||
                agent.subCategory?.toLowerCase().contains('animal') == true ||
                agent.servicesOffered.toLowerCase().contains('pet') ||
                agent.servicesOffered.toLowerCase().contains('animal') ||
                agent.bio.toLowerCase().contains('pet') ||
                agent.bio.toLowerCase().contains('animal') ||
                agent.displayName.toLowerCase().contains('pet') ||
                agent.displayName.toLowerCase().contains('animal');
          }).toList();
          print('🐾 Found ${filteredAgents.length} pet babysitters');
        }
      }

      setState(() {
        _agents = filteredAgents;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error fetching agents: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load agents. Please try again.';
      });
    }
  }

  String get _displayTitle {
    switch (widget.serviceType.toLowerCase()) {
      case 'child_babysitting': return 'Select Childcare Specialist';
      case 'animal_babysitting': return 'Select Pet Care Specialist';
      case 'errand': return 'Select Errand Agent';
      case 'delivery': return 'Select Delivery Agent';
      case 'movers': return 'Select Moving Agent';
      case 'moving': return 'Select Moving Agent';
      case 'grocery': return 'Select Grocery Agent';
      case 'cleaning': return 'Select Cleaning Agent';
      case 'laundry': return 'Select Laundry Agent';
      case 'plumbing': return 'Select Plumbing Expert';
      case 'electrical': return 'Select Electrical Expert';
      case 'carpentry': return 'Select Carpentry Expert';
      case 'painting': return 'Select Painting Expert';
      case 'professional service': return 'Select Professional';
      default: return 'Select Agent';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _whiteAppBar(title: _displayTitle),
      body: Column(
        children: [
          if (_isRecoveredSession) _buildRecoveryBanner(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.serviceType.toUpperCase()} • ₦${widget.orderAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (_isRecoveredSession) ...[
                  const SizedBox(height: 4),
                  Text(
                    '🔄 Recovered session - Continuing where you left off',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kGreen))
                : _errorMessage.isNotEmpty
                ? _buildErrorState()
                : _agents.isEmpty
                ? _buildEmptyState()
                : _buildAgentsList(),
          ),
          if (_selectedAgent != null) _buildSelectionFooter(),
        ],
      ),
    );
  }

  Widget _buildRecoveryBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.green.shade50,
      child: Row(
        children: [
          Icon(Icons.autorenew, color: Colors.green.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Welcome back! Continuing your order from where you left off.',
              style: TextStyle(
                color: Colors.green.shade800,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.green.shade700, size: 16),
            onPressed: () {
              setState(() {
                _isRecoveredSession = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchAgents,
            style: ElevatedButton.styleFrom(backgroundColor: kGreen),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, color: Colors.grey, size: 48),
          const SizedBox(height: 16),
          const Text('No agents available', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _fetchAgents,
            style: ElevatedButton.styleFrom(backgroundColor: kGreen),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _agents.length,
      itemBuilder: (context, index) {
        final agent = _agents[index];
        return _buildAgentCard(agent);
      },
    );
  }

  Widget _buildAgentCard(Agent agent) {
    final isSelected = _selectedAgent?.userId == agent.userId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 2,
      color: isSelected ? kGreen.withOpacity(0.05) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? kGreen : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _selectAgent(agent),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: agent.profileImage.isNotEmpty
                        ? NetworkImage('https://runpro9ja-pxqoa.ondigitalocean.app${agent.profileImage}')
                        : null,
                    child: agent.profileImage.isEmpty
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(agent.displayName,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            if (agent.isVerified) ...[
                              const SizedBox(width: 4),
                              Icon(Icons.verified, size: 16, color: Colors.blue),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(children: [
                          Icon(Icons.star, color: Colors.amber[600], size: 16),
                          const SizedBox(width: 4),
                          Text('${agent.rating} • ${agent.completedJobs} jobs',
                              style: const TextStyle(fontSize: 12)),
                          if (agent.yearsOfExperience.isNotEmpty && agent.yearsOfExperience != '0') ...[
                            const SizedBox(width: 8),
                            Text('• ${agent.yearsOfExperience} years',
                                style: TextStyle(fontSize: 12, color: kGreen)),
                          ],
                        ]),
                        const SizedBox(height: 2),
                        Text(agent.displayLocation,
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        if (agent.subCategory != null && agent.subCategory!.isNotEmpty) ...[
                          Text(agent.subCategory!,
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₦${agent.price.toStringAsFixed(0)}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kGreen)),
                      Text('${agent.distance.toStringAsFixed(1)} km away',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              if (agent.bio.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(agent.bio,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
              if (agent.servicesOffered.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Services: ${agent.servicesOffered}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selectedAgent!.displayName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    Text('₦${_selectedAgent!.price.toStringAsFixed(0)}/hr • ${_selectedAgent!.distance.toStringAsFixed(1)} km away',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _selectedAgent = null),
                icon: const Icon(Icons.close, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _proceedWithAgent,
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Confirm & Create Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAgent(Agent agent) {
    print('👤 Agent selected: ${agent.displayName}');
    setState(() {
      _selectedAgent = agent;
    });
    _saveCurrentProgress();
  }

  Future<void> _proceedWithAgent() async {
    if (_selectedAgent == null) return;

    try {
      setState(() => _isSubmitting = true);

      final finalOrderData = {
        ...widget.orderData,
        'selectedAgent': _selectedAgent!.toJson(),
        'selectedAgentId': _selectedAgent!.userId,
        'selectedAgentName': _selectedAgent!.displayName,
        'totalAmount': widget.orderAmount,
      };

      print('🎯 Creating order with agent: ${_selectedAgent!.displayName}');

      // Handle callback navigation
      if (widget.onAgentSelected != null) {
        await OrderRecoveryService.clearAgentSelectionProgress();
        await OrderRecoveryService.clearPendingOrder();
        widget.onAgentSelected!(_selectedAgent!, finalOrderData);
        return;
      }

      // Handle nextScreen navigation
      if (widget.nextScreen != null) {
        await OrderRecoveryService.clearAgentSelectionProgress();
        await OrderRecoveryService.clearPendingOrder();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => widget.nextScreen!),
        );
        return;
      }

      // CREATE THE ORDER
      try {
        final order = await _createOrderWithSelectedAgent();

        finalOrderData['orderId'] = order.id;
        finalOrderData['_id'] = order.id;
        finalOrderData['isTempOrder'] = false;
        finalOrderData['agentId'] = _selectedAgent!.userId;
        finalOrderData['agentName'] = _selectedAgent!.displayName;

        if (!mounted) return;

        // CLEAR RECOVERY DATA
        await OrderRecoveryService.clearAgentSelectionProgress();
        await OrderRecoveryService.clearPendingOrder();

        _handleDefaultNavigation(finalOrderData, order);

      } catch (e) {
        print('❌ ERROR CREATING ORDER: $e');
        if (mounted) {
          _showError('Failed to create order. Please try again.');
          setState(() => _isSubmitting = false);
        }
      }

    } catch (e) {
      print('❌ UNEXPECTED ERROR: $e');
      if (mounted) {
        _showError('An unexpected error occurred: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _handleDefaultNavigation(Map<String, dynamic> orderData, CustomerOrder? order) {
    final professionalServices = [
      'plumbing', 'electrical', 'carpentry', 'painting', 'professional service'
    ];

    final isProfessionalService = professionalServices.contains(widget.serviceType.toLowerCase());
    final serviceTypeLower = widget.serviceType.toLowerCase();

    print('🧭 Navigating for service: $serviceTypeLower');

    if (serviceTypeLower == 'laundry') {
      print('🧺 Navigating to LAUNDRY WAITING SCREEN');
      final tempOrder = order ?? CustomerOrder(
        id: orderData['orderId'] ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
        serviceCategory: 'laundry',
        description: orderData['description'] ?? 'Laundry Service',
        location: orderData['address'] ?? 'Not specified',
        price: widget.orderAmount,
        status: 'pending',
        createdAt: DateTime.now(),
        isPublic: false,
        isDirectOffer: false,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LaundryOrderWaitingScreen(
            orderId: tempOrder.id,
            selectedAgent: _selectedAgent!,
            orderData: orderData,
            customerOrder: tempOrder,
          ),
        ),
      );
      return;
    }

    if (isProfessionalService) {
      print('👷 Navigating to PROFESSIONAL SERVICE confirmation');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Service Confirmed'),
              backgroundColor: kGreen,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, size: 80, color: kGreen),
                  const SizedBox(height: 20),
                  Text(
                    '${widget.serviceType.toUpperCase()} Service Confirmed!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kGreen),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your ${widget.serviceType} expert will contact you soon.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: kGreen),
                    child: const Text('Return Home', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      return;
    }

    switch (serviceTypeLower) {
      case 'child_babysitting':
      case 'animal_babysitting':
        print('👶 Navigating to BABYSITTING confirmation');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingSummaryScreen(
              orderData: orderData,
              serviceType: widget.serviceType,
              selectedAgent: _selectedAgent!,
            ),
          ),
        );
        break;

      case 'moving':
      case 'movers':
        print('🚛 Navigating to MOVERS confirmation');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MoversOrderConfirmationScreen(
              orderData: orderData,
              selectedAgent: _selectedAgent!,
              serviceType: widget.serviceType,
            ),
          ),
        );
        break;

      case 'errand':
      case 'grocery':
      case 'delivery':
      case 'cleaning':
      default:
        print('📦 Navigating to REGULAR order confirmation');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmationScreen(
              orderId: orderData['orderId'],
              orderData: orderData,
              serviceType: widget.serviceType,
            ),
          ),
        );
        break;
    }
  }

  Future<CustomerOrder> _createOrderWithSelectedAgent() async {
    final agentId = _selectedAgent!.userId;

    try {
      print('🎯 Creating order with agent ID: $agentId');

      final serviceCategory = ServiceMapper.getCategoryId(widget.serviceType);
      final serviceCategoryName = ServiceMapper.getCategoryName(widget.serviceType);

      if (serviceCategory == null) {
        throw Exception('No service category found for service type: ${widget.serviceType}');
      }

      print('🎯 Service Category: $serviceCategory ($serviceCategoryName)');

      final location = widget.orderData['location'] ??
          widget.orderData['address'] ??
          widget.orderData['fromAddress'] ??
          widget.orderData['serviceAddress'] ??
          'Location not specified';

      final details = widget.orderData['description'] ??
          widget.orderData['details'] ??
          widget.orderData['itemsDescription'] ??
          _buildServiceDetails(widget.orderData);

      final professionalServices = ['plumbing', 'electrical', 'carpentry', 'painting', 'professional service'];
      final isProfessionalService = professionalServices.contains(widget.serviceType.toLowerCase());
      final isDeliveryService = widget.serviceType.toLowerCase() == 'delivery';
      final isErrandService = widget.serviceType.toLowerCase() == 'errand' ||
          widget.serviceType.toLowerCase() == 'grocery';
      final isMovingService = widget.serviceType.toLowerCase() == 'moving' ||
          widget.serviceType.toLowerCase() == 'movers';
      final isLaundryService = widget.serviceType.toLowerCase() == 'laundry';

      CustomerOrder order;

      if (isDeliveryService) {
        print('🚚 Creating DELIVERY order...');
        order = await _customerService.createDeliveryOrder(
          fromAddress: widget.orderData['fromAddress'] ?? location,
          toAddress: widget.orderData['toAddress'] ?? '',
          serviceLevel: widget.orderData['serviceLevel'] ?? 'standard',
          totalAmount: widget.orderAmount,
          packageDescription: widget.orderData['packageDescription'] ?? details,
          estimatedDeliveryTime: widget.orderData['estimatedDeliveryTime'],
          requestedAgentId: agentId,
        );
      } else if (isProfessionalService) {
        print('👷 Creating PROFESSIONAL order...');

        String? scheduledDateString;
        String? scheduledTimeString;

        if (widget.orderData['scheduledDate'] != null) {
          if (widget.orderData['scheduledDate'] is DateTime) {
            scheduledDateString = (widget.orderData['scheduledDate'] as DateTime).toIso8601String();
          } else if (widget.orderData['scheduledDate'] is String) {
            scheduledDateString = widget.orderData['scheduledDate'];
          }
        }

        if (widget.orderData['scheduledTime'] != null) {
          if (widget.orderData['scheduledTime'] is TimeOfDay) {
            scheduledTimeString = (widget.orderData['scheduledTime'] as TimeOfDay).format(context);
          } else if (widget.orderData['scheduledTime'] is String) {
            scheduledTimeString = widget.orderData['scheduledTime'];
          }
        }

        final orderResult = await _customerService.createProfessionalOrder(
          serviceCategory: serviceCategory,
          details: details,
          location: location,
          scheduledDate: scheduledDateString,
          scheduledTime: scheduledTimeString,
          urgency: widget.orderData['urgency'] ?? 'medium',
          serviceScale: widget.orderData['serviceScale'] ?? 'minimum',
        );

        if (orderResult is Map<String, dynamic> && orderResult['order'] != null) {
          order = CustomerOrder.fromJson(orderResult['order']);
        } else if (orderResult is Map<String, dynamic>) {
          order = CustomerOrder.fromJson(orderResult);
        } else {
          throw Exception('Invalid order response format: ${orderResult.runtimeType}');
        }
      } else {
        if (isLaundryService) {
          print('🧺 Creating LAUNDRY order...');
          order = await _customerService.createErrandOrder(
            errandType: 'laundry',
            fromAddress: location,
            toAddress: location,
            itemsDescription: details,
            totalAmount: widget.orderAmount,
            requestedAgentId: agentId,
          );
        } else {
          switch (widget.serviceType.toLowerCase()) {
            case 'errand':
            case 'grocery':
              print('🛒 Creating ERRAND order...');
              order = await _customerService.createErrandOrder(
                errandType: widget.orderData['errandType'] ?? widget.serviceType,
                fromAddress: widget.orderData['fromAddress'] ?? location,
                toAddress: widget.orderData['toAddress'] ?? widget.orderData['address'] ?? '',
                itemsDescription: widget.orderData['itemsDescription'] ?? widget.orderData['description'] ?? details,
                totalAmount: widget.orderAmount,
                receiverName: widget.orderData['receiverName'],
                receiverPhone: widget.orderData['receiverPhone'],
                specialInstructions: widget.orderData['specialInstructions'],
                requestedAgentId: agentId,
              );
              break;

            case 'moving':
            case 'movers':
              print('🚛 Creating MOVING order...');
              int? numberOfMovers;
              if (widget.orderData['numberOfMovers'] is int) {
                numberOfMovers = widget.orderData['numberOfMovers'] as int;
              } else if (widget.orderData['numberOfMovers'] is String) {
                numberOfMovers = int.tryParse(widget.orderData['numberOfMovers']);
              }

              DateTime moveDate;
              if (widget.orderData['moveDate'] is DateTime) {
                moveDate = widget.orderData['moveDate'] as DateTime;
              } else if (widget.orderData['moveDate'] is String) {
                moveDate = DateTime.tryParse(widget.orderData['moveDate']) ?? DateTime.now().add(const Duration(days: 1));
              } else {
                moveDate = DateTime.now().add(const Duration(days: 1));
              }

              order = await _customerService.createMoversOrder(
                moveType: widget.orderData['moveType'] ?? 'residential',
                fromAddress: widget.orderData['fromAddress'] ?? location,
                toAddress: widget.orderData['toAddress'] ?? '',
                vehicleType: widget.orderData['vehicleType'] ?? 'medium_truck',
                moveDate: moveDate,
                timeSlot: widget.orderData['timeSlot'] ?? 'morning',
                totalAmount: widget.orderAmount,
                itemsDescription: widget.orderData['itemsDescription'] ?? details,
                numberOfMovers: numberOfMovers ?? 2,
                requestedAgentId: agentId,
              );
              break;

            case 'cleaning':
              print('🧹 Creating CLEANING order...');
              order = await _customerService.createErrandOrder(
                errandType: 'cleaning',
                fromAddress: location,
                toAddress: location,
                itemsDescription: details,
                totalAmount: widget.orderAmount,
                requestedAgentId: agentId,
              );
              break;

            default:
              print('🔧 Creating DEFAULT order...');
              order = await _customerService.createErrandOrder(
                errandType: widget.serviceType,
                fromAddress: location,
                toAddress: location,
                itemsDescription: details,
                totalAmount: widget.orderAmount,
                requestedAgentId: agentId,
              );
              break;
          }
        }
      }

      print('✅ Order creation successful');
      print('   - Order ID: ${order.id}');
      return order;

    } catch (e) {
      print('❌ Error creating order: $e');
      rethrow;
    }
  }

  String _buildServiceDetails(Map<String, dynamic> orderData) {
    final details = StringBuffer();
    details.writeln('${widget.serviceType.toUpperCase()} Service Details:');

    orderData.forEach((key, value) {
      if (value != null && key != 'selectedAgent' && key != 'orderId') {
        if (value is DateTime) {
          details.writeln('$key: ${value.toIso8601String()}');
        } else if (value is TimeOfDay) {
          details.writeln('$key: ${value.format(context)}');
        } else {
          details.writeln('$key: $value');
        }
      }
    });

    return details.toString();
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

PreferredSizeWidget _whiteAppBar({required String title}) => AppBar(
  elevation: 0,
  backgroundColor: Colors.white,
  centerTitle: true,
  leading: const BackButton(color: Colors.black),
  title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
);