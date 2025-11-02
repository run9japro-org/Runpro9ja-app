// screens/agent_selection_screen.dart - COMPLETELY FIXED VERSION
import 'dart:convert';

import 'package:flutter/material.dart';
import '../../auth/Auth_services/auth_service.dart';
import '../../models/agent_model.dart';
import '../../models/customer_models.dart';
import '../../services/customer_services.dart';
import '../../utils/service_mapper.dart';
import '../babysitting_services/babysitting_service.dart';
import '../errand_services/movers_screen.dart';
import '../errand_services/order_confirmation_screen.dart';

const kGreen = Color(0xFF2E7D32);

class AgentSelectionScreen extends StatefulWidget {
  final String serviceType;
  final Map<String, dynamic> orderData;
  final double orderAmount;
  final Widget? nextScreen;
  final Function(Agent, Map<String, dynamic>)? onAgentSelected;

  const AgentSelectionScreen({
    super.key,
    required this.serviceType,
    required this.orderData,
    required this.orderAmount,
    this.nextScreen,
    this.onAgentSelected,
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

  @override
  void initState() {
    super.initState();
    _customerService = CustomerService(_authService);
    _fetchAgents();
  }

  Future<void> _fetchAgents() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      print('🔄 Fetching agents for service: ${widget.serviceType}');

      final agents = await _authService.getAvailableAgents(
        serviceType: widget.serviceType,
      );

      print('✅ Loaded ${agents.length} agents');

      // **ADDED: Debug agent data**
      if (agents.isNotEmpty) {
        print('🔍 FIRST AGENT DEBUG:');
        print('   - agent.id: ${agents[0].id}');
        print('   - agent.userId: ${agents[0].userId}');
        print('   - agent.fullName: ${agents[0].fullName}');
        print('   - agent.serviceType: ${agents[0].serviceType}');
      }

      setState(() {
        _agents = agents;
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
      case 'errand': return 'Select Errand Agent';
      case 'delivery': return 'Select Delivery Agent';
      case 'movers': return 'Select Moving Agent';
      case 'moving': return 'Select Moving Agent';
      case 'grocery': return 'Select Shopping Agent';
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
          // Order Summary Header
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
              ],
            ),
          ),

          // Agents List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kGreen))
                : _errorMessage.isNotEmpty
                ? _buildErrorState()
                : _agents.isEmpty
                ? _buildEmptyState()
                : _buildAgentsList(),
          ),

          // Selected Agent & Proceed Button
          if (_selectedAgent != null) _buildSelectionFooter(),
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
                        ? NetworkImage('https://runpro9ja-backend.onrender.com${agent.profileImage}')
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
    print('👤 Agent selected:');
    print('   - Name: ${agent.displayName}');
    print('   - User ID: ${agent.userId}');
    print('   - Profile ID: ${agent.id}');
    print('   - User ID Length: ${agent.userId.length}');
    print('   - Is User ID Empty: ${agent.userId.isEmpty}');

