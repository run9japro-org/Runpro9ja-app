import 'package:flutter/material.dart';
import 'package:runpro_9ja/services/customer_services.dart';
import 'package:runpro_9ja/screens/professional_services/quotation_acceptance_screen.dart';
import '../../auth/Auth_services/auth_service.dart';
import '../../models/customer_models.dart';

class WaitingQuotationScreen extends StatefulWidget {
  final String orderId;
  final String serviceType;

  const WaitingQuotationScreen({
    super.key,
    required this.orderId,
    required this.serviceType,
  });

  @override
  State<WaitingQuotationScreen> createState() => _WaitingQuotationScreenState();
}

class _WaitingQuotationScreenState extends State<WaitingQuotationScreen> {
  bool _isLoading = true;
  CustomerOrder? _order;
  late final CustomerService customerService;
  bool _hasQuotation = false;
  Map<String, dynamic>? _representative; // Add representative data

  @override
  void initState() {
    super.initState();
    customerService = CustomerService(AuthService());
    _fetchOrderDetails();
    _startPolling();
  }

  Future<void> _fetchOrderDetails() async {
    try {
      final order = await customerService.getOrderById(widget.orderId);

      setState(() {
        _order = order;
        _hasQuotation = order.status == 'quotation_provided';

        // Extract representative data from order (you might need to adjust this based on your API response)
        _representative = _extractRepresentativeData(order);

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch order details: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // Method to extract representative data from order
  Map<String, dynamic>? _extractRepresentativeData(CustomerOrder order) {
    // Adjust this based on how your API returns representative data
    // This could be from order.representative, order.assignedAgent, etc.
    if (order.agent != null && order.agent is Map) {
      return order.agent as Map<String, dynamic>;
    }

    // Fallback: Check if there's any representative info in the order data
    if (order.description?.contains('Representative:') ?? false) {
      // Parse representative info from description (temporary solution)
      return {
        'name': 'Service Representative',
        'phone': 'Contact support for details',
        'profileImage': '',
      };
    }

    return null;
  }

  void _startPolling() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && !_hasQuotation) {
        _fetchOrderDetails();
        _startPolling();
      }
    });
  }

  void _viewQuotation() {
    if (_order == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuotationAcceptanceScreen(
          orderId: widget.orderId,
          quotationAmount: _order!.price,
          quotationDetails: _order!.description,
          recommendedAgents: _order!.recommendedAgents ?? [],
          serviceType: widget.serviceType,
        ),
      ),
    );
  }

  void _contactRepresentative() {
    if (_representative == null) return;

    // Show contact options
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildContactSheet(),
    );
  }

  Widget _buildContactSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Contact Representative',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),

          if (_representative?['name'] != null)
            ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: const Text('Name'),
              subtitle: Text(_representative!['name']),
            ),

          if (_representative?['phone'] != null)
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Phone'),
              subtitle: Text(_representative!['phone']),
              onTap: () {
                // Implement phone call functionality
                Navigator.pop(context);
                // _makePhoneCall(_representative!['phone']);
              },
            ),

          if (_representative?['email'] != null)
            ListTile(
              leading: const Icon(Icons.email, color: Colors.green),
              title: const Text('Email'),
              subtitle: Text(_representative!['email']),
              onTap: () {
                // Implement email functionality
                Navigator.pop(context);
                // _sendEmail(_representative!['email']);
              },
            ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting for Quotation'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.green))
            : Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status Icon
              Icon(
                _hasQuotation ? Icons.task_alt : Icons.schedule,
                size: 80,
                color: _hasQuotation ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 20),

              // Status Text
              Text(
                _hasQuotation ? 'Quotation Ready!' : 'Waiting for Inspection',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Representative Info Card (if available)
              if (_representative != null) ...[
                _buildRepresentativeCard(),
                const SizedBox(height: 16),
              ],

              // Description
              Text(
                _hasQuotation
                    ? 'Our representative has provided the quotation. You can now review and proceed.'
                    : 'A representative will visit your location to inspect and provide a quotation. This usually takes 2-3 hours.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),

              // Quotation Details (if available)
              if (_hasQuotation && _order != null) ...[
                _buildQuotationCard(),
                const SizedBox(height: 20),
              ],

              const Spacer(),

              // Action Buttons
              Column(
                children: [
                  // Contact Representative Button (if representative available)
                  if (_representative != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _contactRepresentative,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Colors.green),
                        ),
                        child: const Text(
                          'Contact Representative',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Main Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _hasQuotation ? _viewQuotation : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasQuotation ? const Color(0xFF2E7D32) : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _hasQuotation ? 'Review Quotation' : 'Waiting for Quotation...',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRepresentativeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assigned Representative',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Representative Avatar
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue[100],
                backgroundImage: _representative?['profileImage'] != null
                    ? NetworkImage(_representative!['profileImage'])
                    : null,
                child: _representative?['profileImage'] == null
                    ? const Icon(Icons.person, color: Colors.blue)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _representative?['name'] ?? 'Service Representative',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (_representative?['phone'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _representative!['phone'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                    if (_representative?['experience'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${_representative!['experience']} years experience',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuotationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          const Text(
            'Proposed Quotation',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₦${_order!.price?.toStringAsFixed(2) ?? '0.00'}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          if (_order!.description != null && _order!.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _order!.description!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ],
      ),
    );
  }
}