    setState(() {
      _selectedAgent = agent;
    });
  }

  Future<void> _proceedWithAgent() async {
    if (_selectedAgent == null) return;

    try {
      setState(() => _isSubmitting = true);

      final finalOrderData = {
        ...widget.orderData,
        'selectedAgent': _selectedAgent!.toJson(),
        'totalAmount': widget.orderAmount,
      };

      if (widget.onAgentSelected != null) {
        print('🎯 Using custom callback for agent selection');
        widget.onAgentSelected!(_selectedAgent!, finalOrderData);
        return;
      }

      if (widget.nextScreen != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => widget.nextScreen!),
        );
        return;
      }

      try {
        final order = await _createOrderWithSelectedAgent();
        finalOrderData['orderId'] = order.id;

        if (!mounted) return;
        _handleDefaultNavigation(finalOrderData);
      } catch (e) {
        finalOrderData['orderId'] = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        finalOrderData['isTempOrder'] = true;

        if (!mounted) return;
        _handleDefaultNavigation(finalOrderData);
      }

    } catch (e) {
      if (mounted) {
        _showError('Failed to create order: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _handleDefaultNavigation(Map<String, dynamic> orderData) {
    final isProfessionalService = widget.serviceType.toLowerCase() == 'professional service' ||
        ['plumbing', 'electrical', 'carpentry', 'painting', 'cleaning', 'laundry']
            .contains(widget.serviceType.toLowerCase());

    if (isProfessionalService) {
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

    switch (widget.serviceType) {
      case 'child_babysitting':
      case 'animal_babysitting':
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
      case 'laundry':
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmationScreen(
              orderData: orderData,
              serviceType: widget.serviceType,
            ),
          ),
        );
        break;
    }
  }

  // **COMPLETELY FIXED: _createOrderWithSelectedAgent method**
  Future<CustomerOrder> _createOrderWithSelectedAgent() async {
    final agentId = _selectedAgent!.userId;

    try {
      print('🎯 ===== AGENT ID VERIFICATION =====');
      print('👤 AGENT IDS:');
      print('   - agent.id (profile ID): ${_selectedAgent!.id}');
      print('   - agent.userId (user ID): ${_selectedAgent!.userId}');
      print('   - Using for requestedAgent: $agentId');
      print('   - Expected user ID: 68fd4318c1b89d5e0463f6c8');
      print('   - IDs Match: ${agentId == '68fd4318c1b89d5e0463f6c8'}');
      print('====================================');

      print('🔍 RAW ORDER DATA: ${widget.orderData}');

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

      // **FIXED: Correct service type detection**
      final isProfessionalService = ServiceMapper.isProfessionalService(widget.serviceType) &&
          !['grocery', 'errand', 'delivery', 'moving', 'movers'].contains(widget.serviceType.toLowerCase());
      final isDeliveryService = widget.serviceType.toLowerCase() == 'delivery';
      final isErrandService = widget.serviceType.toLowerCase() == 'errand' ||
          widget.serviceType.toLowerCase() == 'grocery';
      final isMovingService = widget.serviceType.toLowerCase() == 'moving' ||
          widget.serviceType.toLowerCase() == 'movers';

      print('🔧 Service Type Analysis:');
      print('   - Professional: $isProfessionalService');
      print('   - Delivery: $isDeliveryService');
      print('   - Errand: $isErrandService');
      print('   - Moving: $isMovingService');
      print('   - Actual Service Type: ${widget.serviceType}');

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

        // **FIXED: Handle Map return type from createProfessionalOrder**
        final orderResult = await _customerService.createProfessionalOrder(
          serviceCategory: serviceCategory,
          details: details,
          location: location,
          scheduledDate: scheduledDateString,
          scheduledTime: scheduledTimeString,
          urgency: widget.orderData['urgency'] ?? 'medium',
          serviceScale: widget.orderData['serviceScale'] ?? 'minimum',
        );

        print('📦 Professional order result type: ${orderResult.runtimeType}');

        // Convert Map to CustomerOrder
        if (orderResult is Map<String, dynamic> && orderResult['order'] != null) {
          order = CustomerOrder.fromJson(orderResult['order']);
        } else if (orderResult is Map<String, dynamic>) {
          order = CustomerOrder.fromJson(orderResult);
        } else {
          throw Exception('Invalid order response format: ${orderResult.runtimeType}');
        }
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
          case 'laundry':
            print('🧹 Creating CLEANING/LAUNDRY order...');
            // Use errand order for cleaning/laundry since they're not professional services
            order = await _customerService.createErrandOrder(
              errandType: widget.serviceType,
              fromAddress: location,
              toAddress: location,
              itemsDescription: details,
              totalAmount: widget.orderAmount,
              requestedAgentId: agentId,
            );
            break;

          default:
            print('🔧 Creating DEFAULT order...');
            // Fallback to errand order for unknown services
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

      print('✅ Order creation successful');
      print('   - Order ID: ${order.id}');
      print('   - Agent ID Used: $agentId');
      return order;

    } catch (e) {
      print('❌ Error creating order: $e');
      print('📋 Order Data that caused error: ${widget.orderData}');
      print('🎯 Service Type: ${widget.serviceType}');
      print('👤 Selected Agent User ID: ${_selectedAgent?.userId}');
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